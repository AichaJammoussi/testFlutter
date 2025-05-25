import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:testfront/core/models/MissionRapportDto.dart';

Future<void> generateMissionRapportPdf(MissionRapportDto rapport) async {
  final pdf = pw.Document();

  // Charger le logo
  final ByteData logoData = await rootBundle.load('assets/logo.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();
  final imageLogo = pw.MemoryImage(logoBytes);

  final baseTextStyle = pw.TextStyle(fontSize: 12, color: PdfColors.grey800);
  final titleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900);
  final sectionTitleStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo600);

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(imageLogo, width: 80),
            pw.Text('Rapport de Mission', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
          ],
        ),
        pw.Divider(thickness: 1.5, color: PdfColors.indigo100),
        pw.SizedBox(height: 10),
        pw.Text('Titre : ${rapport.titre}', style: titleStyle),
        pw.Text('Description : ${rapport.description}', style: baseTextStyle),
        pw.Text('Statut : ${rapport.statut}', style: baseTextStyle),
        pw.Text('Priorité : ${rapport.priorite}', style: baseTextStyle),
        pw.Text('Budget : ${rapport.budget.toStringAsFixed(2)} €', style: baseTextStyle),
        pw.Text('Dépenses : ${rapport.depenses.toStringAsFixed(2)} €', style: baseTextStyle),
        pw.SizedBox(height: 20),
        pw.Text('Tâches par Employé', style: sectionTitleStyle),
        pw.SizedBox(height: 10),

        for (var emp in rapport.tachesParEmploye)
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 6),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.indigo100),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('👤 Employé : ${emp.nomComplet}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('💶 Remboursement : ${emp.montantRemboursement.toStringAsFixed(2)} €'),
                pw.SizedBox(height: 6),
                for (var tache in emp.taches) ...[
                  pw.Text('📝 ${tache.titre} (${tache.dateRealisationAsDateTime?.toIso8601String().substring(0, 10) ?? "Date inconnue"})'),
                  pw.Text('  - Budget : ${tache.budgetTache.toStringAsFixed(2)} € | Dépenses : ${tache.depensesTotales.toStringAsFixed(2)} €'),
                  if (tache.depenses.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('  Détails des dépenses :', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                        for (var dep in tache.depenses)
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Text(
                              '    - ${dep.typeDepense} : ${dep.montant.toStringAsFixed(2)} € | ${dep.moyenPaiement} | ${dep.description} | Justification : ${dep.justification}',
                              style: pw.TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  pw.SizedBox(height: 4),
                ],
              ],
            ),
          ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
