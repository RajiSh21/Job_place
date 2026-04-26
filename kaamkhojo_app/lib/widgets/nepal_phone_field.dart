import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';

class NepalPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const NepalPhoneField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.divider)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇳🇵', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text('+977', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          ),
        ),
        hintText: '98XXXXXXXX',
        errorText: errorText,
      ),
    );
  }
}
