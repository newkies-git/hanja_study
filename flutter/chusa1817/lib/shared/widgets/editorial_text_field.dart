import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';

/// 디자인 시스템 "Minimalist" 스타일 텍스트 입력 필드.
///
/// 하단 밑줄이나 박스 테두리 없이 배경색 변화(No-Line Rule)만으로 영역을 정의한다.
/// 포커스 시 배경이 [surfaceContainerLowest]로 전환되며 미세한 글로우 효과가 추가된다.
class EditorialTextField extends StatefulWidget {
  const EditorialTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.validator,
    this.fillColor,
    this.textColor,
    this.hintColor,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;

  @override
  State<EditorialTextField> createState() => _EditorialTextFieldState();
}

class _EditorialTextFieldState extends State<EditorialTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        color: _isFocused
            ? HanjaColors.surfaceContainerLowest
            : (widget.fillColor ?? HanjaColors.surfaceContainerLow),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: HanjaColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        style: TextStyle(
          color: widget.textColor ?? HanjaColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: widget.hintColor ?? HanjaColors.outline,
            fontSize: 14,
          ),
          filled: false, // AnimatedContainer에서 배경 처리
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
