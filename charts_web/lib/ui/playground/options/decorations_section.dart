import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/playground/decorations/decorations_grid.dart';
import 'package:charts_web/ui/playground/decorations/decorations_horizontal_axis.dart';
import 'package:charts_web/ui/playground/decorations/decorations_sparkline.dart';
import 'package:charts_web/ui/playground/decorations/decorations_vertical_axis.dart';
import 'package:charts_web/ui/playground/decorations/decorations_widget.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DecorationsSection extends ConsumerWidget {
  const DecorationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartDecorationsPresenter);
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Decorations',
      subtitle: 'Everything drawn around the items, in a background or a '
          'foreground layer.',
      children: [
        Text('Add a decoration', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AddDecorationTile(
              name: 'Grid',
              image: Assets.png.generalGridDecorationGolden.path,
              onPressed: () => presenter.addDecoration(GridDecoration()),
            ),
            _AddDecorationTile(
              name: 'SparkLine',
              image: Assets.png.generalSparklineDecorationGolden.path,
              onPressed: () => presenter.addDecoration(SparkLineDecoration()),
            ),
            _AddDecorationTile(
              name: 'Horizontal axis',
              image: Assets.png.generalHorizontalDecorationGolden.path,
              onPressed: () =>
                  presenter.addDecoration(HorizontalAxisDecoration()),
            ),
            _AddDecorationTile(
              name: 'Vertical axis',
              image: Assets.png.generalVerticalDecorationGolden.path,
              onPressed: () => presenter.addDecoration(VerticalAxisDecoration()),
            ),
            _AddDecorationTile(
              name: 'Widget',
              image: Assets.png.futuramaSmall.path,
              onPressed: () => presenter.addDecoration(
                WidgetDecoration(
                  widgetDecorationBuilder: (_, __, ___, ____) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        Text('Foreground layer', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (presenter.foregroundDecorations.isEmpty)
          const _EmptyLayerHint(text: 'No foreground decorations yet.')
        else
          ..._editorsFor(presenter.foregroundDecorations),
        const SizedBox(height: 12),
        Text('Background layer', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (presenter.backgroundDecorations.isEmpty)
          const _EmptyLayerHint(text: 'No background decorations yet.')
        else
          ..._editorsFor(presenter.backgroundDecorations),
      ],
    );
  }

  List<Widget> _editorsFor(Map<int, DecorationPainter> decorations) {
    final widgets = <Widget>[];

    decorations.forEach((index, decoration) {
      widgets.add(switch (decoration) {
        GridDecoration() => DecorationsGrid(decorationIndex: index),
        SparkLineDecoration() => DecorationsSparkline(decorationIndex: index),
        VerticalAxisDecoration() =>
          DecorationsVerticalAxis(decorationIndex: index),
        HorizontalAxisDecoration() =>
          DecorationsHorizontalAxis(decorationIndex: index),
        WidgetDecoration() => DecorationsWidget(decorationIndex: index),
        _ => const SizedBox.shrink(),
      });
    });

    return widgets;
  }
}

class _EmptyLayerHint extends StatelessWidget {
  const _EmptyLayerHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _AddDecorationTile extends StatelessWidget {
  const _AddDecorationTile({
    required this.name,
    required this.image,
    required this.onPressed,
  });

  final String name;
  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  Image.asset(image, width: 84, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
