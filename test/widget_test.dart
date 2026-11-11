import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/app.dart';
import 'package:interviewdex/core/constants.dart';
import 'package:interviewdex/core/router/app_router.dart';

void main() {
  testWidgets('shows the InterviewDex home screen', (tester) async {
    await tester.pumpWidget(App(router: AppRouter()));

    expect(find.text(AppConstants.appTitle), findsOneWidget);
    expect(find.text(AppConstants.tagline), findsOneWidget);
  });
}
