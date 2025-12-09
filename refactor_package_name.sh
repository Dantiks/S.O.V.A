#!/bin/bash

# Скрипт для замены package:sova на package:finer во всех Dart файлах

echo "🔄 Начинаем рефакторинг package name..."

# Найти и заменить все вхождения package:sova на package:finer
find lib -name "*.dart" -type f -exec sed -i '' 's/package:sova/package:finer/g' {} \;

# Найти и заменить в тестах
find test -name "*.dart" -type f -exec sed -i '' 's/package:sova/package:finer/g' {} \; 2>/dev/null

# Найти и заменить в integration тестах
find integration_test -name "*.dart" -type f -exec sed -i '' 's/package:sova/package:finer/g' {} \; 2>/dev/null

echo "✅ Рефакторинг завершен!"
echo "📦 Теперь выполните:"
echo "   flutter pub get"
echo "   flutter clean"
echo "   flutter pub run build_runner build --delete-conflicting-outputs"
