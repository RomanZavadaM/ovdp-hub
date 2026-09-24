# Encrypted vault — lifecycle controls

Статус: **IMPLEMENTATION CONTRACT — PR #86**  
Depends on:
- `docs/security-vault.md`
- `docs/security-vault-local-store.md`
- `docs/security-vault-session.md`

This slice implements recovery-slot lifecycle and local deletion only. It does **not** migrate legacy plaintext, define holdings/private payload schema, or expose user-facing vault UI.

## Recovery enable

Recovery may be enabled only for an existing device-openable local vault.

Contract:
- the existing DEK is preserved;
- a new recovery slot wraps that same DEK with the selected approved Argon2id13 profile;
- the new slot is immediately unwrapped and compared with the active DEK before commit;
- because recovery-slot content is authenticated by payload AAD, the private payload is re-encrypted with a fresh nonce and the next logical revision;
- the operation uses the normal known-good atomic commit path;
- if recovery is already configured, enable fails closed.

## Recovery rotate

Rotation:
- requires an existing recovery slot;
- does not rotate the DEK;
- creates and verifies a completely new recovery slot;
- authenticates the new slot binding through a freshly encrypted payload revision;
- atomically replaces the prior vault file only after staged validation;
- old recovery material stops being valid after successful commit.

A failed rotate must leave the previous active vault/recovery slot usable.

## Recovery remove

Removal:
- requires an existing recovery slot;
- preserves the device key and encrypted payload data;
- creates a new payload revision whose authenticated recovery-slot binding is null;
- after commit, portable encrypted backup creation is unavailable until recovery is enabled again;
- existing external backup files are untouched.

## Session authorization and serialization

Recovery mutations and local delete are exposed through `VaultSessionController`.

Requirements:
- session must be unlocked for the matching vault;
- controller locks and clears app-held plaintext **before** running the lifecycle mutation;
- success leaves the session locked;
- failure leaves plaintext cleared and enters a technical `error` state;
- a store operation already in flight causes `vault.session_busy`;
- second save, recovery/delete mutation, and re-unlock cannot overlap an unfinished save/open/lifecycle store operation;
- manual lock may still happen immediately while a store operation is in flight; re-unlock waits until that store operation has finished.

The LocalVaultStore is not a re-entrant mutation API. Product/UI callers must use the session/lifecycle orchestration contract instead of running concurrent direct mutations.

## Local delete

“Delete local vault” means only app-owned local state for that vault:
- active encrypted vault file;
- app-owned `.pending`, `.backup`, and `.deleting` artifacts;
- device key;
- highest-accepted revision metadata.

It never deletes user-selected external encrypted backups.

No secure-erase claim is made for SSD/flash blocks, filesystem snapshots, cloud/provider history or external copies.

## Delete transaction

Normal delete:
1. validate/open the active encrypted vault with the device key;
2. reject rollback/corrupt state;
3. clean stale app-owned write artifacts;
4. rename active file to `.deleting`;
5. remove device key/revision metadata;
6. remove `.deleting`.

Failure after staging:
- if device-key deletion fails, restore the staged file;
- if file deletion fails after key deletion, restore the device key/revision and active file where possible;
- if rollback itself fails, surface `vault.delete_rollback_failed`; never claim deletion succeeded.

Crash recovery:
- `.deleting` + device key still present → normal open/delete may restore the active file first;
- `.deleting` + device key absent → a repeated delete resumes/finalizes deletion;
- local delete is idempotent after successful completion.

## Reserved paths

Portable backup/restore must reject the active vault and app-owned lifecycle artifact paths:
- active file;
- `.pending`;
- `.backup`;
- `.deleting`.

This prevents an external backup operation from overwriting internal transactional state.

## Regression requirements

Tests cover:
- enable recovery on a vault created without recovery;
- rotate recovery and rejection of the old secret;
- remove recovery while preserving device-key access;
- portable backup unavailable after recovery removal;
- failed recovery-slot commit preserves old usable state;
- delete removes only app-owned local state and leaves external backup untouched;
- delete rollback after device-key or post-key failure;
- interrupted delete before/after device-key deletion;
- reserved backup/restore paths;
- lifecycle call requires matching unlocked session and locks first;
- lifecycle failure is plaintext-free;
- in-flight save serializes second save, lifecycle mutation and re-unlock.

## Explicitly deferred

- recovery/delete UI and confirmation copy;
- biometric/user-presence UX;
- legacy `sets/*.json` migration/deletion;
- holdings/acquisition-lot/private payload schema;
- secure erase claims;
- external provider live-vault support.
