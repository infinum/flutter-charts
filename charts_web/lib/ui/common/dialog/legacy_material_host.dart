// One of two files allowed to import package:flutter/material.dart. Its whole
// job is the boundary between the legacy Material library and material_ui.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Gives a legacy-Material subtree the `Material` ancestor it looks for.
///
/// `flex_color_picker` imports `package:flutter/material.dart`, so its widgets
/// call `debugCheckHasMaterial`, which searches for the *legacy* `Material`
/// widget. Our dialogs come from `material_ui`, whose `AlertDialog` inserts
/// `material_ui`'s `Material` — a different class — so the search fails with
/// "No Material widget found".
///
/// `MaterialUiCompatibilityBridge` in main.dart bridges `ThemeData` and
/// `MaterialLocalizations`, but not the ancestor lookup, which is why this is
/// needed as well. Both disappear when the picker migrates.
class LegacyMaterialHost extends StatelessWidget {
  const LegacyMaterialHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => legacy.Material(
        type: legacy.MaterialType.transparency,
        child: child,
      );
}
