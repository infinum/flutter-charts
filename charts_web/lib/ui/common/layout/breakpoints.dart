import 'package:flutter/widgets.dart';

/// Layout buckets for the site. Replaces the old `Respo` wrapper, which scaled
/// the whole app inside a `FittedBox` instead of adapting to the viewport.
enum AppBreakpoint {
  /// Phones. Chart pinned on top, options scroll beneath.
  compact,

  /// Tablets and small windows. Options plus chart; code panel in a drawer.
  medium,

  /// Wide desktop. Options, chart and code panel side by side.
  expanded,
}

const double kMediumBreakpoint = 800;
const double kExpandedBreakpoint = 1400;

AppBreakpoint breakpointForWidth(double width) {
  if (width < kMediumBreakpoint) return AppBreakpoint.compact;
  if (width < kExpandedBreakpoint) return AppBreakpoint.medium;
  return AppBreakpoint.expanded;
}

extension BreakpointContext on BuildContext {
  AppBreakpoint get breakpoint =>
      breakpointForWidth(MediaQuery.sizeOf(this).width);
}
