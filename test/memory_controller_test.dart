import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:echo_grid/game/memory_controller.dart';

Future<void> waitForPhase(MemoryGameController c, GamePhase phase) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (c.phase != phase) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $phase (stuck in ${c.phase})');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  test('level 1 sequence has 3 steps on a 3x3 grid', () async {
    final c = MemoryGameController(random: Random(42), timeScale: 0.01);
    await c.startGame();
    expect(c.gridSize, 3);
    expect(c.sequence.length, 3);
    expect(c.sequence.every((t) => t >= 0 && t < 9), isTrue);
    c.dispose();
  });

  test('repeating the sequence correctly advances to the next level', () async {
    final c = MemoryGameController(random: Random(42), timeScale: 0.01);
    await c.startGame();
    await waitForPhase(c, GamePhase.awaitingInput);

    final seq = List.of(c.sequence);
    for (final tile in seq) {
      await c.onTileTap(tile);
    }
    await waitForPhase(c, GamePhase.awaitingInput);
    expect(c.level, 2);
    expect(c.sequence.length, 4);
    expect(c.score, greaterThan(0));
    c.dispose();
  });

  test('a wrong tap costs a life and replays the same sequence', () async {
    final c = MemoryGameController(random: Random(42), timeScale: 0.01);
    await c.startGame();
    await waitForPhase(c, GamePhase.awaitingInput);

    final seq = List.of(c.sequence);
    final wrongTile = (seq.first + 1) % c.tileCount == seq.first
        ? seq.first + 2
        : (seq.first + 1) % c.tileCount;
    await c.onTileTap(wrongTile);
    expect(c.lives, MemoryGameController.maxLives - 1);

    await waitForPhase(c, GamePhase.awaitingInput);
    expect(c.sequence, seq, reason: 'sequence should replay unchanged');
    expect(c.level, 1);
    c.dispose();
  });

  test('losing all lives ends the game; restart resets state', () async {
    final c = MemoryGameController(random: Random(42), timeScale: 0.01);
    await c.startGame();

    for (var i = 0; i < MemoryGameController.maxLives; i++) {
      await waitForPhase(c, GamePhase.awaitingInput);
      final wrong = (c.sequence[0] + 1) % c.tileCount;
      await c.onTileTap(wrong == c.sequence[0] ? wrong + 1 : wrong);
    }
    expect(c.phase, GamePhase.gameOver);
    expect(c.lives, 0);

    await c.startGame();
    await waitForPhase(c, GamePhase.awaitingInput);
    expect(c.lives, MemoryGameController.maxLives);
    expect(c.level, 1);
    expect(c.score, 0);
    c.dispose();
  });

  test('input is ignored while the sequence is playing', () async {
    final c = MemoryGameController(random: Random(42), timeScale: 1.0);
    // Real-speed playback: phase stays `showing` long enough to tap into it.
    final start = c.startGame();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c.phase, GamePhase.showing);
    await c.onTileTap(0);
    expect(c.lives, MemoryGameController.maxLives);
    expect(c.score, 0);
    c.dispose();
    await start;
  });

  test('grid grows to 4x4 at level 6', () {
    final c = MemoryGameController(random: Random(1));
    c.level = 6;
    expect(c.gridSize, 4);
    expect(c.tileCount, 16);
    c.dispose();
  });
}
