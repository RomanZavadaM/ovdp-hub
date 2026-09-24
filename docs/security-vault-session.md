# Encrypted vault — session and locking foundation

Статус: **IMPLEMENTATION CONTRACT — PR #83**  
Depends on: `docs/security-vault.md`, `docs/security-vault-local-store.md`.

This slice governs only the in-process unlocked session. It does **not** migrate legacy plaintext, expose portfolio UI, or claim that existing user data is encrypted.

## State machine

Allowed states:
- `locked`
- `unlocking`
- `unlocked`
- `locking`
- `error`

The session starts locked.

## Unlock

- unlock is explicit and always goes through `VaultContentStore.open`;
- the store result is copied into session-owned memory;
- the returned store buffer is overwritten immediately after the copy;
- stale async unlock completion cannot reopen a session after manual lock/dispose/newer transition;
- unlock error clears any held plaintext and enters `error`.

## Manual lock

Manual lock:
- invalidates pending async completions through a generation token;
- cancels inactivity/background timers;
- overwrites the session-owned plaintext buffer before dropping the reference;
- clears activity/background timestamps;
- ends in `locked`.

The implementation minimizes plaintext lifetime but does not claim guaranteed Dart heap zeroization.

## Inactivity

`VaultSessionPolicy.inactivityTimeout` is injected. This slice defines no hidden product default.

- successful unlock starts inactivity tracking;
- explicit activity resets the timer;
- reading a plaintext copy counts as activity;
- successful save refreshes activity;
- inactivity expiry locks the session.

## Background / foreground

`backgroundGrace` is also injected.

- background records a timestamp and schedules a lock after the grace interval for both `unlocked` **and in-flight `unlocking`** states;
- an unlock that completes after a background-grace lock is stale and cannot repopulate plaintext;
- foreground during an in-flight unlock cancels the pending background timer only when the grace has not expired; if grace already expired it locks/invalidates that unlock;
- foreground checks elapsed wall-clock time, not only timer delivery, because OS suspension may pause timers;
- if background grace or inactivity already expired, foreground locks before the caller may continue with private rendering;
- if neither expired, the session may remain unlocked and activity tracking resumes.

## Async race safety

Every unlock/save/lock/dispose transition is associated with a generation counter.

A completion from an older generation:
- cannot change the current session state;
- cannot repopulate plaintext;
- overwrites its returned plaintext buffer before returning.

This specifically covers manual lock while unlock/save is still in flight.

## Error state

Session errors expose only a stable technical error code:
- known `FormatException` / `StateError` codes are forwarded;
- rollback maps to `vault.rollback_detected`;
- unknown failures map to `vault.session_error`.

Private payload content is never embedded in the session error state.

`clearError()` returns to locked and clears app-held plaintext/timers.

## Disposal

Controller disposal:
- invalidates pending completions;
- cancels timers;
- overwrites/drops the session plaintext buffer;
- clears timestamps.

## Tests required by this slice

Deterministic tests use injected clock/timer scheduling and cover:
- manual unlock/lock;
- inactivity auto-lock;
- background grace;
- foreground enforcement when timers were suspended;
- stale unlock completion after manual lock;
- background during pending unlock cannot bypass grace lock;
- foreground during pending unlock cancels a non-expired grace timer without leaving a delayed stray lock;
- save while unlocked;
- store error → cleared plaintext → error → locked.

## Explicitly deferred

- user-facing lock/unlock UI;
- biometric/user-presence UX;
- concrete timeout defaults;
- legacy `sets/*.json` migration;
- private portfolio schema/UI;
- secure screen / platform screenshot policy;
- production macOS Keychain runtime/provisioning proof.
