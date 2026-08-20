// dart format width=120

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsPngGen {
  const $AssetsPngGen();

  /// File path: assets/png/futurama1.jpeg
  AssetGenImage get futurama1 =>
      const AssetGenImage('assets/png/futurama1.jpeg');

  /// File path: assets/png/futurama2.jpeg
  AssetGenImage get futurama2 =>
      const AssetGenImage('assets/png/futurama2.jpeg');

  /// File path: assets/png/futurama4.jpeg
  AssetGenImage get futurama4 =>
      const AssetGenImage('assets/png/futurama4.jpeg');

  /// File path: assets/png/futurama5.jpeg
  AssetGenImage get futurama5 =>
      const AssetGenImage('assets/png/futurama5.jpeg');

  /// File path: assets/png/futurama_small.png
  AssetGenImage get futuramaSmall =>
      const AssetGenImage('assets/png/futurama_small.png');

  /// File path: assets/png/general_grid_decoration_golden.png
  AssetGenImage get generalGridDecorationGolden =>
      const AssetGenImage('assets/png/general_grid_decoration_golden.png');

  /// File path: assets/png/general_horizontal_decoration_golden.png
  AssetGenImage get generalHorizontalDecorationGolden => const AssetGenImage(
      'assets/png/general_horizontal_decoration_golden.png');

  /// File path: assets/png/general_sparkline_decoration_golden.png
  AssetGenImage get generalSparklineDecorationGolden =>
      const AssetGenImage('assets/png/general_sparkline_decoration_golden.png');

  /// File path: assets/png/general_vertical_decoration_golden.png
  AssetGenImage get generalVerticalDecorationGolden =>
      const AssetGenImage('assets/png/general_vertical_decoration_golden.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        futurama1,
        futurama2,
        futurama4,
        futurama5,
        futuramaSmall,
        generalGridDecorationGolden,
        generalHorizontalDecorationGolden,
        generalSparklineDecorationGolden,
        generalVerticalDecorationGolden
      ];
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/bar_chart_icon.svg
  String get barChartIcon => 'assets/svg/bar_chart_icon.svg';

  /// File path: assets/svg/bubble_chart_icon.svg
  String get bubbleChartIcon => 'assets/svg/bubble_chart_icon.svg';

  /// File path: assets/svg/deco_background.svg
  String get decoBackground => 'assets/svg/deco_background.svg';

  /// File path: assets/svg/deco_foreground.svg
  String get decoForeground => 'assets/svg/deco_foreground.svg';

  /// File path: assets/svg/line_no.svg
  String get lineNo => 'assets/svg/line_no.svg';

  /// File path: assets/svg/line_yes.svg
  String get lineYes => 'assets/svg/line_yes.svg';

  /// File path: assets/svg/showcase.svg
  String get showcase => 'assets/svg/showcase.svg';

  /// File path: assets/svg/smoothed_no.svg
  String get smoothedNo => 'assets/svg/smoothed_no.svg';

  /// File path: assets/svg/smoothed_yes.svg
  String get smoothedYes => 'assets/svg/smoothed_yes.svg';

  /// File path: assets/svg/strategy default.svg
  String get strategyDefault => 'assets/svg/strategy default.svg';

  /// File path: assets/svg/strategy stack.svg
  String get strategyStack => 'assets/svg/strategy stack.svg';

  /// List of all assets
  List<String> get values => [
        barChartIcon,
        bubbleChartIcon,
        decoBackground,
        decoForeground,
        lineNo,
        lineYes,
        showcase,
        smoothedNo,
        smoothedYes,
        strategyDefault,
        strategyStack
      ];
}

class Assets {
  const Assets._();

  static const $AssetsPngGen png = $AssetsPngGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
