import Foundation

/// Localized strings for SnapDoc. All user-facing text (file-type names, default
/// file names, menu titles) lives in the NewFileKit framework so both the app and
/// the Finder Sync extension share one translation table (en + tr).
public enum Loc {
    /// Looks up `key` in NewFileKit's Localizable.strings; falls back to the
    /// (English) key itself if a translation is missing.
    public static func string(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .newFileKit, value: key, comment: "")
    }
}
