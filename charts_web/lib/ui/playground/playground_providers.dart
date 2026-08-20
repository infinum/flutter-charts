import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the generated-source panel is showing. On expanded layouts this
/// controls the third pane; on smaller ones, the sheet.
final codePanelVisibleProvider = StateProvider<bool>((ref) => true);
