# SnapDoc — Logo Kullanım Kılavuzu

## 1. Logo
**Fikir:** Sayfanın kıvrık köşesinin yerini “yeni” artısı alıyor. Dosya ve eylem tek bir siluette birleşiyor.
Artı sayfaya yapıştırılmış bir rozet değil: sayfa, artının etrafından oyulmuş.

| Sürüm | Dosya | Ne zaman |
|---|---|---|
| Yatay (ana) | `masters/snapdoc-horizontal*.svg` | README başlığı, web sitesi, sunumlar |
| Dikey | `masters/snapdoc-stacked*.svg` | Kare/dikey alanlar, sticker, sosyal kapak |
| Sembol | `masters/snapdoc-symbol*.svg` | Avatar, uygulama içi, 32 px ve üstü |
| Sembol, küçük boyut | `masters/snapdoc-symbol-small*.svg` | **32 px'in altında** (boşluklar ve artı kalınlaştırılmış) |
| Wordmark | `masters/snapdoc-wordmark*.svg` | Sembol zaten görünürken (ör. ikonun yanında başlık) |

Her sürümün dört rengi var: renkli (açık zemin), `-reversed` (koyu zemin), `-black`, `-white`.

## 2. Boşluk alanı
**X = artının kol kalınlığı.** Logonun her yanında en az **1 X** boş alan bırakın. Yatay logoda sembol ile yazı
arasındaki mesafe sabittir (≈ 1,5 X), değiştirmeyin.

## 3. Minimum boyut
| Sürüm | Ekran | Baskı |
|---|---|---|
| Yatay | 96 px genişlik | 25 mm |
| Dikey | 64 px genişlik | 18 mm |
| Sembol | 16 px (`-small` dosyası) | 5 mm |

## 4. Renk
| Ad | HEX | RGB | CMYK (yaklaşık) | Pantone (en yakın) |
|---|---|---|---|---|
| Mürekkep (Ink) | `#16181D` | 22, 24, 29 | 24 / 17 / 0 / 89 | Black 6 C |
| Mercan (Snap Coral) | `#F25A2B` | 242, 90, 43 | 0 / 63 / 82 / 5 | 172 C |
| Beyaz | `#FFFFFF` | 255, 255, 255 | 0 / 0 / 0 / 0 | — |

- Mercan yalnızca **artıda** kullanılır; sayfa her zaman mürekkep ya da beyazdır.
- Mercan, beyaz üzerinde 3,4:1, mürekkep üzerinde 5,4:1 kontrast verir (grafik öğe için WCAG 3:1 ✔). Mercanı
  küçük metin rengi olarak kullanmayın.
- **Onaylı zeminler:** renkli logo → beyaz / açık gri · `-reversed` → mürekkep / siyah · `-white` → mercan veya
  fotoğraf · `-black` → tek renk baskı, faks, gravür.
- Pantone ve CMYK değerleri yaklaşıktır; baskıdan önce prova ile doğrulayın.

## 5. Tipografi
- **Wordmark** hazır bir fonttan yazılmadı, yuvarlak uçlu monoline harflerle elle çizildi. Font lisansı gerekmez.
  Wordmark'ı asla klavyeden yazarak yeniden oluşturmayın.
- **Arayüz ve metinler:** macOS sistem fontu (SF Pro), uygulama içinde serbest. Web için
  `-apple-system, BlinkMacSystemFont, "Inter", sans-serif`.
- Marka adı metin içinde her zaman **SnapDoc** (büyük S ve D) yazılır. Logodaki küçük harfler yalnızca görseldir.

## 6. macOS ikonları
- **Uygulama ikonu:** `macos/AppIcon.appiconset/`. Apple ızgarasına uyar (1024 tuvalde 824 px gövde). 16–64 px
  boyutları küçük boyut çiziminden, gölgesiz üretildi.
- **Menü çubuğu:** `macos/MenuBarIcon.imageset/`, *template* görsel olarak ayarlı (macOS açık/koyu moda göre
  renklendirir). 18 pt tuval, küçük boyut çizimi.

## 7. Yapmayın
Esnetmeyin veya sıkıştırmayın · artıyı sayfadan ayırmayın, yerini veya boyutunu değiştirmeyin · artıyı başka
renge boyamayın · döndürmeyin · gölge, kontur, degrade eklemeyin (degrade yalnızca macOS ikon zemininde) ·
renkli logoyu koyu zemine koymayın (`-reversed` kullanın) · kalabalık fotoğraf üzerinde zeminsiz kullanmayın ·
32 px'in altında standart sembolü kullanmayın.

## 8. Notlar
- Tescil: Benzer işaret taraması yapılmadı. Kullanmadan önce TÜRKPATENT / EUIPO / USPTO'da ve tersine görsel
  aramayla kontrol edin.
- macOS 26 (Tahoe): Sistem, Icon Composer ile hazırlanmış `.icon` dosyalarını tercih ediyor. Klasik PNG seti
  çalışır ama katmanlı “Liquid Glass” görünümü için `masters/snapdoc-appicon-macos.svg` katmanlarından
  (zemin / sayfa / artı) bir `.icon` dosyası hazırlanabilir.
- Kaynak: Tüm geometri `source/` altındaki Python betikleriyle üretildi. Oranları değiştirmek için `geo.py`
  içindeki parametreleri düzenleyip `build.py`'yi çalıştırın.
