import Foundation
import NewFileKit

/// Watches `RequestBridge.sharedDir` for de-quarantine requests dropped by the
/// Finder Sync extension and clears `com.apple.quarantine` from each named file.
/// Runs in the non-sandboxed app, which is allowed to remove the attribute.
///
/// SECURITY: only strips quarantine when the attribute's *agent* is our own
/// extension ("FinderSyncExt"). This prevents a hostile process from using this
/// app as a confused deputy to de-quarantine arbitrary downloaded files.
final class RequestWatcher {

    private var source: DispatchSourceFileSystemObject?
    private var fd: Int32 = -1

    func start() {
        let dir = RequestBridge.sharedDir
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        processAll()   // handle anything queued while the app was closed

        fd = open(dir.path, O_EVTONLY)
        guard fd >= 0 else { return }
        let src = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd,
                                                            eventMask: .write,
                                                            queue: .main)
        src.setEventHandler { [weak self] in self?.processAll() }
        src.setCancelHandler { [weak self] in
            if let f = self?.fd, f >= 0 { close(f) }
        }
        src.resume()
        source = src
    }

    private func processAll() {
        let dir = RequestBridge.sharedDir
        guard let items = try? FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil) else { return }

        for req in items where req.pathExtension == "req" {
            if let data = try? Data(contentsOf: req),
               let path = String(data: data, encoding: .utf8), !path.isEmpty {
                dequarantineIfOurs(path)
            }
            try? FileManager.default.removeItem(at: req)
        }
    }

    /// Removes quarantine only if it was applied by our extension.
    private func dequarantineIfOurs(_ path: String) {
        guard let value = quarantineValue(of: path) else { return } // already clean
        guard value.contains("FinderSyncExt") else { return }       // not ours → refuse
        path.withCString { _ = removexattr($0, "com.apple.quarantine", 0) }
    }

    /// Reads the raw com.apple.quarantine xattr value, or nil if absent.
    private func quarantineValue(of path: String) -> String? {
        let key = "com.apple.quarantine"
        let size = getxattr(path, key, nil, 0, 0, 0)
        guard size > 0 else { return nil }
        var data = Data(count: size)
        let read = data.withUnsafeMutableBytes {
            getxattr(path, key, $0.baseAddress, size, 0, 0)
        }
        guard read >= 0 else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
