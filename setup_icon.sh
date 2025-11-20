#!/bin/bash

echo "🦉 SOVA Icon Setup Script"
echo "=========================="
echo ""

# Проверяем наличие файла иконки
if [ -f "assets/icons/app_icon.png" ]; then
    echo "✅ Файл app_icon.png найден!"
    echo ""
    echo "Генерирую иконки для Android и iOS..."
    flutter pub get
    flutter pub run flutter_launcher_icons
    echo ""
    echo "✅ Иконки успешно сгенерированы!"
    echo ""
    echo "Теперь пересоберите приложение:"
    echo "  flutter clean"
    echo "  flutter build apk --release"
else
    echo "❌ Файл app_icon.png не найден!"
    echo ""
    echo "Пожалуйста, сохраните изображение совы как:"
    echo "  assets/icons/app_icon.png"
    echo ""
    echo "Затем запустите этот скрипт снова:"
    echo "  bash setup_icon.sh"
fi
