import 'package:flutter/painting.dart';

/// Emits `Color(0xAARRGGBB)`. Uses `toARGB32()`; the per-channel getters
/// (`.alpha`, `.red`, ...) have been deprecated since Flutter 3.27.
String colorLiteral(Color color) {
  final argb = color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');

  return 'Color(0x$argb)';
}

/// Always renders as a Dart double, so `2` never lands in an `int` parameter.
String doubleLiteral(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(1) : '$value';

String edgeInsetsLiteral(EdgeInsets insets) {
  if (insets == EdgeInsets.zero) return 'EdgeInsets.zero';

  if (insets.left == insets.right && insets.top == insets.bottom) {
    if (insets.left == insets.top) {
      return 'EdgeInsets.all(${doubleLiteral(insets.left)})';
    }

    return 'EdgeInsets.symmetric(horizontal: ${doubleLiteral(insets.left)}, '
        'vertical: ${doubleLiteral(insets.top)})';
  }

  return 'EdgeInsets.only(left: ${doubleLiteral(insets.left)}, '
      'top: ${doubleLiteral(insets.top)}, '
      'right: ${doubleLiteral(insets.right)}, '
      'bottom: ${doubleLiteral(insets.bottom)})';
}

String radiusLiteral(Radius radius) => radius.x == radius.y
    ? 'Radius.circular(${doubleLiteral(radius.x)})'
    : 'Radius.elliptical(${doubleLiteral(radius.x)}, '
        '${doubleLiteral(radius.y)})';

String borderRadiusLiteral(BorderRadius radius) {
  if (radius == BorderRadius.zero) return 'BorderRadius.zero';

  final topLeft = radius.topLeft;
  final topRight = radius.topRight;
  final bottomLeft = radius.bottomLeft;
  final bottomRight = radius.bottomRight;

  if (topLeft == topRight &&
      topRight == bottomLeft &&
      bottomLeft == bottomRight) {
    return 'BorderRadius.all(${radiusLiteral(topLeft)})';
  }

  if (topLeft == topRight && bottomLeft == bottomRight) {
    return 'BorderRadius.vertical(top: ${radiusLiteral(topLeft)}, '
        'bottom: ${radiusLiteral(bottomLeft)})';
  }

  if (topLeft == bottomLeft && topRight == bottomRight) {
    return 'BorderRadius.horizontal(left: ${radiusLiteral(topLeft)}, '
        'right: ${radiusLiteral(topRight)})';
  }

  return 'BorderRadius.only(topLeft: ${radiusLiteral(topLeft)}, '
      'topRight: ${radiusLiteral(topRight)}, '
      'bottomLeft: ${radiusLiteral(bottomLeft)}, '
      'bottomRight: ${radiusLiteral(bottomRight)})';
}

String borderSideLiteral(BorderSide side) => side == BorderSide.none
    ? 'BorderSide.none'
    : 'BorderSide(color: ${colorLiteral(side.color)}, '
        'width: ${doubleLiteral(side.width)})';

// Not const: Alignment overrides ==, which const map keys may not do.
final Map<Alignment, String> _namedAlignments = {
  Alignment.topLeft: 'Alignment.topLeft',
  Alignment.topCenter: 'Alignment.topCenter',
  Alignment.topRight: 'Alignment.topRight',
  Alignment.centerLeft: 'Alignment.centerLeft',
  Alignment.center: 'Alignment.center',
  Alignment.centerRight: 'Alignment.centerRight',
  Alignment.bottomLeft: 'Alignment.bottomLeft',
  Alignment.bottomCenter: 'Alignment.bottomCenter',
  Alignment.bottomRight: 'Alignment.bottomRight',
};

String alignmentLiteral(AlignmentGeometry alignment) {
  if (alignment is! Alignment) return 'Alignment.center';

  return _namedAlignments[alignment] ??
      'Alignment(${doubleLiteral(alignment.x)}, ${doubleLiteral(alignment.y)})';
}

String gradientLiteral(LinearGradient gradient) {
  final parts = <String>[
    'colors: [${gradient.colors.map(colorLiteral).join(', ')}]',
    'begin: ${alignmentLiteral(gradient.begin)}',
    'end: ${alignmentLiteral(gradient.end)}',
  ];

  final stops = gradient.stops;
  if (stops != null) {
    parts.add('stops: [${stops.map(doubleLiteral).join(', ')}]');
  }

  return 'LinearGradient(${parts.join(', ')})';
}
