import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:testfront/core/models/MissionRapportDto.dart';
import 'package:intl/intl.dart';

Future<void> generateMissionRapportPdf(MissionRapportDto rapport) async {
  final pdf = pw.Document();

  final ByteData logoData = await rootBundle.load('lib/core/images/steros.jpg');
  final Uint8List logoBytes = logoData.buffer.asUint8List();
  final imageLogo = pw.MemoryImage(logoBytes);

  final dateFormat = DateFormat('dd/MM/yyyy  HH:mm');
  final currentDateTime = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  final baseStyle = pw.TextStyle(fontSize: 11);
  final boldStyle = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
  final headerStyle = pw.TextStyle(
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
  );
  final sectionTitleStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.indigo900,
  );

  pw.Widget sectionTitle(String title) => pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Text(title, style: sectionTitleStyle),
  );

  pw.Widget dataRow(String label, String value) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Flexible(flex: 2, child: pw.Text("$label :", style: boldStyle)),
        pw.SizedBox(width: 10),
        pw.Flexible(flex: 5, child: pw.Text(value, style: baseStyle)),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(24),
      build:
          (context) => [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(imageLogo, width: 80),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Rapport de Mission", style: headerStyle),
                      pw.Text("Généré le : $currentDateTime", style: baseStyle),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),

            // Section: Informations Générales
            sectionTitle("Informations Générales"),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  dataRow("Titre", rapport.titre),
                  dataRow("Description", rapport.description),
                  dataRow("Statut", rapport.statut),
                  dataRow("Priorité", rapport.priorite),
                  dataRow(
                    "Date Début Prévue",
                    dateFormat.format(rapport.dateDebutPrevue),
                  ),
                  dataRow(
                    "Date Fin Prévue",
                    dateFormat.format(rapport.dateFinPrevue),
                  ),
                  dataRow(
                    "Date Début Réelle",
                    rapport.dateDebutReelle != null
                        ? dateFormat.format(rapport.dateDebutReelle!)
                        : "Non renseignée",
                  ),
                  dataRow(
                    "Date Fin Réelle",
                    rapport.dateFinReelle != null
                        ? dateFormat.format(rapport.dateFinReelle!)
                        : "Non renseignée",
                  ),
                  dataRow("Transport", rapport.typeMoyenTransport),
                ],
              ),
            ),

            // Section: Véhicules Utilisés
            if (rapport.vehicules.isNotEmpty) ...[
              sectionTitle("Véhicules Utilisés"),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      rapport.vehicules
                          .map(
                            (v) => pw.Text(
                              "- ${v.marque} ${v.modele} (Immatriculation : ${v.immatriculation})",
                              style: baseStyle,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],

            // Section: Budget & Finances
            sectionTitle("Budget & Finances"),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  dataRow("Budget", "${rapport.budget.toStringAsFixed(3)} Dt"),
                  dataRow(
                    "Dépenses",
                    "${rapport.depenses.toStringAsFixed(3)} Dt",
                  ),
                ],
              ),
            ),

            // Section: Tâches par Employé
            sectionTitle("Tâches par Employé"),
            for (var emp in rapport.tachesParEmploye)
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 6),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.indigo200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Employé : ${emp.nomComplet}", style: boldStyle),
                    pw.Text(
                      "Remboursement : ${emp.montantRemboursement.toStringAsFixed(3)} Dt",
                      style: baseStyle,
                    ),
                    pw.SizedBox(height: 6),
                    for (var tache in emp.taches) ...[
                      pw.Text(
                        "* ${tache.titre} (${tache.dateRealisationAsDateTime != null ? dateFormat.format(tache.dateRealisationAsDateTime!) : "Date inconnue"})",
                        style: boldStyle,
                      ),
                      pw.Text(
                        "Budget : ${tache.budgetTache.toStringAsFixed(3)} Dt | Dépenses : ${tache.depensesTotales.toStringAsFixed(3)} Dt",
                        style: baseStyle,
                      ),
                      if (tache.depenses.isNotEmpty) ...[
                        pw.Text(
                          "Détails des dépenses :",
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                        ),
                        for (var dep in tache.depenses)
                          pw.Bullet(
                            text:
                                "${dep.typeDepense} | ${dep.montant.toStringAsFixed(3)} Dt | ${dep.moyenPaiement} | ${dep.description}",
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                      pw.SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
          ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
