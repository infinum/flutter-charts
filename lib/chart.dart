/// Library for creating highly customizable charts
library charts_painter;

import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_drawing/path_drawing.dart';

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
// Geometry painters
part 'chart/render/chart_data_renderer.dart';
// Decorations painter
part 'chart/render/chart_decoration_renderer.dart';
part 'chart/render/chart_item_renderer.dart';

/// Render
part 'chart/render/chart_renderer.dart';
part 'chart/render/decorations/border_decoration.dart';
part 'chart/render/decorations/decoration_painter.dart';
part 'chart/render/decorations/grid_decoration.dart';
part 'chart/render/decorations/horizontal_axis_decoration.dart';
part 'chart/render/decorations/selected_item_decoration.dart';
part 'chart/render/decorations/spark_line_decoration.dart';
part 'chart/render/decorations/target_decoration.dart';
part 'chart/render/decorations/target_legends_decoration.dart';
part 'chart/render/decorations/value_decoration.dart';
part 'chart/render/decorations/vertical_axis_decoration.dart';
part 'chart/render/geometry/bar_geometry_painter.dart';
part 'chart/render/geometry/bubble_geometry_painter.dart';
part 'chart/render/geometry/geometry_painter.dart';

/// Widgets
part 'chart/widgets/animated_chart.dart';
part 'chart/widgets/chart.dart';
part 'chart/widgets/chart_widget.dart';
