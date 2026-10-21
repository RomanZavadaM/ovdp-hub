# START HERE — OVDP Hub

Оновлено: **21.10.2026**

## Поточна точка

1. Останній опублікований prerelease: **v0.10.1 / 0.10.1+23**.
2. `main` містить F5 private collections: `c6fcdecd4edfbe0ad681195b17bf48df77abfd52`.
3. Активний PR #157: public Inzhur/UNIVER offers з per-source ISIN comparison.
4. Кандидат **v0.11.0+24** ще не опублікований: спочатку фінальний docs-sync, exact-head platform gates, merge, post-merge gates і immutable release.
5. Не повертати старі work/feature branches як джерело коду й не переписувати tag/release v0.10.1.

## Порядок відновлення контексту

`PROJECT_RULES.md` → `PROJECT_STATE.md` → `WORKLOG.md` → фактичні GitHub `main`/open PR/latest release → Issue #18.

## Незмінні правила

- local-first; без broker login/OTP, execution, private portfolio relay чи analytics tracking;
- приватні суми/нотатки — лише encrypted vault;
- невідоме не перетворювати на нуль або вигадане значення;
- explicit consent для plaintext export і destructive migration;
- повний platform gate перед merge/release;
- crypto/KDF не змінювати без окремого плану;
- deferred signing/devices/stores/installers/auto-update не оголошувати завершеними.

## Наступна дія

Завершити PR #157 на його точному head: документація всіма сімома мовами, analyze/tests, Windows/macOS exact packaged smoke, Android release, iOS unsigned. Після green merge — повторити main verification, зафіксувати SHA/runs у `PROJECT_STATE.md`, `WORKLOG.md`, changelog, release notes та Issue #18.
