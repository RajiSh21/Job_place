import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/otp_input_field.dart';
import '../../config/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _secondsLeft = 60;
  Timer? _timer;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP ६ अंकको हुनुपर्छ।')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOTP(_otp);
    if (!mounted) return;
    if (success) {
      final user = auth.currentUser;
      if (user?.hasName == false) {
        context.go('/auth/role');
      } else if (user?.role == 'worker') {
        context.go('/worker/dashboard');
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'OTP गलत छ।'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    await auth.sendOTP(widget.phone);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'OTP प्रमाणित गर्नुहोस्',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'OTP पठाइयो: ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    ),
                    TextSpan(
                      text: '+977 ${widget.phone}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              OtpInputField(
                onCompleted: (otp) {
                  setState(() => _otp = otp);
                  _verify();
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: auth.loading ? null : _verify,
                child: auth.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('प्रमाणित गर्नुहोस्'),
              ),
              const SizedBox(height: 20),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'पुनः पठाउन: $_secondsLeft सेकेन्ड',
                        style: const TextStyle(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('OTP पुनः पठाउनुहोस्'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
