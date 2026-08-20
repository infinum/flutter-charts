import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Session-only theme mode. Not persisted: persistence would need a storage
/// dependency this demo does not otherwise want.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
