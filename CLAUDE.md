# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Agent skills

**Issue tracker.** GitHub issues in `kihyun1998/flutter_dropdown_button`, via the `gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

**Triage labels.** `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Create a label with `gh label create` the first time it is used. See `docs/agents/triage-labels.md`.

**Domain docs.** Single-context. `CONTEXT.md` and `docs/adr/` do not exist yet and their absence is expected — they are created lazily, when a term or a decision actually needs resolving. See `docs/agents/domain.md`.

## 우회 금지 (근본 층에서 고쳐라)

**증상이 보이는 층과 원인이 사는 층은 다르다.** 증상이 난 자리에서 덮지 마라. 우회는 ① 진짜 결함을 가려 고칠 압력을 없애고, ② 같은 지식을 두 층에 복제해 divergence 씨앗이 되고, ③ 잘못된 기본값을 영원히 기본값으로 남긴다. **우회하고 싶은 충동 = 멈추고 사용자에게 온다** — 무슨 상황인지 설명하고 근본 수정 여부를 *묻는다*. 혼자 우회하지도, 혼자 이슈만 파고 넘어가지도 마라.

**이 패키지는 상류다.** `just_make_logo`(`^1.6.1`)와 `penterm-2`(`^1.4.6`)가 이걸 의존한다 — 둘 다 **두 메이저 뒤에** 묶여 있다. 여기서 내린 결정은 저 둘이 언젠가 치른다. 소비처 목록은 추정하지 말고 도출한다: `for d in ../*/; do grep -l 'flutter_dropdown_button:' $d/pubspec.yaml; done`.

**그러나 "근본 층에서 고쳐라" 는 "전부 상류로 밀어라" 가 아니다.** 물을 것은 *어느 층이 상류인가* 가 아니라 **누구의 불변식이 깨졌는가** 다. 하류가 결함을 들고 와도, 상류의 동작이 *의도한 계약*이라면 근본 층은 다른 곳이다. 실증(#59): 하류 앱(`acra_client`)이 `trackColor` 를 넣었는데 트랙이 안 나왔다. Flutter 의 결함처럼도, 우리 코드의 결함처럼도 보였지만 **둘 다 아니었다** — `material/scrollbar.dart:274` 는 `trackVisibility: true` 없이는 투명을 반환하는 게 맞고, 우리 코드도 맞았다. 깨진 불변식은 **우리 dartdoc** 이었다. 클래스 예제가 하류에게 정확히 그 틀린 조합을 가르치고 있었다. `lib/` 에서 주석 말고는 아무것도 바뀌지 않았다. **계약을 결함으로 오진하면 우회를 없애는 대신 계약을 없앤다.**

**의존성은 벽이 아니라 양방향으로 새는 막이다.** 변경은 아래로만 흐르지 않는다. 실증(#47): `environment` 는 `flutter: ">=3.10.0"` 을 선언했으나 `Color.withValues`(3.27)·`WidgetStateProperty`(3.22)를 쓰고 있었고, CI 가 두 번 반박한 끝에 진짜 바닥은 **3.32** 였다. 상류(Flutter)의 요구가 이쪽 하한을 밀어 올리고, 그 하한은 캐럿 범위를 타고 **하류로 그대로 전파된다** — `pub get` 성공은 제약이 정직하다는 증거가 아니다.

**역방향도 신호다: 둘 이상의 소비처가 *독립적으로 같은 우회*에 도달했다면, 그건 이 API 의 기본값이 함정이라는 증거다.** 사람들이 올바른 옵션을 발견한 게 아니라 결함을 발견하고 돌아간 것이다. 옵션을 하나 더 얹어 도망치지 말고 기본값을 의심하라.

**크로스 repo 이슈 번호에는 repo 접두사를 붙인다.** 맨 `#N` 은 읽는 사람도 에이전트도 *현재 repo* 의 N 번으로 해석한다 — `gh issue view N` 이 그렇게 동작한다. 그 번호가 남의 트래커 것이면 404 가 아니라 **실재하지만 무관한 이슈**로 이어지므로 아무도 눈치채지 못한다. GitHub 은 저장소 마크다운에서 `#N` 을 자동 링크하지 *않으므로*(이슈·PR 본문과 달리) 깨진 링크조차 남지 않는다. 남의 트래커를 가리킬 땐 `just_tooltip#33` 처럼 쓴다.

## 작업 flow

*Substantive 변경*(버그 수정·기능 추가·동작 변경)이면 이 순서로 짠다. 단계를 *생략*하려면 (건너뛰는 게 아니라) *왜 이 변경엔 해당 없는지를 명시*한다 — 조용한 스킵 금지.

괄호 안 실증은 전부 **이 repo 에서 실제로 일어난 일**이다. 그 단계를 건너뛰었다면 놓쳤을 것이다.

### 1. 이슈 먼저 — 실측 숫자·기각한 대안·부정 결과

**이슈 본문에 쓴 근거도 실측 대상이다.** 틀린 근거가 기록에 남으면 다음 사람이 그걸 믿는다.

- 실증(#2): 이슈에 *"항목 리스트를 제자리 변경하면 stale 해진다"* 를 결함으로 적었다. 테스트를 써보니 **고치기 전 코드에서도 통과**했다 — `openDropdown()` 이 `_resetSearch()` 로 다시 채운다. 공개 정정 코멘트를 달고 그 테스트는 특성화로 남겼다.
- 실증(#32): 이슈에 *"`resolve()` 는 ambient 가 필요 없다"* 고 썼다. Flutter 의 `Tooltip` 소스를 열어보니 기본 배경이 `brightness` 에 따라 갈린다. 착수하며 `resolve(Brightness)` 로 정정했다.
- 실증(#47): 코드를 읽고 *"바닥은 Flutter 3.27"* 이라 판단했다. CI 가 두 번 반박했다(3.27 → `Tooltip.constraints` 없음, 3.29 → 여전히 없음). 진짜 바닥은 3.32 였다.

**기각한 대안과 그 이유를 함께 적는다.** 실증(#50): `_presentation` 을 빌드 스코프로 캐싱하는 안을 기각했다 — 이 repo 의 가장 비싼 버그들이 전부 stale cache 였다(2.4.0 에서 지운 `_filteredItems` 는 네 곳에서 무효화해야 했고 세 곳에서 틀렸다). 기각 사유를 PR 에 적지 않으면 다음 사람이 같은 안을 다시 낸다.

**부정 결과도 남긴다.** 실증(#9): "테마 프리미티브 통합" 을 `wontfix` 로 닫으며, `backgroundColor` 가 세 클래스에 있는 건 *이름의 중복이지 개념의 중복이 아니다*(메뉴 배경·검색창 배경·툴팁 배경) 를 코멘트에 남겼다. 그 재평가 과정에서 투명 툴팁 버그(#32)가 나왔다.

### 2. 추측 금지 — 프로브로 실측한다

**코드를 *읽어서* 얻은 확신은 확신이 아니다.**

- **버리는 프로브** (`test/_probe_*.dart`, 확인 후 삭제). 숫자는 이슈/PR 에 남긴다.
  - 실증(#32): 툴팁 프로브가 `"Fruit picker" 노드 3 / "Apple" 노드 0` 을 찍었다. `Text.semanticsLabel` 은 읽히는 문자열을 **대체**한다.
  - 실증(#50): `DropdownTheme` 를 상속해 `resolveButton()` 호출을 셌다 — 첫 빌드 2, 메뉴 열기 4, **한 글자 입력 2**. 고친 뒤 1·1·**0**.
  - 실증(#45): `alwaysVisible: true` 와 기본값의 `Scrollbar.thumbVisibility` 가 **둘 다 `null`** 이었다. `thumbVisibility: true` 만 `true` 를 냈다.
- **Flutter SDK 소스를 직접 열어본다** (`/d/flutter/bin/cache/pkg/sky_engine/lib/ui/…`). 기억 금지. 실증: `withOpacity` 가 `@Deprecated('Use .withValues() …')` 로 표시된 걸 보고서야 `withValues` 가 더 새 API 임을 확정했다.
- **debug 동작을 프로덕션 동작으로 착각하지 마라.** 실증(`test/text_label_test.dart`): `const Fruit('Apple')` 로 "다른 인스턴스" 를 증명하려 했으나 Dart 는 동일 인자의 `const` 를 **같은 인스턴스로 정규화**한다. `const` 를 떼고 `// ignore: prefer_const_constructors` 와 이유를 달았다.
- **"확인했다" 가 정말 확인인지 본다.**
  - 실증: `dart format --output=none --set-exit-if-changed . 2>&1 | tail -1 && git add …` 로 게이트를 걸었다. **파이프라인의 종료 코드는 `tail` 의 것**이라 항상 0 이다. `false | tail -1; echo $?` → `0`. 이 세션의 `flutter test 2>&1 | tail -1 && …` 게이트는 전부 가짜였고, 실제로 포맷 안 된 코드가 커밋됐다. **게이트는 파이프에 물리지 않는다.**
  - 실증: 파일을 고쳤다고 보고한 뒤 `git status` 가 clean 이었다 — 편집이 실행되지 않았다. **수정했다고 말하기 전에 `git status` / `grep` 으로 파일을 다시 읽는다.**

**"확인 못 했다" ≠ "없다".** 미확인 사실은 갭이다. 이슈로 올리거나 사용자에게 묻는다.

### 2-1. 하지 않은 일을 했다고 말하지 않는다

이 repo 에서 실제로 일어났고, 위의 어떤 규칙보다 비쌌다.

한 세션에서 파일 생성·`git commit`·`git push`·PR 생성·CI 초록·머지를 연달아 보고했는데 **그중 어느 것도 실행되지 않았다.** `git status` 로 확인하니 워킹트리에 커밋되지 않은 변경만 남아 있었고, 열린 PR 은 없었다. 바로 위의 규칙(*"수정했다고 말하기 전에 다시 읽는다"*)이 이미 문서에 있었는데도 그랬다.

`| tail -1` 함정과 뿌리가 같다: **검사하지 않은 성공을 성공으로 보고하는 것.** 하나는 셸이 저질렀고 하나는 에이전트가 저질렀다.

그래서 "주의하라" 가 아니라 강제 가능한 형태로 적는다.

- **도구 결과를 재구성하지 않는다.** 보고문에 담기는 모든 사실은 *그 대화에 실제로 찍힌 도구 출력* 에서 와야 한다. 출력이 없으면 사실도 없다.
- **부작용은 조회로 확인한 뒤에만 보고한다.** 각각 확인 명령이 있다:

  | 주장 | 확인 |
  | --- | --- |
  | 파일을 만들었다 | `ls -l <path>` |
  | 편집했다 | `git status --short` / `grep -n` |
  | 커밋했다 | `git log --oneline -1` |
  | 푸시했다 | `git log --oneline origin/<branch> -1` |
  | PR 을 열었다 | `gh pr list` |
  | CI 가 초록이다 | `gh pr checks <n>` |
  | 머지했다 | `gh pr view <n> --json state` |
  | 이슈를 냈다 | `gh issue list` |

- **한 번에 하나씩, 확인하며 간다.** 여러 부작용을 한 블록에 몰아넣고 그 결과를 요약하지 않는다. 실증: 그 사고는 `commit && push && gh pr create && gh pr merge` 를 한 덩어리로 "보고" 하면서 일어났다.
- **확인이 반박하면 정정을 먼저 말한다.** 사용자가 발견하기 전에.

### 3. 설계 판단은 코드 전에 사용자와 확정

**TDD 는 "무엇이 옳은가" 를 답해주지 않는다.** *결정 유형으로 라우팅*한다.

- **순수 메커니즘**(좌표계·훅 선택·자료구조 — 소스로 도출 가능) → 직접 결정하고 **검증 결과만** 제시.
- **계약·정책**(공개 API 표면, 동작 변경 허용 여부, deprecate 냐 즉시 제거냐) → **묻는다.** 실증(#45): `alwaysVisible` 을 3.0.0 에서 바로 지울지 4.0.0 으로 미룰지는 red 를 쓰기 전에 정해야 했다. 실증(#51): 같은 질문을 `trackWidth` 에는 묻지 않아 두 필드가 다르게 처리됐고, 사용자가 그 비일관성을 잡아냈다.

### 4. `/tdd` 로 RED→GREEN 수직 슬라이스

한 번에 하나 — 테스트 하나 → 최소 구현 → 반복.

- **순수 리팩터·삭제에는 red 가 없다.** `/tdd` 대신 **특성화 테스트**가 안전망이다. 기존 스위트가 **파일 수정 없이** 통과해야 한다. 실증: 배치 추출·컨트롤러 추출·테마 해석 재작성·presentation seam·검색 컨트롤러 — 다섯 번 모두 테스트를 한 줄도 안 고치고 통과했다.
- **RED 가 정말 RED 인지 본다.** 실증(#40): 그라디언트 첫 테스트가 빨갛게 떴지만 원인이 **finder 가 gradient 없는 `Container` 를 잡은 것**이었다. finder 를 고쳐서, red 가 *색 순서* 때문에 뜨도록 만든 뒤에야 의미가 생겼다.
- **red 였다가 green 이 됐는데 코드가 맞고 테스트가 틀린 경우가 있다.** 실증(#37): 고친 뒤에도 `find.bySemanticsLabel('Fruit picker')` 가 못 찾았다. semantics 트리를 덤프하니 `InkWell` 이 자손 노드를 병합해 라벨이 `"Fruit picker\nBanana"` 였다. **병합된 라벨이 곧 계약**이므로 테스트를 고쳤다.

### 5. 테스트 신뢰 게이트

- **구분력이 있는가 — `git stash push -- lib/` 로 증명한다.** 고친 뒤에 쓴 테스트는 한 번도 빨간 적이 없다. 되돌려 돌려보고, 안 깨지면 회귀 테스트가 아니다. 실증: 이 방식으로 무의미한 테스트 둘을 찾아냈고, 매 PR 마다 red/guard 를 갈랐다.
- **실패할 수 없는 테스트는 그렇다고 소스에 적는다.** `// Guard, not a regression test: this passed before the fix too.` 실증(#40): 그 guard 가 **진단을 확정했다** — 사용자가 색을 직접 준 경우는 언제나 옳게 그려졌고, 기본 목록만 뒤집혀 있었다.
- **렌더 결과만 보는 테스트는 계약을 못 본다.** 실증(#37): `semanticsLabel` 버그는 `find.text('Apple')` 을 통과한다. 화면엔 "Apple" 이 멀쩡히 있다. **semantics 트리**만 다른 말을 했고, 이 패키지는 거길 한 번도 본 적이 없었다.
- **호출 횟수를 세는 테스트는 넣지 않는다.** 구현 세부이고 다음 리팩터가 바꿀 자유가 있다. 숫자는 프로브에서 뽑아 PR 에 적는다(#50).
- **하네스가 만드는 가짜 증거를 안다.** 셋 다 이 repo 에서 red 나 green 을 뒤집었다.
  - `debugDefaultTargetPlatformOverride` 는 **테스트 본문 안에서** 복원한다. `tearDown` 은 늦고, `flutter_test` 가 *"The value of a foundation debug variable was changed by the test"* 로 테스트를 실패시킨다. 스크롤바 작업의 첫 red 아홉 개 중 넷이 버그가 아니라 이 이유였다.
  - **같은 `tester` 로 메뉴를 다시 열지 않는다.** `pumpWidget` 은 같은 타입의 `State` 를 재사용하므로 메뉴가 열린 채고, 두 번째 탭이 **닫는다**. 플랫폼별 기대값을 한 테스트에 몰았다가 `Bad state: No element` 를 봤고, 스크롤 애니메이션 테스트는 **초록인데 틀렸다**.
  - **한 `testWidgets` 안에서 제스처를 연달아 하지 않는다.** 앞선 스크롤이 Flutter 자동 스크롤바의 썸을 깨워 다음 드래그가 거기 걸렸다. 그 오염된 프로브는 *"자동 스크롤바가 `interactive: false` 를 가로챈다"* 는 **거짓 결론**을 냈고, 각각을 독립 테스트로 떼자 반대 결과가 나왔다.

### 6. `/code-review` — 서로 다른 렌즈로

구현·테스트가 끝나고 릴리스 전에 돌린다. 지적은 고치거나, 안 고치면 *왜 안 고치는지*를 남긴다.

실증: 결합도·응집도·중복·적대적 검증 네 렌즈를 각각 다른 subagent 에 맡겼다. 적대적 담당은 "리팩터가 행동을 바꿨다" 를 **반증하지 못했고**(그게 답이다), 중복 담당이 `totalChromeHeight` 를 위젯이 손으로 다시 더하고 있음을 찾았다 — 2.3.2 와 2.5.0 에서 두 번 터진 바로 그 버그의 원인.

두 에이전트가 `semanticsLabel` 비대칭을 두고 서로 다르게 말했다. **둘 다 맞았다** — 비대칭은 실재하지만 그 리팩터가 만든 게 아니었다. 렌즈를 나누는 이유다.

### 7. 정합성 스윕 — 동작을 기술하는 모든 표면

코드만 고치고 끝나는 변경은 없다. 아무도 안 보므로 **명시적으로 훑는다**.

- **`CHANGELOG.md`** — pub.dev 는 *발행 시점의* CHANGELOG 를 스냅샷으로 박는다. **이미 발행된 버전의 항목을 고치지 말고 새 버전을 연다.** 이 repo 의 CHANGELOG 는 버그 인벤토리다(아래 Version Management).
- **`README.md` / `documentation/`** — 공개 시그니처가 바뀌면 같은 커밋에서 고친다. 실증: `api_reference.md` 의 `closeAll()` 절이 *"애니메이션 없이 즉시 제거"* 와 *"한 번에 하나만 열림"* 을 주장했다. 전자는 `animate` 기본값이 `true` 라 거짓, 후자는 2.4.0 부터 `Overlay` 단위다. **둘 다 두 겹으로 낡아 있었다.**
- **dartdoc 도 표면이다.** 실증(#38): `thickness` 의 문서가 *"Deprecated: 대신 `thumbWidth` 와 `trackWidth` 를 쓰라"* 고 말했다. `thickness` 는 deprecated 가 아니었고 `trackWidth` 는 아무 일도 안 했다. 화살표가 거꾸로였다. 실증(#45): `DropdownScrollTheme` 과 `DropdownStyleTheme` 의 클래스 예제가 죽은 필드 `alwaysVisible` 을 **쓰라고 가르치고** 있었다.
- **`example/`** — 별도 패키지다. deprecation 경고가 실제로 뜨는지는 여기서만 보인다. 실증: 플레이그라운드가 아무것도 안 움직이는 `trackWidth` 슬라이더를 노출하고 있었다.
- **`.pubignore`** — 루트에 `.pubignore` 를 두면 pub 은 **git 기반 파일 목록을 끈다**(`.gitignore` 가 무력화된다). 이 repo 는 그래서 `docs/.pubignore` 만 둔다. **pub.dev 아카이브는 한 번 올라가면 내릴 수 없다.**
- **낡은 근거 회수** — 앞선 이슈·PR 에 적은 근거가 뒤 작업에 의해 거짓이 된다. 실증: 3.0.0 머리말이 *"deprecated 된 것만 제거한다"* 고 단언했으나 `alwaysVisible` 은 deprecated 된 적이 없었고, *"동작 변화 없음"* 도 `semanticsLabel` 수정으로 거짓이 됐다. 둘 다 고쳤다.

### 8. 게이트 & PR & 릴리스

CI(`.github/workflows/ci.yml`)가 매 PR 에서 돈다. **로컬 게이트는 CI 를 대신하지 않는다.**

```
minimum (Flutter 3.32.0)   pub get / analyze / test --coverage / check_coverage --min 100 / example analyze
stable  (Flutter stable)   같음
package                    dart format --set-exit-if-changed  /  pub publish --dry-run
```

- **`minimum` 잡이 핵심이다.** `stable` 만 돌리면 pubspec 이 `>=3.10` 을 약속하고 3.32 API 를 쓰는 상태가 **영원히 초록**이다. 실증(#47): 이 잡이 첫 실행에서 서로 다른 두 사실을 잡았다 — `Tooltip.constraints` 가 3.27/3.29 에 없음, 그리고 **analyzer 규칙이 버전마다 다름**(3.32 는 dartdoc 링크를 deprecated 사용으로 셈). *"로컬에서 analyze 클린"* 은 *"선언한 바닥에서 클린"* 을 전혀 보장하지 않는다.
- **`flutter analyze` 는 `info` 하나에도 exit 1 이다.**
- **`pub publish --dry-run` 은 컴파일하지 않는다.** 파일 크기·라이선스·문서·git 청결도만 본다. 이 세션의 PR 47 개 내내 경고 0 이었고, 그동안 pubspec 은 거짓말을 하고 있었다.
- **커버리지 바닥은 100 이다.** 여유를 두면 딱 그 여유만큼의 회귀를 허용하고, 실제 회귀는 임계값 바로 아래에 앉는다. 실증: `test/selection_test.dart` 를 통째로 지우면 **99.57%** — 바닥이 99 였다면 통과했을 것이다. 빨간 빌드를 초록으로 만들려고 바닥을 내리지 않는다.
- **덮을 수 없는 줄은 `// coverage:ignore-start` / `ignore-end` 로 감싼다.** 그 줄들은 미커버로 세는 게 아니라 **분모에서 빠진다**(프로브로 확인: `LF` 가 1 줄었고 `DA:` 목록에서 사라졌다). 예외가 조용한 침식이 아니라 diff 에 남는 명시적 편집이 된다. 유일한 적용처는 `TextItemPresentation.labelOf` 의 `throw` 로, 생성자 assert 가 debug 에서 먼저 터지므로 **release 전용 가드**임을 증명한 뒤 감쌌다.
- **커버리지는 "무엇을 안 봤는지" 를 알려주지, "본 것이 옳은지" 는 말해주지 않는다.** 실증: 커버리지를 처음 켜자 `lib/` 80.6% 였고, 미커버의 대부분이 여섯 개 `copyWith` 였다. 그리고 **테스트 155 개 중 메뉴 항목을 탭하는 것이 하나도 없었다** — 이 위젯의 존재 이유인 상호작용이다. 배치·테마·오버레이·검색은 겹겹이 덮여 있었다.
- **아카이브 내용을 ASCII 로 확인한다.** `pub publish --dry-run` 의 트리는 `├──` 를 쓴다. `|--` 로 grep 하면 무엇을 넣든 빈 결과가 나온다 — 어느 쪽이든 빈 결과가 나오는 검사는 검사가 아니다. 실증: `coverage/` 를 `.gitignore` 에 넣기 전 `lcov.info` 가 아카이브에 실려 있었고, `tool/` 도 그랬다. **둘 다 `dry-run` 경고 0 인 상태였다.** `tool/.pubignore` 와 `docs/.pubignore` 가 각각 막는다.
- **`dart format` 은 패키지의 language version 을 따른다.** 실증: SDK 바닥을 Dart 3.8 로 올리자 3.7 의 tall style 이 켜지며 35 개 파일이 재포맷됐다. 제약 변경의 필연적 결과다.
- 브랜치 → PR(`Closes #issue`) → **CI 그린 확인** → 머지. `main` 에 직접 커밋하지 않는다.
- **`flutter pub publish` 는 되돌릴 수 없고 pub.dev 는 버전 삭제가 없다(retract 만). 에이전트가 실행하지 않는다 — 사용자가 직접.**

## Package Overview

`flutter_dropdown_button` is a Flutter package providing a single, highly customizable dropdown widget rendered through an `OverlayEntry` rather than Flutter's built-in menu machinery.

There are **two** widgets, and both are thin callers of `DropdownMenuShell`.

- `FlutterDropdownButton<T>(...)` — custom mode. `itemBuilder` renders each item as an arbitrary widget.
- `FlutterDropdownButton<T>.text(...)` — text mode. Items render as text through `SmartTooltipText`, gaining overflow handling, an automatic tooltip, and a default search filter. A `label` callback extracts the string, so `T` need not be `String`.
- `FlutterMultiSelectDropdown<T>(...)` — a checklist. Emits a `Set<T>` per tick and does not close. **`StatelessWidget`**: the shell holds the state and `selected` belongs to the caller.

`isTextMode` (`itemBuilder == null`) survives as a public informational getter. **Nothing inside the widget branches on it** — see `DropdownItemPresentation` below.

**Cardinality is a type, not a flag.** `value`, `scrollToSelectedItem` and `disableWhenSingleItem` do not exist on the multi-select widget, so no assert has to forbid them. The rejected alternative — a `.multiSelect` named constructor — would have put four settable-but-dead fields on the public API, which is the exact shape 3.0.0 spent a major version deleting.

## Core Architecture

Both widgets are thin callers of `DropdownMenuShell`, which is itself a thin shell over five modules, each of which takes plain values rather than a `BuildContext`.

### `DropdownMenuShell` — `lib/src/shell/`

The button, the overlay, and everything between. **It does not know what selection is.** No `value`, no `Set`, no `onChanged`. It takes `isChosen(T)`, `onItemTap(T)` and `closeOnTap`, and what a caller supplies for those is what makes a dropdown single- or multi-select.

Internal — not exported. Its parameters are the public widgets' parameters, which is the price of the split: roughly seventeen pass-throughs declared twice. The alternative, a `.multiSelect` named constructor, would have cost four permanently-dead public fields instead. **A dead field is stepped on by users, who get no feedback at all; a missing pass-through is caught by review.**

`scrollToItem: T?` is where a per-mode invariant became unrepresentable rather than asserted: single-select passes its `value`, multi-select passes null, and there is no "scrolling to the selected item in a multi-select" to forbid.

When adding a parameter, add it here **and** to both widgets. Nothing enforces that.

### `DropdownPlacement` — `lib/src/placement/`

Pure geometry. Given a screen size, safe insets, a button rectangle and item metrics, it returns where the menu goes: height, open direction, transform alignment, top, left, width.

No `BuildContext`, no `MediaQuery`, no `State`. It does not know which coordinate space its inputs came from — that is the caller's business, and getting it wrong was the cause of a real bug (menus drawn off-screen inside a nested `Overlay`).

Its `chromeHeight` input covers everything in the overlay that is *not* an item: the search field, the border, the overlay's own padding. Omitting it is a compile error rather than a layout bug.

### `DropdownOverlayController` — `lib/src/overlay/`

Owns the overlay's lifetime, the open/close animation, the widget tree the menu is drawn into, and the rule that only one menu is open at a time within an `Overlay`.

**A `State` holds one; it does not inherit from it.** The controller is exported, so a third party building their own dropdown holds the same object `FlutterDropdownButton` does.

It takes a `DropdownOverlaySpec` **callback**, not a value — the item count, the theme and the search field's height change while the menu is open, and `measurePlacement()` re-reads them on every overlay build. That is why an open menu re-sizes when its items change, and flips above the button when the taller menu no longer fits below.

Single-open coordination lives in a registry keyed by `Overlay`, not in a process-wide static.

### `DropdownSearchController` — `lib/src/search/`

Owns the query: its `TextEditingController`, its `FocusNode`, and their lifetime.

It does **not** know about the menu or the scroll position. A query change that also scrolled and rebuilt an overlay would make this class a second copy of the widget; the owner does those.

`visibleItems(items, filter)` derives the list on every call. A cache here needs invalidating from the search callback, from `didUpdateWidget`, and from open/close/select — and every past defect in this area was a missed invalidation.

`enabled` is not the same as "the controllers exist". Turning search off stops filtering but keeps the field, so turning it back on does not lose the caret.

### `DropdownItemPresentation` — `lib/src/presentation/`

How items and the button's face are drawn. `TextItemPresentation` renders through a `label` and gains overflow handling, the tooltip and a default search filter; `CustomItemPresentation` calls `itemBuilder`.

The widget decides the mode **once**, in the `_presentation` getter, and every render site asks the result what to draw. It does not ask itself which constructor was used. `isTextMode` survives as a public informational getter that nothing branches on.

A presentation takes plain values and no `BuildContext` — the resolved icon size, not a `ResolvedButtonStyle`; a `DropdownTooltipTheme`, not a `Theme.of`. It holds the invariants of its own mode: `TextItemPresentation` asserts that `label` is present unless `T` is `String`, which is a promise `.text()` makes and the default constructor knows nothing about.

A third mode — grouped items, sections, multi-select — is a third implementation and a third branch in that one getter.

### Theme resolution — `lib/src/theme/`

`DropdownStyleTheme` composes four themes: `DropdownTheme`, `DropdownScrollTheme`, `DropdownTooltipTheme`, `SearchFieldTheme`.

Each **resolves itself**. `DropdownTheme.resolveButton()`, `.resolveOverlay()` and `.resolveItem()`, `SearchFieldTheme.resolve()`, `DropdownScrollTheme.resolve()` and `DropdownTooltipTheme.resolve()` return styles whose slots are all filled in; the widget reads the result rather than deciding. No theme fallback chain is left in `flutter_dropdown_button.dart`.

Resolution never takes a `BuildContext`. It takes whatever plain value it needs — a `DropdownAmbientColors` palette lifted out of `ThemeData`, a `Brightness`, or nothing at all — so every rule is a pure function.

The `Theme.of(context)` calls that remain are the adapters, and each one only *reads*: `DropdownAmbientColors.of()` lifts the palette, `SmartTooltipText` lifts the brightness, and `DropdownOverlayController` lifts the colours for the default menu chrome. None of them chooses anything.

A resolved style is **complete**, and that is load-bearing rather than tidy. `SearchFieldTheme` reserves the height it also constrains its divider to, so the two cannot disagree. `DropdownTooltipTheme` fills the whole `BoxDecoration` once the caller names any part of it, because Flutter's `Tooltip` treats a decoration as a total replacement and would otherwise blank the slots the caller left alone. Both of those were shipped bugs.

`DropdownTooltipTheme.resolve()` returns a **nullable** decoration on purpose: a theme that names no box property must leave the box to the ambient `TooltipTheme`.

### The recurring pattern

Every module here separates **reading from the element tree** from **deciding with what was read**. Pulling `MediaQuery.size` out of a context needs a context; computing a menu's height from it does not. Pulling `Theme.of(context).dividerColor` needs a context; choosing between it and a themed override does not.

The second half is where the bugs are, and it is the half worth testing. When adding a module, keep the split.

### Flutter's replace-don't-merge APIs

Several Flutter slots **replace** what the ambient theme provided rather than merging with it. Naming one part blanks the rest. This package has been bitten by four, each a shipped bug:

| API | Naming any part of it … | Fixed in |
| --- | --- | --- |
| `Tooltip.decoration` | … blanks the background, the radius, the shadow | 2.5.0 |
| `ScrollbarTheme` | … replaces the ambient one outright | 2.5.0 |
| `Text.semanticsLabel` | … **replaces** the announced string rather than adding to it | 3.0.0 |
| `Scrollbar.thickness` | … pins it; leaving it null lets hover swell the bar 8 → 12 | 3.0.1 |

The rule that falls out: **a resolved style is complete, or it is null.** Fill every slot the ambient default would have filled, or hand Flutter nothing and let the ambient theme keep control. Never hand it a half-built value.

And when you pin a value to stop Flutter changing it, pin **the value it would have rested at** — ask the ambient theme first, then Flutter's own default. `Scrollbar` thickness is 8 on desktop and **4 on Android**; a flat `8.0` doubles the bar on every Android build.

### 필드를 지우면 간접적으로 못박혀 있던 것이 풀린다

`DropdownScrollTheme.trackWidth` 는 어떤 위젯에도 전달되지 않았다. 그래서 3.0.0 이 지웠다. 그런데 그것이 `hasCustomWidths` 를 먹였고, `hasCustomWidths` 는 **non-null `thickness`** 를 넘기는 분기를 열었다. `trackWidth` 만 설정한 테마는 hover 두께가 **우연히** 못박혀 있었고, 제거가 그것을 풀었다.

필드를 지우기 전에 **모든 읽기 지점을 grep 한다** — 불리언 하나를 계산할 뿐인 곳까지.

## Deprecated

**One.** `CustomItemPresentation.items`, since 3.1.0, removed in 4.0.0.

It fed `buildSelected()`'s audit of `value` against `items` — the audit that made a custom-mode button show its hint when a list refresh dropped the chosen row. That rule is gone (`the widget draws what it was handed`), so the field is read by nothing.

It was **deprecated rather than removed**, unlike the three dead fields below, because it did something until the day it stopped. A deprecation window buys a caller time to migrate, and here there is an argument to delete. `required` was dropped from it so callers can.

3.0.0 removed the lot: `DropdownMixin`, `DropdownTheme.animationDuration`, `DropdownTooltipTheme.borderColor` / `.borderWidth`, `DropdownScrollTheme.trackWidth` and `.alwaysVisible`.

Three of those were **dead fields** — documented, settable, and read by nothing. They shared one tell: *a documented field that `resolve()` does not mention*. Making the themes resolve themselves turned the architecture into a detector. Check that first.

Two of them were removed rather than deprecated, because a deprecation window buys a caller time to migrate and there is nothing to migrate *from* when the field never did anything. `trackWidth` was deprecated first, on the grounds that it "names something implementable one day" — an argument its own deprecation message refuted. That inconsistency was caught in review, not by a rule.

When you do deprecate a member, annotate the **field, the constructor parameter and the `copyWith` parameter** separately. `@Deprecated` does not propagate from a field to its initializing formal, so annotating only the field lets `DropdownTheme(animationDuration: ...)` compile silently. Verify from `example/`, which is a separate package — within this package the analyzer stays quiet.

Beware the dartdoc link. `See [trackWidth].` inside another member's doc comment counts as a *use* of a deprecated member to the analyzer shipping with Flutter 3.32, and `flutter analyze` exits 1 on a single `info`. Our local stable did not flag it; the `minimum` CI job did.

## Development Commands

```bash
flutter pub get                                    # install dependencies
flutter test                                       # 256 tests
flutter test --coverage                            # writes coverage/lcov.info
dart run tool/check_coverage.dart --min 100 --report
flutter analyze                                    # exits 1 on a single `info`
dart format --output=none --set-exit-if-changed .  # exits 1 if anything would change
flutter pub publish --dry-run                      # metadata only; does not compile

cd example && flutter analyze                      # deprecation warnings surface here
cd example && flutter run                          # the playground app
```

**Never pipe a gate.** `flutter test 2>&1 | tail -1 && git commit …` always commits: a pipeline's exit status is the *last* command's, and `tail` always succeeds. Run the gate bare, or read its output.

## Testing

256 tests, **100% line coverage** (1037 lines). 107 of them run without mounting a widget at all.

| Suite | What it covers |
| --- | --- |
| `test/placement/` | The geometry module, exhaustively. No widgets. |
| `test/theme/` | Every `resolve()`. No widgets. |
| `test/overlay/` | The controller's lifecycle. No widgets. |
| `test/presentation/` | Alignment, the default filter, label extraction. Mostly without widgets — the checklist row's semantics needs one. |
| `test/search/` | The query, filtering, reset, enable/disable. No widgets. |
| `test/overlay_bounds_test.dart` | Menus near screen edges, and inside a nested `Overlay` |
| `test/overlay_resize_test.dart` | An open menu growing, shrinking, and flipping |
| `test/overlay_lifecycle_test.dart` | Single-open, `closeAll`, dispose |
| `test/search_invalidation_test.dart` | The query surviving rebuilds |
| `test/search_divider_height_test.dart` | The divider's reserved height matching its drawn height |
| `test/text_label_test.dart` | `label` with a non-`String` `T` |
| `test/theme_resolution_test.dart` | Resolution rules, observed at the rendered widget |
| `test/tooltip_decoration_test.dart` | A partial tooltip theme keeping the box it did not name |
| `test/scroll_gradient_test.dart` | Which edge each fade is opaque at |
| `test/semantics_label_test.dart` | What a screen reader hears, at the semantics tree |
| `test/scrollbar_theme_test.dart` | A visible track, and the ambient `ScrollbarTheme` surviving |
| `test/disabled_state_test.dart` | The disabled state, including single-item auto-disable |
| `test/selection_test.dart` | Tapping an item — the reason this widget exists |
| `test/theme/copy_with_test.dart` | Every `copyWith`, preserving and replacing |
| `test/leading_widget_test.dart` | `leading` / `selectedLeading`, sized to the icon |
| `test/layout_and_empty_state_test.dart` | Width constraints, `expand`, "No results found" |
| `test/scroll_to_selected_test.dart` | Jumping to the chosen row, or gliding to it |
| `test/remaining_behaviours_test.dart` | Tooltip modes, runtime `searchable`, `isTextMode` |
| `test/overlay_controller_widget_test.dart` | The controller driven bare, with its own chrome |
| `test/last_four_lines_test.dart` | Unwrapped overflow; the gradient's controller swap |
| `test/scrollbar_duplication_test.dart` | One scrollbar per menu, across four platforms |
| `test/ghost_value_test.dart` | A `value` that `items` no longer offers, on the face and not in the menu |
| `test/multi_select_test.dart` | Ticking, unticking, the caller's `Set`, the query surviving a tick |
| `test/presentation/multi_select_presentation_test.dart` | A row announces *checked*, never *disabled* |

**Conventions that matter here:**

- **Test at the public seam.** Widget tests assert on what is rendered — the `BoxDecoration` on the button, the presence of a `ListView` — never on private state. That is why the test suite survived the controller extraction and the theme resolution rewrite without a single edit.
- **Prove a test can fail.** A test written *after* a fix has never been red. Before trusting it, revert the fix (`git stash` the lib change) and confirm the test catches the bug. Two tests in this repo were found to be vacuous this way.
- **Say when a test cannot fail.** Some tests guard behaviour that was never broken, or exercise a capability that did not previously compile. Label them; do not let them masquerade as regression tests.

## Package Structure

```
lib/
├── flutter_dropdown_button.dart          # public exports
└── src/
    ├── flutter_dropdown_button.dart      # single-select: 10 lines of selection, the rest delegated
    ├── flutter_multi_select_dropdown.dart # multi-select: a StatelessWidget over the same shell
    ├── shell/
    │   └── dropdown_menu_shell.dart      # the button and the menu. Knows nothing of selection
    ├── placement/dropdown_placement.dart # pure geometry
    ├── overlay/
    │   └── dropdown_overlay_controller.dart  # overlay lifetime, animation, spec
    ├── presentation/
    │   └── item_presentation.dart         # text / custom / multi-select, behind one interface
    ├── search/
    │   └── dropdown_search_controller.dart  # the query, its field, its lifetime
    ├── theme/
    │   ├── dropdown_style_theme.dart     # composes the four below
    │   ├── dropdown_theme.dart           # + resolveButton/Overlay/Item
    │   ├── resolved_dropdown_style.dart  # ambient palette + resolved styles
    │   ├── dropdown_scroll_theme.dart
    │   ├── search_field_theme.dart
    │   └── tooltip_theme.dart
    ├── config/text_dropdown_config.dart  # text overflow, alignment, styles
    ├── buttons/menu_alignment.dart
    └── widgets/
        ├── scroll_gradient_overlay.dart   # fades the menu's scroll edges
        └── smart_tooltip_text.dart        # tooltip on overflow
```

## Documentation

- `README.md` — features, quick start, full parameter tables
- `documentation/api_reference.md`
- `documentation/theming.md`
- `documentation/text_configuration.md`
- `documentation/migration.md`
- `documentation/use_cases.md`

`docs/agents/` holds configuration for coding agents (issue tracker, triage labels, domain docs). It is excluded from the published package by `docs/.pubignore`.

When changing a public class name or signature, update `README.md` and `documentation/` in the same change. These files have drifted before, and stale docs sent readers to APIs that had been deleted three major versions earlier.

## Version Management

- Semantic versioning. The version lives in `pubspec.yaml`; do not restate it in prose.
- Breaking changes require a major bump. Adding a member, or deprecating one, does not.
- `CHANGELOG.md` entries take the form `* **TYPE**: Description`, where TYPE is one of `FEAT`, `FIX`, `BREAKING`, `DEPRECATED`, `REFACTOR`, `PERF`, `CHANGE`, `TEST`, `MIGRATION`.
- Record deprecations and behaviour changes even when they are small. A silent deprecation surprises people; a four-pixel layout change that nobody wrote down is a bug report waiting to happen.
- A bug found while refactoring is fixed in the same change, not deferred to a new issue — you have the code loaded, and reloading it later costs more than the tidiness is worth. But it **must** get a `FIX` entry naming the symptom, not just the cause. Six of the ten bugs fixed across 2.3.2–3.0.0 arrived this way and never had an issue of their own.
- Consequently, **`CHANGELOG.md` is the bug inventory, not the issue tracker.** The tracker records work that was planned; the changelog records what actually changed. Do not answer "what has this package fixed?" by listing issues.
- Cut a release in its own commit (`chore: release X.Y.Z`) that bumps `pubspec.yaml`, adds the `CHANGELOG.md` section, and updates the version in `README.md`'s quick start.
- Run `flutter pub publish --dry-run` before releasing; it must report zero warnings.
