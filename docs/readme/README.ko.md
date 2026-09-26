# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)

> **현재 범위의 최종 checkpoint: [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **개발 상태: PARKED / 현재 범위 완료. 활성 개발 없음.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## 제품

OVDP Hub는 우크라이나 국채 OVDP용 local-first Flutter/Dart 앱입니다. 시장 출처 확인, 시나리오 계획, 중립적 비교, 실제 기록 기반의 암호화 개인 포트폴리오를 제공합니다.

## v0.9.4

- NBU / MinFin / 판매자 레이어와 provenance/freshness;
- 수수료, 세금, FX, 반복 필요, reserve floor, 포지션별 조기 매도를 포함한 Planner;
- 자동 winner가 없는 A/B/C 비교;
- deterministic CSV/ICS export와 Economic Pulse;
- 매수/매도/쿠폰/상환, 명시적 lot 할당, ISIN ledger를 포함한 암호화 Portfolio;
- recovery secret 확인/회전 및 Windows portable encrypted backup/restore;
- 실제 packaged lifecycle smoke를 통과한 macOS Keychain 기반 Portfolio;
- Android SAF 및 iOS security-scoped 외부 저장소 기반;
- mobile external workspace, encrypted backup transport, fail-closed 권한 처리;
- terminate/relaunch 2단계 mobile self-test;
- Classic / Workbench / Light Dashboard와 UK/EN/FR/DE/ES/KO/JA UI, 언어/appearance 저장.

현금 요약에는 열린 포지션의 현재 시장가치가 포함되지 않으며 투자수익률 지표가 아닙니다. 확인되지 않은 수수료는 0으로 바꾸지 않습니다.

## 설치

Windows: ZIP 전체를 풀고 `ovdp_hub.exe`를 실행합니다. macOS: `ovdp_hub.app`을 엽니다; 이 checkpoint는 notarized가 아닙니다. Android: `OVDP-Hub.apk`를 설치합니다. iOS 패키지는 unsigned이며 설치에는 별도의 Apple signing/provisioning이 필요합니다.

전체 안내서: **[한국어 사용자 가이드](../user-guide/USER_GUIDE.ko.md)**.

## 검증 및 PARKED 범위

v0.9.4 release run #113은 analyze, **218/218 tests**, Windows/macOS exact packaged ZIP smoke, Android release packaging, unsigned iOS packaging, START/source, checksum, legal notice 검증을 통과했습니다.

연기되었으며 활성 NEXT가 아닌 항목: Android 실기기 SAF persistence/revoke 검증, signed iOS development build + iPhone runtime 검증, production signing/notarization/store distribution, installer, auto-update. 이 실기기 시나리오는 `RUNTIME VALIDATED`로 표시하지 않습니다.

## 개인정보 및 라이선스

개인 포트폴리오 데이터는 로컬에 암호화되어 유지됩니다. legacy workspace JSON은 평문으로 남을 수 있으며 migration은 원본 JSON을 자동 삭제하지 않습니다.

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software이며 공개 저장소는 open-source 라이선스를 부여하지 않습니다. [LICENSE.md](../../LICENSE.md) 참조.
