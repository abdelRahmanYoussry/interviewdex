import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static TextStyle code(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(fontFamily: 'JetBrainsMono');
  }
}
