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
    this.applyToPlayground,
  });

  final String id;
  final String title;
  final String blurb;
  final List<String> tags;

  /// Builds the live chart. Returns a widget, not a `ChartState`, so entries
  /// needing a wrapper (the scrollable one) fit the same shape.
  final Widget Function(BuildContext context) buildChart;

  final String snippet;

  /// Set only for entries whose configuration the playground can actually
  /// represent. Entries without it show no "Open in playground" action.
  final void Function(WidgetRef ref)? applyToPlayground;
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
