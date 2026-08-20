import 'package:material_ui/material_ui.dart';

import 'package:charts_web/ui/design/number_field.dart';

class BorderRadiusDialog extends StatefulWidget {
  const BorderRadiusDialog({super.key, required this.radius});

  static Future<BorderRadius?> show(BuildContext context, BorderRadius radius) {
    return showDialog<BorderRadius>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Set Border Radius'),
            content: BorderRadiusDialog(radius: radius),
          );
        });
  }

  final BorderRadius radius;

  @override
  State<BorderRadiusDialog> createState() => _BorderRadiusDialogState();
}

class _BorderRadiusDialogState extends State<BorderRadiusDialog> {
  late BorderRadius state;

  @override
  void initState() {
    super.initState();

    state = widget.radius;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'In this editor you can only change circular border. More advances properties (like non-circular border) can be accessed in code.'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      NumberField(
                        label: 'Top-left',
                        value: state.topLeft.x,
                        step: 4,
                        onChanged: (a) {
                          setState(() {
                            state = state.copyWith(topLeft: Radius.circular(a));
                          });
                        },
                        fallback: widget.radius.topLeft.x,
                      ),
                      NumberField(
                          label: 'Bottom-left',
                          value: state.bottomLeft.x,
                          step: 4,
                          onChanged: (a) {
                            setState(() => state =
                                state.copyWith(bottomLeft: Radius.circular(a)));
                          },
                          fallback: widget.radius.bottomLeft.x),
                    ],
                  )),
              const SizedBox(width: 16),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.7),
                  borderRadius: state,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      NumberField(
                          label: 'Top-right',
                          value: state.topRight.x,
                          step: 4,
                          onChanged: (a) {
                            setState(() => state =
                                state.copyWith(topRight: Radius.circular(a)));
                          },
                          fallback: widget.radius.topRight.x),
                      NumberField(
                          label: 'Bottom-right',
                          value: state.bottomRight.x,
                          step: 4,
                          onChanged: (a) {
                            setState(() => state = state.copyWith(
                                bottomRight: Radius.circular(a)));
                          },
                          fallback: widget.radius.bottomRight.x),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(BorderRadius.zero);
                },
                child: const Text('No Border radius'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(state);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
