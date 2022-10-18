import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SwitchWithImage extends StatelessWidget {
  const SwitchWithImage({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title1,
    required this.title2,
    this.subtitle,
    required this.image1,
    required this.image2,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool>? onChanged;

  final String title1;
  final String title2;
  final String? subtitle;

  final String image1;
  final String image2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SwitchListTile(
          value: value,
          title: Text(value ? title1 : title2),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          onChanged: onChanged,
        ),
        Positioned(
          right: 8,
          top: 2,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xffdedede),
              ),
              height: subtitle != null ? 60 : 45,
              width: subtitle != null ? 60 : 45,
              margin: EdgeInsets.only(right: subtitle != null ? 4 : 14),
              padding: const EdgeInsets.only(bottom: 4),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                value ? image1 : image2,
                height: 40,
              ),
            ),
          ),
        )
      ],
    );
  }
}
