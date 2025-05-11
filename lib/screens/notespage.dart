import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final listItemController = TextEditingController();

  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> listItems = [];

  String noteType = '';
  int? editingIndex;
  bool isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes');
    if (data != null) {
      notes = List<Map<String, dynamic>>.from(json.decode(data));
      setState(() {});
    }
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(notes));
  }

  void resetFields() {
    titleController.clear();
    contentController.clear();
    listItemController.clear();
    listItems.clear();
    noteType = '';
    editingIndex = null;
  }

  void openEditor(String type) {
    setState(() {
      noteType = type;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  if (noteType == 'text')
                    TextField(
                      controller: contentController,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'Note'),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: listItemController,
                                decoration: const InputDecoration(labelText: 'List item'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final text = listItemController.text.trim();
                                if (text.isEmpty) return;
                                modalSetState(() {
                                  listItems.add({'text': '', 'checked': false});
                                  listItemController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listItems.length + 1, // +1 for the add new row
                          itemBuilder: (context, index) {
                            if (index == listItems.length) {
                              return ListTile(
                                leading: const Icon(Icons.add_circle_outline),
                                title: const Text("Add new item"),
                                onTap: () {
                                  modalSetState(() {
                                    listItems.add({'text': '', 'checked': false});
                                  });
                                },
                              );
                            }

                            final item = listItems[index];
                            final controller = TextEditingController(text: item['text']);

                            return ListTile(
                              leading: Checkbox(
                                value: item['checked'],
                                onChanged: (val) {
                                  modalSetState(() {
                                    listItems[index]['checked'] = val!;
                                  });
                                },
                              ),
                              title: TextField(
                                controller: controller,
                                decoration: const InputDecoration(border: InputBorder.none),
                                onChanged: (newText) {
                                  listItems[index]['text'] = newText;
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  modalSetState(() {
                                    listItems.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      final validText = noteType == 'text' && content.isNotEmpty;
                      final validList = noteType == 'list' && listItems.any((item) => item['text'].trim().isNotEmpty);

                      if (!validText && !validList) return;

                      final finalTitle = title.isNotEmpty
                          ? title
                          : noteType == 'text'
                          ? content.split('\n').first
                          : listItems.first;

                      final note = {
                        'title': finalTitle,
                        'type': noteType,
                        'content': noteType == 'text' ? content : List.from(listItems),
                        'timestamp': DateTime.now().toIso8601String(),
                      };

                      setState(() {
                        if (editingIndex != null) {
                          notes[editingIndex!] = note;
                          editingIndex = null;
                        } else {
                          notes.add(note);
                        }
                        resetFields();
                      });

                      saveNotes();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    ).whenComplete(() {
      resetFields();
    });
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void editNote(int index) {
    final note = notes[index];
    setState(() {
      editingIndex = index;
      titleController.text = note['title'];
      noteType = note['type'];
      if (noteType == 'text') {
        contentController.text = note['content'];
      } else {
        listItems = List<Map<String, dynamic>>.from(note['content']);
      }
    });
    openEditor(noteType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.green.shade700,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isFabExpanded) ...[
              FloatingActionButton.extended(
                heroTag: 'text',
                backgroundColor: Colors.green.shade300,
                icon: const Icon(Icons.text_fields),
                label: const Text('Text Note'),
                onPressed: () {
                  openEditor('text');
                },
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'list',
                backgroundColor: Colors.green.shade300,
                icon: const Icon(Icons.list),
                label: const Text('List Note'),
                onPressed: () {
                  openEditor('list');
                },
              ),
              const SizedBox(height: 10),
            ],
            FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(isFabExpanded ? Icons.close : Icons.add),
              onPressed: () {
                setState(() {
                  isFabExpanded = !isFabExpanded;
                });
              },
            ),
          ],
        ),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet.'))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final date = DateFormat.yMMMd().add_jm().format(DateTime.parse(note['timestamp']));
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.green.shade50,
            child: ListTile(
              onTap: () => editNote(index),
              title: Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (note['type'] == 'text')
                    Text(note['content'], maxLines: 3, overflow: TextOverflow.ellipsis)
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          (note['content'] as List).take(3).length,
                              (i) => Text(
                                (note['content'][i] is Map &&
                                    note['content'][i].containsKey('text') &&
                                    note['content'][i].containsKey('checked'))
                                    ? "${i + 1}. ${note['content'][i]['text']} ${note['content'][i]['checked'] ? '✓' : ''}"
                                    : "${i + 1}. Invalid item format",
                              ),
                        ),
                        if ((note['content'] as List).length > 3)
                          const Text("+ more...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Text(date, style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteNote(index),
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
