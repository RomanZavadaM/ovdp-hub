# OVDP Hub v0.9.3 — 사용자 가이드

## 목적
OVDP Hub는 우크라이나 국채 OVDP를 위한 local-first 앱입니다. 시장 출처 확인, 시나리오 계획, 비교, 실제 기록 기반의 암호화 개인 포트폴리오를 제공합니다. 앱은 거래를 실행하지 않습니다.

## 설치
**Windows:** 전체 ZIP을 풀고 `ovdp_hub.exe`를 실행합니다. DLL/리소스를 실행 파일과 함께 유지해야 합니다. 테스트 prerelease는 production code-signing이 없어 SmartScreen이 표시될 수 있습니다.

**macOS:** ZIP을 풀고 `ovdp_hub.app`을 엽니다. 현재 prerelease는 notarized 상태가 아니므로 최초 차단 후 System Settings → Privacy & Security에서 **Open Anyway**가 표시될 수 있습니다.

**Android:** Android ZIP을 풀고 `OVDP-Hub.apk`를 설치합니다. development signing을 사용하는 테스트 빌드입니다.

**iOS:** 공개 패키지는 unsigned이며 별도의 Apple signing/provisioning이 필요합니다.

## 언어와 화면
지원 언어: Ukrainian, English, Français, Deutsch, Español, 한국어, 日本語. 화면 모드: Classic, Workbench, Light Dashboard. 선택한 언어와 화면 모드는 이 기기에 로컬로 저장되며 다음 실행 때 복원됩니다.

## 시장/ISIN
카탈로그에서 OVDP를 검색/필터링할 수 있습니다. ISIN 카드에서 NBU, MinFin, 판매자 데이터를 분리해 보여 주고 source date, retrieval time, freshness/status를 표시합니다. yield-only나 nominal 값은 자동으로 실제 거래 가격으로 취급되지 않습니다.

## Planner
시나리오는 하나의 기준 통화를 사용합니다. 예산, reserve, 기간, 필요금액, 포지션, 수수료, 세금, FX, 조기 매도, reserve floor, 일회성/반복 필요를 설정할 수 있습니다. 알 수 없는 값은 0으로 바꾸지 않고 unknown 상태로 유지합니다.

A/B/C는 호환되는 저장 시나리오 2–3개를 비교하지만 자동 winner를 선택하지 않습니다. CSV/ICS는 로컬 `exports/` 폴더에 저장됩니다.

## 내 포트폴리오
포트폴리오는 로컬 암호화 흐름이며 create/open/lock을 지원합니다.

**매수:** 실제 ISIN/날짜/수량/금액과 수수료 상태를 기록합니다.

**매도:** 매도 수량을 acquisition lot에 명시적으로 할당합니다. FIFO/LIFO를 임의로 추정하지 않습니다.

**쿠폰 / 상환:** 실제 받은 금액만 기록합니다.

**ISIN ledger:** 매수/매도/쿠폰/상환 이력을 확인할 수 있으며 수량이 0인 종료 포지션도 계속 표시됩니다.

**실제 현금 요약:** 통화별 매수액, 매도대금, 쿠폰, 상환, 알려진 수수료를 표시합니다. 관련 수수료가 unknown이면 정확한 net cash result는 표시하지 않습니다.

열린 포지션의 현재 시장가치를 더하지 않으므로 시장가치 평가나 투자수익률 지표가 아닙니다.

## Legacy migration
마이그레이션 wizard는 지원되는 사용자 legacy 데이터를 암호화 payload로 복사하고 암호화 사본을 검증합니다. 원본 JSON은 자동 삭제하지 않습니다.

## 백업/업데이트
큰 업데이트 전에는 포트폴리오를 잠그고 workspace를 백업하며 encrypted portable backup을 확인하고 recovery material을 별도 보관하세요. Desktop 업데이트는 새 프로그램 폴더에 풀고 새 버전을 확인할 때까지 기존 workspace를 유지하세요.

Windows의 **내 포트폴리오**에서는 휴대 가능한 암호화 백업을 만들고 이를 이용해 비어 있는 로컬 포트폴리오를 복원할 수 있습니다. 포트폴리오 생성 시 복구 비밀문구를 두 번 입력하며 이후 변경할 수도 있습니다. Android/iOS 외부 파일 흐름은 별도 SAF/security-scoped 단계까지 보류됩니다.

## 검증과 일반 문제
GitHub Release의 `SHA256SUMS.txt`로 다운로드 파일을 검증할 수 있습니다. unsigned 테스트 prerelease이므로 SmartScreen/macOS 경고가 나올 수 있습니다. “Unknown fee”는 오류가 아니라 의도된 상태입니다. iOS unsigned ZIP은 직접 설치할 수 없습니다.

## 한계
OVDP Hub는 브로커가 아닙니다. 금융 행동 전 가격, 수수료, 세금, 날짜와 조건을 1차 출처 및 본인의 은행/브로커에서 다시 확인하세요.
