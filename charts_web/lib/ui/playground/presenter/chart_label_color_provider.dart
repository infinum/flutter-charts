import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Colour for text the chart itself draws — axis values and legends.
///
/// `HorizontalAxisDecoration` and `VerticalAxisDecoration` default
/// `legendFontStyle` to `TextStyle(fontSize: 12)`, which has no colour and so
/// paints black. That is invisible on a dark surface, so the app pushes the
/// active `onSurface` in here and the axis presenters read it.
final chartLabelColorProvider =
    StateProvider<Color>((ref) => const Color(0xFF000000));

/// Colour for grid and axis lines. Same problem as the label colour: the chart
/// paints these itself, so a hardcoded grey ignores the theme. The user can
/// still override it per decoration.
final chartGridColorProvider =
    StateProvider<Color>((ref) => const Color(0xFF9E9E9E));
