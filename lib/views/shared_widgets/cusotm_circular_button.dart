import 'package:flutter/material.dart';

class CustomCircularButton extends StatelessWidget {
  const CustomCircularButton(
      {super.key,
      this.iconSize,
      this.padding,
      required this.icon,
      required this.onPressed,
      this.iconColor,
      this.backgroundColor});

  final double? iconSize, padding;
  final IconData icon;
  final void Function() onPressed;
  final Color? iconColor, backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(padding ?? 10),
      ),
      child: Icon(
        icon,
        size: iconSize ?? 30,
        color: iconColor,
      ),
    );
  }
}
