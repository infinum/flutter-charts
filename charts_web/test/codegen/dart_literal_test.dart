import 'package:charts_web/codegen/dart_literal.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('colorLiteral emits an opaque 32-bit ARGB literal', () {
    expect(colorLiteral(const Color(0xFFD8262C)), 'Color(0xFFD8262C)');
    expect(colorLiteral(const Color(0x0A000000)), 'Color(0x0A000000)');
  });

  test('doubleLiteral always reads as a double', () {
    expect(doubleLiteral(2), '2.0');
    expect(doubleLiteral(2.5), '2.5');
    expect(doubleLiteral(-3), '-3.0');
  });

  test('edgeInsetsLiteral picks the shortest accurate form', () {
    expect(edgeInsetsLiteral(EdgeInsets.zero), 'EdgeInsets.zero');
    expect(edgeInsetsLiteral(const EdgeInsets.all(4)), 'EdgeInsets.all(4.0)');
    expect(
      edgeInsetsLiteral(const EdgeInsets.symmetric(horizontal: 2)),
      'EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0)',
    );
    expect(
      edgeInsetsLiteral(const EdgeInsets.only(left: 1, bottom: 3)),
      'EdgeInsets.only(left: 1.0, top: 0.0, right: 0.0, bottom: 3.0)',
    );
  });

  test('borderRadiusLiteral picks the shortest accurate form', () {
    expect(borderRadiusLiteral(BorderRadius.zero), 'BorderRadius.zero');
    expect(
      borderRadiusLiteral(BorderRadius.circular(8)),
      'BorderRadius.all(Radius.circular(8.0))',
    );
    expect(
      borderRadiusLiteral(
          const BorderRadius.vertical(top: Radius.circular(6))),
      'BorderRadius.vertical(top: Radius.circular(6.0), '
      'bottom: Radius.circular(0.0))',
    );
  });

  test('borderSideLiteral collapses the none case', () {
    expect(borderSideLiteral(BorderSide.none), 'BorderSide.none');
    expect(
      borderSideLiteral(const BorderSide(color: Color(0xFF112233), width: 2)),
      'BorderSide(color: Color(0xFF112233), width: 2.0)',
    );
  });

  test('alignmentLiteral prefers the named constants', () {
    expect(alignmentLiteral(Alignment.centerLeft), 'Alignment.centerLeft');
    expect(
        alignmentLiteral(const Alignment(0.25, -0.5)), 'Alignment(0.25, -0.5)');
  });

  test('gradientLiteral emits colors, begin and end', () {
    expect(
      gradientLiteral(const LinearGradient(
        colors: [Color(0xFFD8262C), Color(0xFF000000)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      )),
      'LinearGradient(colors: [Color(0xFFD8262C), Color(0xFF000000)], '
      'begin: Alignment.centerLeft, end: Alignment.centerRight)',
    );
  });
}
