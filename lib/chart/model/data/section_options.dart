part of charts_painter;

class SectionOptions {
  SectionOptions({
    required this.sectionIndex,
    required this.sectionOffset,
  });

  final int sectionIndex;
  final int sectionOffset;

  @override
  int get hashCode => Object.hash(sectionIndex, sectionOffset);

  @override
  bool operator ==(Object other) {
    if (other is SectionOptions) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  String toString() {
    return 'SectionOptions{sectionIndex: $sectionIndex, sectionOffset: $sectionOffset}';
  }
}
