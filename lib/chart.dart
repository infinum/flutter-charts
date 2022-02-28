/// Library for creating highly customizable charts
library charts_painter;

import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// State
part 'chart/model/chart_state.dart';

/// Data
part 'chart/model/data/chart_data.dart';
part 'chart/model/data_strategy/data_strategy.dart';
part 'chart/model/data_strategy/default_data_strategy.dart';
part 'chart/model/data_strategy/stack_data_strategy.dart';

/// Geometries
part 'chart/model/geometry/bar_value_item.dart';
part 'chart/model/geometry/bubble_value_item.dart';
part 'chart/model/geometry/candle_value_item.dart';
part 'chart/model/geometry/chart_item.dart';

/// Theme
part 'chart/model/theme/chart_behaviour.dart';
part 'chart/model/theme/item_theme/bar_item_options.dart';
part 'chart/model/theme/item_theme/item_options.dart';
part 'chart/model/theme/item_theme/line_item_options.dart';

/// Render
part 'chart/render/chart_renderer.dart';
// Data renderers
part 'chart/render/data_renderer/chart_data_renderer.dart';
part 'chart/render/data_renderer/chart_linear_data_renderer.dart';
// Decoration painters
part 'chart/render/decorations/border_decoration.dart';
part 'chart/render/decorations/decoration_painter.dart';
part 'chart/render/decorations/grid_decoration.dart';
part 'chart/render/decorations/horizontal_axis_decoration.dart';
part 'chart/render/decorations/renderer/chart_decoration_child_renderer.dart';
part 'chart/render/decorations/renderer/chart_decoration_renderer.dart';
part 'chart/render/decorations/selected_item_decoration.dart';
part 'chart/render/decorations/spark_line_decoration.dart';
part 'chart/render/decorations/target_decoration.dart';
part 'chart/render/decorations/target_legends_decoration.dart';
part 'chart/render/decorations/value_decoration.dart';
part 'chart/render/decorations/vertical_axis_decoration.dart';
part 'chart/render/decorations_renderer.dart';
// Geometry painters
part 'chart/render/geometry/leaf_item_renderer.dart';
part 'chart/render/geometry/painters/bar_geometry_painter.dart';
part 'chart/render/geometry/painters/bubble_geometry_painter.dart';
part 'chart/render/geometry/painters/geometry_painter.dart';
// Utils
part 'chart/render/util/dashed_path_util.dart';

/// Widgets
part 'chart/widgets/animated_chart.dart';
part 'chart/widgets/chart.dart';
part 'chart/widgets/chart_widget.dart';
