import Foundation

/// Lightweight bridge between the sandboxed Finder Sync extension and the
/// non-sandboxed menu-bar app.
///
/// The extension cannot strip the `com.apple.quarantine` attribute the sandbox
/// forces onto files it creates (that would escape Gatekeeper). So after creating
/// a file, the extension drops a tiny request here; the running app — which is not
/// sandboxed — picks it up and removes the quarantine so executables (.command)
/// aren't reported as "damaged".
public enum RequestBridge {

    /// Shared drop folder both processes can reach (extension via its broad
    /// file entitlement, app because it isn't sandboxed).
    public static let sharedDir = URL(fileURLWithPath: "/Users/Shared/SnapDoc", isDirectory: true)

    /// Called by the extension: queue `fileURL` to have its quarantine removed.
    public static func requestDequarantine(_ fileURL: URL) {
        try? FileManager.default.createDirectory(at: sharedDir,
                                                 withIntermediateDirectories: true)
        let req = sharedDir.appendingPathComponent(UUID().uuidString + ".req")
        try? Data(fileURL.path.utf8).write(to: req)
    }
}
