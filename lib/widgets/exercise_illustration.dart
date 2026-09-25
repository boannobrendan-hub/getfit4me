import 'package:flutter/material.dart';
import 'dart:math';

/// Movement archetypes used to categorize exercises for both the vector
/// fallback illustration and (eventually) video asset lookup.
enum ExCat { squat, pushup, plank, lunge, row, press, jump, balance, carry, rotation, bridge, stretch, cardio, generic }

ExCat categorizeExercise(String name) {
  final n = name.toLowerCase();
  if (n.contains('squat')) return ExCat.squat;
  if (n.contains('push-up') || n.contains('push up') || n.contains('renegade')) return ExCat.pushup;
  if (n.contains('plank') || n.contains('hollow') || n.contains('dead bug') || n.contains('deadbug') || n.contains('bird-dog') || n.contains('bird dog') || n.contains('anti-rotation')) return ExCat.plank;
  if (n.contains('lunge') || n.contains('step-up') || n.contains('step up')) return ExCat.lunge;
  if (n.contains('row') || n.contains('pulldown') || n.contains('pull-apart') || n.contains('pull apart') || n.contains('face pull') || n.contains('wall slide')) return ExCat.row;
  if (n.contains('press') || n.contains('curl')) return ExCat.press;
  if (n.contains('jump') || n.contains('bound') || n.contains('hop')) return ExCat.jump;
  if (n.contains('balance') || n.contains('clamshell') || n.contains('abduction') || n.contains('calf raise') || n.contains('heel raise')) return ExCat.balance;
  if (n.contains('carry') || n.contains('farmer')) return ExCat.carry;
  if (n.contains('rotation') || n.contains('twist') || n.contains('slam') || n.contains('throw') || n.contains('separation')) return ExCat.rotation;
  if (n.contains('bridge') || n.contains('deadlift') || n.contains('hinge')) return ExCat.bridge;
  if (n.contains('breath') || n.contains('stretch') || n.contains('mobility') || n.contains('cat-cow') || n.contains('cat cow') || n.contains('foam roller')) return ExCat.stretch;
  if (n.contains('walk') || n.contains('cycling') || n.contains('shuffle') || n.contains('shadow') || n.contains('burpee') || n.contains('drill') || n.contains('march') || n.contains('skip') || n.contains('stride') || n.contains('taps')) return ExCat.cardio;
  return ExCat.generic;
}

const Map<ExCat, String> exCatLabel = {
  ExCat.squat: 'Squat Pattern',
  ExCat.pushup: 'Push-Up Pattern',
  ExCat.plank: 'Core Stability',
  ExCat.lunge: 'Lunge / Split Stance',
  ExCat.row: 'Pulling Pattern',
  ExCat.press: 'Pressing Pattern',
  ExCat.jump: 'Explosive / Plyometric',
  ExCat.balance: 'Balance & Stability',
  ExCat.carry: 'Loaded Carry',
  ExCat.rotation: 'Rotational Power',
  ExCat.bridge: 'Hip Hinge / Bridge',
  ExCat.stretch: 'Mobility & Recovery',
  ExCat.cardio: 'Cardio / Movement Drill',
  ExCat.generic: 'General Movement',
};

// ── VIDEO INTEGRATION (production only — see README.md) ────────────────────
// Add `video_player: ^2.9.2` (already in pubspec.yaml) and fill in this map
// with asset paths once you've filmed demo clips. Until filled in, every
// exercise falls back to the vector START/FINISH illustration below, so the
// app always shows something useful.
const Map<ExCat, String> videoAssetForCategory = {
  // ExCat.squat: 'assets/exercise_videos/squat.mp4',
  // ExCat.pushup: 'assets/exercise_videos/pushup.mp4',
  // ... add the rest as you film them
};

/// Renders either a real demo video (if configured) or a two-panel
/// START/FINISH vector illustration as a safety-net fallback.
class ExerciseIllustration extends StatelessWidget {
  final String exerciseName;
  final Color color;
  const ExerciseIllustration({super.key, required this.exerciseName, required this.color});

  @override
  Widget build(BuildContext context) {
    final cat = categorizeExercise(exerciseName);
    // TODO (production): if videoAssetForCategory[cat] is non-null, play it
    // with video_player here (looped, muted by default), falling back to
    // the CustomPaint illustration below on load failure. See the DartPad
    // prototype's _ExerciseIllustrationState comments for the exact
    // VideoPlayerController wiring.

    return Container(
      width: double.infinity,
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Stack(children: [
        Positioned.fill(
          child: SizedBox.expand(child: CustomPaint(painter: _StickFigurePainter(category: cat, color: color))),
        ),
        Positioned(
          left: 12,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(exCatLabel[cat]!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Row(children: [
            Expanded(child: Center(child: _stepChip('START', color))),
            Expanded(child: Center(child: _stepChip('FINISH', color))),
          ]),
        ),
      ]),
    );
  }

  Widget _stepChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
    );
  }
}

class _StickFigurePainter extends CustomPainter {
  final ExCat category;
  final Color color;
  const _StickFigurePainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.height;
    final double panelW = size.width / 2;
    final double offsetX0 = (panelW - s) / 2;
    final double offsetX1 = panelW + (panelW - s) / 2;

    Offset pp(int panel, double x, double y) {
      final ox = panel == 0 ? offsetX0 : offsetX1;
      return Offset(ox + x * s, y * s);
    }

    final shirt = Paint()..color = color..style = PaintingStyle.fill;
    final shortsColor = Color.lerp(color, Colors.black, 0.32)!;
    final limbColor = Color.lerp(color, Colors.black, 0.14)!;
    final skinColor = Color.lerp(color, Colors.white, 0.55)!;
    final shorts = Paint()..color = shortsColor..style = PaintingStyle.fill;
    final limb = Paint()..color = limbColor..style = PaintingStyle.fill;
    final skin = Paint()..color = skinColor..style = PaintingStyle.fill;
    final joint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final floor = Paint()..color = Colors.grey.shade300;
    final shadow = Paint()..color = Colors.black.withOpacity(0.08);
    final divider = Paint()..color = Colors.grey.shade300..strokeWidth = 1;

    canvas.drawLine(Offset(panelW, s * 0.06), Offset(panelW, s * 0.96), divider);

    void cap(int panel, double x1, double y1, double x2, double y2, double wFrac, Paint paint) {
      final a = pp(panel, x1, y1);
      final b = pp(panel, x2, y2);
      final len = (b - a).distance;
      final ang = (b - a).direction;
      final w = s * wFrac;
      canvas.save();
      canvas.translate(a.dx, a.dy);
      canvas.rotate(ang);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w / 2, -w / 2, len + w, w), Radius.circular(w / 2)), paint);
      canvas.restore();
    }

    void jointDot(int panel, double x, double y) => canvas.drawCircle(pp(panel, x, y), s * 0.026, joint);
    void hand(int panel, double x, double y, [Paint? paint]) => canvas.drawCircle(pp(panel, x, y), s * 0.038, paint ?? skin);

    void head(int panel, double x, double y, {double facing = 1}) {
      canvas.drawCircle(pp(panel, x, y), s * 0.072, skin);
      canvas.drawArc(Rect.fromCenter(center: pp(panel, x, y - 0.005), width: s * 0.15, height: s * 0.15), pi, pi, true, shirt);
      canvas.drawCircle(pp(panel, x + facing * 0.022, y - 0.005), s * 0.011, Paint()..color = Colors.black87);
    }

    void groundLine(int panel) => canvas.drawRect(Rect.fromLTRB(panel == 0 ? 0 : panelW, s * 0.94, panel == 0 ? panelW : size.width, s * 1.0), floor);
    void shadowOval(int panel, double cx, double wFrac) => canvas.drawOval(Rect.fromCenter(center: pp(panel, cx, 0.965), width: s * wFrac, height: s * 0.03), shadow);

    // Generic two-pose silhouette — sufficient as a safety-net illustration
    // across all categories. (For the full 14-category detail set with
    // equipment, see the DartPad prototype's _StickFigurePainter.)
    for (final panel in [0, 1]) {
      groundLine(panel);
      shadowOval(panel, 0.5, 0.5);
      final bend = panel == 1 ? 0.08 : 0.0;
      cap(panel, 0.5, 0.21, 0.5, 0.6 - bend, 0.115, shirt);
      cap(panel, 0.5, 0.6 - bend, 0.4, 0.9, 0.078, shorts);
      hand(panel, 0.4, 0.92);
      cap(panel, 0.5, 0.6 - bend, 0.6, 0.9, 0.078, shorts);
      hand(panel, 0.6, 0.92);
      cap(panel, 0.5, 0.27, 0.3, 0.46 + bend, 0.062, limb);
      hand(panel, 0.29, 0.48 + bend);
      cap(panel, 0.5, 0.27, 0.7, 0.46 + bend, 0.062, limb);
      hand(panel, 0.71, 0.48 + bend);
      jointDot(panel, 0.5, 0.6 - bend);
      head(panel, 0.5, 0.14);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
