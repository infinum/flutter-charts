import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id of the gallery entry currently loaded into the playground, or null when
/// the user is on the built-in defaults.
///
/// Reset means "back to where I started", and if you arrived from the gallery
/// that is the example you opened, not the app defaults.
final appliedGalleryEntryProvider = StateProvider<String?>((ref) => null);

/// Whether the next press of Reset drops the loaded example instead of
/// putting it back.
///
/// Reset is a two-step once you arrive from the gallery: the first press
/// undoes your edits and returns the example, the second leaves the example
/// behind for the built-in defaults. [resetPlayground] clears this, so opening
/// another example always starts the pair over.
final resetToDefaultsNextProvider = StateProvider<bool>((ref) => false);
