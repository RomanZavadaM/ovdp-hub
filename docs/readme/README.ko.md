# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · [🇫🇷 Français](README.fr.md) · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · **🇰🇷 한국어** · [🇯🇵 日本語](README.ja.md)

> **현재 테스트 prerelease: [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip)

## 제품
OVDP Hub는 우크라이나 국채 OVDP용 local-first Flutter/Dart 앱입니다. 시장 출처 확인, 시나리오 계획, 중립적 비교, 실제 기록 기반의 암호화 개인 포트폴리오를 제공합니다.

## v0.9.3 주요 기능
- NBU / MinFin / 판매자 레이어와 provenance/freshness;
- 수수료, 세금, FX, 조기 매도, reserve floor, 반복 필요를 포함한 Planner;
- 자동 winner가 없는 A/B/C 비교;
- deterministic CSV/ICS export;
- 상시 Economic Pulse;
- 매수/매도/쿠폰/상환을 기록하는 암호화 포트폴리오;
- 임의 FIFO/LIFO 대신 acquisition lot 명시 할당;
- ISIN ledger와 종료 포지션 조회;
- unknown 수수료를 0으로 바꾸지 않는 실제 현금 요약;
- 암호화 복사본 검증을 포함한 비파괴 legacy migration;
- Classic / Workbench / Light Dashboard;
- UK/EN/FR/DE/ES/KO/JA UI.

현금 요약에는 열린 포지션의 현재 시장가치가 포함되지 않으므로 투자수익률 지표가 아닙니다.

## 설치
Windows: ZIP 전체를 풀고 `ovdp_hub.exe`를 실행합니다. macOS: `ovdp_hub.app`을 엽니다; 현재 prerelease는 notarized가 아닙니다. Android: `OVDP-Hub.apk`를 설치합니다. iOS 패키지는 unsigned입니다.

전체 안내서: **[한국어 사용자 가이드](../user-guide/USER_GUIDE.ko.md)**.

## 개인정보
개인 포트폴리오 데이터는 로컬에 암호화되어 유지됩니다. legacy workspace JSON은 평문으로 남을 수 있으며 migration은 원본 JSON을 자동 삭제하지 않습니다.

## 검증 및 라이선스
v0.9.3은 analyze/tests, Windows/macOS 실제 패키지 executable smoke, Android, unsigned iOS, START/source, checksum, legal notice 검증을 통과했습니다.

Copyright © 2026 Roman Zavada. All rights reserved. Proprietary software; [LICENSE.md](../../LICENSE.md) 참조.
