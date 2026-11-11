import 'package:flutter/material.dart';

import '../../domain/entities/interview_question.dart';
import 'localized_content_text.dart';

class TemplateAnswerForm extends StatelessWidget {
  const TemplateAnswerForm({
    required this.template,
    required this.answers,
    required this.languageCode,
    required this.onChanged,
    super.key,
  });

  final FillInTemplate template;
  final Map<String, String> answers;
  final String languageCode;
  final void Function(String fieldId, String value) onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocalizedContentText(
            template.template,
            languageCode: languageCode,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          for (final field in template.fields) ...[
            Builder(
              builder: (context) {
                final resolvedLanguage =
                    field.label.resolveWith(languageCode).languageCode;
                final direction =
                    resolvedLanguage.split('-').first == 'en'
                        ? TextDirection.ltr
                        : TextDirection.rtl;
                return Directionality(
                  textDirection: direction,
                  child: TextFormField(
                    key: ValueKey('template-${field.id}'),
                    initialValue: answers[field.id] ?? '',
                    textDirection: direction,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: field.label.resolve(languageCode),
                      hintText: field.placeholder.resolve(languageCode),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => onChanged(field.id, value),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}
