import 'package:flutter/material.dart';

class StatusOverlay extends StatelessWidget {
  final bool visible;
  final String message;
  final Icon icon;
  final Color backgroundColor;
  final Color textColor;
  final double keySize;
  final double keyBorderRadius;

  const StatusOverlay({
    super.key,
    required this.visible,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.keySize,
    required this.keyBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Container(
          width: keySize * 2.5,
          height: keySize * 2.5,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(keyBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(76),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon.icon,
                size: keySize <= 48 ? 36 : 48,
                color: textColor,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
