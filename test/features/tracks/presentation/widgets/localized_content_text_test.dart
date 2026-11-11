import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/tracks/domain/value_objects/localized_text.dart';
import 'package:interviewdex/features/tracks/presentation/widgets/localized_content_text.dart';

void main() {
  testWidgets('RTL short English labels align at UI start, unlike paragraphs', (
    tester,
  ) async {
    final label = LocalizedText({'en': 'English topic'});
    final paragraph = LocalizedText({'en': 'English paragraph'});
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocalizedContentText(
                label,
                languageCode: 'ar',
                alignToUiStart: true,
              ),
              LocalizedContentText(paragraph, languageCode: 'ar'),
            ],
          ),
        ),
      ),
    );

    final labelFinder = find.text('English topic');
    final paragraphFinder = find.text('English paragraph');
    expect(Directionality.of(tester.element(labelFinder)), TextDirection.ltr);
    expect(tester.widget<Text>(labelFinder).textAlign, TextAlign.right);
    expect(
      Directionality.of(tester.element(paragraphFinder)),
      TextDirection.ltr,
    );
    expect(tester.widget<Text>(paragraphFinder).textAlign, TextAlign.start);
  });
}
