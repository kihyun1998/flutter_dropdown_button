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
- **#90 (`git add -A` 는 내가 안 쓴 것도 담는다).** 워킹트리에 `pubspec.yaml` 의
  `dependency_overrides: flutter_checkbox: path: /Volumes/…` 가 있었다 — 주석에
  "TEMPORARY … removed immediately after the run" 이라고 적힌, 내가 만들지 않은 블록.
  `git add -A` 로 담아 푸시했고, **`test:` 라고 적힌 커밋이 패키지 매니페스트를 바꿨다.**
  그 경로는 러너에 없으므로 `pub get` 에서 **세 잡이 20 초 만에** 죽었다. `publish
  --dry-run` 도 같이 빨갰다 — 즉 그대로 머지됐다면 경로 override 가 아카이브 후보까지
  갔다. 스테이징은 `git add <경로>` 로 하거나, `-A` 를 쓸 거면 **`git diff --cached
  --stat` 을 읽고 나서** 커밋한다. 판별 신호는 커밋 stat 의 파일 수가 내가 만진 수와
  다른 것.
- **판별력 검증은 `git stash push -- lib/` 가 늘 되는 게 아니다.** 이미 커밋한 뒤에는
  stash 할 게 없어 조용히 빈 stash 가 되고, `pop` 이 "No stash entries found" 로 실패해도
  **테스트는 초록으로 돈다** — 아무것도 안 되돌린 채. 커밋 후에는 해당 줄을 직접 지우고
  돌린 뒤 `git checkout <파일>` 로 복구한다(#90 에서 2/3 red 확인).

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

- **#95 (인용문을 열어보지 않았다).** 이슈 본문이 `"anchored rather than modal, no
  scrim"` 을 "문서가 약속한 히트테스트가 코드와 다르다" 의 근거로 인용했다. 실제 문장을
  열어보니 멀티셀렉트 **UX** 서술이었다 — scrim 레이어 없음, 확인 버튼 없음, 메뉴가 열린 채
  유지됨. 셋 다 지금 코드에서 참이다. 줄 번호도 밀려 있었다(`api_reference.md:102`→136,
  `README.md:262`→264). 문서는 **틀린 게 아니라 비어 있었다**(네 표면 전부가 "탭이
  소비된다" 에 침묵). 처방이 *재작성*에서 *추가*로 바뀐다. #2 와 같은 부류지만 여기선
  근거가 아니라 **인용문 자체**가 미검증이었다.
- **#95 (대조군이 증상의 처분을 바꾼다).** 자기 동작만 재면 "닫는 탭이 삼켜진다" 는 사실만
  나오고 그건 이미 본문에 있었다. Material `DropdownButton` 을 같은 조건에 놓자 숫자가
  **글자 그대로 같았다**(둘 다 1 차 `behind=0`, 2 차 `behind=1`; `_DropdownRoute` 는
  `barrierDismissible=true` / `barrierColor=>null` 인 `PopupRoute`). 증상이 *결함*에서
  *계약*으로 재분류돼 코드 대신 문서로 갔다. **실측은 주장을 확인하고, 대조군은 주장의
  의미를 바꾼다.**

- **#95 (이름이 메커니즘을 오해시킨다 — `translucent`).** 배리어가 탭을 먹는 것을
  "히트테스트를 가로챈다" 로 읽었다. 소스는 반대를 말한다: `HitTestBehavior.translucent`
  는 자기를 히트 경로에 넣되 `hitTarget=false` 를 돌려주므로(`rendering/proxy_box.dart:183-192`)
  `RenderTheatre` 가 아래 엔트리까지 계속 히트테스트한다(`widgets/overlay.dart:1098-1100`).
  **뒤 위젯은 포인터를 실제로 받는다** — 실측 `listenerDowns=1 listenerUps=1 taps=0`.
  잃는 것은 `gestures/arena.dart:170-177` 의 "first member wins" 에서다. 대조로
  Material 의 `ModalBarrier` 는 `HitTestBehavior.opaque`(`widgets/modal_barrier.dart:441`)
  로 히트테스트 **차단**이다 — 탭 수는 같게 관측되지만 메커니즘이 다르다.
  이 한 줄이 선택지 목록을 바꿨다: **"소비를 멈춘다" 와 "`Listener` 로 바꾼다" 는 같은
  것**이다(아레나 멤버로 남아 소비만 안 할 수는 없다). 4 개인 줄 알았던 옵션이 3 개였다.

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

- **#106 (게이트를 설계 *전에* 돌려 API 가용성을 확정한다).** "티커가 꺼졌는지 물어보고
  분기한다" 가 자연스러운 설계였는데, 프로브가 아직 `TickerMode.of` 를 쓰고 있을 때
  `flutter analyze` 를 돌려보니 `info - 'of' is deprecated … 1 issue found. exit=1`.
  3.35 이후 deprecated 이고 이 repo 의 게이트는 info 하나에도 exit 1 이며, 대체재
  `TickerMode.valuesOf` 는 **3.32 바닥에 없다** — CI 두 잡이 양쪽에서 닫는다. 그래서
  픽스가 티커 상태를 **묻지 않고** teardown 을 타이머와 경주시키는 형태가 됐다.
  소스만 읽었으면 설계를 마친 뒤 CI 에서 두 번 튕겼을 것이다. **폐기용 프로브가 살아
  있는 동안이 게이트에게 API 를 물어볼 가장 싼 순간이다.**

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
- **#106 (뿌리를 한 칸 더 내려가면 이슈·픽스·테스트가 동시에 단단해진다).** 증상은
  "열린 메뉴 위로 라우트를 push 하면 화면이 잠긴다" 였다. 거기서 멈췄으면 라우트 감지
  코드가 들어가고 `TickerMode` 를 직접 끄는 소비자는 계속 깨졌을 것이다. 판별 프로브는
  **Navigator 를 빼는 것**이었다 — 맨 `TickerMode(enabled: false)` 만으로 똑같이 났다
  (`close() +2초 → anim=reverse v=1.00`, 엔트리 그대로). 그 순간 제목이
  "티커가 꺼지면 `close()` 가 끝나지 않는다" 로 바뀌었고, 회귀 테스트가 Navigator 없이
  써졌고, 픽스가 라우트를 몰라도 되게 됐다. **재현 조건에서 무엇을 *뺄* 수 있는지가
  뿌리를 찾는 방법이다.**
- **#95 (선재 결함인지는 추론하지 말고 대조 실행으로 가른다).** 완결성 패스가 꺼낸
  다섯 항목이 "우리 수정 때문이냐" 는 질문을 받았다. 코드를 읽고 "히트테스트는 안
  건드렸으니 무관" 이라 답할 수도 있었지만, `git checkout <픽스 직전 커밋> -- lib/` 로
  되돌려 같은 프로브를 한 번 돌리자 **다섯 줄이 글자 그대로 동일**하게 나왔다. 한 번의
  체크아웃이 다섯 항목을 동시에 판정한다. (끝나고 `git checkout HEAD -- lib/` 로 복구하고
  `diff` 가 비었는지 확인한다 — `git stash` 함정과 같은 자리다.)

- **#95 (잘못 만든 프로브는 추론보다 나쁘다).** `TapRegion` 의 bare-`Overlay` 무동작을
  소비자가 우회할 수 있는지 재는 프로브가 `onTapOutside=0` 을 냈다 — 하마터면 "우회도
  불가능" 을 이슈에 박을 뻔했다. 원인은 구성 오류였다: `RenderTapRegionSurface` 는
  `deferToChild` 라 탭이 **그 서브트리 안의 무언가에 실제로 맞아야** 발화하는데, surface 를
  화면 크기 `Material` **아래**에 넣어 전면(700,500)에 히트 대상이 없었다. surface 를 위로
  올리자 `1`. `MaterialApp` 에서 `TapRegion` 이 되는 것도 surface 가 화면을 감시해서가
  아니라 아래에 `Scaffold`/`Material` 이라는 화면 크기 히트 대상이 깔려서다. **0 이 나왔을
  때 왜 0 인지 설명하지 못하면 그건 아직 측정이 아니다.**
- **#95 (실패가 아니라 성공을 재서 처방을 죽였다).** bare 호스트에서 `TapRegion` 이 안
  된다(`0`)는 것만으로는 "우회하면 되지" 로 반박된다. 패키지가 자기 오버레이 엔트리 안에
  surface 를 심고 **전면 히트 타깃을 되돌리자 `1` 이 됐다** — 우회는 성공하지만, 그 성공이
  `TapRegion` 의 유일한 이점(전면 위젯 제거)을 지운다. 순환. 기각 근거가 "미측정이라
  위험" 에서 확정으로 바뀌었고, 딸린 비용(3.32 의 `consumeOutsideTaps`, CI `minimum` 잡)도
  같이 무의미해졌다. **처방을 죽이는 건 실패 측정이 아니라 무의미한 성공 측정이다.**

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

- **#96 (반박 렌즈는 판정만 뒤집는 게 아니라 선택지 자체를 늘린다).** 갭 렌즈가 "빈 상태
  높이 바닥을 순수 `resolve()` 안에 넣나, 셸의 `_buildSpec` 에서 `itemCount` 를 속이나" 의
  양자택일을 냈고, 반박 렌즈가 그 이분법을 **거짓**으로 판정하며 제3의 층을 냈다 —
  기본값 0 인 `emptyStateHeight` 필드(순수·단위테스트 가능·기존 서드파티 스펙엔 불활성·
  `resolve()` 가 읽으므로 죽은 필드 탐지기도 통과). 같은 패스에서 처방 문장 하나("기존
  emptyBuilder 를 재사용한다")가 **그 자체로 미결 API 결정**(N1: 재사용 vs 새 훅, 그리고
  semver 등급)임도 잡혔다 — 처방은 결정을 안고 있고, 렌즈는 그 결정을 표면화한다.
  두 렌즈를 스탠스로 가른 값이 정확히 여기서 나왔다.
- **#96 (한 처방의 절반은 조건이 아니라 기하다).** "조건을 `items.isEmpty` 로 넓힌다" 만으로는
  아무것도 안 보인다 — `preferredHeight` 의 항목 항이 0 이라 빈 목록 메뉴는 **크롬만큼만**
  열린다(실측 200×2 / 검색 켬 200×50). 문서화된 필드가 안 불리는 결함의 처방이 placement
  까지 내려간 이유. 증상이 "빌더가 안 불린다" 여도 뿌리는 두 모듈에 걸쳐 있을 수 있다.
- **#95 (재현 가능한 참인 관찰이 곧 결함은 아니다 — 자기 기록에도 restatement 테스트를 건다).**
  반박 렌즈가 "`Overlay` 두 개면 메뉴가 **둘 다** 열린다, 게다가 1 탭에" 를 냈고, 나는
  그걸 *"광고된 '한 번에 하나만' 계약 위반"* 으로 두 번 옮겨 적었다. 재현도 됐고 숫자도
  맞았다. **파기 직전에 근거를 다시 읽어서 뒤집혔다** — 규칙의 범위가 처음부터 `Overlay`
  단위였다: `:87-88` *"only one menu is open at a time **within an [Overlay]**"*,
  `:165-166` *"two menus in two different Overlays … **do not contend**"*. 의도된 설계다.
  덤으로 렌즈의 "방향 비대칭(한쪽은 2 탭)" 주장도 반증됐다 — 양방향 `1 탭`, 그리고
  `closeAll()` 이 양쪽에 닿는다. 레퍼런스를 빼고 재진술하는 테스트는 **남의 코드가 아니라
  우리 기록에 대해서도** 돌려야 한다: *"이 코드는 X 하고, 우리 기록은 Y 라고 말한다"* 에서
  Y 를 실제로 열어보지 않으면 렌즈의 프레이밍이 그대로 결함 등록으로 간다.
- **렌즈 보고를 액면가로 옮기지 않는다.** 위 건 말고도 이 패스에서 렌즈 주장 셋이
  깨졌다: 방향 비대칭(반증), "소비자 우회도 불가능"(측정 구성 오류였다 — surface 를
  화면 크기 `Material` **아래** 넣어 전면에 히트 대상이 없었다), 그리고 "옵션 A 와 C 는
  별개"(같은 것이었다). 렌즈는 **후보**를 내지 결론을 내지 않는다.

## Step 6 — 정합성 스윕

- **#88~#91 (빈 grep 결과를 "없다" 로 읽었다 — 한 릴리스에서 세 번).** 셋 다 같은 뿌리다:
  *검색이 아무것도 안 냈다* 를 *그런 건 없다* 로 승격했다.
  ① **줄바꿈이 문구를 갈랐다.** #91 이 "keyboard navigation" 주장을 `api_reference.md` 와
  `use_cases.md` 에서 좁히고 **README 를 놓쳤다** — pub.dev 가 가장 먼저 렌더하는 페이지다.
  `grep "keyboard navigation" README.md` 가 **0 건**을 냈기 때문인데, 실제로는 `(theming,
  keyboard\nnavigation, ...)` 로 줄을 넘어 있었다. 줄 단위 검색은 줄을 넘는 주장을 못 본다.
  여러 단어 문구는 `grep -Pzo` 나 `python re.S` 로, 아니면 첫 단어만으로 찾는다.
  ② **`documentation/` 을 통째로 대조한 적이 없었다.** 이슈마다 *건드린* 문서만 고쳤다.
  전체를 훑자 #88 이 쓴 문장을 #91 이 거짓으로 만든 것이 나왔다 — *"`InkWell` 이 기여하는
  건 bare 앵커가 갖지 못한 focusability"* 인데 #91 이 바로 그 focusability 를 줬다.
  #91 은 **같은 파일의 두 섹션 옆**을 편집하면서 못 봤다. 릴리스 끝에 `README` ·
  `CHANGELOG` · `pubspec` · `documentation/` 을 **한 세트로** 다시 읽는다.
  ③ **호출자를 깨뜨리는 항목이 CHANGELOG 에만 있었다.** `itemBuilder` 에서 `selected` 를
  선언한 호출자는 행이 라벨을 잃는데(조용히), 그 경고가 한 번 읽히고 마는 문서에만 있었다.
  깨지는 것은 그걸 디버깅할 사람이 있을 자리 — API 레퍼런스 — 에도 둔다.
- **#90 (Edit 이 prefix 만 매치하면 나머지를 조용히 옮긴다).** `CHANGELOG` 에 #90 섹션을
  끼울 때 `old_string` 이 #89 의 TEST 항목 **앞부분만** 매치했다. 실패하지 않았다 — 나머지
  문장이 삽입한 블록 뒤로 밀려 마지막 줄 끝에 들러붙었고(`…along with it The tests pump a
  single frame…`), 발행 직전에 사용자가 물어보고서야 발견됐다. 긴 줄을 앵커로 쓸 때는 그
  줄 **전체**를 쓰거나, 커밋 전에 결과를 읽는다.
- **#95/#102 (문서 수정은 결정을 담는다 — 몇 개를 담는지 세라).** "바깥 탭이 소비된다" 를
  적는 순간 그 동작은 *결함*이 아니라 *계약*이 된다. 같은 이슈의 다른 두 증상(드롭다운
  전환에 탭 두 번, 열린 채 스크롤 시 앵커 고착)도 같이 적을 뻔했는데, 그건 **미결 설계
  결정 셋을 소리 없이 확정**하는 일이었다 — 나중에 고칠 때 breaking 이 된다. 계약으로
  올린 건 대조군이 정상임을 확정한 하나뿐이고 나머지는 이슈에 남겼다(#95·#103). 판별
  질문: *이 문장을 적은 뒤에 이 동작을 고치면 breaking 인가?* 그렇다면 아직 적을 때가
  아니다. **문서 커밋이 위험해지는 건 대개 이 경로다.**
- **#95/#102 (`lib/` 를 건드려도 CHANGELOG 항목이 아닐 수 있다).** 이 커밋은 `lib/` 파일
  둘을 바꿨지만 `CHANGELOG.md` 는 비었다 — 바뀐 건 dartdoc 뿐이고, 그건 pub.dev 로 나가는
  **표면**이지 동작이 아니다. 기준은 "파일이 바뀌었나" 가 아니라 "동작이 바뀌었나" 다
  (`theflow.md` 의 CHANGELOG = 버그 인벤토리).
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

- **#106 (다음 버전 번호는 레지스트리에 물어본다 — repo 는 모른다).** `pubspec.yaml` 이
  `4.2.0`, `CHANGELOG.md` 에 4.2.0 절이 있으니 다음은 4.2.1 이라고 판단해 올렸다.
  `publish --dry-run` 이 힌트로 반박했다: *"The previous version is 4.1.0"*. 레지스트리에
  직접 확인하니 발행된 최신은 **4.1.0** 이고 `4.2.0` 은 **존재한 적이 없다** — 즉 4.2.0
  절은 스냅샷되지 않았고 아직 편집 가능하다. 4.2.1 로 갔으면 pub.dev 가 4.1.0 → 4.2.1
  로 건너뛰고 4.2.0 노트가 붕 떴을 것이다. **repo 의 버전은 "다음에 낼 것" 이고
  레지스트리의 버전은 "실제로 나간 것" 이다.** "발행된 항목은 다시 쓰지 않는다" 규칙의
  *발행 여부*도 레지스트리가 답한다.

- **#47 (minimum 잡이 핵심).** `stable` 만 돌리면 pubspec 이 `>=3.10` 을 약속하고 3.32
  API 를 쓰는 상태가 **영원히 초록**. 이 잡이 첫 실행에서 둘을 잡았다 — `Tooltip.constraints`
  가 3.27/3.29 에 없음, 그리고 analyzer 규칙이 버전마다 다름(3.32 는 dartdoc 링크를
  deprecated 사용으로 셈).
- **#90 (버전 차이는 추측으로 좁히지 말고 CI 에게 물어본다).** 새 테스트가 `stable` 에서
  초록, `3.32.0` 에서만 빨갰는데 로그에는 `Expected: false / Actual: <true>` 뿐이었다.
  "감싸는 스크롤 노드의 액션이겠지" 로 단언을 좁히면 초록은 되지만 그건 **초록 만들려고
  단언을 낮추는 것**이다. 대신 실패 메시지가 액션 목록을 실어오게 고쳐 한 번 더 돌렸다.
  답은 스크롤이 아니었다 — `[tap, moveCursorBackwardByCharacter, setSelection,
  moveCursorBackwardByWord, setText, focus]`, 즉 `EditableText` 의 액션이고 노드 크기가
  `200x146`. **바닥 버전에서는 빈 상태 메시지가 검색 필드로 병합된다**(3.44 에서는
  `166x40` 에 액션 0). 추측했다면 진짜 결함 하나를 단언과 함께 지웠을 것이다. CI 왕복
  2 분이 그 값이다.
- **한 테스트에 무관한 두 주장을 지우지 않는다.** 위 단언은 "배리어가 아님" 과 "메시지가
  버튼이 아님" 을 겸하고 있었다. 배리어를 구별하는 것은 **크기**(화면 전체)뿐이므로 그것만
  단언하고, 병합 쪽은 숫자와 함께 주석·이슈 코멘트로 뺐다. 겸하면 매트릭스 한쪽에서
  엉뚱한 이유로 빨개진다.
- **커버리지 바닥은 100, 여유 없이.** `test/selection_test.dart` 를 통째로 지우면
  **99.57%** — 바닥이 99 였다면 통과. 실제 회귀는 임계값 바로 밑에 앉는다.
  `// coverage:ignore` 는 미커버가 아니라 **분모에서 빠진다**(프로브로 `LF` 1 감소 확인).
- **커버리지 ≠ 정확성.** 처음 켜자 `lib/` 80.6%, 미커버 대부분이 여섯 `copyWith`, 그리고
  **테스트 155 개 중 메뉴 항목을 탭하는 게 하나도 없었다** — 이 위젯의 존재 이유.
- **`dart format` 은 language version 을 따른다.** SDK 바닥을 Dart 3.8 로 올리자 tall
  style 이 켜지며 35 개 파일이 재포맷됐다.
