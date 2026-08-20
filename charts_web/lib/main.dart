import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/theme/theme_mode_provider.dart';
import 'package:charts_web/ui/shell/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const ProviderScope(child: ChartsWebApp()));
}

class ChartsWebApp extends ConsumerWidget {
  const ChartsWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'charts_painter',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      builder: _builder,
      home: const AppShell(),
    );
  }
}

Widget _builder(BuildContext context, Widget? child) {
  // MaterialUiCompatibilityBridge is deprecated on purpose: it is a migration
  // utility. Needed until flex_color_picker moves to package:material_ui.
  // Remove this wrapper and the ignore below when it does.
  // ignore: deprecated_member_use
  return MaterialUiCompatibilityBridge(
    child: child ?? const SizedBox.shrink(),
  );
}
