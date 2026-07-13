import 'package:flutter/material.dart';

import 'memory_controller.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  late final MemoryGameController _controller = MemoryGameController();

  @override
  void initState() {
    super.initState();
    _controller.startGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Column(
                  children: [
                    _Hud(controller: _controller),
                    _StatusBanner(controller: _controller),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _TileGrid(controller: _controller),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                if (_controller.phase == GamePhase.gameOver)
                  _GameOverOverlay(controller: _controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.controller});

  final MemoryGameController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pill('Level ${controller.level}'),
          Row(
            children: List.generate(
              MemoryGameController.maxLives,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i < controller.lives ? Icons.favorite : Icons.favorite_border,
                  color: i < controller.lives
                      ? Colors.redAccent
                      : Colors.white24,
                  size: 22,
                ),
              ),
            ),
          ),
          _pill('${controller.score}'),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});

  final MemoryGameController controller;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (controller.phase) {
      GamePhase.showing => ('Watch closely…', Colors.amberAccent),
      GamePhase.awaitingInput => ('Your turn!', Colors.greenAccent),
      GamePhase.levelComplete => ('Level complete!', Colors.lightBlueAccent),
      GamePhase.gameOver => ('', Colors.transparent),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        text,
        key: ValueKey(text),
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.controller});

  final MemoryGameController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.gridSize;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: controller.tileCount,
      itemBuilder: (context, index) {
        return _Tile(
          index: index,
          total: controller.tileCount,
          highlight: controller.highlightFor(index),
          onTap: () => controller.onTileTap(index),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.index,
    required this.total,
    required this.highlight,
    required this.onTap,
  });

  final int index;
  final int total;
  final TileHighlight highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hue = 360.0 * index / total;
    final base = HSLColor.fromAHSL(1, hue, 0.65, 0.24).toColor();
    final lit = HSLColor.fromAHSL(1, hue, 0.85, 0.58).toColor();

    final (color, borderColor, scale) = switch (highlight) {
      TileHighlight.none => (base, Colors.transparent, 1.0),
      TileHighlight.lit => (lit, Colors.white70, 1.06),
      TileHighlight.correct => (lit, Colors.greenAccent, 1.06),
      TileHighlight.wrong => (const Color(0xFFB71C1C), Colors.redAccent, 0.94),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: highlight == TileHighlight.lit ||
                    highlight == TileHighlight.correct
                ? [BoxShadow(color: lit.withValues(alpha: 0.6), blurRadius: 18)]
                : const [],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.controller});

  final MemoryGameController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Score ${controller.score}  ·  Reached level ${controller.level}',
              style: const TextStyle(color: Colors.white70, fontSize: 17),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: controller.startGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              child: const Text('Play Again', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
