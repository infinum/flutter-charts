import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id of the gallery entry currently loaded into the playground, or null when
/// the user is on the built-in defaults.
///
/// Reset means "back to where I started", and if you arrived from the gallery
/// that is the example you opened, not the app defaults.
final appliedGalleryEntryProvider = StateProvider<String?>((ref) => null);
