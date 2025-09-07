import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Notes App 🧠',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Color> tagColors = [
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
    Colors.teal.shade200,
  ];

  List<Map<String, dynamic>> get _filteredNotes {
    if (_searchController.text.isEmpty) return _notes;
    return _notes
        .where((note) =>
            note['title']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            note['content']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  void _addOrEditNote({Map<String, dynamic>? note, int? index}) {
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController =
        TextEditingController(text: note?['content'] ?? '');
    int selectedColorIndex =
        note?['colorIndex'] ?? Random().nextInt(tagColors.length);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(note == null ? "Add Note" : "Edit Note",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: "Content",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: List.generate(tagColors.length, (i) {
                    return GestureDetector(
                      onTap: () {
                        setModalState(() => selectedColorIndex = i);
                      },
                      child: CircleAvatar(
                        backgroundColor: tagColors[i],
                        radius: 18,
                        child: selectedColorIndex == i
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("AI Suggest Title"),
                      onPressed: () {
                        if (contentController.text.isNotEmpty) {
                          // fake AI title suggestion
                          titleController.text =
                              _fakeAISuggestion(contentController.text);
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          if (note == null) {
                            _notes.add({
                              'title': titleController.text,
                              'content': contentController.text,
                              'colorIndex': selectedColorIndex,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Note added successfully")),
                            );
                          } else {
                            _notes[index!] = {
                              'title': titleController.text,
                              'content': contentController.text,
                              'colorIndex': selectedColorIndex,
                            };
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Note updated successfully")),
                            );
                          }
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _fakeAISuggestion(String content) {
    if (content.length < 15) return "Quick Note";
    if (content.toLowerCase().contains("flutter")) return "Flutter Ideas";
    if (content.toLowerCase().contains("todo")) return "Task List";
    return "Note about ${content.split(" ").first}";
  }

  void _deleteNoteAt(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notes.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note deleted successfully")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("AI Notes 🧠"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text("No Notes Yet 📝"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredNotes.length,
              itemBuilder: (_, i) {
                final note = _filteredNotes[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: tagColors[note['colorIndex']],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      note['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(note['content']),
                    onTap: () =>
                        _addOrEditNote(note: note, index: _notes.indexOf(note)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black87),
                      onPressed: () => _deleteNoteAt(_notes.indexOf(note)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: Colors.teal,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
