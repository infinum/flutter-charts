import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// One gallery example: a live chart, the copy that explains it, and the
/// snippet that produces it.
class GalleryEntry {
  const GalleryEntry({
    required this.id,
    required this.title,
    required this.blurb,
    required this.tags,
    required this.buildChart,
    required this.snippet,
    required this.applyToPlayground,
  });

  final String id;
  final String title;
  final String blurb;
  final List<String> tags;

  /// Builds the live chart. Returns a widget, not a `ChartState`, so entries
  /// needing a wrapper (the scrollable one) fit the same shape.
  final Widget Function(BuildContext context) buildChart;

  final String snippet;

  /// Loads this example into the playground. Required, so an entry cannot be
  /// added without a way to open it; where the playground cannot represent
  /// something exactly, the closest configuration is applied and the gap is
  /// noted in a comment at the call site.
  final void Function(WidgetRef ref) applyToPlayground;
}

const List<String> galleryTags = [
  'bar',
  'bubble',
  'line',
  'stacked',
  'decoration',
  'axis',
  'custom',
  'scroll',
];
