# SnapDoc

Windows'taki **Yeni ▸ Word / Excel / Metin …** sağ tık menüsünün macOS karşılığı.
Bir tıkla aktif klasörde yeni dosya/klasör oluştur.

İki şekilde çalışır:

- **Menü bar**: menü çubuğundaki ikona tıkla → bir tür seç → öndeki Finder
  penceresinin klasöründe (yoksa Masaüstü'nde) oluşur, Finder'da seçili gelir.
- **Sağ tık**: bir Finder klasöründe (boş alana da olur) sağ tıkla → tek bir
  **"Yeni ▸"** öğesi; üzerine gelince türler alt menüde açılır.

## Kurulum

İki sürüm var:

### 🟦 SnapDoc Lite — DMG ile (kolay)
[Releases](../../releases) sayfasından `SnapDoc.dmg`'yi indir → aç → SnapDoc'u
`Applications`'a sürükle. İlk açılışta Gatekeeper uyarısı çıkarsa: **System Settings >
Privacy & Security** → aşağıda "SnapDoc yine de aç" / **Open Anyway**.

> **DMG sürümü menü bar üzerinden belge oluşturmayı destekler. Finder sağ tık
> entegrasyonu, macOS imzalama ve uzantı kısıtları nedeniyle yalnızca uygulama
> kaynak koddan yerel olarak derlendiğinde güvenilir şekilde çalışır.**

(Apple Silicon / arm64 Mac gerekir.)

### 🟩 SnapDoc Full — kaynaktan derle (sağ tık çalışır)
Finder sağ tık menüsünün de çalışması için uygulamayı kendi Apple ID'nle derlemen
gerekir (macOS, Finder uzantılarını ancak yerel/geçerli bir imzayla kaydeder):

```sh
git clone https://github.com/codeeren/SnapDoc.git
cd SnapDoc
./build.sh
```

Ön koşullar ve ayrıntılar için aşağıdaki **Derleme** bölümüne bak.

## Türler

Klasör, Metin (.txt), Markdown (.md), CSV (.csv), JSON (.json), HTML (.html),
Python (.py), Terminal Betiği (.command), Word (.docx), Excel (.xlsx), PowerPoint (.pptx).

Tür eklemek/çıkarmak için tek dosya yeterli: `NewFileKit/FileCatalog.swift`.

> Boş `.docx/.xlsx/.pptx` geçerli dosya değildir; `NewFileKit/Resources/` içindeki
> geçerli boş şablonlardan kopyalanır.

## Mimari

```
SnapDoc.app                  (LSUIElement — Dock'ta görünmez, sadece menü bar)
├─ App/                      menü bar (NSStatusItem) + RequestWatcher
├─ NewFileKit.framework      ortak katalog + dosya oluşturma + şablonlar + köprü
└─ FinderSyncExt.appex       Finder Sync uzantısı (sağ tık alt menüsü, SANDBOX'LI)
```

`App` ve `FinderSyncExt`, ortak `NewFileKit` framework'ünü kullanır.

### Çözülen macOS engelleri (geliştirici notları)

Bu projeyi çalışır hale getirmek için aşılan, belgelenmeye değer noktalar:

1. **ASCII paket adı.** Bundle/executable adındaki Unicode karakterler (örn. "ş")
   codesign'ı bozuyor (`code object is not signed at all`). `PRODUCT_NAME` ASCII
   tutulmalı; görünen ad gerekiyorsa `CFBundleDisplayName` ile ayarlanır.
2. **Apple Development sertifikası şart.** macOS Tahoe, ad-hoc imzalı Finder Sync
   uzantısını kaydetmiyor. Xcode'a Apple ID ile giriş + ücretsiz "Personal Team"
   gerekli (`DEVELOPMENT_TEAM` `project.yml`'de gömülü).
3. **Uzantı sandbox'lı OLMALI.** Sandbox'sız uzantıyı `pkd` sessizce reddediyor.
   `com.apple.security.app-sandbox = true` + dosya yazma için path istisnaları.
4. **Menü eylemi `target=self` ile gitmiyor.** Menü Finder sürecinde çizildiği için
   eylemler responder zinciriyle dönmeli; seçilen tür `NSMenuItem.tag` ile taşınır.
5. **Karantina / "hasar görmüş".** Sandbox, oluşturulan dosyalara `com.apple.quarantine`
   koyar ve içeriden kaldırılmasına izin vermez → `.command` "hasar görmüş" der.
   Çözüm: uzantı `/Users/Shared/SnapDoc/`'a istek bırakır; sandbox'sız app
   (`RequestWatcher`) karantinayı siler.

## Derleme

**Ön koşullar (bir kez):**

1. **Tam Xcode** kurulu (`sudo xcode-select -s /Applications/Xcode.app`).
2. **Xcode'a Apple ID** ile giriş: Xcode > Settings > Accounts > "+" (ücretsiz).
3. **XcodeGen**: `brew install xcodegen`.

**Derle + kur + uzantıyı etkinleştir (tek komut):**

```sh
./build.sh
```

Betik: proje üretir, otomatik imzayla derler, `/Applications`'a kurar, LaunchServices'e
kaydeder, uygulamayı başlatır, Finder uzantısını etkinleştirir.

> İlk seferde Finder Sync uzantısı System Settings > General > Login Items &
> Extensions altında otomatik etkin gelir; gelmezse oradan elle açılır.
> Menü bar'ı ilk kullanışta Finder otomasyon (Apple Events) izni sorulur → İzin Ver.

## Doğrulama

1. Menü çubuğunda ikon → tıkla → tür listesi → dosya oluşur.
2. Finder'da boş alana sağ tık → **Yeni ▸** → tür → dosya/klasör oluşur.
3. **Terminal Betiği** oluştur → çift tıkla → "hasar" demeden Terminal'de çalışır.

## Sağlamlık / güvenlik

- **Confused-deputy koruması:** App, bir `.req` isteğindeki dosyanın karantinasını
  **yalnızca ajanı kendi uzantımız (`FinderSyncExt`) ise** kaldırır. Böylece kötü
  niyetli bir süreç, app'i kullanarak Safari'den inmiş bir dosyanın Gatekeeper
  karantinasını sildiremez. Ek olarak istek klasörü `/Users/Shared/SnapDoc`
  755/kullanıcı sahipli — başka kullanıcı yazamaz.
- **Konteyner tuzağı kapatıldı:** Hedef klasör belirlenemezse uzantı dosyayı
  sandbox konteynerine yazmaz; işlemi iptal eder.
- **Otomatik başlatma:** App, `SMAppService` ile Login Item olarak kayıtlıdır;
  yeniden başlatmadan sonra da çalışır. İstemiyorsan System Settings > General >
  Login Items'tan kaldırabilirsin.

## Notlar / kısıtlar

- `DEVELOPMENT_TEAM` (`project.yml` içinde) bu makineye özel; başka makinede kendi
  Apple ID team ID'nle değiştir.
- **Sertifika ömrü:** Ücretsiz Apple Development sertifikası ~1 yıl geçerlidir
  (macOS'ta iOS'taki 7 günlük sınır yoktur). Süre dolarsa `./build.sh` ile yeniden derle.
- `.command` de-quarantine'i için menü bar uygulamasının çalışıyor olması gerekir
  (Login Item bunu garanti eder). Diğer türler app kapalıyken de sağ tıktan oluşur.

## Lisans

MIT
