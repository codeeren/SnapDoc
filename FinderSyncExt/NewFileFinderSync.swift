import Cocoa
import FinderSync
import NewFileKit

/// Finder Sync extension that adds a single "New ▸" item to the Finder
/// context menu; hovering it reveals the file-type submenu. Works on the empty
/// area of a folder (container) as well as on selected items.
final class NewFileFinderSync: FIFinderSync {

    override init() {
        super.init()
        refreshWatchedVolumes()

        // "/" only covers the boot volume. NAS (SMB), USB and other disks are
        // separate volumes and must be registered one by one — including those
        // mounted/unmounted while the extension is running.
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didMountNotification, NSWorkspace.didUnmountNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refreshWatchedVolumes()
            }
        }
    }

    /// Watches the boot volume plus every currently mounted volume.
    private func refreshWatchedVolumes() {
        var urls: Set<URL> = [URL(fileURLWithPath: "/")]
        let volumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) ?? []
        urls.formUnion(volumes)
        FIFinderSyncController.default().directoryURLs = urls
        NSLog("SnapDoc: izlenen birimler: \(urls.map(\.path).sorted())")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        guard menuKind == .contextualMenuForContainer
                || menuKind == .contextualMenuForItems else {
            return menu
        }

        // Not: alt menü ikonu Finder sürecinde template olarak çizilmediği için
        // siyah görünüyordu; temiz dursun diye ikon koymuyoruz.
        let parent = NSMenuItem(title: Loc.string("New"), action: nil, keyEquivalent: "")

        let submenu = NSMenu(title: Loc.string("New"))
        // ÖNEMLİ: menü Finder sürecinde çizilir; bu yüzden target=self KULLANMA
        // (o nesne Finder sürecinde yok). Eylem responder zinciriyle uzantıya döner.
        // Hangi türün seçildiğini taşımak için tag = katalog indeksi kullanılır.
        for (index, type) in FileCatalog.all.enumerated() {
            let item = NSMenuItem(title: type.displayName,
                                  action: #selector(createFile(_:)),
                                  keyEquivalent: "")
            item.tag = index
            submenu.addItem(item)
            // Klasör'den sonra ayraç: klasörü dosya türlerinden ayır.
            if type.id == "folder" {
                submenu.addItem(.separator())
            }
        }
        parent.submenu = submenu
        menu.addItem(parent)
        return menu
    }

    @objc func createFile(_ sender: NSMenuItem) {
        let index = sender.tag
        guard index >= 0, index < FileCatalog.all.count else {
            NSLog("SnapDoc: geçersiz menü öğesi (tag=\(sender.tag))")
            return
        }
        let type = FileCatalog.all[index]

        guard let folder = targetFolder() else {
            // Hedef klasör belirlenemezse konteynere yazmaktansa hiçbir şey yapma.
            NSLog("SnapDoc: hedef klasör belirlenemedi")
            NSSound.beep()
            return
        }
        NSLog("SnapDoc: '\(type.id)' oluşturuluyor -> \(folder.path)")
        do {
            let url = try FileFactory.create(type, in: folder)
            NSLog("SnapDoc: oluşturuldu \(url.path)")
            // Klasör hariç: sandbox karantinayı içeriden silemez, app'e kaldırttır.
            if case .folder = type.content {} else {
                RequestBridge.requestDequarantine(url)
            }
        } catch {
            NSLog("SnapDoc: HATA \(error) — klasör: \(folder.path)")
            NSSound.beep()
        }
    }

    /// The folder the user right-clicked in, or nil if it can't be determined.
    private func targetFolder() -> URL? {
        let controller = FIFinderSyncController.default()
        if let target = controller.targetedURL() {
            return target
        }
        if let first = controller.selectedItemURLs()?.first {
            return first.deletingLastPathComponent()
        }
        return nil
    }
}
