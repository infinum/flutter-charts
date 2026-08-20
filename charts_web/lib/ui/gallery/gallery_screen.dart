import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/gallery/gallery_detail.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final selectedGalleryTagProvider = StateProvider<String?>((ref) => null);

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedTag = ref.watch(selectedGalleryTagProvider);
    final entries = selectedTag == null
        ? galleryEntries
        : galleryEntries
            .where((entry) => entry.tags.contains(selectedTag))
            .toList();

    final columns = switch (context.breakpoint) {
      AppBreakpoint.compact => 1,
      AppBreakpoint.medium => 2,
      AppBreakpoint.expanded => 3,
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Gallery', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Every chart below is live, not a screenshot. Open one for its '
          'source.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: galleryTags
              .map((tag) => FilterChip(
                    label: Text(tag),
                    selected: selectedTag == tag,
                    onSelected: (selected) => ref
                        .read(selectedGalleryTagProvider.notifier)
                        .state = selected ? tag : null,
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) => _GalleryCard(entry: entries[index]),
        ),
      ],
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.entry});

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => GalleryDetail(entry: entry),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Builder(builder: entry.buildChart)),
              const SizedBox(height: 12),
              Text(entry.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                entry.blurb,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
