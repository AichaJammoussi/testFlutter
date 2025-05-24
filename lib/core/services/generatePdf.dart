import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:testfront/core/models/MissionRapportDto.dart';


Future<void> generateMissionRapportPdf(MissionRapportDto rapport) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('Rapport de Mission', style: pw.TextStyle(fontSize: 24)),
        ),
        pw.Paragraph(text: 'Titre: ${rapport.titre}'),
        pw.Paragraph(text: 'Description: ${rapport.description}'),
        pw.Paragraph(text: 'Statut: ${rapport.statut}'),
        pw.Paragraph(text: 'Priorité: ${rapport.priorite}'),
        pw.Paragraph(text: 'Budget: ${rapport.budget}'),
        pw.Paragraph(text: 'Dépenses: ${rapport.depenses}'),
        pw.Paragraph(
          text: 'Décision Admin: ${rapport.estAccepteParAdmin != null ? (rapport.estAccepteParAdmin! ? 'Acceptée' : 'Refusée') : 'Non décidée'}',
        ),
        if (rapport.dateDecisionAdmin != null)
          pw.Paragraph(
            text: 'Date décision: ${rapport.dateDecisionAdmin}',
          ),
        pw.SizedBox(height: 20),
        pw.Text('Tâches par Employé', style: pw.TextStyle(fontSize: 18)),
        for (var emp in rapport.tachesParEmploye)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Employé: ${emp.nomComplet}'),
              for (var tache in emp.taches)
                pw.Bullet(
  text:
    '${tache.titre} (${tache.dateRealisationAsDateTime != null ? tache.dateRealisationAsDateTime!.toIso8601String() : "Date inconnue"}) - Budget: ${tache.budgetTache}',
),


              pw.SizedBox(height: 10),
            ],
          )
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
