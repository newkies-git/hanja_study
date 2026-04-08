// 퀴즈 세션에서 사용하는 공유 모델.

enum QuizQuestionType {
  /// 한자 제시 → 훈·음 4지선다
  readingChoice,

  /// 훈·음 제시 → 한자 4지선다
  characterChoice,
}

/// 퀴즈 유형 선택 (설정 화면에서 사용)
enum QuizTypeOption {
  readingChoice('훈음 선택', '한자를 보고 훈·음을 고르세요'),
  characterChoice('한자 선택', '훈·음을 보고 한자를 고르세요'),
  mixed('혼합', '두 유형을 섞어서 출제합니다');

  const QuizTypeOption(this.label, this.description);
  final String label;
  final String description;
}

class QuizQuestion {
  const QuizQuestion({
    required this.hanjaId,
    required this.character,
    required this.reading,
    required this.meaning,
    required this.choices,
    required this.correctIndex,
    required this.type,
  });

  final String hanjaId;
  final String character;
  final String reading;
  final String meaning;

  /// 4개 선택지.
  ///  - readingChoice: "{reading} {meaning}" 형태 문자열
  ///  - characterChoice: 한자 문자 1글자
  final List<String> choices;

  /// choices 내 정답 인덱스 (0~3)
  final int correctIndex;
  final QuizQuestionType type;
}

class QuizResultData {
  const QuizResultData({
    required this.questions,
    required this.userAnswers,
  });

  final List<QuizQuestion> questions;

  /// 사용자가 선택한 인덱스 (0~3). 미응답 시 -1.
  final List<int> userAnswers;

  int get totalCount => questions.length;

  int get correctCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctIndex) count++;
    }
    return count;
  }

  double get accuracy => totalCount > 0 ? correctCount / totalCount : 0;

  List<int> get wrongIndices {
    final result = <int>[];
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] != questions[i].correctIndex) result.add(i);
    }
    return result;
  }
}
