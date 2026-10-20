# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)

> **현재 테스트 릴리스: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
> **개발 상태: ACTIVE — 2026-10-20 v0.10.1 릴리스 체크포인트 준비 중.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## 제품

OVDP Hub는 우크라이나 국채 OVDP용 local-first Flutter/Dart 앱입니다. 시장 출처 확인, 시나리오 계획, 중립적 비교, 실제 기록 기반의 암호화 개인 포트폴리오를 제공합니다.

## v0.10.1 새 기능

- 암호화 사본과 현재 원본을 다시 확인한 뒤에만 평문을 삭제하는 더 안전한 비공개 Planner 마이그레이션;
- 잠금 시 비공개 Planner를 지우고 대화상자, 날짜 선택기, 오래된 비동기 완료를 취소;
- lock/background/dispose가 완료되지 않은 recovery/create/restore/migration을 취소하고 늦게 도착한 키를 제거;
- 비공개 CSV/ICS 내보내기는 평문 저장에 대한 명시적 동의와 정확한 대상 경로를 표시;
- 암호화, KDF 매개변수, payload schema는 변경되지 않았으며 schema v4 유지.

## 제품 범위

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

## 검증 및 범위

v0.10.1 release run #116(commit `933a7bd`)은 analyze, **314 tests**, capability 목록을 포함한 Windows/macOS exact packaged ZIP smoke, Android release packaging, unsigned iOS packaging, START/source, checksum, legal notice 검증을 통과했습니다.

연기: Android 실기기 SAF 검증, signed iOS 실기기 검증, production signing/notarization/store 배포, 설치 프로그램, 자동 업데이트. 경과이자와 수익률은 참고치이며 투자 권유가 아닙니다.

## 개인정보 및 라이선스

개인 포트폴리오 데이터는 로컬에 암호화되어 유지됩니다. legacy workspace JSON은 평문으로 남을 수 있으며 migration은 원본 JSON을 자동 삭제하지 않습니다.

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software이며 공개 저장소는 open-source 라이선스를 부여하지 않습니다. [LICENSE.md](../../LICENSE.md) 참조.
