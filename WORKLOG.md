# WORKLOG — OVDP Hub

Оновлено: **26.09.2026**

## STATUS

**PARKED — поточний рівень розробки закритий.**

Активних PR: після фінального docs-sync не повинно бути.  
Активного `DOING` / `NEXT`: **немає**.

## Фінальний checkpoint цього етапу

**v0.9.4 / 0.9.4+21**

- release PR #135;
- release/product checkpoint commit `1185ad7f94339cd8865f3123570b9ad14a935114`;
- native post-merge run #518 — SUCCESS;
- release run #113 — SUCCESS;
- GitHub prerelease `v0.9.4` published 26.09.2026;
- 218/218 tests;
- Windows/macOS exact packaged ZIP smoke;
- Android test APK package;
- unsigned iOS package;
- START/source, SHA256SUMS, legal notices.

## Що закрито перед PARKED

Після v0.9.3 завершено й інтегровано:
- Portfolio recovery/rotation та Windows portable encrypted backup/restore;
- Planner safe criteria/date editing;
- Catalog/UI localization cleanup;
- persisted language/appearance;
- shared date controls;
- macOS Keychain runtime proof + Portfolio enablement;
- Android SAF + iOS security-scoped external storage foundation;
- mobile external workspace / encrypted backup transport;
- two-phase mobile runtime probe harness;
- durable recovery/state mechanism;
- фінальний v0.9.4 parked checkpoint.

## Deferred backlog — НЕ NEXT

Ці пункти не виконувати без нового рішення власника:
- Android physical SAF persistence/revoke/provider-loss test;
- iOS development signing і physical iPhone runtime validation;
- Windows code signing;
- macOS notarization;
- Android/iOS store signing/distribution;
- installers / auto-update;
- нові product/domain/UX slices.

## Recovery rule

Якщо робота колись відновиться:
1. `START_HERE.md`;
2. `PROJECT_RULES.md`;
3. `PROJECT_STATE.md`;
4. цей `WORKLOG.md`;
5. фактичний GitHub `main`, latest release, open PR;
6. останні записи Issue #18.

Після цього власник має явно визначити новий scope. **Не продовжувати deferred backlog автоматично і не повторювати вже merged роботу.**
