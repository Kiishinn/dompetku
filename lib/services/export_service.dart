import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  Future<void> exportPdfReport(List<TransactionModel> transactions, double totalIncome, double totalExpense) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Laporan Keuangan Dompetku', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text('Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('Total Pemasukan: ${CurrencyFormatter.format(totalIncome)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  pw.Text('Total Pengeluaran: ${CurrencyFormatter.format(totalExpense)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Tanggal', 'Judul Transaksi', 'Kategori', 'Dompet', 'Jenis', 'Nominal'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellAlignment: pw.Alignment.centerLeft,
              data: transactions.map((t) => [
                '${t.date.day}/${t.date.month}/${t.date.year}',
                t.title,
                t.categoryName,
                t.displayWallet,
                t.isIncome ? 'Pemasukan' : 'Pengeluaran',
                CurrencyFormatter.format(t.amount),
              ]).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_Dompetku_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
