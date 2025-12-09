import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/services/ocr_service.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final OCRService _ocrService = OCRService();
  Map<String, dynamic>? _scannedData;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать чек'),
      ),
      body: _scannedData == null
          ? _buildScanPrompt()
          : _buildScannedDataForm(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _scanReceipt,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Сканировать'),
      ),
    );
  }

  Widget _buildScanPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Отсканируйте чек',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Данные будут автоматически распознаны',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedDataForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_scannedData!['imagePath'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _scannedData!['imagePath'],
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 24),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Магазин',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: _scannedData!['merchant'] ?? '',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Сумма',
            border: OutlineInputBorder(),
            suffixText: '₸',
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _scannedData!['amount']?.toString() ?? '',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Дата',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: _scannedData!['date'] ?? DateTime.now().toString(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveTransaction,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
          child: const Text('Сохранить транзакцию'),
        ),
      ],
    );
  }

  Future<void> _scanReceipt() async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      final data = await _ocrService.scanReceipt();
      if (data != null && mounted) {
        setState(() => _scannedData = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _saveTransaction() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Транзакция сохранена')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
