import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/notes.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());

  await Hive.openBox<Note>('notesBox');
  await Hive.openBox('settingsBox');

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    NimbusApp(
      isDarkMode: isDarkMode,
    ),
  );
}

class NimbusApp extends StatefulWidget {
  final bool isDarkMode;

  const NimbusApp({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<NimbusApp> createState() => _NimbusAppState();
}

class _NimbusAppState extends State<NimbusApp> {

  late bool isDarkMode;

  @override
  void initState() {
    super.initState();

    isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      home: HomeScreen(
        isDarkMode: isDarkMode,

        onThemeChanged: (value) async {
          setState(() {
            isDarkMode = value;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isDarkMode', value);
        },
      ),
    );
  }
}