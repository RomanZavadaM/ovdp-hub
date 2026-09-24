# Encrypted vault — local store / lifecycle

Статус: implementation contract for PR #81.  
Governing documents: `docs/security-vault.md`, `docs/security-vault-dependency-review.md`.

This slice implements encrypted storage mechanics only. It **does not** migrate current `sets/*.json`, introduce a private portfolio schema, or make a user-facing claim that existing OVDP Hub data is encrypted.

## File format v1

Active local file name:

```text
<vaultId>.ovdp-vault.json
```

Top-level fields:
- `application = OVDP-HUB-VAULT-FILE`;
- `fileVersion = 1`;
- `vaultId`;
- monotonic `revision`;
- authenticated encrypted `payload` envelope;
- optional `recoverySlot`.

The outer `vaultId` and `revision` must exactly match the authenticated payload envelope.

## Authenticated recovery-slot binding

A recovery slot is optional, but when present its canonical serialized representation is bound into the payload AEAD authenticated header.

Consequences:
- removing the recovery slot from a recovery-enabled vault fails closed;
- replacing or changing the recovery slot without re-encrypting the payload fails closed;
- adding a recovery slot to a payload that was created without one fails closed.

The recovery slot independently authenticates its own metadata and wrapped DEK.

## Recovery slot v1

Fields:
- `slotType = recovery`;
- `slotVersion = 1`;
- `vaultId`;
- `algorithm = xchacha20poly1305-ietf`;
- exact Argon2id13 KDF parameters;
- random salt;
- random XChaCha20 nonce;
- wrapped 256-bit DEK.

Only the approved KDF profiles from the dependency/security review are accepted. Unknown or weaker parameters fail closed.

Wrong recovery secret, modified metadata or modified wrapped DEK cannot produce a usable DEK.

## Create

1. generate a random DEK;
2. optionally create a recovery-wrapped DEK slot;
3. encrypt payload revision 1 with the recovery-slot binding in AEAD AAD;
4. store the DEK through the platform `VaultDeviceKeyStore`;
5. commit the encrypted vault file through the atomic write protocol;
6. store highest accepted revision = 1.

If the encrypted file has already committed but revision-state persistence fails, the device key is **not** deleted. A later successful open can recover and persist the revision marker.

## Open

1. load device-protected DEK;
2. recover an interrupted replace when target is missing and a known-good backup exists;
3. parse and authenticate the active encrypted file;
4. if the active target is corrupt but a backup exists, independently authenticate the backup before restoring it;
5. compare file revision with highest accepted device revision;
6. lower revision → `VaultRollbackException`; do not silently accept it;
7. higher valid revision → persist it as highest accepted;
8. only after successful acceptance remove stale pending/backup artifacts;
9. decrypt and return payload bytes.

## Save

1. open/authenticate current vault;
2. reject rollback state;
3. increment revision exactly once;
4. encrypt new payload with the existing DEK and existing recovery-slot binding;
5. run atomic commit;
6. persist the new highest accepted revision.

No user/private domain record semantics are present in this layer.

## Atomic commit

For active vault writes:

```text
serialize candidate
→ write <target>.pending with flush
→ parse + authenticate pending
→ rename current target to <target>.backup
→ rename pending to target
→ parse + authenticate committed target
→ delete backup only after success
```

On an in-process failure after replace:
- restore previous backup;
- never leave the failed candidate as the only active copy.

On restart:
- if target is missing and backup exists, restore backup;
- if target exists but is corrupt and backup exists, authenticate backup independently before restoring it;
- rollback checks occur before stale backup cleanup.

## Portable encrypted backup

Portable backup creation requires a recovery slot. A vault without recovery cannot be advertised as portable.

Backup content is the encrypted vault file; plaintext is not exported by this API.

Restore:
1. parse backup;
2. require matching `vaultId`;
3. require recovery slot;
4. derive recovery KEK and unwrap DEK;
5. authenticate/decrypt payload before touching active vault;
6. reject revision lower than highest accepted device revision;
7. reject a conflicting existing device key;
8. commit through the same atomic active-file path;
9. persist recovered DEK on a fresh device/profile only after validation path succeeds sufficiently to proceed.

Corrupt backup or wrong recovery secret never replaces the active vault.

## Rollback model

AEAD cannot distinguish a valid older ciphertext from the newest one.

The device key store therefore retains the highest accepted revision:
- file revision < highest accepted → explicit rollback error;
- file revision == highest accepted → normal;
- authenticated file revision > highest accepted → accept and advance marker.

A new device with no trusted local revision marker can only establish trust through explicit recovery/restore.

## Tests in this slice

Regression coverage includes:
- recovery DEK round-trip;
- wrong recovery secret;
- recovery slot strip/replace detection;
- create/open/save + monotonic revisions;
- post-replace injected failure restores previous known-good vault;
- process-restart recovery from authenticated backup;
- lower revision rollback rejection while preserving backup;
- revision-state persistence failure after create does not destroy device key/file;
- portable backup restore on fresh device store;
- corrupt/wrong-secret backup does not replace current vault;
- portable backup refused without recovery.

## Deferred

Not in PR #81:
- migration of legacy `sets/*.json`;
- private portfolio / acquisition schema;
- lock-screen / unlock UI;
- recovery-secret UX;
- accepting an intentional lower-revision rollback;
- live provider-backed synchronized vault;
- record-level conflict merge;
- deletion of legacy plaintext.

Those require separate reviewed slices.
