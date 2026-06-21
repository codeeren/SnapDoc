import Cocoa
import ServiceManagement
import NewFileKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let requestWatcher = RequestWatcher()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Sandbox'lı uzantının bıraktığı karantina-kaldırma isteklerini dinle.
        requestWatcher.start()

        // Açılışta otomatik başlat: .command de-quarantine ve menü bar her zaman hazır.
        // (Kullanıcı isterse System Settings > Login Items'tan kaldırabilir.)
        try? SMAppService.mainApp.register()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let icon = NSImage(systemSymbolName: "doc.badge.plus",
                           accessibilityDescription: "Yeni Dosya")
        icon?.isTemplate = true   // menü çubuğunun açık/koyu temasına uyum sağlar
        item.button?.image = icon

        let menu = NSMenu()
        let header = NSMenuItem(title: "Yeni Dosya Oluştur", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        for type in FileCatalog.all {
            let menuItem = NSMenuItem(title: type.displayName,
                                      action: #selector(createFile(_:)),
                                      keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = type.id
            menu.addItem(menuItem)
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Çıkış",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))

        item.menu = menu
        statusItem = item
    }

    @objc private func createFile(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String,
              let type = FileCatalog.type(withID: id) else { return }

        let folder = FinderTarget.frontmostFolder()
        do {
            let url = try FileFactory.create(type, in: folder)
            // Reveal & select the new file in Finder so the user can rename it.
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } catch {
            let alert = NSAlert()
            alert.messageText = "Dosya oluşturulamadı"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}
