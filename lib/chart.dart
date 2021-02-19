library flutter_charts;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// State
part 'chart/model/chart_state.dart';

/// Data
part 'chart/model/data/chart_data.dart';

/// Geometries
part 'chart/model/geometry/bar_value_item.dart';
part 'chart/model/geometry/bubble_value_item.dart';
part 'chart/model/geometry/candle_value_item.dart';
part 'chart/model/geometry/chart_item.dart';

/// Theme
part 'chart/model/theme/chart_behaviour.dart';
part 'chart/model/theme/chart_item_options.dart';

/// Painters
part 'chart/painter/chart_painter.dart';
// Decorations painter
part 'chart/painter/decorations/border_decoration.dart';
part 'chart/painter/decorations/decoration_painter.dart';
part 'chart/painter/decorations/grid_decoration.dart';
part 'chart/painter/decorations/horizontal_axis_decoration.dart';
part 'chart/painter/decorations/selected_item_decoration.dart';
part 'chart/painter/decorations/spark_line_decoration.dart';
part 'chart/painter/decorations/target_decoration.dart';
part 'chart/painter/decorations/target_legends_decoration.dart';
part 'chart/painter/decorations/value_decoration.dart';
part 'chart/painter/decorations/vertical_axis_decoration.dart';
// Geometry painters
part 'chart/painter/geometry/bar_geometry_painter.dart';
part 'chart/painter/geometry/bubble_geometry_painter.dart';
part 'chart/painter/geometry/geometry_painter.dart';

/// Widgets
part 'chart/widgets/animated_chart.dart';
part 'chart/widgets/chart.dart';
part 'chart/widgets/chart_widget.dart';
part 'chart/widgets/simple_charts/simple_bar_chart.dart';
part 'chart/widgets/simple_charts/simple_line_chart.dart';
