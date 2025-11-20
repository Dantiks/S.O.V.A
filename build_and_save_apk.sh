#!/bin/bash

# 🚀 Автоматическая сборка и сохранение APK в Downloads
# Использование: ./build_and_save_apk.sh [версия] [описание]
# Пример: ./build_and_save_apk.sh "1.0.1" "Added PIN system"

set -e  # Остановить при ошибке

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     S.O.V.A APK Builder & Saver       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Получить версию из аргументов или использовать дату
if [ -z "$1" ]; then
    VERSION=$(date +%Y.%m.%d)
    echo -e "${YELLOW}⚠️  Версия не указана, используется дата: $VERSION${NC}"
else
    VERSION=$1
fi

# Получить описание из аргументов
if [ -z "$2" ]; then
    DESCRIPTION="release"
else
    DESCRIPTION=$2
fi

# Создать имя файла
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILENAME="SOVA-v${VERSION}-${DESCRIPTION}-${TIMESTAMP}.apk"
DOWNLOADS_PATH="$HOME/Downloads/$FILENAME"

echo -e "${BLUE}📦 Версия:${NC} $VERSION"
echo -e "${BLUE}📝 Описание:${NC} $DESCRIPTION"
echo -e "${BLUE}📂 Файл:${NC} $FILENAME"
echo ""

# Очистка предыдущей сборки
echo -e "${YELLOW}🧹 Очистка предыдущей сборки...${NC}"
flutter clean > /dev/null 2>&1

# Получение зависимостей
echo -e "${YELLOW}📥 Получение зависимостей...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}🔨 Начало сборки APK...${NC}"
echo -e "${YELLOW}⏳ Это может занять несколько минут...${NC}"
echo ""

# Сборка APK
if flutter build apk --release; then
    echo ""
    echo -e "${GREEN}✅ Сборка успешно завершена!${NC}"
    
    # Проверка существования APK
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        # Копирование в Downloads
        cp build/app/outputs/flutter-apk/app-release.apk "$DOWNLOADS_PATH"
        
        # Получить размер файла
        FILE_SIZE=$(du -h "$DOWNLOADS_PATH" | cut -f1)
        
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║          ✅ APK ГОТОВ!                 ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}📍 Расположение:${NC} $DOWNLOADS_PATH"
        echo -e "${BLUE}📦 Размер:${NC} $FILE_SIZE"
        echo ""
        
        # Показать последние 5 APK файлов
        echo -e "${BLUE}📂 Последние APK файлы в Downloads:${NC}"
        ls -lht ~/Downloads/SOVA*.apk 2>/dev/null | head -5 | while read line; do
            echo "   $line"
        done
        
        echo ""
        echo -e "${GREEN}🎉 Готово! APK сохранен в Downloads${NC}"
        
        # Открыть папку Downloads (опционально)
        read -p "Открыть папку Downloads? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open ~/Downloads
        fi
    else
        echo -e "${RED}❌ Ошибка: APK файл не найден после сборки${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${RED}❌ Ошибка при сборке APK${NC}"
    exit 1
fi
