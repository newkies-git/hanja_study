import '../router/app_router.dart';

/// 앱 내 주요 라우트 경로를 생성하는 유틸리티.
abstract final class RouteBuilders {
  /// 한자 상세 화면 경로.
  static String hanjaDetail(String id) => '${AppRoutes.hanjaDetail}/$id';

  /// 쓰기 연습 화면 경로. [label]은 화면 상단에 표시할 훈음 문자열.
  static String study(String id, String label) =>
      '${AppRoutes.study}/$id?meaning=${Uri.encodeComponent(label)}';
}
