import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';
import 'form_field_label.dart';

/// 레이블, 입력 필드, 에러 메시지를 하나로 묶은 통합 입력 그룹.
/// 
/// [FormField]를 직접 확장하여 중첩 검증 오류를 방지하고, 
/// 에디토리얼 디자인 가이드(42px 고정 높이)를 엄격히 준수한다.
class EditorialInputGroup extends FormField<String> {
  EditorialInputGroup({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    super.validator,
    this.onChanged,
    this.labelColor,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.isRequired = false,
  }) : super(
          initialValue: controller.text,
          builder: (FormFieldState<String> state) {
            final context = state.context;
            final textTheme = Theme.of(context).textTheme;
            final bool hasError = state.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 레이블
                Row(
                  children: [
                    FormFieldLabel(
                      label: label,
                      color: labelColor,
                    ),
                    if (isRequired)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          '*',
                          style: TextStyle(color: HanjaColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. 입력 필드 (42px 고정 박스)
                _FieldBox(
                  isFocused: state is _EditorialInputGroupState ? (state as _EditorialInputGroupState).isFocused : false,
                  hasError: hasError,
                  fillColor: fillColor,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 42),
                    child: TextField(
                      controller: controller,
                      focusNode: state is _EditorialInputGroupState ? (state as _EditorialInputGroupState).focusNode : null,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      obscuringCharacter: '*',
                      cursorColor: textColor ?? HanjaColors.primary,
                      onChanged: (value) {
                        state.didChange(value);
                        if (onChanged != null) onChanged(value);
                      },
                      style: TextStyle(
                        color: textColor ?? HanjaColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: hintColor ?? HanjaColors.outline,
                          fontSize: 14,
                          height: 1.0,
                        ),
                        filled: false,
                        prefixIcon: prefix,
                        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                        suffixIcon: suffix != null 
                            ? Theme(
                                data: Theme.of(context).copyWith(
                                  iconTheme: IconThemeData(
                                    size: 20,
                                    color: (hasError ? HanjaColors.error : HanjaColors.onSurfaceVariant).withValues(alpha: 0.7),
                                  ),
                                ),
                                child: suffix,
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 13,
                          bottom: 0,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // 3. 에러 메시지
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: hasError
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            state.errorText!,
                            style: textTheme.bodySmall?.copyWith(
                                  color: HanjaColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        );

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final Color? labelColor;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final bool isRequired;

  @override
  FormFieldState<String> createState() => _EditorialInputGroupState();
}

class _EditorialInputGroupState extends FormFieldState<String> {
  late FocusNode focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isFocused = focusNode.hasFocus;
    });
  }
}

/// 입력 필드의 박스 스타일링 (포커스 및 에러 상태 반영)
class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.child,
    required this.isFocused,
    required this.hasError,
    this.fillColor,
  });

  final Widget child;
  final bool isFocused;
  final bool hasError;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        color: hasError
            ? HanjaColors.error.withValues(alpha: 0.1)
            : (fillColor ?? HanjaColors.surfaceContainerLow), // 포커스 시 배경색을 화이트로 강제 변경하지 않음
        borderRadius: BorderRadius.circular(12),
        boxShadow: hasError || isFocused
            ? [
                BoxShadow(
                  color: hasError
                      ? HanjaColors.error.withValues(alpha: 0.25)
                      : (isFocused ? HanjaColors.primary.withValues(alpha: 0.2) : Colors.transparent),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                  spreadRadius: 1,
                ),
              ]
            : null,
        border: hasError
            ? Border.all(color: HanjaColors.error.withValues(alpha: 0.5), width: 1)
            : (isFocused 
                ? Border.all(color: HanjaColors.primary.withValues(alpha: 0.5), width: 1)
                : null),
      ),
      child: child,
    );
  }
}
