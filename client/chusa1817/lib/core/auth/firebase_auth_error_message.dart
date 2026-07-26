import 'package:firebase_auth/firebase_auth.dart';

String firebaseAuthErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }

  switch (error.code) {
    case 'invalid-email':
      return '이메일 형식이 올바르지 않습니다.';
    case 'user-disabled':
      return '이 계정은 비활성화되어 있습니다. 관리자에게 문의해 주세요.';
    case 'user-not-found':
      return '해당 이메일로 가입된 계정을 찾을 수 없습니다.';
    case 'wrong-password':
      return '비밀번호가 올바르지 않습니다.';
    case 'invalid-credential':
      return '로그인 정보가 올바르지 않습니다.';
    case 'invalid-app-credential':
      return '기기 인증에 실패했습니다. (Play 서비스/에뮬레이터 이미지 확인 필요)';
    case 'missing-recaptcha-token':
    case 'captcha-check-failed':
      return '자동화 방지(캡차) 검증에 실패했습니다. 잠시 후 다시 시도해 주세요.';
    case 'email-already-in-use':
      return '이미 사용 중인 이메일입니다.';
    case 'weak-password':
      return '비밀번호가 너무 약합니다. 더 강한 비밀번호를 설정해 주세요.';
    case 'operation-not-allowed':
      return '현재 이 로그인 방식이 비활성화되어 있습니다. (Firebase Auth 설정 필요)';
    case 'network-request-failed':
      return '네트워크 연결을 확인해 주세요.';
    case 'too-many-requests':
      return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    default:
      return error.message ?? '인증에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }
}

