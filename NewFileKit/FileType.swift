import Foundation

/// A single file type that the app can create (Word, Excel, text, …).
public struct FileType: Identifiable, Sendable {
    public let id: String
    /// Shown in the menus.
    public let displayName: String
    /// File extension without the dot, e.g. "docx".
    public let fileExtension: String
    /// Default base file name (Windows style), e.g. "Yeni Word Belgesi".
    public let defaultBaseName: String
    /// How the file's initial bytes are produced.
    public let content: Content

    public enum Content: Sendable {
        /// Write this UTF-8 string into the new file (empty string => empty file).
        case text(String)
        /// Same as `.text` but also marks the file executable (chmod +x).
        case executableText(String)
        /// Copy a bundled template resource named `<name>.<fileExtension>`.
        case template(String)
        /// Create a new empty directory instead of a file.
        case folder
    }

    public init(id: String,
                displayName: String,
                fileExtension: String,
                defaultBaseName: String,
                content: Content) {
        self.id = id
        self.displayName = displayName
        self.fileExtension = fileExtension
        self.defaultBaseName = defaultBaseName
        self.content = content
    }
}
