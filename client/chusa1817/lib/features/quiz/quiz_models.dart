// 퀴즈 세션에서 사용하는 공유 모델.

enum QuizQuestionType {
  /// 한자 제시 → 훈·음 4지선다
  readingChoice,

  /// 훈·음 제시 → 한자 4지선다
  characterChoice,

  /// 훈·음 제시 → 캔버스에 직접 쓰기 (자가 채점)
  writing,
}

/// 퀴즈 유형 선택 (설정 화면에서 사용)
enum QuizTypeOption {
  readingChoice('훈음 선택', '한자를 보고 훈·음을 고르세요'),
  characterChoice('한자 선택', '훈·음을 보고 한자를 고르세요'),
  mixed('혼합', '두 유형을 섞어서 출제합니다'),
  writing('쓰기 시험', '훈·음을 보고 한자를 직접 쓰세요');

  const QuizTypeOption(this.label, this.description);
  final String label;
  final String description;
}

/// 문제당 타이머 설정
enum QuizTimerOption {
  none('없음', 0),
  ten('10초', 10),
  fifteen('15초', 15),
  twenty('20초', 20);

  const QuizTimerOption(this.label, this.seconds);
  final String label;
  final int seconds;
}

/// 범위 필터 (학교급)
enum QuizLevelFilter {
  all('전체', 'all'),
  middle('중학', 'middle'),
  high('고등', 'high');

  const QuizLevelFilter(this.label, this.value);
  final String label;
  final String value;
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
  ///  - writing: 빈 리스트 (자가 채점)
  final List<String> choices;

  /// choices 내 정답 인덱스 (0~3). writing 유형은 0 고정 (미사용).
  final int correctIndex;
  final QuizQuestionType type;
}

/// 퀴즈 세션 설정 + 문항 묶음.
class QuizSession {
  const QuizSession({
    required this.questions,
    this.timerSeconds = 0,
  });

  final List<QuizQuestion> questions;

  /// 문제당 제한 시간(초). 0이면 타이머 없음.
  final int timerSeconds;
}

class QuizResultData {
  const QuizResultData({
    required this.questions,
    required this.userAnswers,
  });

  final List<QuizQuestion> questions;

  /// 사용자가 선택한 인덱스 (0~3). 미응답/오답(자가) 시 -1.
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
