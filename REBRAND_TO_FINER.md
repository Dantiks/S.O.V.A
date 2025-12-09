# 🎨 Ребрендинг приложения в FINER

## ✅ Что уже сделано

1. **Dashboard обновлен:**
   - ✅ Изменено приветствие с "Добро пожаловать!" на "Финансы под контролем 💰"
   - ✅ Добавлен AI помощник в правом верхнем углу
   - ✅ При первом запуске показывается туториал
   - ✅ Кнопки быстрых действий теперь функциональные:
     - Добавить доход → открывает AddTransactionScreen
     - Добавить расход → открывает AddTransactionScreen
     - Перевод между счетами → открывает AddTransactionScreen
   - ✅ После добавления транзакции появляется push-уведомление

2. **Вкладка "Счета" улучшена:**
   - ✅ Общий баланс теперь большой и заметный (48px шрифт)
   - ✅ Баланс размещен в центре карточки
   - ✅ Улучшена визуализация

3. **Конфигурация обновлена:**
   - ✅ pubspec.yaml: название изменено на `finer`
   - ✅ AndroidManifest.xml: label изменен на "FINER"
   - ✅ README.md: обновлено на FINER

4. **Новые сервисы и виджеты:**
   - ✅ `tutorial_service.dart` - управление туториалом
   - ✅ `ai_helper_button.dart` - кнопка AI помощника

## 🔨 Что нужно сделать

### 1. Рефакторинг package name

Выполните скрипт для замены всех импортов:

```bash
chmod +x refactor_package_name.sh
./refactor_package_name.sh
```

Или вручную:
```bash
find lib -name "*.dart" -type f -exec sed -i '' 's/package:sova/package:finer/g' {} \;
```

### 2. Обновить зависимости

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Создать новую иконку приложения

#### Опция А: Используя онлайн генератор

1. Создайте иконку на https://www.canva.com или https://www.figma.com
2. Дизайн для FINER:
   - **Цвета**: Градиент фиолетовый (#7A3DF2 → #5A2DB2)
   - **Иконка**: Кошелек или монета с буквой "F"
   - **Стиль**: Современный, минималистичный
   - **Размер**: 1024x1024px

3. Сохраните как `app_icon.png` в `assets/icons/`

4. Обновите иконку:
```bash
flutter pub run flutter_launcher_icons
```

#### Опция Б: Используя текущий редактор

Создайте файл `assets/icons/app_icon.png` с дизайном для FINER.

### 4. Обновить навигацию к чату

В файле `dashboard_tab.dart` метод `_navigateToChat()` нужно доработать.

Добавьте в `home_screen.dart`:

```dart
// Добавить controller для PageView
final PageController _pageController = PageController();

// Метод для переключения вкладок
void switchToTab(int index) {
  _pageController.jumpToPage(index);
  setState(() => _selectedIndex = index);
}

// И передать его в dashboard через параметры или provider
```

### 5. Переименовать папку проекта (опционально)

```bash
cd ~/Desktop
mv SOVA FINER
cd FINER
```

### 6. Обновить bundle ID (для production)

**Android** (`android/app/build.gradle`):
```gradle
applicationId "com.finer.app"  // вместо com.sova.app
```

**iOS** (если будет iOS версия):
- Откройте Xcode
- Измените Bundle Identifier на `com.finer.app`

### 7. Тестирование

После всех изменений:

```bash
# Очистка
flutter clean

# Установка зависимостей
flutter pub get

# Генерация кода
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск
flutter run
```

## 🎯 Проверочный список

- [ ] Скрипт рефакторинга выполнен
- [ ] `flutter pub get` выполнен успешно
- [ ] Build runner отработал без ошибок
- [ ] Приложение запускается без ошибок
- [ ] Туториал показывается при первом запуске
- [ ] AI помощник виден в правом верхнем углу Dashboard
- [ ] Кнопки быстрых действий работают
- [ ] При добавлении транзакции появляется уведомление
- [ ] Вкладка "Счета" показывает большой общий баланс
- [ ] Название приложения в меню - "FINER"
- [ ] Иконка приложения обновлена

## 📱 Дополнительные улучшения (опционально)

### Splash Screen с новым брендом

Создайте файл `assets/images/finer_logo.png` и обновите splash screen.

### Цветовая схема

Убедитесь, что акцентный цвет `#7A3DF2` используется во всем приложении.

### Анимации

Туториал уже имеет анимации, но можно добавить:
- Анимацию появления AI помощника
- Конфетти при достижении финансовых целей
- Плавные переходы между экранами

## 🐛 Возможные проблемы

### Ошибки после рефакторинга

Если возникают ошибки импортов:
```bash
flutter clean
rm -rf .dart_tool
flutter pub get
```

### Проблемы с build_runner

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Конфликты в generated файлах

Удалите все `.g.dart` и `.freezed.dart` файлы и пересоздайте:
```bash
find . -name "*.g.dart" -type f -delete
find . -name "*.freezed.dart" -type f -delete
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚀 Готово к развертыванию

После всех изменений, приложение готово к:
- Тестированию на устройствах
- Сборке APK: `./quick_build.sh`
- Публикации в Google Play Store (требуется подписание)

---

**Дата ребрендинга:** Декабрь 2024  
**Новое название:** FINER  
**Слоган:** Ваш умный финансовый помощник для управления деньгами
