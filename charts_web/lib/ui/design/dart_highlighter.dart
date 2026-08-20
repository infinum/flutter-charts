import 'package:material_ui/material_ui.dart';

/// Colours for the code surfaces, derived from the active Material scheme so
/// code reads correctly in both light and dark.
class DartCodeScheme {
  const DartCodeScheme({
    required this.base,
    required this.keyword,
    required this.type,
    required this.number,
    required this.string,
    required this.comment,
  });

  factory DartCodeScheme.of(ColorScheme scheme) => DartCodeScheme(
        base: scheme.onSurface,
        keyword: scheme.primary,
        type: scheme.tertiary,
        // Literals share one colour on purpose: numbers and strings are the
        // same kind of thing, and it keeps types visually distinct.
        number: scheme.secondary,
        string: scheme.secondary,
        comment: scheme.onSurfaceVariant,
      );

  final Color base;
  final Color keyword;
  final Color type;
  final Color number;
  final Color string;
  final Color comment;
}

const Set<String> _keywords = {
  'as', 'await', 'class', 'const', 'else', 'enum', 'extends', 'false', 'final',
  'for', 'if', 'import', 'in', 'is', 'new', 'null', 'return', 'super', 'switch',
  'this', 'true', 'var', 'void', 'while',
};

final RegExp _tokenPattern = RegExp(
  r"(?<comment>//[^\n]*)"
  r"|(?<string>'(?:[^'\\\n]|\\.)*')"
  r'|(?<hex>\b0[xX][0-9a-fA-F]+\b)'
  r'|(?<number>\b\d+(?:\.\d+)?\b)'
  r'|(?<type>\b[A-Z][A-Za-z0-9_]*\b)'
  r'|(?<word>\b[a-z_][A-Za-z0-9_]*\b)',
);

/// Splits [source] into styled spans. Concatenating the spans always
/// reproduces [source] byte for byte.
List<TextSpan> highlightDart(String source, DartCodeScheme scheme) {
  final spans = <TextSpan>[];
  var cursor = 0;

  void plain(String text) {
    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: TextStyle(color: scheme.base)));
    }
  }

  for (final match in _tokenPattern.allMatches(source)) {
    plain(source.substring(cursor, match.start));
    cursor = match.end;

    final text = match[0]!;
    final color = switch (match) {
      _ when match.namedGroup('comment') != null => scheme.comment,
      _ when match.namedGroup('string') != null => scheme.string,
      _ when match.namedGroup('hex') != null => scheme.number,
      _ when match.namedGroup('number') != null => scheme.number,
      _ when match.namedGroup('type') != null => scheme.type,
      _ => _keywords.contains(text) ? scheme.keyword : scheme.base,
    };

    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: color == scheme.keyword ? FontWeight.w600 : null,
      ),
    ));
  }

  plain(source.substring(cursor));

  return spans;
}
