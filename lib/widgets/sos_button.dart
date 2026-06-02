import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'crisis_sheet.dart';

class SosIconButton extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SosIconButton({
    super.key,
    this.size = 40,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.brand.withValues(alpha: 0.08);
    final fg = foregroundColor ?? AppColors.brand;

    return Semantics(
      button: true,
      label: 'Butuh bantuan sekarang',
      child: Tooltip(
        message: 'Butuh bantuan sekarang',
        child: Padding(
          padding: margin,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => showCrisisSheet(context),
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  Icons.volunteer_activism_rounded,
                  color: fg,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
