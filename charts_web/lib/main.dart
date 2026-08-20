import 'package:charts_web/ui/common/respo/respo.dart';
import 'package:charts_web/ui/home/home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'InterTight',
        primarySwatch: Colors.red,
      ),
      builder: _builder,
      home: HomeScreen(),
    );
  }
}

Widget _builder(BuildContext context, Widget? child) {
  // MaterialUiCompatibilityBridge is deprecated on purpose: it is a migration
  // utility. Needed until flex_color_picker moves to package:material_ui.
  // Remove this wrapper and the ignore below when it does.
  // ignore: deprecated_member_use
  return MaterialUiCompatibilityBridge(
    child: Respo(child: child ?? const SizedBox.shrink()),
  );
}
