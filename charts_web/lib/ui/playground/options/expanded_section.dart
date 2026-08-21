import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three top-level option groups.
enum OptionSection { data, itemOptions, decorations }

/// Which group is open. The panel is an accordion: opening one closes the
/// others, so the whole option surface stays scannable instead of becoming a
/// very long scroll.
///
/// Null means all three are collapsed, which is what you get by closing the
/// open one.
final expandedOptionSectionProvider =
    StateProvider<OptionSection?>((ref) => OptionSection.data);
