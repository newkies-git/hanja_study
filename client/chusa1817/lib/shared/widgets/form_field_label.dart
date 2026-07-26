import 'package:flutter/material.dart';

/// 폼 섹션의 레이블 텍스트 위젯.
///
/// 기존 private `_FieldLabel`을 public으로 승격하여
/// 로그인, 설정 등 여러 폼 화면에서 재사용 가능하게 한다.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
    );
  }
}
