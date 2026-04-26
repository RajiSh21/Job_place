import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/nepal_phone_field.dart';
import '../../utils/validators.dart';
import '../../config/app_theme.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();
    final success = await auth.sendOTP(phone);
    if (mounted && success) {
      context.push('/auth/otp', extra: phone);
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'नमस्ते! 🙏',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'KaamKhojo मा स्वागत छ।\nफोन नम्बर प्रविष्ट गर्नुहोस्।',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 40),
                const Text(
                  'फोन नम्बर',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                NepalPhoneField(
                  controller: _phoneController,
                ),
                const SizedBox(height: 12),
                Text(
                  'OTP तपाईंको फोनमा पठाइनेछ।',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: auth.loading ? null : _sendOtp,
                  child: auth.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('OTP पठाउनुहोस्'),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Nepal\'s #1 local services marketplace',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
