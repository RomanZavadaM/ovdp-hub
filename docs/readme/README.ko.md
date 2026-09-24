# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.2](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.2) (0.9.2+19)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/OVDP-Hub-0.9.2-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.2/SHA256SUMS.txt)

---

### v0.9.2 체크포인트

**v0.9.2+19**에는 상시 **경제 지표**와 첫 사용자용 **내 포트폴리오** 흐름이 추가됩니다. 로컬 암호화 포트폴리오 생성/열기/잠금, 실제 OVDP 매수 기록, derived holdings 표시를 지원합니다. 또한 실제 배포되는 Windows/macOS ZIP과 executable 자체를 검증하는 release gate가 추가됩니다.

**개인정보 경계:** legacy `sets/*.json`은 여전히 자동 암호화되지 않습니다. migration/cleanup wizard는 다음 별도 사용자 단계이며 Android SAF / iOS security-scoped는 연기됩니다.


### 소개

**OVDP Hub**는 우크라이나 국채(OVDP), 시장 정보 출처, 개인 투자 시나리오를 살펴보기 위한 설치형 Flutter/Dart 애플리케이션입니다. 대상 플랫폼은 **Windows, macOS, Android, iOS**이며 Web/PWA는 현재 제품 범위에 포함되지 않습니다.

활성 코드는 `apps/native`에 있습니다. 현재 체크포인트는 **0.9.2+19**입니다. 0.9.0 이후 UI/Planner/export 변경과 검증된 내부 vault/private-domain/migration 기반이 포함됩니다. 사용자용 vault/migration/portfolio 연결은 아직 별도 단계입니다.

### 현재 기능

- NBU 공개 데이터를 기반으로 한 로컬 OVDP 카탈로그;
- 검색, 필터, 지급 일정, 발행물 비교;
- 출처, source date, retrieved time, freshness/status를 분리해 보여 주는 **NBU / 재무부 / 판매자** 데이터 계층;
- 구조화된 재무부 경매 일정과 placement/switch 상세 결과;
- 사용자가 명시적으로 우선순위를 정하는 여러 가격 출처;
- 예산, 준비금, 만기 범위, 미래 지출을 위한 플래너;
- 명시적인 매수 수수료 가정: 알 수 없는 수수료를 0으로 처리하지 않음;
- 2026년 우크라이나 거주 개인의 OVDP에 대한 검증된 세금 프로필과 **미확인 / 검증된 0** 구분;
- 기본 현금흐름의 통화를 섞지 않는 명시적 FX 비교(수동 환율, 날짜, 출처 URL);
- 각 포지션별 매도일과 BID/수동 exit 가격을 사용하는 만기 전 매도;
- typed 규칙으로 저장되는 반복 주요 필요와 별도 일회성 추가 필요;
- 엄격한 비교 조건과 자동 승자 없이 저장된 시나리오 2–3개를 중립적으로 비교하는 **A/B/C** 기능;
- typed reserve floor / 최소 잔액 규칙: 적용일부터 해당 금액은 유동 현금으로 유지되며 지출로 처리되지 않음;
- 활성 작업공간의 `exports` 폴더에 scenario/needs/coverage/cashflow를 저장하는 결정적 로컬 Planner CSV/ICS 내보내기; PDF는 보고서 구조 안정화 후로 연기;
- Planner 생성 문구 / preset label은 안정적인 ID로 저장하고 표시 시 현지화하며, 사용자가 입력한 이름은 그대로 유지;
- 휴대 가능한 JSON 작업 폴더에 시나리오 저장;
- 활성 UI와 주요 사용자 오류가 **UK / EN / FR / DE / ES / KO / JA**로 현지화됨.

명목 쿠폰을 시장 수익률로 간주하지 않으며, yield-only 관측값을 자동으로 가격으로 사용하지 않습니다. 알 수 없는 수수료, 세금, FX도 자동으로 0으로 대체하지 않습니다.

### 플래너

플래너는 의도적으로 단일 통화 시나리오를 유지합니다. 만기 분배, 계산 수익 모드, 미래 지출 충당을 지원하며 수량과 총가격을 수동으로 수정할 수 있습니다.

공개된 0.9.0 체크포인트 이후 개발:

1. **DONE** — 가격 출처 우선순위;
2. **DONE** — 매수 수수료 가정;
3. **DONE** — 검증된 세금 가정;
4. **DONE** — FX 가정;
5. **DONE** — exit 가정;
6. **DONE** — 중립적 A/B/C 비교;
7. **DONE** — Planner 생성 문구 / preset label 현지화 + 회귀 테스트;
8. **DONE** — v0.9.0 prerelease checkpoint;
9. **DONE** — reserve floor / 최소 잔액;
10. **DONE** — 결정적 로컬 CSV/ICS 내보내기; PDF 연기;
11. **DONE** — encrypted-vault/private-domain/비파괴 migration 기반; 12. **DONE** — v0.9.2+18 체크포인트; 13. **NEXT** — Android SAF / iOS security-scoped 외부 폴더 접근; 사용자용 vault/migration UX는 별도 gate.

OVDP Hub는 실제 매매를 실행하지 않으며 판매자의 실제 재고를 확인하지 않습니다.

### 데이터와 개인정보

카탈로그와 시나리오는 사용자 기기에 저장됩니다. 데스크톱에서는 작업 폴더를 열거나 복사할 수 있습니다. OVDP Hub는 개인 포트폴리오 데이터를 위한 중앙 서버를 운영하지 않습니다.

현재 사용자용 선택 흐름에서 사용하는 legacy workspace JSON은 향후 명시적인 vault/migration 흐름이 연결되고 성공적으로 실행되기 전까지 **평문**입니다. v0.9.2에는 검증된 encrypted-vault/private-payload/migration 기반이 있지만 기존 `sets/*.json`을 자동으로 다시 쓰거나 삭제하지 않습니다. Legacy workspace에는 서명 키, KYC 문서 또는 기타 비밀정보를 저장하지 마십시오.

### 빠른 테스트

일반 변경에서는 `flutter analyze`, `flutter test`, START 패키징을 수행합니다. Windows에서는 `START.bat`, macOS에서는 `START.command`를 사용합니다. 첫 로컬 실행에는 Flutter 3.47.5와 해당 플랫폼 빌드 도구가 필요합니다.

정식 prerelease는 Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, 법적 고지, 변경되지 않는 tag, GitHub Release를 생성합니다.

### 저작권

**Copyright © 2026 Roman Zavada. All rights reserved.**

OVDP Hub는 **독점 소프트웨어(proprietary software)**입니다. 공개 저장소라고 해서 오픈소스 라이선스가 부여되는 것은 아니며 복사, 수정, 재게시, 판매, 재배포 또는 파생 버전 제작 권한을 의미하지 않습니다.

[LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md), [COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md)를 참고하세요.

### 개발

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

다른 대상: `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

프로젝트 상태: [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md), [PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md), [PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md), [WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md), [CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)
