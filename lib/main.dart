import 'package:flutter/material.dart';

import 'game/memory_page.dart';

void main() {
  runApp(const MemoryApp());
}

class MemoryApp extends StatelessWidget {
  const MemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MemoryPage(),
    );
  }
}
