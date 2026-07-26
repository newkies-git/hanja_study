import 'package:flutter/material.dart';

/// 이용약관 및 개인정보처리방침의 본문을 관리하는 컴포넌트.
class TermsModalContent extends StatelessWidget {
  const TermsModalContent({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 이용약관 (Terms of Use) 본문
  static const String termsOfUse = '''
제 1 조 (목적)
이 약관은 추사 1817(이하 "앱")이 제공하는 모든 서비스의 이용조건 및 절차, 이용자와 앱의 권리, 의무, 책임사항을 규정함을 목적으로 합니다.

제 2 조 (용어의 정의)
1. "서비스"라 함은 앱이 제공하는 모든 학습 및 관련 기능을 의미합니다.
2. "이용자"라 함은 앱에 접속하여 이 약관에 따라 서비스를 이용하는 회원 및 비회원을 말합니다.

제 3 조 (약관의 효력 및 변경)
1. 이 약관은 앱 내에 게시함으로써 효력이 발생합니다.
2. 앱은 필요한 경우 관련 법령을 위배하지 않는 범위 내에서 이 약관을 변경할 수 있습니다.

제 4 조 (서비스 이용)
1. 이용자는 앱이 정한 절차에 따라 가입하여 서비스를 이용할 수 있습니다.
2. 서비스 이용은 앱의 업무상 또는 기술상 특별한 지장이 없는 한 연중무휴, 1일 24시간 운영을 원칙으로 합니다.
''';

  /// 개인정보처리방침 (Privacy Policy) 본문
  static const String privacyPolicy = '''
1. 개인정보의 수집 및 이용 목적
추사 1817은 서비스 제공을 위해 필요한 최소한의 개인정보를 수집합니다.
- 회원가입 및 관리: 서비스 이용 의사 확인, 본인 식별 등
- 서비스 제공: 학습 기록 관리, 맞춤형 콘텐츠 제공

2. 수집하는 개인정보 항목
- 필수항목: 이름, 이메일 주소, 비밀번호
- 선택항목: 관심 분야 및 학습 설정

3. 개인정보의 보유 및 이용 기간
이용자의 개인정보는 수집 및 이용 목적이 달성되면 지체 없이 파기합니다. 단, 관계 법령에 의해 보존할 필요가 있는 경우 해당 기간 동안 보관합니다.

4. 개인정보의 제3자 제공
추사 1817은 개인정보를 원칙적으로 이용자의 동의 없이 제3자에게 제공하지 않습니다.
''';
}
