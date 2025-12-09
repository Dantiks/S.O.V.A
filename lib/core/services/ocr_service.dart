// OCRService временно отключен
// Требуется установка зависимостей: google_mlkit_text_recognition, image_picker

import 'dart:io';

class OCRService {
  Future<Map<String, dynamic>?> scanReceipt() async {
    throw UnimplementedError('OCRService requires google_mlkit_text_recognition and image_picker packages');
  }

  Future<Map<String, dynamic>?> scanReceiptFromGallery() async {
    throw UnimplementedError('OCRService requires google_mlkit_text_recognition and image_picker packages');
  }

  void dispose() {
    // Cleanup if needed
  }
}
