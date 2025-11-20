#!/bin/bash
# Быстрая сборка APK и сохранение в Downloads

echo "🚀 Быстрая сборка APK..."
flutter build apk --release && \
cp build/app/outputs/flutter-apk/app-release.apk ~/Downloads/SOVA-$(date +%Y%m%d-%H%M%S).apk && \
echo "✅ APK сохранен в Downloads!" && \
ls -lh ~/Downloads/SOVA*.apk | tail -1
