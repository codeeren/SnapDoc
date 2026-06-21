#!/bin/bash
# SnapDoc — tam sürüm (menü bar + Finder sağ tık uzantısı) derleme & kurulum.
#
# ÖN KOŞUL (bir kez, senin yapman gerek):
#   Xcode > Settings > Accounts > "+" > Apple ID ile giriş yap (ücretsiz).
#   Bu, otomatik bir "Apple Development" sertifikası oluşturur. macOS Tahoe'da
#   Finder Sync uzantısının kaydı için bu ŞART (ad-hoc imza yetmiyor).
#
# Sonra sadece:  ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

command -v xcodegen >/dev/null || { echo "xcodegen gerekli: brew install xcodegen"; exit 1; }

# DEVELOPMENT_TEAM project.yml içinde gömülü. Xcode'a Apple ID ile giriş yapılmış olmalı
# (Xcode > Settings > Accounts), aksi halde imzalama başarısız olur.

echo "==> Proje üretiliyor..."
xcodegen generate >/dev/null

echo "==> Derleniyor (otomatik imza, gerekirse profil oluşturulur)..."
rm -rf build
xcodebuild -project SnapDoc.xcodeproj -scheme SnapDoc -configuration Release \
  -derivedDataPath build \
  -allowProvisioningUpdates \
  build

APP_BUILT="build/Build/Products/Release/SnapDoc.app"

echo "==> /Applications'a kuruluyor..."
pkill -f "SnapDoc.app/Contents/MacOS" 2>/dev/null || true
rm -rf /Applications/SnapDoc.app
cp -R "$APP_BUILT" /Applications/

LSR=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
echo "==> LaunchServices kaydı..."
"$LSR" -f -R /Applications/SnapDoc.app

echo "==> Uygulama başlatılıyor (uzantı kaydı için)..."
open /Applications/SnapDoc.app
sleep 3

echo "==> Finder Sync uzantısı etkinleştiriliyor..."
pluginkit -e use -i com.eren.SnapDoc.FinderSyncExt 2>/dev/null || true
killall Finder 2>/dev/null || true
sleep 1

echo ""
if pluginkit -m -p com.apple.FinderSync 2>/dev/null | grep -q "com.eren.SnapDoc"; then
  echo "✅ Uzantı kayıtlı ve etkin. Bir Finder klasöründe sağ tıkla > 'Yeni'."
else
  echo "⚠️  Uzantı henüz görünmüyor. System Settings > General >"
  echo "   Login Items & Extensions altından 'SnapDoc Finder Uzantısı'nı elle açın."
fi
echo "Menü bar ikonu menü çubuğunda görünmeli."
