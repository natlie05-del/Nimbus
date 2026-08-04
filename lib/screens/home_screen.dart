import 'package:flutter/material.dart';
import 'add_note_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notes.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final settingsBox = Hive.box('settingsBox');

    sortOption =
        settingsBox.get(
          'sortOption',
          defaultValue: 'newest',
        );
  }
  String sortOption = 'newest';
  final TextEditingController searchController = TextEditingController();


  String getGreeting() {
    final hour = DateTime
        .now()
        .hour;

    if (hour < 12) {
      return "Good Morning️";
    } else if (hour < 17) {
      return "Good Afternoon 🌤️";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Night Owl ?";
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final noteDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    String formatTime(DateTime date) {
      final hour = date.hour == 0
          ? 12
          : date.hour > 12
          ? date.hour - 12
          : date.hour;

      final minute = date.minute
          .toString()
          .padLeft(2, '0');

      final period =
      date.hour >= 12 ? "PM" : "AM";

      return "$hour:$minute $period";
    }

    if (noteDay == today) {
      return "Today • ${formatTime(date)}";
    }

    if (noteDay == yesterday) {
      return "Yesterday • ${formatTime(date)}";
    }

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${date.day} ${months[date.month - 1]} • ${formatTime(date)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,

        title: ValueListenableBuilder(
          valueListenable: Hive.box<Note>('notesBox').listenable(),

          builder: (context, Box<Note> box, _) {
            final count = box.length;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Nimbus",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  count == 1
                      ? "1 Note • ${box.values
                      .where((note) => note.isPinned)
                      .length} Pinned"
                      : "$count Notes • ${box.values
                      .where((note) => note.isPinned)
                      .length} Pinned",
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // GREETING + THEME BUTTON
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        getGreeting(),

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Capture every thought,\none note at a time.",

                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    widget.onThemeChanged(
                      !widget.isDarkMode,
                    );
                  },

                  icon: Icon(
                    widget.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,

                    size: 26,
                    color: colorScheme.onSurface,
                  ),

                  tooltip: widget.isDarkMode
                      ? "Switch to light mode"
                      : "Switch to dark mode",
                ),
              ],
            ),

            const SizedBox(height: 20),


            // searchbar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,

                style: const TextStyle(
                  color: Colors.black,
                ),

                onChanged: (value) {
                  setState(() {});
                },

                decoration: InputDecoration(
                  hintText: "Search your notes...",

                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                  ),

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6B7280),
                  ),

                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Clear search
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF6B7280),
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        ),

                      // Sorting menu
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: Color(0xFF6B7280),
                        ),

                        onSelected: (value) async {
                          setState(() {
                            sortOption = value;
                          });

                          final settingsBox = Hive.box('settingsBox');

                          await settingsBox.put(
                            'sortOption',
                            value,
                          );
                        },

                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'newest',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_downward),
                                const SizedBox(width: 10),
                                const Text("Newest First"),
                                if (sortOption == 'newest') ...[
                                  const Spacer(),
                                  const Icon(Icons.check),
                                ],
                              ],
                            ),
                          ),

                          PopupMenuItem(
                            value: 'oldest',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward),
                                const SizedBox(width: 10),
                                const Text("Oldest First"),
                                if (sortOption == 'oldest') ...[
                                  const Spacer(),
                                  const Icon(Icons.check),
                                ],
                              ],
                            ),
                          ),

                          PopupMenuItem(
                            value: 'pinned',
                            child: Row(
                              children: [
                                const Icon(Icons.push_pin_outlined),
                                const SizedBox(width: 10),
                                const Text("Pinned First"),
                                if (sortOption == 'pinned') ...[
                                  const Spacer(),
                                  const Icon(Icons.check),
                                ],
                              ],
                            ),
                          ),

                          PopupMenuItem(
                            value: 'title_az',
                            child: Row(
                              children: [
                                const Icon(Icons.sort_by_alpha),
                                const SizedBox(width: 10),
                                const Text("Title A → Z"),
                                if (sortOption == 'title_az') ...[
                                  const Spacer(),
                                  const Icon(Icons.check),
                                ],
                              ],
                            ),
                          ),

                          PopupMenuItem(
                            value: 'title_za',
                            child: Row(
                              children: [
                                const Icon(Icons.sort_by_alpha),
                                const SizedBox(width: 10),
                                const Text("Title Z → A"),
                                if (sortOption == 'title_za') ...[
                                  const Spacer(),
                                  const Icon(Icons.check),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF5AA9FF),
                      width: 2.5,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // NOTES LIST
            Expanded(
              child: ValueListenableBuilder(
                valueListenable:
                Hive.box<Note>('notesBox').listenable(),

                builder: (context, Box<Note> box, _) {
                  if (box.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 90,
                            color: Color(0xFFA7D8FF),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "No notes yet",

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Start by creating your\nfirst note.",

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final search = searchController.text.toLowerCase();

                  final notes = box.values
                      .where((note) {
                    return note.title.toLowerCase().contains(search) ||
                        note.content.toLowerCase().contains(search);
                  })
                      .toList();

                  switch (sortOption) {
                    case 'newest':
                      notes.sort(
                            (a, b) => b.updatedAt.compareTo(a.updatedAt),
                      );
                      break;

                    case 'oldest':
                      notes.sort(
                            (a, b) => a.updatedAt.compareTo(b.updatedAt),
                      );
                      break;

                    case 'pinned':
                      notes.sort((a, b) {
                        if (a.isPinned && !b.isPinned) {
                          return -1;
                        }

                        if (!a.isPinned && b.isPinned) {
                          return 1;
                        }

                        return b.updatedAt.compareTo(a.updatedAt);
                      });
                      break;

                    case 'title_az':
                      notes.sort(
                            (a, b) => a.title.toLowerCase().compareTo(
                          b.title.toLowerCase(),
                        ),
                      );
                      break;

                    case 'title_za':
                      notes.sort(
                            (a, b) => b.title.toLowerCase().compareTo(
                          a.title.toLowerCase(),
                        ),
                      );
                      break;
                  }

                  if (notes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: colorScheme.onSurfaceVariant,
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "No matching notes found",

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 100,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notes.length,

                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return Dismissible(
                        key: Key(
                          note.key.toString(),
                        ),

                        direction:
                        DismissDirection.endToStart,

                        confirmDismiss: (direction) async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Delete Note?"),
                                  ],
                                ),

                                content: const Text(
                                  "Are you sure you want to delete this note?",
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete != true) {
                            return false;
                          }

                          final deletedNote = Note(
                            title: note.title,
                            content: note.content,
                            createdAt: note.createdAt,
                            updatedAt: note.updatedAt,
                            isPinned: note.isPinned,
                          );

                          await note.delete();

                          final messenger = ScaffoldMessenger.maybeOf(context);

                          messenger?.hideCurrentSnackBar();

                          messenger?.showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: const Color(0xFF323232),

                              duration: const Duration(seconds: 5),

                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 12),
                                  Text("Note deleted"),
                                ],
                              ),

                              action: SnackBarAction(
                                label: "UNDO",
                                textColor: Color(0xFFA7D8FF),

                                onPressed: () {
                                  Hive.box<Note>('notesBox').add(deletedNote);
                                },
                              ),
                            ),
                          );

                          return true;
                        },

                        background: Container(
                          alignment:
                          Alignment.centerRight,

                          padding:
                          const EdgeInsets.only(
                            right: 25,
                          ),

                          decoration:
                          BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),

                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),

                        child: Card(
                          margin:
                          const EdgeInsets.only(
                            bottom: 16,
                          ),

                          elevation: 3,

                          shadowColor:
                          Colors.black12,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),

                          child: Padding(
                            padding:
                            const EdgeInsets.all(
                              16,
                            ),

                            child: ListTile(
                              contentPadding:
                              EdgeInsets.zero,

                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddNoteScreen(
                                          note: note,
                                        ),
                                  ),
                                );
                              },

                              title: Row(
                                children: [
                                  if (note.isPinned)
                                    const Padding(
                                      padding:
                                      EdgeInsets.only(
                                        right: 6,
                                      ),

                                      child: Icon(
                                        Icons.push_pin,
                                        size: 18,
                                        color:
                                        Colors.orange,
                                      ),
                                    ),

                                  Expanded(
                                    child: Text(
                                      note.title,

                                      maxLines: 1,

                                      overflow:
                                      TextOverflow
                                          .ellipsis,

                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,

                                        fontSize: 18,

                                        color: colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),

                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant,),

                                    onSelected: (value) async {

                                      // PIN / UNPIN
                                      if (value == 'pin') {
                                        note.isPinned = !note.isPinned;
                                        await note.save();
                                      }

                                      // COPY
                                      if (value == 'copy') {
                                        final textToCopy =
                                            "${note.title}\n\n${note.content}";

                                        await Clipboard.setData(
                                          ClipboardData(text: textToCopy),
                                        );

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            duration: const Duration(seconds: 2),
                                            content: const Row(
                                              children: [
                                                Icon(
                                                  Icons.copy,
                                                  color: Color(0xFFA7D8FF),
                                                ),
                                                SizedBox(width: 12),
                                                Text("Note copied to clipboard"),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      // SHARE
                                      if (value == 'share') {
                                        final textToShare =
                                            "${note.title}\n\n${note.content}";

                                        try {
                                          final result = await SharePlus.instance.share(
                                            ShareParams(
                                              text: textToShare,
                                              subject: note.title,
                                            ),
                                          );

                                          debugPrint(
                                            "Share result: ${result.status}",
                                          );
                                        } catch (e) {
                                          debugPrint(
                                            "Share error: $e",
                                          );
                                        }
                                      }

                                    },

                                    itemBuilder:
                                        (context) =>
                                    [
                                      PopupMenuItem(
                                        value: 'pin',

                                        child: Row(
                                          children: [
                                            Icon(
                                              note.isPinned
                                                  ? Icons
                                                  .push_pin_outlined
                                                  : Icons
                                                  .push_pin,
                                            ),

                                            const SizedBox(
                                              width: 10,
                                            ),

                                            Text(
                                              note.isPinned
                                                  ? 'Unpin'
                                                  : 'Pin',
                                            ),
                                          ],
                                        ),
                                      ),

                                      PopupMenuItem(
                                        value: 'copy',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.copy),
                                            SizedBox(width: 10),
                                            Text("Copy"),
                                          ],
                                        ),
                                      ),

                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share_outlined),
                                            SizedBox(width: 10),
                                            Text("Share"),
                                          ],
                                        ),
                                      ),

                                      const PopupMenuDivider(),

                                      const PopupMenuItem(
                                        enabled: false,
                                        value: 'delete',

                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color:
                                              Colors.red,
                                            ),

                                            SizedBox(
                                              width: 10,
                                            ),

                                            Text(
                                              "Delete (Swipe)",

                                              style:
                                              TextStyle(
                                                color:
                                                Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              subtitle: Padding(
                                padding:
                                const EdgeInsets.only(
                                  top: 10,
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [
                                    Text(
                                      formatDate(note.updatedAt),

                                      style: TextStyle(
                                        color: colorScheme
                                            .onSurfaceVariant,

                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      note.content,

                                      maxLines: 3,

                                      overflow:
                                      TextOverflow
                                          .ellipsis,

                                      style: TextStyle(
                                        fontSize: 15,

                                        height: 1.4,

                                        color: colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // NEW NOTE BUTTON
      floatingActionButton:
      FloatingActionButton.extended(
        heroTag: "addNote",

        tooltip: "Create New Note",

        elevation: 6,

        backgroundColor: const Color(0xFF5AA9FF),
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),

        label: const Text(
          "New Note",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
              const AddNoteScreen(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }
}