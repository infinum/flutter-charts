// ignore_for_file: prefer-single-widget-per-file

import 'package:flutter/material.dart';

const _mobileBreakpoint = 800;
const _tabletBreakpoint = 1400;
const _tabletScaleUp = 0.95;
const _desktopScaleUp = 0.9;

/// Responsive inherited widget based on responsive_framework package but stripped down to functions I need. The
/// responsive_framework had an issue where inspector it would bug out with inspector: https://github.com/Codelessly/ResponsiveFramework/issues/115
class Respo extends StatefulWidget {
  const Respo({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static RespoWrapperData of(BuildContext context) {
    final InheritedRespoWrapper? data =
        context.dependOnInheritedWidgetOfExactType<InheritedRespoWrapper>();
    if (data != null) return data.data;
    throw FlutterError.fromParts(
      <DiagnosticsNode>[
        ErrorSummary(
            'ResponsiveWrapper.of() called with a context that does not contain a ResponsiveWrapper.'),
        ErrorDescription(
            'No Responsive ancestor could be found starting from the context that was passed '
            'to ResponsiveWrapper.of(). Place a ResponsiveWrapper at the root of the app '
            'or supply a ResponsiveWrapper.builder.'),
        context.describeElement('The context used was')
      ],
    );
  }

  @override
  State<Respo> createState() => RespoState();
}

class RespoState extends State<Respo> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is readable here, so the very first build already lays out at
    // the real window size instead of the 200x200 placeholder below.
    setDimensions();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // When physical dimensions change, update state.
    // The required MediaQueryData is only available
    // on the next frame for physical dimension changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Widget could be destroyed by resize. Verify widget
      // exists before updating dimensions.
      if (mounted) {
        setDimensions();
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant Respo oldWidget) {
    setDimensions();
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedRespoWrapper(
      data: RespoWrapperData.fromResponsiveWrapper(this),
      child: MediaQuery(
        data: calculateMediaQueryData(),
        child: SizedBox(
          width: windowWidth > 0 ? windowWidth : double.infinity,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            child: Container(
              width: scaledWidth > 0 ? scaledWidth : 200,
              height: scaledHeight > 0 ? scaledHeight : 200,
              // Shrink wrap height if no MediaQueryData is passed.
              alignment: Alignment.center,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void setDimensions() {
    devicePixelRatio = getDevicePixelRatio();
    windowWidth = getWindowWidth();
    windowHeight = getWindowHeight();
    // screenWidth = getScreenWidth();
    // screenHeight = getScreenHeight();
    scaledWidth = getScaledWidth();
    scaledHeight = getScaledHeight();
  }

  double scaledWidth = 0;
  double scaledHeight = 0;

  double devicePixelRatio = 1;

  double getDevicePixelRatio() {
    return MediaQuery.of(context).devicePixelRatio;
  }

  double windowWidth = 0;

  double getWindowWidth() {
    return MediaQuery.of(context).size.width;
  }

  double windowHeight = 0;

  double getWindowHeight() {
    return MediaQuery.of(context).size.height;
  }

  double getScreenWidth() {
    return windowWidth;
  }

  double getScreenHeight() {
    return windowHeight;
  }

  double getScaledWidth() {
    if (windowWidth < _mobileBreakpoint) {
      return windowWidth;
    } else if (windowWidth < _tabletBreakpoint) {
      return windowWidth * _tabletScaleUp;
    } else {
      return windowWidth * _desktopScaleUp;
    }
  }

  double getScaledHeight() {
    if (windowWidth < _mobileBreakpoint) {
      return windowHeight;
    } else if (windowWidth < _tabletBreakpoint) {
      return windowHeight * _tabletScaleUp;
    } else {
      return windowHeight * _desktopScaleUp;
    }
  }

  MediaQueryData calculateMediaQueryData() {
    return MediaQuery.of(context).copyWith(
      size: Size(scaledWidth, scaledHeight),
      // devicePixelRatio: devicePixelRatio * activeScaleFactor,
      // viewInsets: scaledViewInsets,
      // viewPadding: scaledViewPadding,
      // padding: scaledPadding,
    );
  }
}

@immutable
class InheritedRespoWrapper extends InheritedWidget {
  final RespoWrapperData data;

  /// Creates a widget that provides [ResponsiveWrapperData] to its descendants.
  ///
  /// The [data] and [child] arguments must not be null.
  const InheritedRespoWrapper(
      {Key? key, required this.data, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedRespoWrapper oldWidget) =>
      data != oldWidget.data;
}

@immutable
class RespoWrapperData {
  final double screenWidth;
  final double screenHeight;
  final double scaledWidth;
  final double scaledHeight;

  bool get isMobile => screenWidth < _mobileBreakpoint;

  ResponsiveSize get size {
    if (screenWidth < _mobileBreakpoint) {
      return ResponsiveSize.small;
    } else if (screenWidth < _tabletBreakpoint) {
      return ResponsiveSize.medium;
    } else {
      return ResponsiveSize.large;
    }
  }

  const RespoWrapperData._({
    required this.screenWidth,
    required this.screenHeight,
    required this.scaledWidth,
    required this.scaledHeight,
  });

  static RespoWrapperData fromResponsiveWrapper(RespoState state) {
    return RespoWrapperData._(
      scaledWidth: state.scaledWidth,
      scaledHeight: state.scaledHeight,
      screenHeight: state.windowHeight,
      screenWidth: state.windowWidth,
    );
  }
}

enum ResponsiveSize { small, medium, large }
