import 'package:daymark/core/utils/date_utils.dart';
import 'package:daymark/features/summary/domain/entities/journal_summary.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  /// Generate printable & shareable PDF for a JournalSummary
  static Future<void> exportSummaryPdf(JournalSummary summary) async {
    final doc = pw.Document();

    final fontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    final fontSemiBold = await PdfGoogleFonts.plusJakartaSansSemiBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DAYMARK',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#10B981'),
                      ),
                    ),
                    pw.Text(
                      'Every day leaves a mark.',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'JOURNAL EXECUTIVE SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Text(
                      '${AppDateUtils.formatDisplay(summary.startDate)} - ${AppDateUtils.formatDisplay(summary.endDate)}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated via ${summary.providerUsed} on ${AppDateUtils.formatDisplay(summary.generatedAt)}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),

            // Overview Metric Bar
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F1F5F9'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('Total Entries', summary.totalEntries.toString(), fontBold),
                  _buildMetric(
                    'Period Span',
                    '${AppDateUtils.toLocalDateOnly(summary.endDate).difference(AppDateUtils.toLocalDateOnly(summary.startDate)).inDays + 1} Days',
                    fontBold,
                  ),
                  _buildMetric('Status', 'Documented', fontBold),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Executive Summary
            pw.Text(
              'Executive Overview',
              style: pw.TextStyle(
                fontSize: 14,
                font: fontSemiBold,
                color: PdfColor.fromHex('#0F172A'),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              summary.executiveSummary,
              style: const pw.TextStyle(
                fontSize: 10.5,
                lineSpacing: 1.4,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 20),

            // Key Activities
            _buildSection(
              title: 'Key Activities & Timeline',
              items: summary.keyActivities,
              accentHex: '#10B981',
              fontSemiBold: fontSemiBold,
            ),
            pw.SizedBox(height: 16),

            // Learnings
            _buildSection(
              title: 'Key Learnings & Insights',
              items: summary.learnings,
              accentHex: '#6366F1',
              fontSemiBold: fontSemiBold,
            ),
            pw.SizedBox(height: 16),

            // Achievements
            _buildSection(
              title: 'Achievements & Milestones',
              items: summary.achievements,
              accentHex: '#F59E0B',
              fontSemiBold: fontSemiBold,
            ),
            pw.SizedBox(height: 16),

            // Challenges
            _buildSection(
              title: 'Challenges & Overcoming Obstacles',
              items: summary.challenges,
              accentHex: '#EF4444',
              fontSemiBold: fontSemiBold,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'DAYMARK_Summary_${AppDateUtils.formatDateKey(summary.startDate)}_${AppDateUtils.formatDateKey(summary.endDate)}.pdf',
    );
  }

  static pw.Widget _buildMetric(String label, String value, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, font: fontBold, color: PdfColor.fromHex('#0F172A'))),
      ],
    );
  }

  static pw.Widget _buildSection({
    required String title,
    required List<String> items,
    required String accentHex,
    required pw.Font fontSemiBold,
  }) {
    if (items.isEmpty) return pw.SizedBox();

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: PdfColor.fromHex(accentHex), width: 3)),
      ),
      padding: const pw.EdgeInsets.only(left: 10, top: 2, bottom: 2),
      child: pw.Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              font: fontSemiBold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
          pw.SizedBox(height: 6),
          ...items.map((item) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: pw.TextStyle(color: PdfColor.fromHex(accentHex), fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
