#!/bin/bash
# ══════════════════════════════════════════════════════════════
#  سكريبت إعداد مشروع مستشار التحصين الصحي الموسع
# ══════════════════════════════════════════════════════════════

echo "🇾🇪 =================================="
echo "   مستشار التحصين الصحي الموسع - اليمن"
echo "=================================="

# التحقق من Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت!"
    echo "حمّل Flutter من: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter موجود: $(flutter --version | head -1)"

# إنشاء المشروع الكامل
echo ""
echo "📁 إنشاء هيكل المشروع..."

# تشغيل flutter create لإنشاء الملفات المفقودة
flutter create . --org ye.gov.health --project-name yemen_epi_bot --platforms android,ios --no-overwrite

echo ""
echo "📦 تثبيت الحزم..."
flutter pub get

echo ""
echo "🔤 تحميل الخطوط العربية..."
mkdir -p assets/fonts
cd assets/fonts

# تحميل خط Tajawal
if [ ! -f "Tajawal-Regular.ttf" ]; then
    echo "  تحميل Tajawal-Regular.ttf..."
    curl -sL "https://github.com/google/fonts/raw/main/ofl/tajawal/Tajawal%5Bwght%5D.ttf" -o Tajawal-Regular.ttf 2>/dev/null || echo "  ⚠️ حمّل الخط يدوياً من: https://fonts.google.com/specimen/Tajawal"
fi

if [ ! -f "Tajawal-Bold.ttf" ]; then
    cp Tajawal-Regular.ttf Tajawal-Bold.ttf 2>/dev/null
fi

cd ../..

echo ""
echo "✅ تم الإعداد بنجاح!"
echo ""
echo "📱 لتشغيل التطبيق:"
echo "   flutter run"
echo ""
echo "📦 لبناء APK:"
echo "   flutter build apk --release"
echo ""
echo "🇾🇪 بالتوفيق! صحة أطفالنا أولويتنا 💉"
