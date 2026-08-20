import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

enum ShellDestination {
  playground('Playground', Icons.tune),
  gallery('Gallery', Icons.grid_view),
  concepts('Concepts', Icons.school_outlined);

  const ShellDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Which panel the rail is showing. A provider rather than local state so the
/// gallery can send you to the playground after applying an example.
final shellDestinationProvider =
    StateProvider<ShellDestination>((ref) => ShellDestination.playground);
