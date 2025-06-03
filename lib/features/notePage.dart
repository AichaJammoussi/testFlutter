import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFE8F0FE), // Bleu pastel très clair
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFB2C7F7), // Bleu clair
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB39DDB), // Violet pastel
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = notesJson.map((e) => json.decode(e)).cast<Map<String, dynamic>>().toList();
    });
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((e) => json.encode(e)).toList();
    await prefs.setStringList('notes', notesJson);
  }

  void addOrEditNote({Map<String, dynamic>? existingNote}) {
  final titleController = TextEditingController(text: existingNote?['title'] ?? '');
  final contentController = TextEditingController(text: existingNote?['content'] ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Color(0xFFF3F4FF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Titre',
                      filled: true,
                      fillColor: Color(0xFFDEE9FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      hintText: 'Contenu',
                      filled: true,
                      fillColor: Color(0xFFDEE9FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB39DDB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty && content.isEmpty) return;

                      final note = {
                        'id': existingNote?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': title,
                        'content': content,
                        'updatedAt': DateTime.now().millisecondsSinceEpoch,
                      };

                      setState(() {
                        if (existingNote != null) {
                          final index = notes.indexWhere((n) => n['id'] == existingNote['id']);
                          if (index != -1) notes[index] = note;
                        } else {
                          notes.insert(0, note);
                        }
                      });

                      saveNotes();
                      Navigator.pop(context);
                    },
                    child: Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}


  void deleteNote(String id) async {
    setState(() {
      notes.removeWhere((n) => n['id'] == id);
    });
    await saveNotes();
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Notes'),
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'Aucune note',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) {
    final note = notes[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFFE3F2FD), // Bleu clair
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['title'] ?? 'Sans titre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E), // Bleu foncé
              ),
            ),
            SizedBox(height: 6),
            Text(
              note['content'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A148C), // Violet foncé
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => addOrEditNote(existingNote: note),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF5E35B1), // Violet
                  ),
                  icon: Icon(Icons.edit, size: 20),
                  label: Text('Modifier'),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => deleteNote(note['id']),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 225, 110, 128), // Rouge
                  ),
                  icon: Icon(Icons.delete_outline, size: 20),
                  label: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
)
,
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditNote(),
        child: Icon(Icons.add),
     ),
);
}
}
