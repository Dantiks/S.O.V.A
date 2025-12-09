import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class ExportService {
  // PDF export закомментирован, т.к. зависимости не установлены
  /*
  Future<File> exportTransactionsToPDF({
    required List<Map<String, dynamic>> transactions,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd.MM.yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Период: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Дата', 'Описание', 'Категория', 'Сумма'],
            data: transactions.map((t) => [
              dateFormat.format(DateTime.parse(t['date'])),
              t['description'],
              t['category'],
              '${t['amount']} ₸',
            ]).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> exportTransactionsToCSV({
    required List<Map<String, dynamic>> transactions,
  }) async {
    final List<List<dynamic>> rows = [
      ['Дата', 'Описание', 'Категория', 'Тип', 'Сумма', 'Счет'],
    ];

    for (var t in transactions) {
      rows.add([
        t['date'],
        t['description'],
        t['category'],
        t['type'],
        t['amount'],
        t['accountId'],
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file;
  }

  */
  
  Future<void> printPDF(File pdfFile) async {
    // await Printing.layoutPdf(onLayout: (_) => pdfFile.readAsBytes());
    throw UnimplementedError('PDF printing requires pdf and printing packages');
  }

  Future<void> sharePDF(File pdfFile) async {
    // await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: 'sova_report.pdf');
    throw UnimplementedError('PDF sharing requires pdf and printing packages');
  }
}
