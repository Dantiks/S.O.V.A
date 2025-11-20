import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  Future<Map<String, dynamic>?> scanReceipt() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    return _parseReceiptData(recognizedText.text, image.path);
  }

  Map<String, dynamic> _parseReceiptData(String text, String imagePath) {
    final lines = text.split('\n');
    double? amount;
    String? merchant;
    DateTime? date;

    // Simple parsing logic - can be enhanced with ML
    for (var line in lines) {
      // Extract amount (looking for numbers with currency)
      final amountMatch = RegExp(r'(\d+[.,]\d{2})').firstMatch(line);
      if (amountMatch != null && amount == null) {
        amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', '.'));
      }

      // Extract date
      final dateMatch = RegExp(r'(\d{2})[./](\d{2})[./](\d{2,4})').firstMatch(line);
      if (dateMatch != null && date == null) {
        try {
          date = DateTime.parse('${dateMatch.group(3)}-${dateMatch.group(2)}-${dateMatch.group(1)}');
        } catch (_) {}
      }

      // First line often contains merchant name
      if (merchant == null && line.trim().isNotEmpty) {
        merchant = line.trim();
      }
    }

    return {
      'amount': amount,
      'merchant': merchant,
      'date': date?.toIso8601String(),
      'imagePath': imagePath,
      'rawText': text,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
