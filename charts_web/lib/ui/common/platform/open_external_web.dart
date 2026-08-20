import 'dart:js_interop';

@JS('window.open')
external void _windowOpen(String url, String target);

/// Opens [url] in a new browser tab.
void openExternal(String url) => _windowOpen(url, '_blank');
