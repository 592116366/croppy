import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoKnobButton extends StatelessWidget {
  const CupertinoKnobButton({
    super.key,
    required this.isActive,
    required this.isPositive,
    required this.onPressed,
    required this.child,
    this.progressPainter,
  });

  final bool isActive;
  final bool isPositive;
  final VoidCallback onPressed;
  final Widget child;
  final CustomPainter? progressPainter;

  @override
  Widget build(BuildContext context) {
    final color =
        isPositive ? CupertinoColors.systemYellow : CupertinoColors.white;

    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minSize: 40.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        opacity: isActive ? 1.0 : 0.5,
        child: CustomPaint(
          foregroundPainter: progressPainter,
          child: Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
              border: Border.all(
                width: 2.0,
                color: color.withOpacity(0.35),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class CupertinoKnob extends StatelessWidget {
  const CupertinoKnob({
    super.key,
    required this.value,
    required this.extent,
    required this.onChanged,
    required this.inactiveChild,
  });

  final double value;
  final double extent;
  final ValueChanged<double> onChanged;
  final Widget inactiveChild;

  @override
  Widget build(BuildContext context) {
    final isActive = value != 0.0;
    final isPositive = value > 0.0;

    final color =
        isPositive ? CupertinoColors.systemYellow : CupertinoColors.white;

    late final Widget child;

    if (value == 0.0) {
      child = Icon(
        Icons.straighten_rounded,
        color: color,
        size: 16.0,
      );
    } else {
      child = Text(
        value.round().toString(),
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 14.0,
              color: color,
            ),
      );
    }

    return CupertinoKnobButton(
      isActive: isActive,
      isPositive: isPositive,
      onPressed: () => onChanged(0.0),
      progressPainter: _CupertinoKnobProgressPainter(value / extent),
      child: child,
    );
  }
}

class _CupertinoKnobProgressPainter extends CustomPainter {
  _CupertinoKnobProgressPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = value > 0 ? CupertinoColors.systemYellow : Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      (Offset.zero & size).deflate(1.0),
      -pi / 2,
      value * (2 * pi),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CupertinoKnobProgressPainter oldDelegate) => true;
}