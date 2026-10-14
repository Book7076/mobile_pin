import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/auth/register_screen.dart';
import 'package:pin_mobile/screens/profile/forgot_password_otp_screen.dart';
import 'package:pin_mobile/screens/profile/forgot_password_screen.dart';
import 'package:pin_mobile/screens/profile/reset_password_screen.dart';
import 'package:pin_mobile/screens/profile/reset_password_success_screen.dart';

// 1x1 transparent PNG for mock network images
final List<int> _kTransparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Auth Registration and Password Reset Comprehensive Tests', () {
    testWidgets('1. RegisterScreen renders all registration input fields and labels', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('สมัครสมาชิก'), findsWidgets);

      // Check form fields by keys
      expect(find.byKey(const Key('first_name_field')), findsOneWidget);
      expect(find.byKey(const Key('last_name_field')), findsOneWidget);
      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);

      // Check back button
      expect(find.byKey(const Key('register_back_button')), findsOneWidget);
    });

    testWidgets('2. RegisterScreen shows validation alert on empty submit', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit button with empty fields
      final submitButton = find.byKey(const Key('register_submit_button'));
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Snackbar validation message appears for empty first name
      expect(find.text('กรุณากรอกชื่อจริง'), findsOneWidget);
    });

    testWidgets('3. ForgotPasswordScreen renders email input and submit button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'test@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ลืมรหัสผ่าน'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('ส่งรหัสยืนยัน'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('4. ForgotPasswordOtpScreen renders 6 OTP boxes and timer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ForgotPasswordOtpScreen(email: 'user@example.com'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ลืมรหัสผ่าน'), findsOneWidget);
      expect(find.textContaining('user@example.com'), findsOneWidget);
      expect(find.text('ยืนยัน'), findsOneWidget);
      // Timer countdown text
      expect(find.textContaining('00:'), findsOneWidget);
      // Verify OTP text fields exist
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('5. ResetPasswordScreen renders password inputs and save button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordScreen(email: 'user@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ลืมรหัสผ่าน'), findsOneWidget);
      expect(find.text('รหัสผ่านใหม่'), findsOneWidget);
      expect(find.text('ยืนยันรหัสผ่านใหม่'), findsOneWidget);
      expect(find.text('ยืนยัน'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('6. ResetPasswordSuccessScreen renders success icon and return button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ResetPasswordSuccessScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขรหัสผ่านสำเร็จ'), findsOneWidget);
      expect(find.textContaining('รหัสผ่านของคุณถูกเปลี่ยนเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('กลับสู่หน้าโปรไฟล์'), findsOneWidget);
    });
  });
}
