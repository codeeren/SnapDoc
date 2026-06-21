import Foundation

/// The single source of truth for every file type offered in both the menu bar
/// and the Finder right-click submenu. Add or remove a line here to change both.
public enum FileCatalog {

    public static let all: [FileType] = [
        FileType(id: "folder", displayName: "Klasör", fileExtension: "",
                 defaultBaseName: "Yeni Klasör", content: .folder),

        FileType(id: "txt",  displayName: "Metin Belgesi", fileExtension: "txt",
                 defaultBaseName: "Yeni Metin Belgesi", content: .text("")),

        FileType(id: "md",   displayName: "Markdown", fileExtension: "md",
                 defaultBaseName: "Yeni Belge", content: .text("# Başlık\n")),

        FileType(id: "csv",  displayName: "CSV", fileExtension: "csv",
                 defaultBaseName: "Yeni Tablo", content: .text("")),

        FileType(id: "json", displayName: "JSON", fileExtension: "json",
                 defaultBaseName: "Yeni Dosya", content: .text("{}\n")),

        FileType(id: "html", displayName: "HTML", fileExtension: "html",
                 defaultBaseName: "Yeni Sayfa", content: .text(htmlSkeleton)),

        FileType(id: "py",   displayName: "Python", fileExtension: "py",
                 defaultBaseName: "Yeni Script", content: .text("#!/usr/bin/env python3\n")),

        FileType(id: "command", displayName: "Terminal Betiği", fileExtension: "command",
                 defaultBaseName: "Yeni Betik", content: .executableText("#!/bin/bash\n")),

        FileType(id: "docx", displayName: "Word Belgesi", fileExtension: "docx",
                 defaultBaseName: "Yeni Word Belgesi", content: .template("blank")),

        FileType(id: "xlsx", displayName: "Excel Çalışma Kitabı", fileExtension: "xlsx",
                 defaultBaseName: "Yeni Excel Çalışma Kitabı", content: .template("blank")),

        FileType(id: "pptx", displayName: "PowerPoint Sunusu", fileExtension: "pptx",
                 defaultBaseName: "Yeni PowerPoint Sunusu", content: .template("blank")),
    ]

    public static func type(withID id: String) -> FileType? {
        all.first { $0.id == id }
    }

    private static let htmlSkeleton = """
    <!DOCTYPE html>
    <html lang="tr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Yeni Sayfa</title>
    </head>
    <body>

    </body>
    </html>
    """
}
