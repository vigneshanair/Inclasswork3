import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5B6CFF),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),

        // Use *Data classes* for newer Flutter SDKs
        cardTheme: CardThemeData(
          elevation: 10,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sketch Emojis'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '🙂 Smiley'),
              Tab(text: '🥳 Celebrating'),
              Tab(text: '❤️ Heart'),
            ],
          ),
        ),
        body: const TabBarView(children: [SmileyTab(), PartyTab(), HeartTab()]),
      ),
    );
  }
}

/* ---------------------------- Common Shell ---------------------------- */

/// Gradient background + centered card.
/// Canvas is small to avoid "bottom overflowed" on short screens.
class CanvasShell extends StatelessWidget {
  final Widget controls;
  final CustomPainter painter;

  const CanvasShell({required this.controls, required this.painter, super.key});

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final side = min(
      shortest * 0.55,
      280.0,
    ); // tweak down if you still overflow

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFBFF), Color(0xFFF2F7FF), Color(0xFFEFFCF7)],
        ),
      ),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                controls,
                const SizedBox(height: 10),
                SizedBox(
                  width: side,
                  height: side,
                  child: CustomPaint(painter: painter),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveChips extends StatelessWidget {
  final List<String> labels;
  const ActiveChips(this.labels, {super.key});
  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: -8,
      children: labels
          .map(
            (s) => Chip(
              side: BorderSide(color: Colors.grey.shade300),
              label: Text(s),
            ),
          )
          .toList(),
    );
  }
}

/* ------------------------------- TAB 1 --------------------------------
   Smiley: dropdown toggles [Add Color], [Add Hair], [Add Ears]
   Yellow shows ONLY after "Add color" is selected.
--------------------------------------------------------------------------- */

enum SmileyOption { addColor, addHair, addEars }

class SmileyTab extends StatefulWidget {
  const SmileyTab({super.key});
  @override
  State<SmileyTab> createState() => _SmileyTabState();
}

class _SmileyTabState extends State<SmileyTab> {
  bool addColor = false; // OFF by default
  bool addHair = false;
  bool addEars = false;
  SmileyOption? _selected;

  void _applyOption(SmileyOption? opt) {
    if (opt == null) return;
    setState(() {
      switch (opt) {
        case SmileyOption.addColor:
          addColor = !addColor;
          break;
        case SmileyOption.addHair:
          addHair = !addHair;
          break;
        case SmileyOption.addEars:
          addEars = !addEars;
          break;
      }
      _selected = null; // reset to hint
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = <String>[
      if (addColor) 'Color: yellow',
      if (addHair) 'Hair',
      if (addEars) 'Ears',
    ];
    return CanvasShell(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Options:'),
              const SizedBox(width: 10),
              DropdownButton<SmileyOption>(
                hint: const Text('Choose…'),
                value: _selected,
                onChanged: _applyOption,
                items: const [
                  DropdownMenuItem(
                    value: SmileyOption.addColor,
                    child: Text('Add color'),
                  ),
                  DropdownMenuItem(
                    value: SmileyOption.addHair,
                    child: Text('Add hair'),
                  ),
                  DropdownMenuItem(
                    value: SmileyOption.addEars,
                    child: Text('Add ears'),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${active.length} active',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ActiveChips(active),
        ],
      ),
      painter: SketchSmileyPainter(
        addColor: addColor,
        addHair: addHair,
        addEars: addEars,
      ),
    );
  }
}

class SketchSmileyPainter extends CustomPainter {
  final bool addColor;
  final bool addHair;
  final bool addEars;

  SketchSmileyPainter({
    this.addColor = false,
    this.addHair = false,
    this.addEars = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // --- FIXED ORDER ---
    // 1) (Optional) tiny white pad BEHIND everything (keeps edges crisp)
    final pad = Paint()..color = Colors.white;
    canvas.drawCircle(c, r + 2, pad);

    // 2) Face fill (yellow) only if requested
    if (addColor) {
      final faceFill = Paint()..color = const Color(0xFFFFE066);
      canvas.drawCircle(c, r, faceFill);
    }

    // 3) Ears (behind ring look)
    if (addEars) {
      final earPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08;
      final earR = r * 0.26;
      canvas.drawCircle(c.translate(-r * 0.88, -r * 0.05), earR, earPaint);
      canvas.drawCircle(c.translate(r * 0.88, -r * 0.05), earR, earPaint);
    }

    // 4) Outer ring
    final ring = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, ring);

    // Hair
    if (addHair) {
      final hair = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round;
      final top = c.translate(0, -r * 0.95);
      canvas.drawArc(
        Rect.fromCenter(
          center: top.translate(-r * 0.28, 0),
          width: r * 0.7,
          height: r * 0.5,
        ),
        pi * 0.95,
        -pi * 0.35,
        false,
        hair,
      );
      canvas.drawArc(
        Rect.fromCenter(center: top, width: r * 0.7, height: r * 0.5),
        pi * 0.98,
        -pi * 0.35,
        false,
        hair,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: top.translate(r * 0.28, 0),
          width: r * 0.7,
          height: r * 0.5,
        ),
        pi * 1.01,
        -pi * 0.35,
        false,
        hair,
      );
    }

    // Eyes
    final eye = Paint()..color = Colors.black;
    final eyeX = r * 0.36;
    final eyeY = -r * 0.12;
    final eyeW = r * 0.17;
    final eyeH = r * 0.28;
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(-eyeX, eyeY),
        width: eyeW,
        height: eyeH,
      ),
      eye,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(eyeX, eyeY),
        width: eyeW,
        height: eyeH,
      ),
      eye,
    );

    // Smile + subtle tips
    final smileRect = Rect.fromCircle(
      center: c.translate(0, r * 0.05),
      radius: r * 0.66,
    );
    final smile = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(smileRect, pi * 0.15, pi * 0.70, false, smile);

    final tip = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(smileRect, pi * 0.12, pi * 0.06, false, tip);
    canvas.drawArc(smileRect, pi * 0.79, pi * 0.06, false, tip);
  }

  @override
  bool shouldRepaint(covariant SketchSmileyPainter old) =>
      old.addColor != addColor ||
      old.addHair != addHair ||
      old.addEars != addEars;
}

/* ------------------------------- TAB 2 --------------------------------
   Party: dropdown toggles [Add Color], [Add Background Color], [Add Ears]
   Yellow shows ONLY after "Add color" is selected.
--------------------------------------------------------------------------- */

enum PartyOption { addColor, addBgColor, addEars }

class PartyTab extends StatefulWidget {
  const PartyTab({super.key});
  @override
  State<PartyTab> createState() => _PartyTabState();
}

class _PartyTabState extends State<PartyTab> {
  bool addColor = false; // OFF by default
  bool addBg = false;
  bool addEars = false;
  PartyOption? _selected;

  void _applyOption(PartyOption? opt) {
    if (opt == null) return;
    setState(() {
      switch (opt) {
        case PartyOption.addColor:
          addColor = !addColor;
          break;
        case PartyOption.addBgColor:
          addBg = !addBg;
          break;
        case PartyOption.addEars:
          addEars = !addEars;
          break;
      }
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = <String>[
      if (addColor) 'Color: yellow',
      if (addBg) 'Background',
      if (addEars) 'Ears',
    ];
    return CanvasShell(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Options:'),
              const SizedBox(width: 10),
              DropdownButton<PartyOption>(
                hint: const Text('Choose…'),
                value: _selected,
                onChanged: _applyOption,
                items: const [
                  DropdownMenuItem(
                    value: PartyOption.addColor,
                    child: Text('Add color'),
                  ),
                  DropdownMenuItem(
                    value: PartyOption.addBgColor,
                    child: Text('Add background color'),
                  ),
                  DropdownMenuItem(
                    value: PartyOption.addEars,
                    child: Text('Add ears'),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${active.length} active',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ActiveChips(active),
        ],
      ),
      painter: PartyCelebrationPainter(
        addColor: addColor,
        addBg: addBg,
        addEars: addEars,
      ),
    );
  }
}

class PartyCelebrationPainter extends CustomPainter {
  final bool addColor;
  final bool addBg;
  final bool addEars;

  PartyCelebrationPainter({
    this.addColor = false,
    this.addBg = false,
    this.addEars = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.36;

    // Optional local background
    if (addBg) {
      final bg = Paint()..color = const Color(0xFFEFF7FF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
        bg,
      );
    }

    // --- FIXED ORDER ---
    // 1) tiny white pad behind
    final pad = Paint()..color = Colors.white;
    canvas.drawCircle(c, r + 2, pad);

    // 2) Yellow face fill only if requested
    if (addColor) {
      final fill = Paint()..color = const Color(0xFFFFE066);
      canvas.drawCircle(c, r, fill);
    }

    // 3) Ears (if any)
    if (addEars) {
      final earPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08;
      final earR = r * 0.24;
      canvas.drawCircle(c.translate(-r * 0.88, -r * 0.00), earR, earPaint);
      canvas.drawCircle(c.translate(r * 0.88, -r * 0.00), earR, earPaint);
    }

    // 4) Outer ring
    final ring = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, ring);

    // Eyes (closed)
    final eyeStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.055
      ..strokeCap = StrokeCap.round;
    final left = Path()
      ..moveTo(c.dx - r * 0.42, c.dy - r * 0.10)
      ..quadraticBezierTo(
        c.dx - r * 0.30,
        c.dy - r * 0.24,
        c.dx - r * 0.16,
        c.dy - r * 0.10,
      );
    final right = Path()
      ..moveTo(c.dx + r * 0.16, c.dy - r * 0.10)
      ..quadraticBezierTo(
        c.dx + r * 0.30,
        c.dy - r * 0.24,
        c.dx + r * 0.42,
        c.dy - r * 0.10,
      );
    canvas.drawPath(left, eyeStroke);
    canvas.drawPath(right, eyeStroke);

    // Party hat + pom
    final hat = Path()
      ..moveTo(c.dx, c.dy - r * 1.06)
      ..lineTo(c.dx - r * 0.58, c.dy - r * 0.20)
      ..lineTo(c.dx + r * 0.58, c.dy - r * 0.20)
      ..close();
    final hatStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.055
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hat, hatStroke);
    canvas.drawCircle(
      Offset(c.dx, c.dy - r * 1.08),
      r * 0.06,
      Paint()..color = Colors.black,
    );

    // Party blower + spiral
    final tube = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.075
      ..strokeCap = StrokeCap.round;
    final mouth = c.translate(0, r * 0.12);
    final tubePath = Path()
      ..moveTo(mouth.dx, mouth.dy)
      ..quadraticBezierTo(
        mouth.dx + r * 0.24,
        mouth.dy - r * 0.02,
        mouth.dx + r * 0.45,
        mouth.dy + r * 0.02,
      );
    canvas.drawPath(tubePath, tube);

    final spiral = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.055
      ..strokeCap = StrokeCap.round;
    final bx = mouth.dx + r * 0.45;
    final by = mouth.dy + r * 0.02;
    for (int i = 0; i < 3; i++) {
      final w = r * (0.28 - i * 0.06);
      final h = r * (0.18 - i * 0.045);
      final rect = Rect.fromCenter(
        center: Offset(bx + r * (0.04 + i * 0.02), by),
        width: w,
        height: h,
      );
      canvas.drawArc(rect, 0, pi * 1.2, false, spiral);
    }

    // Confetti wiggles
    final wiggle = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.045
      ..strokeCap = StrokeCap.round;
    final rnd = Random(9);
    for (int i = 0; i < 12; i++) {
      final ang = (i / 12.0) * 2 * pi + rnd.nextDouble() * 0.2;
      final dist = r * (0.95 + rnd.nextDouble() * 0.18);
      final p = c + Offset(cos(ang) * dist, sin(ang) * dist);
      final s = r * 0.16;
      final rect = Rect.fromCenter(center: p, width: s, height: s * 0.58);
      final start = (i.isEven) ? pi * 0.10 : pi * 1.10;
      canvas.drawArc(rect, start, pi * 0.65, false, wiggle);
    }
  }

  @override
  bool shouldRepaint(covariant PartyCelebrationPainter old) =>
      old.addColor != addColor || old.addBg != addBg || old.addEars != addEars;
}

/* ------------------------------- TAB 3 --------------------------------
   Heart: dropdown toggles [Add Background Color Red]
   Default HEART FILL = RED
--------------------------------------------------------------------------- */

enum HeartOption { addBgRed }

class HeartTab extends StatefulWidget {
  const HeartTab({super.key});
  @override
  State<HeartTab> createState() => _HeartTabState();
}

class _HeartTabState extends State<HeartTab> {
  bool addBgRed = false; // background red (toggle)
  HeartOption? _selected;

  void _applyOption(HeartOption? opt) {
    if (opt == null) return;
    setState(() {
      if (opt == HeartOption.addBgRed) addBgRed = !addBgRed;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = <String>[if (addBgRed) 'Background: red'];
    return CanvasShell(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Options:'),
              const SizedBox(width: 10),
              DropdownButton<HeartOption>(
                hint: const Text('Choose…'),
                value: _selected,
                onChanged: _applyOption,
                items: const [
                  DropdownMenuItem(
                    value: HeartOption.addBgRed,
                    child: Text('Add background color red'),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${active.length} active',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ActiveChips(active),
        ],
      ),
      painter: HeartPainter(
        addBgRed: addBgRed,
        fillRed: true,
      ), // red fill is default
    );
  }
}

class HeartPainter extends CustomPainter {
  final bool addBgRed;
  final bool fillRed; // red fill for heart
  HeartPainter({this.addBgRed = false, this.fillRed = true});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide * 0.36;

    if (addBgRed) {
      final bg = Paint()..color = const Color(0xFFFFE5E8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
        bg,
      );
    }

    // Heart path
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.25)
      ..cubicTo(
        c.dx + s * 0.5,
        c.dy - s * 0.3,
        c.dx + s,
        c.dy + s * 0.35,
        c.dx,
        c.dy + s,
      )
      ..cubicTo(
        c.dx - s,
        c.dy + s * 0.35,
        c.dx - s * 0.5,
        c.dy - s * 0.3,
        c.dx,
        c.dy + s * 0.25,
      )
      ..close();

    // Default: fill red
    if (fillRed) {
      final fill = Paint()..color = const Color(0xFFE53935);
      canvas.drawPath(path, fill);
    }

    // Outline
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.10
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(covariant HeartPainter old) =>
      old.addBgRed != addBgRed || old.fillRed != fillRed;
}
