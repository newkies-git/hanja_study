import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 디자인 시스템 "Minimalist" 스타일 텍스트 입력 필드.
///
/// 하단 밑줄이나 박스 테두리 없이 [surfaceContainerLow] 배경만으로
/// 입력 영역을 정의한다 (No-Line Rule).
/// 포커스 시 배경이 [surfaceContainerLowest]로 전환된다.
class EditorialTextField extends StatelessWidget {
  const EditorialTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: HanjaColors.surfaceContainerLow,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
