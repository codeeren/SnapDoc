import Foundation

private final class BundleToken {}

public extension Bundle {
    /// The NewFileKit framework bundle (where the blank Office templates live).
    static var newFileKit: Bundle { Bundle(for: BundleToken.self) }
}

/// Creates files on disk for a given `FileType`.
public enum FileFactory {

    public enum FactoryError: LocalizedError {
        case templateMissing(String)

        public var errorDescription: String? {
            switch self {
            case .templateMissing(let name):
                return "Şablon bulunamadı: \(name)"
            }
        }
    }

    /// Creates a new file of `type` inside `folder`, picking a unique Windows-style
    /// name ("Yeni …", "Yeni … 2", …). Returns the URL of the created file.
    @discardableResult
    public static func create(_ type: FileType,
                              in folder: URL,
                              bundle: Bundle = .newFileKit) throws -> URL {
        let target = uniqueURL(base: type.defaultBaseName, ext: type.fileExtension, in: folder)

        switch type.content {
        case .text(let body):
            try Data(body.utf8).write(to: target)

        case .executableText(let body):
            try Data(body.utf8).write(to: target)
            try FileManager.default.setAttributes([.posixPermissions: 0o755],
                                                  ofItemAtPath: target.path)

        case .template(let name):
            guard let src = bundle.url(forResource: name, withExtension: type.fileExtension) else {
                throw FactoryError.templateMissing("\(name).\(type.fileExtension)")
            }
            try FileManager.default.copyItem(at: src, to: target)

        case .folder:
            try FileManager.default.createDirectory(at: target,
                                                    withIntermediateDirectories: false)
            return target
        }

        // Sandbox'lı uzantı dosyaya karantina etiketi koyar; .command gibi
        // çalıştırılabilir dosyalar bu yüzden "hasar görmüş" diye açılmaz.
        // Kullanıcının kendi oluşturduğu dosyada karantinayı kaldırıyoruz.
        removeQuarantine(target)
        return target
    }

    /// Removes the com.apple.quarantine xattr so freshly created executables/files
    /// aren't blocked by Gatekeeper.
    private static func removeQuarantine(_ url: URL) {
        url.withUnsafeFileSystemRepresentation { cPath in
            guard let cPath else { return }
            removexattr(cPath, "com.apple.quarantine", 0)
        }
    }

    /// Returns a non-colliding URL inside `folder`. Empty `ext` => no dot (folders).
    static func uniqueURL(base: String, ext: String, in folder: URL) -> URL {
        let fm = FileManager.default
        let suffix = ext.isEmpty ? "" : ".\(ext)"
        var candidate = folder.appendingPathComponent("\(base)\(suffix)")
        var index = 2
        while fm.fileExists(atPath: candidate.path) {
            candidate = folder.appendingPathComponent("\(base) \(index)\(suffix)")
            index += 1
        }
        return candidate
    }
}
