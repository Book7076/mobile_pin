import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/core/social_link_manager.dart';
import 'package:pin_mobile/screens/profile/settings_screen.dart';
import 'package:pin_mobile/screens/profile/social_connect_screen.dart';

void main() {
  setUp(() {
    SocialLinkManager.reset();
  });

  group('SocialLinkManager Unit Tests', () {
    test('initially unlinked and allows linking either', () {
      expect(SocialLinkManager.linkedProvider, isNull);
      expect(SocialLinkManager.isFacebookLinked, isFalse);
      expect(SocialLinkManager.isGoogleLinked, isFalse);
      expect(SocialLinkManager.canLink('facebook'), isTrue);
      expect(SocialLinkManager.canLink('google'), isTrue);
    });

    test('linking Facebook blocks Google', () {
      final successFb = SocialLinkManager.linkProvider('facebook');
      expect(successFb, isTrue);
      expect(SocialLinkManager.isFacebookLinked, isTrue);
      expect(SocialLinkManager.isGoogleLinked, isFalse);
      expect(SocialLinkManager.canLink('facebook'), isTrue);
      expect(SocialLinkManager.canLink('google'), isFalse);

      // Attempting to link Google while Facebook is linked must fail
      final successGg = SocialLinkManager.linkProvider('google');
      expect(successGg, isFalse);
      expect(SocialLinkManager.isGoogleLinked, isFalse);
    });

    test('unlinking allows linking Google and then blocks Facebook', () {
      SocialLinkManager.linkProvider('facebook');
      expect(SocialLinkManager.isFacebookLinked, isTrue);

      SocialLinkManager.unlinkProvider();
      expect(SocialLinkManager.linkedProvider, isNull);
      expect(SocialLinkManager.canLink('google'), isTrue);
      expect(SocialLinkManager.canLink('facebook'), isTrue);

      final successGg = SocialLinkManager.linkProvider('google');
      expect(successGg, isTrue);
      expect(SocialLinkManager.isGoogleLinked, isTrue);
      expect(SocialLinkManager.canLink('facebook'), isFalse);

      final successFb = SocialLinkManager.linkProvider('facebook');
      expect(successFb, isFalse);
    });
  });

  group('SettingsScreen and SocialConnectScreen Widget Tests', () {
    testWidgets('SettingsScreen displays "เชื่อมต่อ facebook google" row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(
            email: 'Emma.carter@gmail.com',
            phone: '099-888-7777',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('เชื่อมต่อ facebook google'), findsOneWidget);
      expect(find.text('ยังไม่เชื่อมต่อ'), findsOneWidget);
    });

    testWidgets('Tapping "เชื่อมต่อ facebook google" navigates to SocialConnectScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(
            email: 'Emma.carter@gmail.com',
            phone: '099-888-7777',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rowFinder = find.byKey(const Key('settings_social_connect_row'));
      expect(rowFinder, findsOneWidget);
      await tester.tap(rowFinder);
      await tester.pumpAndSettle();

      // Check SocialConnectScreen title and cards
      expect(find.text('เชื่อมต่อ Facebook / Google'), findsOneWidget);
      expect(find.text('ช่องทางการเชื่อมต่อ'), findsOneWidget);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.byKey(const Key('social_connect_facebook_btn')), findsOneWidget);
      expect(find.byKey(const Key('social_connect_google_btn')), findsOneWidget);
    });

    testWidgets('Connecting Facebook sets Facebook as connected and blocks Google', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SocialConnectScreen(email: 'Emma.carter@gmail.com'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Connect Facebook
      final fbBtn = find.byKey(const Key('social_connect_facebook_btn'));
      await tester.ensureVisible(fbBtn);
      await tester.tap(fbBtn);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Facebook is now connected
      expect(SocialLinkManager.isFacebookLinked, isTrue);
      expect(find.byKey(const Key('social_unlink_facebook_btn')), findsOneWidget);
      expect(find.text('เชื่อมต่อแล้ว'), findsWidgets);

      // Google is now locked/blocked
      expect(find.text('ไม่สามารถเชื่อมต่อ Google ได้'), findsOneWidget);

      // Tapping disabled Google button shows warning
      final ggBtn = find.byKey(const Key('social_connect_google_btn'));
      await tester.ensureVisible(ggBtn);
      await tester.tap(ggBtn);
      await tester.pumpAndSettle();
      expect(find.text('ไม่สามารถเชื่อมต่อ Google ได้'), findsWidgets);
      expect(find.text('เข้าใจแล้ว'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('เข้าใจแล้ว'));
      await tester.pumpAndSettle();

      // Now unlink Facebook
      final fbUnlinkBtn = find.byKey(const Key('social_unlink_facebook_btn'));
      await tester.ensureVisible(fbUnlinkBtn);
      await tester.tap(fbUnlinkBtn);
      await tester.pumpAndSettle();

      expect(find.text('ยืนยันยกเลิก'), findsOneWidget);
      await tester.tap(find.text('ยืนยันยกเลิก'));
      await tester.pumpAndSettle();

      // Both are unlinked again
      expect(SocialLinkManager.linkedProvider, isNull);
      expect(find.byKey(const Key('social_connect_facebook_btn')), findsOneWidget);
      expect(find.byKey(const Key('social_connect_google_btn')), findsOneWidget);
    });
  });
}
