## [3.1.0] - 15.02.2023
* Added a screenshot
* Fixed VerticalAxisDecoration padding
* Fixed item width for WidgetItemOptions
* Add onHover states to ChartBehavior
* Add ScrollSettings to ChartBehavior to control number of visible items when in scroll mode



## [3.0.0] - 02.11.2022
* Introduction of WidgetItemOptions and WidgetDecoration
* ChartState: data and itemOptions are now required named parameters
* New item options builder parameter
* Deprecated: BarValue, BubbleValue,TargetLineDecoration, TargetLineTextDecoration,
TargetAreaDecoration, BorderDecoration, SelectedItemDecoration, ValueDecoration
* multiItemStack moved to DefaultDataStrategy stackMultipleValues
* Fix: Add alignment to chart items when max item size is set
* Migration guide: https://github.com/infinum/flutter-charts/wiki/Migration-guide-to-3.0

## [2.0.0+2] - 05.04.2022.
* Reduce final .apk app size when using this lib
* Fixed `ValueDecoration` when all items were 0
* Add value label generator in `ValueDecoration`
* Add show the line for value to `HorizontalDecoration` for more precise control of when to show horizontal line
* Fix gradient color on `SparkLineDecoration`
* Fix fixed horizontal decoration values getting clipped

## [2.0.0+1] - 01.03.2022.
* Updated packages
* Removed flutter_path_drawing dependency
* Selected item can be shown on value

## [2.0.0] - 30.11.2021.
**This release has some breaking changes. You might have to update existing charts code!**

* Migrate the lib to use custom render objects instead of CustomPainters
* Extend DataStrategy from enum to abstract class, extending it to manipulate data further
* Removed options from Charts, they are now part of ChartData or ItemOptions
* Update README with more examples and possibilities

## [1.1.0] - 12.05.2021.

* Migrate to null safety

## [1.0.0+1] - 26.02.2021.

* Formatting fixes

## [1.0.0] - 25.02.2021.

* Initial release
