# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)

> **현재 테스트 릴리스: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
> **개발 상태: ACTIVE — v0.10.1 게시 완료; 다음 체크포인트를 검증 중입니다.**
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


## v0.10.1 이후 — 다음 체크포인트 후보

- F5는 `main`에 통합되었습니다. 이름과 메모가 있는 비공개 모음은 포트폴리오에 암호화되어 저장되고 편집·재열기가 가능하며, 잠그면 비공개 초안이 지워집니다.
- 공개 ISIN 목록은 포트폴리오 없이 작동하며 비공개 메모를 포함하지 않습니다.
- 기존 평문 모음의 이동은 명시적 작업입니다. 전체 암호화 사본과 변경되지 않은 원본을 검증한 뒤에만 원본을 삭제하며, 충돌·알 수 없는 필드·잠금·오류가 있으면 원본을 보존합니다.
- Payload schema v4는 v1–v4를 읽으며 암호화 방식과 KDF는 변경되지 않았습니다.
- PR #157은 Inzhur, UNIVER, PrivatBank의 공개 제안을 ISIN·통화·만기로 비교하는 읽기 전용 화면을 준비합니다. 가격·수익률·수량·출처 시간은 구분하며 모르는 값은 추정하지 않습니다.
- 아직 게시된 릴리스가 아니며 현재 다운로드는 v0.10.1입니다.

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

PR #155 exact head는 analyze, **314 tests**, Windows/macOS exact ZIP smoke, Android release 및 unsigned iOS packaging을 통과했습니다. v0.10.1 release workflow는 이 gate를 반복하고 START/source, checksum, legal notice를 게시해야 합니다.

연기: Android 실기기 SAF 검증, signed iOS 실기기 검증, production signing/notarization/store 배포, 설치 프로그램, 자동 업데이트. 경과이자와 수익률은 참고치이며 투자 권유가 아닙니다.

## 개인정보 및 라이선스

개인 포트폴리오 데이터는 로컬에 암호화되어 유지됩니다. legacy workspace JSON은 평문으로 남을 수 있으며 migration은 원본 JSON을 자동 삭제하지 않습니다.

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software이며 공개 저장소는 open-source 라이선스를 부여하지 않습니다. [LICENSE.md](../../LICENSE.md) 참조.
