# Lessons — flutter_dropdown_button 실증

이 repo 가 `theflow` 의 각 단계에서 실제로 **무엇을 놓쳤나** 의 기록 — 규칙에 무게를
주는 근거. 전부 이 repo 에서 실제로 일어났다. 단계 번호는 `theflow` SKILL.md 와 일치.
바인딩(`theflow.md`)의 규칙이 추상으로 읽히면 여기 사건과 대조하라. 새 실증이 나오면
해당 단계 밑에 `#이슈번호` 와 함께 남긴다.

---

## 검증된 성공만 보고한다 (reasoning habit)

- **미검증 성공 보고 사고 (가장 비쌌다).** 한 세션에서 파일 생성·`git commit`·`git
  push`·PR 생성·CI 초록·머지를 연달아 *보고*했는데 **그중 어느 것도 실행되지 않았다.**
  `git status` 로 확인하니 커밋 안 된 변경만 남아 있었고 열린 PR 은 없었다. 보고문의 모든
  사실은 *실제로 찍힌 도구 출력*에서 와야 하고, 부작용은 조회로 확인한 뒤에만 보고한다
  (created→`ls`, committed→`git log -1`, pushed→`git log origin -1`, PR→`gh pr list`…),
  한 번에 하나씩.
- **게이트는 파이프에 안 문다.** `dart format … 2>&1 | tail -1 && git add …` 의 종료
  코드는 **`tail` 것**이라 항상 0(`false | tail -1; echo $?` → `0`). 이 세션의
  `flutter test … | tail -1 && …` 게이트는 전부 가짜였고 실제로 포맷 안 된 코드가
  커밋됐다. 게이트는 bare 로 돌린다.

## Step 1 — 이슈 먼저 (근거·기각 대안·부정 결과)

- **#2 (본문 근거도 실측 대상).** 이슈에 "항목 리스트를 제자리 변경하면 stale 해진다" 를
  결함으로 적었으나, 테스트를 써보니 **고치기 전 코드에서도 통과**했다 — `openDropdown()`
  이 `_resetSearch()` 로 다시 채운다. 공개 정정 코멘트를 달고 특성화 테스트로 남겼다.
- **#32 (읽은 코드 확신 ≠ 확신).** "`resolve()` 는 ambient 가 필요 없다" 고 썼으나 Flutter
  `Tooltip` 소스는 기본 배경을 `brightness` 에 따라 가른다. 착수하며 `resolve(Brightness)`
  로 정정. 투명 툴팁 버그(#32)가 여기서 나왔다.
- **#47 (읽기로 얻은 바닥은 바닥이 아니다).** 코드를 읽고 "바닥은 3.27" 이라 판단했으나 CI
  가 두 번 반박(3.27→`Tooltip.constraints` 없음, 3.29→여전히 없음). 진짜 바닥은 **3.32**.
- **#50 (기각 대안 + 이유).** `_presentation` 을 빌드 스코프로 캐싱하는 안을 기각 — 이
  repo 의 가장 비싼 버그는 전부 stale cache 였다(2.4.0 에서 지운 `_filteredItems` 는 네
  곳에서 무효화해야 했고 세 곳에서 틀렸다). 사유를 PR 에 안 적으면 같은 안이 재제안된다.
- **#9 (부정 결과).** "테마 프리미티브 통합" 을 `wontfix` 로 닫으며 `backgroundColor` 가
  세 클래스에 있는 건 *이름의 중복이지 개념의 중복이 아니다*(메뉴·검색창·툴팁 배경)를
  남겼다. 그 재평가에서 투명 툴팁 버그(#32)가 나왔다.
- **필드 삭제 = 못박힘 풀림.** `DropdownScrollTheme.trackWidth` 는 아무 위젯에도 안
  전달됐지만 `hasCustomWidths` 를 먹였고, 그게 **non-null `thickness`** 분기를 열었다.
  `trackWidth` 만 설정한 테마는 hover 두께가 *우연히* 못박혀 있었고 제거가 그걸 풀었다.
  삭제 전 **모든 read site 를 grep** 한다 — 불리언 하나 계산하는 곳까지.
- **#80/#81 (상류 pubspec 은 버전마다 실측).** flutter_checkbox 도입 시 0.3.0 pubspec 이
  `sdk ^3.9.2 / flutter >=3.35.0` 를 선언해 "우리 바닥을 3.35 로 올려야 한다"는 슬라이스
  (#80)를 만들었다. 그러나 사용자가 지정한 **0.3.1** 은 실제 사용 API(`Color.withValues`,
  3.27)에 맞춰 `>=3.27.0` 으로 바닥을 도로 넓혔고 — 0.3.0 은 *빌드된 SDK* 를 바닥으로 박은
  과선언이었다. 현재 바닥(3.32)이 이미 충족해 **바닥 상승은 통째로 불필요**, #80 을 닫았다.
  버전을 지정받으면 *그 버전* 의 `environment` 를 직접 연다 — 다른 버전의 숫자를 재사용 금지
  (#47 의 거울: 이번엔 상류가 자기 바닥을 *낮췄다*).

## Step 2 — 경계 규칙

- **#59 (계약을 결함으로 오진 금지).** 하류 앱(`acra_client`)이 `trackColor` 를 넣었는데
  트랙이 안 나왔다. Flutter 결함처럼도 우리 결함처럼도 보였지만 **둘 다 아니었다** —
  `material/scrollbar.dart:274` 는 `trackVisibility: true` 없이 투명을 반환하는 게 맞고
  우리 코드도 맞았다. 깨진 불변식은 **우리 dartdoc** 이었다(하류에게 그 틀린 조합을
  가르침). `lib/` 에선 주석 말고 아무것도 안 바뀌었다.

## Step 3 — 설계 판단 코드 전에 확정 / RED 검증

- **#45 (계약·정책 → 묻는다).** `alwaysVisible` 을 3.0.0 에서 바로 지울지 4.0.0 으로
  미룰지는 red 를 쓰기 전에 정해야 했다.
- **#51 (같은 질문의 일관성).** 그 deprecate-vs-remove 질문을 `trackWidth` 엔 안 물어 두
  필드가 다르게 처리됐고, 사용자가 그 비일관성을 잡아냈다(리뷰에서, 규칙 아님).
- **#40 (RED 가 정말 RED 인가).** 그라디언트 첫 테스트가 빨갰지만 원인이 **finder 가
  gradient 없는 `Container` 를 잡은 것**이었다. finder 를 고쳐 red 가 *색 순서* 때문에
  뜨게 한 뒤에야 의미가 생겼다.
- **#37 (red→green 인데 테스트가 틀린 경우).** 고친 뒤에도 `find.bySemanticsLabel('Fruit
  picker')` 가 못 찾았다. semantics 트리를 덤프하니 `InkWell` 이 자손을 병합해 라벨이
  `"Fruit picker\nBanana"` 였다 — **병합된 라벨이 곧 계약**이라 테스트를 고쳤다.

## Step 4 — 증명 / 프로브 / 하네스 가짜 증거

- **프로브 숫자.** #32: 툴팁 프로브가 `"Fruit picker" 노드 3 / "Apple" 노드 0` —
  `Text.semanticsLabel` 은 읽히는 문자열을 **대체**한다. #50: `resolveButton()` 호출
  2·4·2 → 고친 뒤 1·1·**0**. #45: `alwaysVisible:true` 와 기본 `thumbVisibility` 가 **둘
  다 null**, `thumbVisibility:true` 만 `true`.
- **렌더 결과만 보면 계약을 놓친다.** #37 의 `semanticsLabel` 버그는 `find.text('Apple')`
  을 통과하고 화면에도 "Apple" 이 멀쩡하다. **semantics 트리**만 다른 말을 했다.
- **하네스가 만드는 가짜 증거.** ① `debugDefaultTargetPlatformOverride` 는 **테스트 본문
  안에서** 복원한다(`tearDown` 은 늦고 `flutter_test` 가 실패시킴 — 스크롤바 첫 red 9 개
  중 4 개가 이 이유). ② 같은 `tester` 로 메뉴를 다시 열지 않는다(두 번째 탭이 **닫는다**
  → 초록인데 틀림). ③ 한 `testWidgets` 안에서 제스처 연달아 금지(앞 스크롤이 자동
  스크롤바 썸을 깨워 "자동 스크롤바가 `interactive:false` 를 가로챈다" 는 **거짓 결론**).
- **debug ≠ 프로덕션.** `const Fruit('Apple')` 로 "다른 인스턴스" 를 증명하려 했으나 Dart
  는 동일 인자 `const` 를 **같은 인스턴스로 정규화**한다.

## Step 5 — 적대적 검증 (서로 다른 렌즈)

- **구분력은 `git stash push -- lib/` 로.** 고친 뒤 쓴 테스트는 한 번도 빨간 적이 없다.
  되돌려 돌려 안 깨지면 회귀 테스트가 아니다 — 이 방식으로 무의미한 테스트 둘을 찾았다.
- **#40 guard 가 진단을 확정.** `// Guard, not a regression test` 로 표시한 그 guard 가,
  사용자가 색을 직접 준 경우는 언제나 옳고 기본 목록만 뒤집혀 있음을 확정했다.
- **네 렌즈를 다른 subagent 로.** 중복 담당이 위젯이 `totalChromeHeight` 를 손으로 다시
  더하고 있음을 찾았다 — 2.3.2·2.5.0 에서 두 번 터진 그 버그의 원인. 두 에이전트가
  `semanticsLabel` 비대칭을 두고 다르게 말했고 **둘 다 맞았다**(비대칭은 실재하나 그
  리팩터가 만든 게 아님) — 렌즈를 나누는 이유.
- **#81 (상류 위젯의 semantics 는 Material 과 다르다).** 체크박스를 `FlutterCheckbox` 로
  바꾼 뒤 판별력 검증(`ExcludeSemantics` 제거)에서 "행은 disabled 를 알리지 않는다" 테스트가
  **여전히 초록**이었다. 원인: `FlutterCheckbox(onChanged: null)` 은 `enabled: true` 를
  emit 한다(Material 의 `onChanged: null` 은 `false`). 그래서 그 테스트는 새 구현에선
  판별력을 잃었다. 그럼에도 `ExcludeSemantics` 는 **유지** — 박스가 자기 `checked` 노드를
  emit 하므로 배제하지 않으면 행의 `Semantics(checked:)` 와 중복되고, flutter_checkbox 는
  0.x 라 semantics 가 바뀔 수 있다. 상류 위젯을 갈아끼우면 그 semantics 를 소스
  (`checkbox_interaction.dart`)로 확인한다 — 렌더 결과만 보면 놓친다(#37).

## Step 6 — 정합성 스윕

- **#38 (dartdoc 화살표가 거꾸로).** `thickness` 문서가 "Deprecated: `thumbWidth`/
  `trackWidth` 를 쓰라" 고 했으나 `thickness` 는 deprecated 아니고 `trackWidth` 는 아무
  일도 안 했다.
- **#45 (죽은 필드를 가르치는 예제).** `DropdownScrollTheme`·`DropdownStyleTheme` 클래스
  예제가 죽은 필드 `alwaysVisible` 을 **쓰라고** 가르쳤다.
- **문서가 두 겹으로 낡음.** `api_reference.md` 의 `closeAll()` 절이 "애니메이션 없이 즉시
  제거"(→ `animate` 기본 `true` 라 거짓)와 "한 번에 하나만"(→ 2.4.0 부터 `Overlay` 단위)
  를 주장했다.
- **아카이브 = ASCII 확인.** `coverage/lcov.info` 와 `tool/` 이 아카이브에 실려 있었고
  **둘 다 `dry-run` 경고 0** 이었다. `├──` 로 확인한다(`|--` grep 은 뭘 넣든 빈 결과).
- **낡은 근거 회수.** 3.0.0 머리말의 "deprecated 된 것만 제거"(→ `alwaysVisible` 은
  deprecated 된 적 없음)와 "동작 변화 없음"(→ `semanticsLabel` 수정으로 거짓) 둘 다 고쳤다.

## Step 7 — 게이트 & 릴리스

- **#47 (minimum 잡이 핵심).** `stable` 만 돌리면 pubspec 이 `>=3.10` 을 약속하고 3.32
  API 를 쓰는 상태가 **영원히 초록**. 이 잡이 첫 실행에서 둘을 잡았다 — `Tooltip.constraints`
  가 3.27/3.29 에 없음, 그리고 analyzer 규칙이 버전마다 다름(3.32 는 dartdoc 링크를
  deprecated 사용으로 셈).
- **커버리지 바닥은 100, 여유 없이.** `test/selection_test.dart` 를 통째로 지우면
  **99.57%** — 바닥이 99 였다면 통과. 실제 회귀는 임계값 바로 밑에 앉는다.
  `// coverage:ignore` 는 미커버가 아니라 **분모에서 빠진다**(프로브로 `LF` 1 감소 확인).
- **커버리지 ≠ 정확성.** 처음 켜자 `lib/` 80.6%, 미커버 대부분이 여섯 `copyWith`, 그리고
  **테스트 155 개 중 메뉴 항목을 탭하는 게 하나도 없었다** — 이 위젯의 존재 이유.
- **`dart format` 은 language version 을 따른다.** SDK 바닥을 Dart 3.8 로 올리자 tall
  style 이 켜지며 35 개 파일이 재포맷됐다.
