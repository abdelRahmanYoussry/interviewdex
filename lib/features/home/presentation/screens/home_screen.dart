import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.launchRepository = _launchRepository, super.key});

  final Future<bool> Function(Uri) launchRepository;

  static Future<bool> _launchRepository(Uri uri) =>
      launchUrl(uri, webOnlyWindowName: '_blank');

  Future<void> _openRepository(BuildContext context) async {
    final opened = await launchRepository(
      Uri.parse(AppConstants.repositoryUrl),
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.githubOpenFailure),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            tooltip: localizations.githubRepo,
            onPressed: () => _openRepository(context),
            icon: const Icon(Icons.code),
          ),
          IconButton(
            tooltip: localizations.settings,
            onPressed:
                () => Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Icon(
                      Icons.style_outlined,
                      color: theme.extension<AppColors>()!.accent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.homeWelcome,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.tagline,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const ValueKey('quickQuiz'),
                    onPressed:
                        () => Navigator.of(context).pushNamed(AppRoutes.quiz),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(localizations.quickQuiz),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.quizSubtitle,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('startInterview'),
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.interview),
                    icon: const Icon(Icons.record_voice_over_outlined),
                    label: Text(localizations.startInterview),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
