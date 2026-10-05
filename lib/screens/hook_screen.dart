import 'package:flutter/material.dart';

/// Charismatic 4-page onboarding intro shown before the waiver. Identical
/// in content/structure to the DartPad prototype â€” purely presentational,
/// no backend dependency.
class HookScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const HookScreen({super.key, required this.onContinue});

  @override
  State<HookScreen> createState() => _HookScreenState();
}

class _HookScreenState extends State<HookScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const _pages = [
    {
      'gradient': [Color(0xFF0D1B2A), Color(0xFF134E4A)],
      'emoji': 'ðŸ”¥',
      'title': "Your Comeback\nStarts Right Now.",
      'subtitle': "Real training for real bodies â€” built around YOUR sport AND your condition, not despite them. No judgment. No cookie-cutter plans. Just progress.",
    },
    {
      'gradient': [Color(0xFF134E4A), Color(0xFF1B3A4B)],
      'emoji': 'ðŸ‘¥',
      'title': "Meet Your\nDream Team.",
      'subtitle': "ðŸ”¥ Brendan for wellness & strength.\nðŸ’™ Justin for conditioning & endurance.\nâš¡ Cameron for power & strength.\nðŸŒŠ Bell for recovery & endurance.\n\nFour coaches. Zero ego. All heart.",
    },
    {
      'gradient': [Color(0xFF1B3A4B), Color(0xFF0F2C3A)],
      'emoji': 'âš¡',
      'title': "Built Around\nYOU. Every Day.",
      'subtitle': "Tell us how you're feeling â€” your energy, your pain, your sport or condition â€” and your routine adapts instantly. Smart enough to push you. Caring enough to know when to pull back.",
    },
    {
      'gradient': [Color(0xFF1A237E), Color(0xFF4A148C)],
      'emoji': '✝️',
      'title': "Strengthen Your\nTemple.",
      'subtitle': "\"Do you not know that your bodies are temples of the Holy Spirit?\"\n— 1 Corinthians 6:19\n\nGetFit4Me was built on the belief that honoring God starts with how you treat the body He gave you. Let's train with purpose.",
    },
    {
      'gradient': [Color(0xFF0F2C3A), Color(0xFF0D1B2A)],
      'emoji': '🚀',
      'title': "Today Is the\nDay Things Change.",
      'subtitle': "Millions of people are waiting for 'someday.'\n\nYou don't have to. Your team is ready, your plan is ready â€” let's go meet them.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    final colors = _pages[_page]['gradient'] as List<Color>;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: widget.onContinue,
                  child: Text('Skip', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey('emoji_$i'),
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (ctx, scale, child) => Transform.scale(scale: scale, child: child),
                        child: Text(page['emoji'] as String, style: const TextStyle(fontSize: 64)),
                      ),
                      const SizedBox(height: 24),
                      Text(page['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.5)),
                      const SizedBox(height: 20),
                      Text(page['subtitle'] as String, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 15, height: 1.6)),
                    ]),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: active ? const Color(0xFF1DE9B6) : Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(4)),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: _next,
                  child: Text(isLast ? "Let's Go! ðŸš€" : 'Next', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

