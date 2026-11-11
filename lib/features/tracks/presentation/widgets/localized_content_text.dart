import 'package:flutter/material.dart';

import '../../domain/value_objects/localized_text.dart';

class LocalizedContentText extends StatelessWidget {
  const LocalizedContentText(
    this.value, {
    required this.languageCode,
    this.style,
    this.textAlign = TextAlign.start,
    this.alignToUiStart = false,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final LocalizedText value;
  final String languageCode;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool alignToUiStart;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final resolved = value.resolveWith(languageCode);
    final isEnglish = resolved.languageCode.split('-').first == 'en';
    final direction = isEnglish ? TextDirection.ltr : TextDirection.rtl;
    return Directionality(
      textDirection: direction,
      child: Text(
        resolved.text,
        style: style,
        textAlign:
            alignToUiStart
                ? (Directionality.of(context) == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left)
                : textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
