import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Sign In
  final _loginEmailController = TextEditingController(text: 'user@mealmate.com');
  final _loginPasswordController = TextEditingController(text: '123456');

  // Controllers for Sign Up
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  String _selectedRole = 'user'; // 'user' (ผู้ใช้ทั่วไป) or 'owner' (เจ้าของร้าน)

  bool _isLoading = false;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).login(
            _loginEmailController.text.trim(),
            _loginPasswordController.text.trim(),
          );
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).register(
            email: _regEmailController.text.trim(),
            password: _regPasswordController.text.trim(),
            name: _regNameController.text.trim(),
            phone: _regPhoneController.text.trim(),
            role: _selectedRole,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedRole == 'owner'
                ? 'ลงทะเบียนสำเร็จ! เข้าสู่ระบบเจ้าของร้าน'
                : 'ลงทะเบียนสำเร็จ! ยินดีต้อนรับสู่ Mealmate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('ลงทะเบียนไม่สำเร็จ', e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message.isNotEmpty ? message : 'Email หรือ Password ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง', style: TextStyle(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _quickLogin(String role) {
    ref.read(authProvider.notifier).switchDemoRole(role);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Brand Logo & Heading
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7A7A), AppConstants.primaryColor],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: const TextSpan(
                        text: 'Meal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppConstants.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: 'mate',
                            style: TextStyle(color: AppConstants.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ยินดีต้อนรับสู่อาณาจักรของกิน',
                      style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Bar (Login vs Register)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppConstants.primaryColor,
                  unselectedLabelColor: AppConstants.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'เข้าสู่ระบบ'),
                    Tab(text: 'ลงทะเบียนใหม่'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar Views
              SizedBox(
                height: 440,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Quick Test Mode Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'โหมดทดสอบรวดเร็ว (Demo Roles)',
                      style: TextStyle(fontSize: 11, color: AppConstants.textMuted),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Role Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('ผู้ใช้ทั่วไป', style: TextStyle(fontSize: 12)),
                      onPressed: () => _quickLogin('user'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.storefront, size: 16),
                      label: const Text('เจ้าของร้าน', style: TextStyle(fontSize: 12)),
                      onPressed: () => _quickLogin('owner'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings, size: 16),
                      label: const Text('แอดมิน', style: TextStyle(fontSize: 12)),
                      onPressed: () => _quickLogin('admin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _loginEmailController,
          decoration: InputDecoration(
            labelText: 'อีเมล (Email)',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPass,
          decoration: InputDecoration(
            labelText: 'รหัสผ่าน (Password)',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('กรุณาติดต่อแอดมินเพื่อรีเซ็ตรหัสผ่าน')),
              );
            },
            child: const Text('ลืมรหัสผ่าน?', style: TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection Chips
        const Text(
          'เลือกประเภทบัญชีของคุณ:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text('ผู้ใช้ทั่วไป'),
                  ],
                ),
                selected: _selectedRole == 'user',
                selectedColor: AppConstants.primaryLight,
                labelStyle: TextStyle(
                  color: _selectedRole == 'user' ? AppConstants.primaryColor : AppConstants.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'user');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront, size: 16),
                    SizedBox(width: 4),
                    Text('เจ้าของร้าน'),
                  ],
                ),
                selected: _selectedRole == 'owner',
                selectedColor: Colors.orange[50],
                labelStyle: TextStyle(
                  color: _selectedRole == 'owner' ? Colors.deepOrange : AppConstants.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'owner');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regNameController,
          decoration: InputDecoration(
            labelText: _selectedRole == 'owner' ? 'ชื่อเจ้าของร้าน / ผู้ดูแล' : 'ชื่อ-นามสกุล',
            prefixIcon: const Icon(Icons.badge_outlined),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _regEmailController,
          decoration: InputDecoration(
            labelText: 'อีเมล (Email)',
            prefixIcon: const Icon(Icons.email_outlined),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _regPhoneController,
          decoration: InputDecoration(
            labelText: 'เบอร์โทรศัพท์',
            prefixIcon: const Icon(Icons.phone_outlined),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscureRegPass,
          decoration: InputDecoration(
            labelText: 'รหัสผ่าน (อย่างน้อย 6 ตัวอักษร)',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureRegPass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
            ),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedRole == 'owner' ? Colors.deepOrange : AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  _selectedRole == 'owner' ? 'ลงทะเบียนเจ้าของร้าน' : 'ลงทะเบียนผู้ใช้ใหม่',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
