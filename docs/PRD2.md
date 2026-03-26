좋습니다.
그렇다면 구조를 다음처럼 정리하는 것이 가장 안정적입니다.

전제는 이제 명확합니다.
“한자 목록 추출”은 1회성 또는 별도 배치로 수행하고, 이후 운영 단계에서는 원천 한자 목록과 메타데이터를 내부 마스터 데이터로 관리합니다. 따라서 이후 과제의 핵심은 수집보다 정밀한 데이터 구조화와 앱 학습 엔진에 적합한 형태로의 정규화입니다.

아래에서는 제가 앞서 언급한 둘째, 셋째, 넷째 작업을 각각 구체적인 실행 제안으로 정리하겠습니다.

⸻

1. 둘째 작업 제안

네이버 한자사전 파서를 “텍스트 파싱”에서 “네트워크 기반 구조 추출”로 전환

1.1 목적

현재 방식은 화면 텍스트를 긁어 정규식으로 파싱하는 구조입니다. 이 방식은 빠르게 시제품을 만들 수는 있지만, 운영 단계에서는 다음 문제가 큽니다.
	•	화면 DOM이 바뀌면 파서가 쉽게 깨짐
	•	획순 정보가 이미지/SVG/비동기 응답으로 섞여 있으면 정확도가 떨어짐
	•	단어, 성어, 유래, 학습정보가 한 화면 텍스트에 혼합되어 정제 비용이 커짐
	•	필드별 출처와 품질 검증이 어려움

따라서 이후 단계에서는 브라우저 렌더링 결과 텍스트를 읽는 방식이 아니라,
페이지 로딩 시 발생하는 XHR/fetch 응답 또는 내부 JSON 데이터를 직접 캡처하여 구조화하는 방향으로 바꾸는 것이 적절합니다.

⸻

1.2 목표 산출물

각 한자에 대해 아래 계층으로 데이터를 확보합니다.
	•	기본 정보 JSON
	•	한자
	•	음
	•	뜻
	•	부수
	•	총획수
	•	교육용/급수
	•	유래/설명
	•	획순 원본 데이터
	•	stroke order
	•	stroke path
	•	stroke animation sequence
	•	단어/숙어/성어 원본 데이터
	•	표제어
	•	한자 표기
	•	뜻풀이
	•	출전/분류
	•	페이지 메타
	•	수집시각
	•	source_url
	•	parser_version
	•	raw_payload_hash

⸻

1.3 권장 수집 아키텍처

수집 계층 분리

다음 3단 구조를 권장합니다.

A. Browser Collector
	•	Playwright 또는 Puppeteer 사용
	•	페이지 진입 시 발생하는 모든 response 이벤트 수집
	•	URL 패턴, content-type, response body 저장
	•	스크린샷은 디버깅용으로만 저장

B. Raw Payload Store
	•	원본 응답 JSON/HTML/SVG를 그대로 보관
	•	예:
	•	raw/naver/佳/page.html
	•	raw/naver/佳/xhr_001.json
	•	raw/naver/佳/stroke.svg

C. Structured Extractor
	•	raw payload에서 필요한 필드만 정규화
	•	앱에서 사용할 엔티티로 변환
	•	파서 버전 관리

⸻

1.4 Playwright 기반 제안 코드 구조

실제 구현은 다음 구조가 좋습니다.

collector/
 ├─ browser_collector.py
 ├─ response_router.py
 ├─ raw_store.py
 └─ extractors/
     ├─ basic_info_extractor.py
     ├─ stroke_extractor.py
     ├─ words_extractor.py
     └─ idiom_extractor.py

핵심 포인트는 page.content()만 보지 말고, 아래를 함께 잡는 것입니다.
	•	page.on("response", ...)
	•	응답 URL
	•	응답 본문
	•	content-type
	•	status code

예시 설계:

def attach_response_logger(page, raw_dir):
    def handle_response(response):
        try:
            url = response.url
            status = response.status
            headers = response.headers
            ctype = headers.get("content-type", "")
            body = response.body()

            # URL 패턴/ctype 기준 저장
            save_raw_payload(raw_dir, url, status, ctype, body)
        except Exception as e:
            print("response logging error:", e)

    page.on("response", handle_response)


⸻

1.5 실무상 기대 효과

이 구조로 바꾸면 다음 장점이 있습니다.
	•	화면 UI 변경에 덜 민감함
	•	획순 데이터가 JSON/SVG로 존재할 경우 정확하게 확보 가능
	•	기본정보/단어/성어를 개별 source payload로 분리 가능
	•	재파싱 가능
	•	품질 이슈 발생 시 raw payload 재검증 가능

⸻

1.6 제안 의견

이 작업은 단순 개선이 아니라, 사실상 데이터 수집 계층을 “운영형”으로 바꾸는 핵심 작업입니다.
앱이 교육 서비스라면 콘텐츠 품질 문제가 치명적이므로, 저는 이 작업을 가장 우선순위 높게 봅니다.

⸻

2. 셋째 작업 제안

획순 데이터는 svg_paths + 정규화 points + stroke metadata를 함께 저장하는 이중 구조로 설계

2.1 목적

획순 정보는 앱에서 가장 중요한 데이터입니다.
한자를 단순히 보여주는 앱이 아니라 “획순대로 써야 하는 학습 앱”이므로, 획순 데이터는 단순 이미지나 GIF로는 부족합니다.

앱에는 최소 두 종류의 활용이 있습니다.

A. 렌더링/애니메이션용
	•	한 획씩 재생
	•	현재 획 강조
	•	획순 보기
	•	반투명 가이드 표시

B. 필기 판정용
	•	시작점 비교
	•	방향 비교
	•	순서 비교
	•	위치/비율 비교
	•	자형 유사도 비교

이 두 목적이 다르므로 저장 방식도 분리해야 합니다.

⸻

2.2 권장 저장 구조

1) 원본 벡터
	•	svg_paths
	•	장점:
	•	애니메이션 렌더링이 좋음
	•	확대/축소 손실 없음
	•	획별 경로 보존

2) 필기검증용 좌표열
	•	normalized_points
	•	장점:
	•	알고리즘 비교에 적합
	•	방향/형태/길이 계산 가능
	•	기기 해상도와 무관하게 비교 가능

3) 보조 메타데이터
	•	stroke_order
	•	stroke_type
	•	bbox
	•	start_hint
	•	end_hint
	•	centerline
	•	allowed_deviation_profile

⸻

2.3 권장 엔티티 예시

{
  "stroke_data_id": "stroke_4F73",
  "char": "佳",
  "total_strokes": 8,
  "svg_paths": [
    "M10,20 C...",
    "M..."
  ],
  "strokes": [
    {
      "order": 1,
      "type": "left_falling",
      "normalized_points": [[0.12, 0.18], [0.15, 0.24], [0.21, 0.39]],
      "start_hint": [0.12, 0.18],
      "end_hint": [0.21, 0.82],
      "direction": "top_to_bottom",
      "bbox": [0.12, 0.18, 0.21, 0.82]
    }
  ]
}


⸻

2.4 추가로 넣어야 할 필드

운영 수준에서는 아래도 넣는 것이 좋습니다.

stroke_group

복합획 또는 교육용 묶음 표시가 필요할 수 있습니다.

canonical_square_size

정규화의 기준 캔버스 크기
예: 1000 x 1000

display_scale

정답 예시를 정사각형의 80% 크기로 표시하기 위한 기본 비율
예: 0.8

anchor_box

한 글자의 전체 배치 기준 사각형
이 값이 있어야 글자를 화면 정사각형 중앙에 안정적으로 배치할 수 있습니다.

⸻

2.5 앱 엔진 측면 제안

획순 엔티티는 수집과 동시에 앱용으로 바로 쓰지 말고, 아래 3개 단계로 가공하는 것이 좋습니다.

Stage 1. Raw Stroke
	•	SVG path 원본
	•	변형 없음

Stage 2. Canonical Stroke
	•	정규화
	•	bbox 계산
	•	points 샘플링
	•	direction 계산

Stage 3. Learning Stroke Profile
	•	초급 허용오차
	•	중급 허용오차
	•	고급 허용오차
	•	시작점 반경
	•	종점 반경
	•	방향 편차 허용각
	•	길이 편차 허용치

즉, 획순 데이터는 단순 “표시용 자료”가 아니라
학습 판정 프로파일까지 확장되어야 합니다.

⸻

2.6 제안 의견

이 부분은 앱의 차별화 포인트입니다.
대부분의 한자 앱은 획순을 보여주는 데서 끝나지만, 귀하의 앱은 필순 검증이 핵심이므로, 획 데이터 설계에 가장 많은 품질 투자를 해야 합니다.
저는 특히 svg_paths를 버리지 말고 반드시 유지할 것을 권합니다. 나중에 애니메이션 품질, 리플레이 기능, 교정 오버레이를 만들 때 매우 유용합니다.

⸻

3. 넷째 작업 제안

단어/숙어/성어 파서를 한자 상세화면 텍스트 통합 파싱에서 “콘텐츠 영역별 분리 수집” 방식으로 재설계

3.1 목적

현재 방식은 화면 전체 텍스트에서
가객(佳客): 반갑고 귀한 손님
같은 패턴을 정규식으로 찾는 구조입니다.

이 방식은 시제품에서는 유효하지만 운영 단계에서는 다음 문제가 있습니다.
	•	단어와 성어가 혼합될 수 있음
	•	학습정보 설명 문장 속 한자어가 오탐될 수 있음
	•	출전, 주석, 설명문이 뜻풀이로 오인될 수 있음
	•	중복 제거 품질이 떨어짐
	•	단어와 숙어/성어 구분이 어려움

따라서 이후에는 화면 영역 또는 source payload 단위로 분리 파싱해야 합니다.

⸻

3.2 콘텐츠 타입 분리 기준

최소한 아래 4개로 분리하십시오.

A. 단어 엔티티
	•	2~4음절 중심 일반 한자어
	•	예: 가객(佳客), 가경(佳境)

B. 숙어 엔티티
	•	관용적 표현
	•	2자/4자/혼합형 가능

C. 성어/고사성어 엔티티
	•	출전, 의미, 문맥 정보가 있는 관용 표현
	•	예: 漸入佳境

D. 학습 설명 엔티티
	•	자원 설명
	•	유래
	•	자형 설명
	•	품사/용법 주석

이 네 가지를 섞으면 안 됩니다.

⸻

3.3 권장 데이터 모델

단어 엔티티

{
  "word_id": "word_1001",
  "word": "가경",
  "hanja": "佳境",
  "meaning": "흥미와 분위기가 고조되어 가장 좋은 단계",
  "related_hanja": ["佳", "境"],
  "school_recommended": true,
  "content_type": "word"
}

성어 엔티티

{
  "idiom_id": "idiom_2001",
  "phrase": "점입가경",
  "hanja": "漸入佳境",
  "meaning": "들어갈수록 점점 재미가 있음",
  "source_note": "사기, 진서",
  "related_hanja": ["漸", "入", "佳", "境"],
  "content_type": "idiom"
}


⸻

3.4 파싱 전략

1단계. source payload 분리
	•	단어 목록 payload
	•	성어/숙어 목록 payload
	•	학습정보 payload

2단계. 전용 extractor 적용
	•	words_extractor.py
	•	idiom_extractor.py
	•	learning_info_extractor.py

3단계. 후처리
	•	중복 제거
	•	표기 정규화
	•	뜻풀이 정리
	•	포함 한자 역색인 생성

⸻

3.5 포함 한자 역색인 생성 제안

앱에서 중요한 기능 중 하나는 한자를 중심으로 단어/성어를 보여주는 것입니다.
그러므로 콘텐츠 저장 후 다음 인덱스를 자동 생성하는 것이 좋습니다.

예:

{
  "佳": {
    "words": ["word_1001", "word_1002"],
    "idioms": ["idiom_2001"]
  }
}

이렇게 하면 앱 상세화면에서 “이 한자가 포함된 단어/성어”를 매우 빠르게 조회할 수 있습니다.

⸻

3.6 품질 관리 규칙 제안

운영용 품질을 위해 아래 규칙을 넣는 것이 좋습니다.

단어 품질 규칙
	•	word는 한글 표기 존재
	•	hanja는 한자 표기 존재
	•	길이 불일치 시 검토 대상
	•	뜻풀이가 지나치게 길면 요약 버전 별도 생성

성어 품질 규칙
	•	4자 성어 여부 태깅
	•	출전 여부 태깅
	•	교육용 추천 여부 태깅
	•	학습 난이도 태깅

공통 규칙
	•	동일 hanja + meaning 중복 제거
	•	표제어 공백/특수문자 정규화
	•	원문과 표시용 텍스트 분리 저장

⸻

3.7 제안 의견

귀하의 앱에서는 “한자 1자 학습”이 시작점이지만, 학습 효과를 높이는 것은 결국 단어/성어 연결성입니다.
따라서 이 영역은 단순 부가 기능이 아니라, 사용자 체감 가치를 높이는 핵심 콘텐츠입니다.
특히 중·고등 학습자에게는 단어 연계가, 상위 사용자나 급수 대비 사용자에게는 성어/숙어 연계가 강하게 작동합니다.

⸻

4. 세 작업의 우선순위 제안

제가 권하는 우선순위는 아래와 같습니다.

1순위: 둘째 작업

네트워크 기반 raw payload 수집 구조 전환

이유:
	•	이후 모든 데이터 품질의 기반
	•	DOM 변경 리스크 완화
	•	재처리 가능성 확보

2순위: 셋째 작업

획순 엔티티 이중 구조화

이유:
	•	앱 핵심 기능이 필기 학습이기 때문
	•	렌더링과 판정을 동시에 만족시켜야 함

3순위: 넷째 작업

단어/성어/숙어 파서 분리

이유:
	•	콘텐츠 품질을 올리고 학습 확장성을 높임
	•	하지만 핵심 판정 엔진보다는 한 단계 뒤

⸻

5. 권장 작업 패키지

실행 가능한 작업 단위로 나누면 다음 3개 패키지가 적절합니다.

패키지 A. 수집 인프라 고도화
	•	response logger 추가
	•	raw payload 저장
	•	source URL 분류
	•	parser versioning
	•	재처리 배치 스크립트

패키지 B. 획순 데이터 표준화
	•	svg path 추출
	•	point 샘플링
	•	canonical normalization
	•	bbox 및 direction 계산
	•	learning profile 생성

패키지 C. 어휘 콘텐츠 정규화
	•	단어 extractor
	•	성어 extractor
	•	출전/주석 분리
	•	포함 한자 역색인 생성
	•	중복 정제 규칙 추가

⸻

6. 최종 의견

현재 방향은 적절합니다.
한자 목록만 확보되면, 이후 성공 여부는 “몇 글자를 모았는가”보다 얼마나 안정적으로 구조화하고 재사용 가능한 데이터 자산으로 만들었는가에 달려 있습니다.

제 판단으로는 특히 다음 원칙을 유지하는 것이 중요합니다.
	•	원본 raw payload는 반드시 보존할 것
	•	획순은 이미지가 아니라 벡터/좌표 데이터로 관리할 것
	•	단어/성어는 별도 타입으로 분리할 것
	•	앱 표시용 데이터와 필기검증용 데이터는 분리할 것

원하시면 다음 단계로 바로 이어서
1) 이 3개 작업에 대한 디렉터리 구조,
2) Python 코드 골격,
3) SQLite/PostgreSQL 테이블 설계,
4) Flutter 앱에서 사용할 API 스펙까지 정리해 드리겠습니다.