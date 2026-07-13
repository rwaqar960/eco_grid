import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../game/memory_page.dart';
import '../services/high_score_store.dart';

const _shareText = 'Can you beat my memory in Echo Grid? '
    'https://github.com/rwaqar960/eco_grid';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final HighScoreStore _store = HighScoreStore();
  int _bestScore = 0;
  int _bestLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final (score, level) = await _store.load();
    if (!mounted) return;
    setState(() {
      _bestScore = score;
      _bestLevel = level;
    });
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MemoryPage()),
    );
    // Refresh best score when the player comes back from a run.
    _loadBest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LogoMark(),
                  const SizedBox(height: 18),
                  const Text(
                    'Echo Grid',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Watch the pattern. Echo it back.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  _BestScoreCard(score: _bestScore, level: _bestLevel),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _play,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Play'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showInstructions(context),
                          icon: const Icon(Icons.help_outline, size: 20),
                          label: const Text('How to play'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              SharePlus.instance.share(
                                ShareParams(text: _shareText),
                              ),
                          icon: const Icon(Icons.share_outlined, size: 20),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B2029),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _InstructionsSheet(),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 88,
        height: 88,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final color in _colors)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  const _BestScoreCard({required this.score, required this.level});

  final int score;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('Best score', score > 0 ? '$score' : '—'),
          Container(width: 1, height: 36, color: Colors.white12),
          _stat('Best level', level > 0 ? '$level' : '—'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _InstructionsSheet extends StatelessWidget {
  const _InstructionsSheet();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.visibility_outlined, 'Watch the tiles light up in a sequence.'),
      (Icons.touch_app_outlined, 'Tap the tiles back in the same order.'),
      (Icons.trending_up, 'Each level adds a step and speeds up. '
          'At level 6 the grid grows to 4x4.'),
      (Icons.favorite_border, 'You have 3 lives. A wrong tap costs one, '
          'but the sequence replays so you get another look.'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          for (final (icon, text) in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.amberAccent, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
