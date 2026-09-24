# Legacy plaintext migration — encrypted private payload

Статус: **IMPLEMENTATION CONTRACT — PR #94**  
Source: legacy workspace `sets/*.json` records.  
Destination: encrypted private payload schema v3.

This slice implements the migration core only. It does not add migration UI, portfolio UI, or plaintext deletion.

## 1. Inventory result

Legacy `SavedSet` records contain:
- user-authored collection `name`;
- user-authored `note`;
- `savedAt`;
- copies of public Bond records;
- optional raw Planner `scenario`.

They do **not** contain factual acquisition lots, factual broker executions, factual holding quantities, factual disposal allocations or factual cash ledger provenance.

Therefore migration must never reinterpret a saved collection as a real portfolio position.

## 2. Encrypted mapping

Private payload schema v3 adds `legacyCollections`.

Each migrated record stores only:
- stable `sourceId` from the immutable source filename;
- name;
- note;
- savedAt;
- sorted unique selected ISIN references;
- raw Planner scenario, recursively canonicalized by sorted object keys.

Full public Bond snapshots are deliberately omitted. Public NBU/MinFin/seller data stays outside the private payload.

No acquisition lot, cash event, disposal or holding is synthesized. Migration report always records `portfolioFactsCreated = 0`.

## 3. Backward compatibility

Decoder accepts:
- schema v1: acquisition lots + cash events;
- schema v2: v1 + factual disposals;
- schema v3: v2 + encrypted legacy collection records.

Any newly encoded payload uses schema v3.

## 4. Strict source handling

Migration validates the legacy top-level envelope before using `SavedSet.parse`.

Accepted keys:
- schema 1: `schemaVersion/name/note/savedAt/assets`;
- schema 2: the same plus `scenario`.

Unknown top-level fields fail closed as `migration.unsupported_legacy_fields`. This prevents future/private fields from being silently dropped by an older migrator.

Public Bond snapshot internals are parsed by the existing Bond model but are not copied beyond selected ISIN references.

## 5. Idempotence and conflicts

The immutable legacy filename stem is the source identity.

For an already-present source id:
- identical mapped canonical content → `alreadyMigrated`, no vault write/revision bump;
- different mapped private content → `conflict`, never overwrite automatically.

A public Bond snapshot-only change that leaves the private mapped record unchanged does not create a private migration conflict.

## 6. Partial failure

Files are processed independently.

A corrupt or unsupported source:
- is reported `invalid` with a stable error code;
- is not deleted or rewritten;
- does not prevent other valid source files from being copied.

A report with any invalid/conflict item is not `complete`, even if valid items were successfully encrypted.

## 7. Encrypted verification

When at least one new record is copied:

1. decode the current encrypted private payload;
2. construct schema-v3 payload preserving all factual lot/event/disposal records;
3. add only new legacy collection records;
4. save through `VaultContentStore`;
5. reopen/decrypt the vault;
6. compare portfolio record IDs and every expected legacy source id + canonical mapped content.

Verification failure is an error. Migration never uses a successful write as permission to delete plaintext.

## 8. Plaintext deletion

This migrator has **no delete API**.

Legacy source files:
- are never modified by the migration core;
- are never automatically removed after success;
- remain reportable through `plaintextFilesStillPresent` / `requiresExplicitPlaintextCleanup`.

Any future delete/cleanup action requires:
- explicit user action;
- a separate UI/orchestration contract;
- confirmation that the encrypted copy is verified;
- no claim of physical secure erase.

## 9. Session/orchestration boundary

The core migrator operates on `VaultContentStore` and is not yet wired to user-facing flows.

Before UI wiring, migration must be orchestrated as an exclusive locked maintenance operation so it cannot race with an unlocked save/lifecycle operation. This slice does not weaken the existing session serialization contract.

## 10. Regression gates

Tests cover:
- schema-v1 and schema-v2 decode → schema-v3 encode;
- deterministic scenario canonicalization;
- real `Workspace.saveSet()` migration;
- encrypted physical file contains no plaintext migrated note/ISIN/scenario value;
- no acquisition/cash/disposal/holding facts created;
- source file unchanged and still present;
- idempotent rerun without vault revision bump;
- same source id + changed private content → conflict/no overwrite;
- public snapshot-only change → already migrated;
- corrupt source + valid source → partial migration + incomplete report;
- unknown top-level legacy field → fail closed/no vault write.

## 11. Explicitly deferred

- migration UI/status screen;
- explicit plaintext cleanup UI/action;
- portfolio UI;
- automatic mapping from Planner scenario to factual holdings;
- broker statement import;
- reconstruction of missing acquisition/disposal/coupon history;
- live provider-backed vault mutation.
