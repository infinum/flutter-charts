/// Accumulates generated Dart source, owning indentation so emitters never
/// hand-manage whitespace.
class SourceWriter {
  SourceWriter({this.indentWidth = 2});

  final int indentWidth;

  final StringBuffer _buffer = StringBuffer();
  int _depth = 0;

  /// Writes one line at the current depth.
  void line(String text) {
    _buffer.writeln('${' ' * (_depth * indentWidth)}$text');
  }

  /// Writes [text] then indents everything after it.
  void open(String text) {
    line(text);
    _depth++;
  }

  /// Dedents, then writes [text].
  void close(String text) {
    assert(_depth > 0, 'close() without a matching open()');
    _depth--;
    line(text);
  }

  String build() => _buffer.toString().trimRight();
}
