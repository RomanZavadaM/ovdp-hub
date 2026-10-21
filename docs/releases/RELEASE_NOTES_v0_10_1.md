# OVDP Hub v0.10.1 — Release Notes

Test/prerelease checkpoint · 2026-10-20 · app 0.10.1+23 · private portfolio schema v4

## Українська

Це patch-реліз із посиленням приватності та lifecycle без зміни криптографії чи формату даних.

- Перенесення приватних Planner-сценаріїв видаляє plaintext лише після повторної перевірки зашифрованої копії та актуального джерела.
- Lock очищує приватний Planner, закриває transient UI та блокує застарілі async completions.
- Lock/background/dispose скасовують незавершені recovery/create/restore/migration operations і видаляють пізні ключі.
- Приватний CSV/ICS export потребує явної згоди на plaintext і показує точне призначення.
- F5 private collections не включено; воно лишається draft PR #154.

## English

This patch release strengthens privacy and lifecycle handling without changing cryptography or data formats.

- Private Planner migration deletes plaintext only after rechecking the encrypted copy and current source.
- Lock clears the private Planner, closes transient UI, and blocks stale async completions.
- Lock/background/dispose cancel unfinished recovery/create/restore/migration work and remove late keys.
- Private CSV/ICS export requires explicit plaintext consent and shows the exact destination.
- F5 private collections is not included and remains draft PR #154.

## Français

Cette version corrective renforce la confidentialité et le cycle de vie sans modifier la cryptographie ni les formats.

- La migration Planner privée ne supprime le plaintext qu’après revalidation de la copie chiffrée et de la source actuelle.
- Le verrouillage efface le Planner privé, ferme l’UI transitoire et bloque les résultats asynchrones obsolètes.
- Lock/background/dispose annulent recovery/create/restore/migration inachevés et suppriment les clés tardives.
- L’export CSV/ICS privé exige un consentement explicite au plaintext et affiche la destination exacte.
- F5 private collections n’est pas inclus et reste le draft PR #154.

## Deutsch

Dieses Patch-Release stärkt Datenschutz und Lifecycle ohne Änderungen an Kryptografie oder Datenformat.

- Private Planner-Migration löscht Klartext erst nach erneuter Prüfung der verschlüsselten Kopie und aktuellen Quelle.
- Sperren leert den privaten Planner, schließt transiente UI und blockiert veraltete asynchrone Ergebnisse.
- Lock/Background/Dispose brechen unvollständige Recovery/Create/Restore/Migration-Vorgänge ab und entfernen verspätete Schlüssel.
- Privater CSV/ICS-Export verlangt ausdrückliche Klartext-Zustimmung und zeigt das genaue Ziel.
- F5 Private Collections ist nicht enthalten und bleibt Draft-PR #154.

## Español

Esta versión de corrección refuerza privacidad y ciclo de vida sin cambiar criptografía ni formatos.

- La migración privada del Planner elimina texto plano solo tras volver a verificar la copia cifrada y la fuente actual.
- El bloqueo limpia el Planner privado, cierra UI transitoria y bloquea resultados asíncronos obsoletos.
- Lock/background/dispose cancelan recovery/create/restore/migration incompletos y eliminan claves tardías.
- La exportación CSV/ICS privada exige consentimiento explícito y muestra el destino exacto.
- F5 private collections no está incluido y sigue como PR #154 en borrador.

## 한국어

이 패치 릴리스는 암호화와 데이터 형식을 바꾸지 않고 개인정보 보호와 lifecycle 처리를 강화합니다.

- 비공개 Planner 마이그레이션은 암호화 사본과 현재 원본을 다시 확인한 뒤에만 평문을 삭제합니다.
- 잠금은 비공개 Planner와 임시 UI를 지우고 오래된 비동기 완료를 차단합니다.
- lock/background/dispose는 미완료 recovery/create/restore/migration을 취소하고 늦게 도착한 키를 제거합니다.
- 비공개 CSV/ICS 내보내기는 평문 동의와 정확한 대상 경로를 표시합니다.
- F5 private collections는 포함되지 않았으며 draft PR #154로 남습니다.

## 日本語

このパッチリリースは、暗号方式やデータ形式を変更せずにプライバシーと lifecycle 処理を強化します。

- 非公開 Planner 移行は、暗号化コピーと現在のソースを再確認した後にのみ平文を削除します。
- ロック時に非公開 Planner と一時 UI を消去し、古い非同期完了を遮断します。
- lock/background/dispose は未完了の recovery/create/restore/migration を中止し、遅延した鍵を削除します。
- 非公開 CSV/ICS export は平文への明示的同意を要求し、正確な保存先を表示します。
- F5 private collections は含まれず、draft PR #154 のままです。

## Verification and boundaries

PR #155 exact head `92c7dc1` passed Flutter analyze, 314 tests, Windows/macOS exact packaged ZIP smoke, Android release packaging, and unsigned iOS packaging; it was merged to main as `b2051ed`. The release workflow must reproduce the full checkpoint and publish START/source, SHA256SUMS, and legal notices.

Physical-device mobile validation, production signing/notarization, store distribution, installers, and auto-update remain deferred. OVDP Hub does not execute trades and is not investment advice.
