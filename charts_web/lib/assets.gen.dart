/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsPngGen {
  const $AssetsPngGen();

  /// File path: assets/png/futurama1.jpeg
  AssetGenImage get futurama1 => const AssetGenImage('assets/png/futurama1.jpeg');

  /// File path: assets/png/futurama2.jpeg
  AssetGenImage get futurama2 => const AssetGenImage('assets/png/futurama2.jpeg');

  /// File path: assets/png/futurama4.jpeg
  AssetGenImage get futurama4 => const AssetGenImage('assets/png/futurama4.jpeg');

  /// File path: assets/png/futurama5.jpeg
  AssetGenImage get futurama5 => const AssetGenImage('assets/png/futurama5.jpeg');

  /// File path: assets/png/futurama_small.png
  AssetGenImage get futuramaSmall => const AssetGenImage('assets/png/futurama_small.png');

  /// File path: assets/png/general_grid_decoration_golden.png
  AssetGenImage get generalGridDecorationGolden => const AssetGenImage('assets/png/general_grid_decoration_golden.png');

  /// File path: assets/png/general_horizontal_decoration_golden.png
  AssetGenImage get generalHorizontalDecorationGolden =>
      const AssetGenImage('assets/png/general_horizontal_decoration_golden.png');

  /// File path: assets/png/general_sparkline_decoration_golden.png
  AssetGenImage get generalSparklineDecorationGolden =>
      const AssetGenImage('assets/png/general_sparkline_decoration_golden.png');

  /// File path: assets/png/general_vertical_decoration_golden.png
  AssetGenImage get generalVerticalDecorationGolden =>
      const AssetGenImage('assets/png/general_vertical_decoration_golden.png');
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/bar_chart_icon.svg
  String get barChartIcon => 'assets/svg/bar_chart_icon.svg';

  /// File path: assets/svg/bubble_chart_icon.svg
  String get bubbleChartIcon => 'assets/svg/bubble_chart_icon.svg';

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
}

class Assets {
  Assets._();

  static const $AssetsPngGen png = $AssetsPngGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

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
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
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

  String get path => _assetName;

  String get keyName => _assetName;
}
