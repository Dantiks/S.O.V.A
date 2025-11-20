# Assets для S.O.V.A

## 📁 Структура

```
assets/
├── animations/     # Rive анимации
├── images/        # Изображения (PNG, JPG)
├── icons/         # Иконки приложения
├── lottie/        # Lottie JSON анимации
└── fonts/         # Шрифты
```

## 🎨 Необходимые ассеты

### Icons (обязательно)

**app_icon.png** (1024x1024px)
- Основная иконка приложения
- Формат: PNG с прозрачностью
- Используется для генерации иконок всех размеров

**app_icon_foreground.png** (1024x1024px)
- Foreground для Android adaptive icon
- Формат: PNG с прозрачностью

### Images (рекомендуется)

**google_logo.png** (48x48px)
- Логотип Google для кнопки входа
- Формат: PNG
- Можно скачать: https://developers.google.com/identity/branding-guidelines

**logo.png** (512x512px)
- Логотип приложения для README
- Формат: PNG с прозрачностью

### Fonts (включены в проект)

**Inter** - основной шрифт
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

Скачать: https://fonts.google.com/specimen/Inter

## 🦉 Анимация совы

Анимация совы реализована через CustomPainter в коде:
`lib/presentation/screens/splash/widgets/geometric_owl_painter.dart`

Не требует дополнительных файлов.

## 📦 Генерация иконок

После добавления `app_icon.png`:

```bash
flutter pub run flutter_launcher_icons
```

Это создаст иконки для:
- iOS (все размеры)
- Android (все размеры)
- Android adaptive icon

## 🎭 Lottie анимации (опционально)

Можно добавить дополнительные анимации:
- loading.json - Индикатор загрузки
- success.json - Анимация успеха
- error.json - Анимация ошибки

Источники:
- https://lottiefiles.com
- https://lottiefiles.com/featured

## 🔤 Установка шрифтов

1. Скачайте Inter с Google Fonts
2. Поместите файлы в `assets/fonts/`
3. Шрифты уже настроены в `pubspec.yaml`

## 📐 Размеры и форматы

### Иконки приложения
- **iOS**: 1024x1024px (обязательно)
- **Android**: 512x512px (минимум)
- Формат: PNG с прозрачностью

### Изображения
- Используйте PNG для изображений с прозрачностью
- Используйте JPG для фотографий
- Оптимизируйте размер файлов

### Анимации
- Lottie: JSON формат
- Rive: .riv формат
- Максимальный размер: 500KB

## 🎨 Дизайн-гайдлайны

### Цвета
- Основной: #7A3DF2 (Фиолетовый)
- Черный: #000000
- Белый: #FFFFFF

### Стиль
- Минимализм
- Геометрические формы
- Плавные линии
- Современный вид

## 📝 Примечания

1. Все пути к ассетам должны быть указаны в `pubspec.yaml`
2. После добавления новых ассетов запустите `flutter pub get`
3. Для изображений используйте кеширование
4. Оптимизируйте размер файлов для production

## 🔗 Полезные ссылки

- [Flutter Assets](https://docs.flutter.dev/development/ui/assets-and-images)
- [App Icon Generator](https://appicon.co)
- [Lottie Files](https://lottiefiles.com)
- [Google Fonts](https://fonts.google.com)
- [Material Icons](https://fonts.google.com/icons)

## ✅ Чеклист

- [ ] app_icon.png добавлен
- [ ] google_logo.png добавлен
- [ ] Шрифты Inter добавлены
- [ ] Иконки сгенерированы
- [ ] Все пути в pubspec.yaml

После выполнения чеклиста приложение готово к сборке!
