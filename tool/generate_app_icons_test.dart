// Renders the Echo Grid logo to the master icon PNGs consumed by
// flutter_launcher_icons. Not part of the regular test suite (lives outside
// test/); run explicitly when the logo changes:
//
//   flutter test tool/generate_app_icons_test.dart
//   dart run flutter_launcher_icons

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _canvas = 1024.0;
const _background = Color(0xFF10131A);
const _tileColors = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
];

Widget _logoGrid({required double gridSize}) {
  final tile = (gridSize - gridSize * 0.09) / 2;
  final gap = gridSize * 0.09;
  return SizedBox(
    width: gridSize,
    height: gridSize,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var row = 0; row < 2; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var col = 0; col < 2; col++)
                Container(
                  width: tile,
                  height: tile,
                  margin: EdgeInsets.only(
                    right: col == 0 ? gap : 0,
                    bottom: row == 0 ? gap : 0,
                  ),
                  decoration: BoxDecoration(
                    color: _tileColors[row * 2 + col],
                    borderRadius: BorderRadius.circular(tile * 0.24),
                    boxShadow: [
                      BoxShadow(
                        color: _tileColors[row * 2 + col]
                            .withValues(alpha: 0.55),
                        blurRadius: gridSize * 0.07,
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}

Future<void> _capture(
  WidgetTester tester,
  Widget widget,
  String outputPath,
) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: SizedBox(
          width: _canvas,
          height: _canvas,
          child: widget,
        ),
      ),
    ),
  );
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(_canvas, _canvas)
      ..devicePixelRatio = 1.0;
  });

  testWidgets('generate master app icon', (tester) async {
    await _capture(
      tester,
      Container(
        color: _background,
        alignment: Alignment.center,
        child: _logoGrid(gridSize: _canvas * 0.60),
      ),
      'assets/icon/app_icon.png',
    );
  });

  testWidgets('generate adaptive icon foreground', (tester) async {
    // Android adaptive icons crop to a ~61% safe zone; keep the grid small
    // and the backdrop transparent (the background color comes from config).
    await _capture(
      tester,
      Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: _logoGrid(gridSize: _canvas * 0.42),
      ),
      'assets/icon/app_icon_foreground.png',
    );
  });
}
