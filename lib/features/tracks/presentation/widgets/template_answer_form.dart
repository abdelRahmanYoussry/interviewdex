import 'package:flutter/material.dart';

import '../../domain/entities/interview_question.dart';

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
          Text(
            template.template.resolve(languageCode),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          for (final field in template.fields) ...[
            TextFormField(
              key: ValueKey('template-${field.id}'),
              initialValue: answers[field.id] ?? '',
              decoration: InputDecoration(
                labelText: field.label.resolve(languageCode),
                hintText: field.placeholder.resolve(languageCode),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(field.id, value),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}
