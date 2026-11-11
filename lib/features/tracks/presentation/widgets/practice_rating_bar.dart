import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/card_progress.dart';

class PracticeRatingBar extends StatelessWidget {
  const PracticeRatingBar({
    required this.strings,
    required this.onRate,
    super.key,
  });

  final AppLocalizations strings;
  final ValueChanged<CardRating> onRate;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        key: const ValueKey('rate-nailed-it'),
        onPressed: () => onRate(CardRating.nailedIt),
        icon: Icon(
          Icons.star,
          color: Theme.of(context).extension<AppColors>()!.gold,
        ),
        label: Text(strings.nailedIt),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('rate-partly'),
        onPressed: () => onRate(CardRating.partly),
        child: Text(strings.partly),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('rate-missed'),
        onPressed: () => onRate(CardRating.missed),
        child: Text(strings.missed),
      ),
    ],
  );
}
