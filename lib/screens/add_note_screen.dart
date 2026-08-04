import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/notes.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;

  const AddNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,

        title: Text(
          isEditing ? "Edit Note" : "New Note",

          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),

        child: Column(
          children: [

            TextField(
              controller: titleController,

              decoration: InputDecoration(
                hintText: "Enter a title...",

                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),

                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,

                focusedBorder: InputBorder.none,
              ),

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

// CONTENT
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "Start writing here...",
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  focusedBorder: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 10),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                onPressed: () {
                  if (titleController.text.trim().isEmpty &&
                      contentController.text.trim().isEmpty) {
                    return;
                  }

                  String content = contentController.text.trim();

                  String title = titleController.text.trim();
                  // AUTO-GENERATE TITLE FROM CONTENT IF TITLE IS EMPTY
                  if (title.isEmpty) {
                    title = content.split('\n').first.trim();
                  }

                  // EDIT EXISTING NOTE
                  if (widget.note != null) {
                    widget.note!.title = title;

                    widget.note!.content = content;

                    widget.note!.updatedAt =
                        DateTime.now();

                    widget.note!.save();
                  }
                  // CREATE NEW NOTE
                  else {
                    final box =
                    Hive.box<Note>('notesBox');

                    box.add(
                      Note(
                        title: title,
                        content: content,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        isPinned: false,
                      ),
                    );
                  }

                  titleController.clear();
                  contentController.clear();

                  // SUCCESS MESSAGE
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      behavior:
                      SnackBarBehavior.floating,

                      margin:
                      const EdgeInsets.all(16),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      backgroundColor:
                      colorScheme
                          .inverseSurface,

                      duration:
                      const Duration(
                        seconds: 2,
                      ),

                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color:
                            Colors.greenAccent,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Text(
                            isEditing
                                ? "Note updated successfully"
                                : "Note saved successfully",

                            style: TextStyle(
                              color: colorScheme
                                  .onInverseSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AA9FF),
                  foregroundColor:
                  Colors.white,

                  surfaceTintColor:
                  Colors.transparent,

                  elevation: 4,

                  shadowColor:
                  Colors.black26,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.save_outlined,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Text(
                      isEditing
                          ? "Update Note"
                          : "Save Note",

                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}