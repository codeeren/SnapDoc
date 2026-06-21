import Foundation

/// The single source of truth for every file type offered in both the menu bar
/// and the Finder right-click submenu. Add or remove a line here to change both.
public enum FileCatalog {

    public static let all: [FileType] = [
        FileType(id: "folder", displayName: Loc.string("Folder"), fileExtension: "",
                 defaultBaseName: Loc.string("New Folder"), content: .folder),

        FileType(id: "txt",  displayName: Loc.string("Text Document"), fileExtension: "txt",
                 defaultBaseName: Loc.string("New Text Document"), content: .text("")),

        FileType(id: "md",   displayName: Loc.string("Markdown"), fileExtension: "md",
                 defaultBaseName: Loc.string("New Document"), content: .text("# Title\n")),

        FileType(id: "csv",  displayName: Loc.string("CSV"), fileExtension: "csv",
                 defaultBaseName: Loc.string("New Spreadsheet"), content: .text("")),

        FileType(id: "json", displayName: Loc.string("JSON"), fileExtension: "json",
                 defaultBaseName: Loc.string("New File"), content: .text("{}\n")),

        FileType(id: "html", displayName: Loc.string("HTML"), fileExtension: "html",
                 defaultBaseName: Loc.string("New Page"), content: .text(htmlSkeleton)),

        FileType(id: "py",   displayName: Loc.string("Python"), fileExtension: "py",
                 defaultBaseName: Loc.string("New Script"), content: .text("#!/usr/bin/env python3\n")),

        FileType(id: "command", displayName: Loc.string("Shell Script"), fileExtension: "command",
                 defaultBaseName: Loc.string("New Shell Script"), content: .executableText("#!/bin/bash\n")),

        FileType(id: "docx", displayName: Loc.string("Word Document"), fileExtension: "docx",
                 defaultBaseName: Loc.string("New Word Document"), content: .template("blank")),

        FileType(id: "xlsx", displayName: Loc.string("Excel Workbook"), fileExtension: "xlsx",
                 defaultBaseName: Loc.string("New Excel Workbook"), content: .template("blank")),

        FileType(id: "pptx", displayName: Loc.string("PowerPoint Presentation"), fileExtension: "pptx",
                 defaultBaseName: Loc.string("New PowerPoint Presentation"), content: .template("blank")),
    ]

    public static func type(withID id: String) -> FileType? {
        all.first { $0.id == id }
    }

    private static let htmlSkeleton = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>New Page</title>
    </head>
    <body>

    </body>
    </html>
    """
}
