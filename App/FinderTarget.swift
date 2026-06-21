import AppKit
import Foundation

/// Resolves which folder the menu-bar app should create files into.
enum FinderTarget {

    /// The folder of the frontmost Finder window, or the Desktop as a fallback.
    static func frontmostFolder() -> URL {
        let script = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                return POSIX path of (target of front Finder window as alias)
            else
                return POSIX path of (path to desktop)
            end if
        end tell
        """
        if let path = runAppleScript(script), !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop", isDirectory: true)
    }

    private static func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let output = script.executeAndReturnError(&error)
        guard error == nil else { return nil }
        return output.stringValue
    }
}
