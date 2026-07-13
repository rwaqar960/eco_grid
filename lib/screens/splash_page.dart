import 'dart:async';

import 'package:flutter/material.dart';

import 'landing_page.dart';

/// Animated intro: a 2x2 logo grid flashes a short sequence (a taste of the
/// gameplay), the title fades in, then we move on to the landing screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _tileColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
  ];
  static const _flashOrder = [0, 3, 1, 2];

  int? _litTile;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    for (final tile in _flashOrder) {
      if (!mounted) return;
      setState(() => _litTile = tile);
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      setState(() => _litTile = null);
      await Future<void>.delayed(const Duration(milliseconds: 90));
    }
    if (!mounted) return;
    setState(() => _showTitle = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LandingPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(4, (i) {
                  final lit = _litTile == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      color: lit
                          ? _tileColors[i]
                          : _tileColors[i].withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: lit
                          ? [
                              BoxShadow(
                                color: _tileColors[i].withValues(alpha: 0.6),
                                blurRadius: 22,
                              ),
                            ]
                          : const [],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedOpacity(
              opacity: _showTitle ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Column(
                children: [
                  Text(
                    'Echo Grid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'How long can you remember?',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
