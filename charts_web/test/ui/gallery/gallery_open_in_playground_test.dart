import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_detail.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:charts_web/ui/shell/shell_destination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('every gallery entry can be opened in the playground', () {
    // applyToPlayground is required on GalleryEntry, so this mostly guards
    // against an entry being added that throws on apply.
    for (final entry in galleryEntries) {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => entry.applyToPlayground(_RefStub(container)),
        returnsNormally,
        reason: entry.id,
      );
    }
  });

  testWidgets('opening an entry applies it and selects the playground tab',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Start somewhere else so the switch is observable.
    container.read(shellDestinationProvider.notifier).state =
        ShellDestination.gallery;

    final entry =
        galleryEntries.firstWhere((entry) => entry.id == 'bubble');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: GalleryDetail(entry: entry),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open in playground'));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bubble);
    expect(container.read(shellDestinationProvider),
        ShellDestination.playground);
  });
}

/// GalleryEntry.applyToPlayground takes a WidgetRef; outside a widget tree the
/// container's read is the equivalent.
class _RefStub implements WidgetRef {
  _RefStub(this.container);

  final ProviderContainer container;

  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('only read() is used by applyToPlayground');
}
