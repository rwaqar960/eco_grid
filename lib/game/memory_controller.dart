import 'dart:math';

import 'package:flutter/foundation.dart';

enum GamePhase {
  /// The sequence is being played back; input is ignored.
  showing,

  /// Waiting for the player to repeat the sequence.
  awaitingInput,

  /// Sequence completed; brief pause before the next level starts.
  levelComplete,

  /// Out of lives.
  gameOver,
}

/// Which visual feedback a tile should show right now.
enum TileHighlight { none, lit, correct, wrong }

/// Pure game state + rules for the memory sequence game. The UI listens and
/// renders; all timing (playback pacing, feedback flashes) lives here so the
/// widget layer stays dumb.
class MemoryGameController extends ChangeNotifier {
  MemoryGameController({Random? random, this.timeScale = 1.0})
      : _rng = random ?? Random();

  final Random _rng;

  /// Multiplier on all delays; tests can set this near zero.
  final double timeScale;

  static const int maxLives = 3;

  int level = 1;
  int lives = maxLives;
  int score = 0;
  GamePhase phase = GamePhase.showing;

  List<int> sequence = [];
  int inputIndex = 0;

  int? _highlightedTile;
  TileHighlight _highlightKind = TileHighlight.none;

  /// Bumped on every restart so stale async playback loops abort.
  int _generation = 0;
  bool _disposed = false;

  int get gridSize => level < 6 ? 3 : 4;
  int get tileCount => gridSize * gridSize;
  int get sequenceLength => level + 2;

  Duration get stepDuration => _scaled(max(280, 620 - 35 * (level - 1)));

  TileHighlight highlightFor(int tile) =>
      tile == _highlightedTile ? _highlightKind : TileHighlight.none;

  Duration _scaled(num milliseconds) =>
      Duration(milliseconds: max(1, (milliseconds * timeScale).round()));

  Future<void> startGame() async {
    _generation++;
    level = 1;
    lives = maxLives;
    score = 0;
    await _startLevel(newSequence: true);
  }

  /// Replays the current sequence without changing level or score, e.g.
  /// after a dialog covered the board during playback.
  Future<void> replaySequence() async {
    if (phase == GamePhase.gameOver || sequence.isEmpty) return;
    await _startLevel(newSequence: false);
  }

  Future<void> _startLevel({required bool newSequence}) async {
    final gen = _generation;
    if (newSequence) {
      sequence = List.generate(sequenceLength, (_) => _rng.nextInt(tileCount));
    }
    inputIndex = 0;
    phase = GamePhase.showing;
    _setHighlight(null, TileHighlight.none);

    await Future<void>.delayed(_scaled(650));
    if (_stale(gen)) return;

    for (final tile in sequence) {
      _setHighlight(tile, TileHighlight.lit);
      await Future<void>.delayed(stepDuration);
      if (_stale(gen)) return;
      _setHighlight(null, TileHighlight.none);
      await Future<void>.delayed(_scaled(120));
      if (_stale(gen)) return;
    }

    phase = GamePhase.awaitingInput;
    notifyListeners();
  }

  Future<void> onTileTap(int tile) async {
    if (phase != GamePhase.awaitingInput) return;
    final gen = _generation;

    if (tile == sequence[inputIndex]) {
      inputIndex++;
      score += 10 * level;
      _setHighlight(tile, TileHighlight.correct);

      if (inputIndex >= sequence.length) {
        phase = GamePhase.levelComplete;
        score += 50 * level;
        notifyListeners();
        await Future<void>.delayed(_scaled(900));
        if (_stale(gen)) return;
        level++;
        await _startLevel(newSequence: true);
        return;
      }

      await Future<void>.delayed(_scaled(200));
      if (_stale(gen)) return;
      // Only clear if no newer highlight replaced ours in the meantime.
      if (_highlightedTile == tile && _highlightKind == TileHighlight.correct) {
        _setHighlight(null, TileHighlight.none);
      }
      return;
    }

    // Wrong tile.
    lives--;
    _setHighlight(tile, TileHighlight.wrong);
    if (lives <= 0) {
      phase = GamePhase.gameOver;
      notifyListeners();
      return;
    }
    phase = GamePhase.showing;
    notifyListeners();
    await Future<void>.delayed(_scaled(700));
    if (_stale(gen)) return;
    // Replay the same sequence so the player gets another look.
    await _startLevel(newSequence: false);
  }

  void _setHighlight(int? tile, TileHighlight kind) {
    _highlightedTile = tile;
    _highlightKind = kind;
    notifyListeners();
  }

  bool _stale(int gen) => _disposed || gen != _generation;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
