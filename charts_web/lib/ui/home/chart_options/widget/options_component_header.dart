import 'package:material_ui/material_ui.dart';

class OptionsComponentHeader extends StatelessWidget {
  const OptionsComponentHeader(
      {Key? key, required this.title, required this.subtitle})
      : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
