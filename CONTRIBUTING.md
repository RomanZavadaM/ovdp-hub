# Contributing to OVDP Hub

OVDP Hub is **proprietary software**, not an open-source project.

Copyright © 2026 Roman Zavada (Роман Завада). All rights reserved.

## External contributions

Unsolicited code contributions are not automatically accepted. Before submitting a material code, design, documentation or branding contribution, obtain prior agreement from the repository owner regarding the contribution and the rights needed to incorporate it into the proprietary project.

A public pull request does not by itself transfer copyright ownership and does not change the OVDP Hub license.

Pull requests submitted without prior agreement may be reviewed for discussion or closed without merge.

## Technical requirements for an agreed contribution

For active native changes:

- work against the current `main`;
- preserve the privacy and local-first boundaries in `PROJECT_RULES.md`;
- preserve all copyright and third-party notices;
- run `flutter pub get --enforce-lockfile`, `flutter analyze`, and `flutter test`;
- do not commit workspaces, personal investment data, signing keys, databases or private documents;
- do not add a broker/trading integration unless its public documentation and permission to use it have been verified.

See `PROJECT_RULES.md` and `PROJECT_STATE.md` before proposing changes.
