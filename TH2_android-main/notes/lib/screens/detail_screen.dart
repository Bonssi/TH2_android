import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class DetailScreen extends StatefulWidget {
  final Note? note;

  const DetailScreen({super.key, this.note});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController contentController =
      TextEditingController();

  int selectedColor = 0xFFFFFFFF;
  bool isEdited = false;

  final List<int> colors = [
    0xFFFFFFFF,
    0xFFFFF9C4,
    0xFFC8E6C9,
    0xFFFFCDD2,
    0xFFBBDEFB,
    0xFFD1C4E9,
    0xFFFFE0B2,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      selectedColor = widget.note!.color;
    }

    titleController.addListener(() => isEdited = true);
    contentController.addListener(() => isEdited = true);
  }

  Future<void> _autoSave() async {
    if (!isEdited) return;

    final notes = await NoteService.getNotes();

    if (widget.note != null) {
      final index =
          notes.indexWhere((n) => n.id == widget.note!.id);

      if (index != -1) {
        notes[index] = Note(
          id: widget.note!.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          updatedAt: DateTime.now(),
          color: selectedColor,
        );
      }
    } else {
      if (titleController.text.trim().isEmpty &&
          contentController.text.trim().isEmpty) return;

      notes.add(
        Note(
          id: DateTime.now().toString(),
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          updatedAt: DateTime.now(),
          color: selectedColor,
        ),
      );
    }

    await NoteService.saveNotes(notes);
  }

  void _openColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 15,
          runSpacing: 15,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = c;
                      isEdited = true;
                    });
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: selectedColor == c
                          ? Border.all(
                              color: Colors.black,
                              width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _autoSave();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(selectedColor),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme:
              const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _openColorPicker,
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// TITLE
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(
                  hintText: "Tiêu đề",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// CONTENT
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  decoration:
                      const InputDecoration(
                    hintText: "Nhập nội dung...",
                    border: InputBorder.none,
                  ),
                  style:
                      const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}