import 'package:flutter/material.dart';

class CardWithTitleBorderPainter extends CustomPainter {
  final String title;
  final TextStyle titleStyle;
  final Color borderColor;
  final double borderRadius;

  CardWithTitleBorderPainter({
    required this.title,
    required this.titleStyle,
    required this.borderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    /*final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );*/

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double textWidth = textPainter.width;
    final double textHeight = textPainter.height;
    const double textPadding = 8.0;

    final Path path = Path()
      ..moveTo(borderRadius, 0)
      ..lineTo((size.width - textWidth) / 2 - textPadding, 0)
      ..moveTo((size.width + textWidth) / 2 + textPadding, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..arcToPoint(Offset(size.width, borderRadius),
          radius: Radius.circular(borderRadius))
      ..lineTo(size.width, size.height - borderRadius)
      ..arcToPoint(Offset(size.width - borderRadius, size.height),
          radius: Radius.circular(borderRadius))
      ..lineTo(borderRadius, size.height)
      ..arcToPoint(Offset(0, size.height - borderRadius),
          radius: Radius.circular(borderRadius))
      ..lineTo(0, borderRadius)
      ..arcToPoint(Offset(borderRadius, 0), radius: Radius.circular(borderRadius));

    canvas.drawPath(path, paint);

    textPainter.paint(
        canvas, Offset((size.width - textWidth) / 2, -textHeight / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class CardWithTitle extends StatelessWidget {
  final String title;
  final Widget child;
  final Color blockColor;
  final RoundedRectangleBorder shape;
  final Color color;

  const CardWithTitle({
    required this.title,
    required this.color,
    required this.shape, 
    required this.child,
    required this.blockColor,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      color: blockColor,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return Stack(
      children: [
        CustomPaint(
          painter: CardWithTitleBorderPainter(
            title: title,
            titleStyle: titleStyle,
            borderColor: blockColor,
            borderRadius: 12.0,
          ),
          child: Card(
                color: color,
                child: child),
      )]);
    
          //);
  }
}
