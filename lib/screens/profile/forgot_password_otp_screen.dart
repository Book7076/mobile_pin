import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _countdown = 45;

  @override
  void initState() {
    super.initState();
    // Prefill 4, 5, 6 as shown in the reference design for demo convenience
    _controllers[0].text = '4';
    _controllers[1].text = '5';
    _controllers[2].text = '6';

    _startCountdown();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกรหัสยืนยัน 6 หลักให้ครบถ้วน'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: widget.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String timerFormatted =
        '00:${_countdown.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==========================================
          // 1. TOP SOLID BURGUNDY HEADER
          // ==========================================
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              bottom: 16,
              left: 14,
              right: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 34),
                      child: Text(
                        'ลืมรหัสผ่าน',
                        style: TextStyle(
                          fontSize: 19.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. BODY CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Circular Lock Badge
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9B4BC),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF6E162B),
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Instruction Text
                  Text(
                    'กรอกรหัส 6 หลักที่ส่งไปยัง\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF666666),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6-digit OTP Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 54,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF221F21),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2CDD1),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6E162B),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Resend countdown text
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'ไม่ได้รับรหัส? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                      GestureDetector(
                        onTap: _countdown == 0 ? _startCountdown : null,
                        child: Text(
                          'ส่งอีกครั้ง ($timerFormatted)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _countdown == 0
                                ? const Color(0xFF6E162B)
                                : const Color(0xFF6E162B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  // Action Button: ยืนยัน
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E162B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor: const Color(0x336E162B),
                      ),
                      onPressed: _verifyOtp,
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
