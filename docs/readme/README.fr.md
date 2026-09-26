# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · **🇫🇷 Français** · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Checkpoint final du périmètre actuel : [OVDP Hub v0.9.4](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.4) — 0.9.4+21**
>
> **Statut du développement : PARKED / terminé au périmètre actuel. Aucun développement actif.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/OVDP-Hub-0.9.4-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.4/SHA256SUMS.txt)

## Produit

OVDP Hub est une application Flutter/Dart local-first pour les OVDP ukrainiennes : sources de marché, planification de scénarios, comparaison neutre et portefeuille personnel chiffré factuel.

## Points forts v0.9.4

- couches NBU / MinFin / vendeurs avec provenance et freshness;
- Planner avec frais, fiscalité, FX, besoins récurrents, reserve floor et sortie anticipée par position;
- comparaison A/B/C sans gagnant automatique;
- exports CSV/ICS déterministes et Economic Pulse;
- Portfolio chiffré avec achat, vente, coupon, remboursement, allocation explicite aux lots et ledger par ISIN;
- confirmation/rotation du recovery secret et backup/restore chiffré portable sous Windows;
- Portfolio macOS utilisant le Keychain avec smoke du cycle de vie réel du package;
- base Android SAF et iOS security-scoped pour le stockage externe;
- workspace mobile externe, transport de backup chiffré et permissions fail-closed;
- self-test mobile en deux phases avec terminate/relaunch;
- trois apparences et UI UK/EN/FR/DE/ES/KO/JA avec langue/apparence persistantes.

Le résumé de trésorerie n’inclut pas la valeur de marché actuelle des positions ouvertes et n’est pas une mesure de performance. Les frais inconnus restent inconnus.

## Installation

Windows : extraire tout le ZIP et lancer `ovdp_hub.exe`. macOS : extraire et ouvrir `ovdp_hub.app`; ce checkpoint n’est pas notarized. Android : installer `OVDP-Hub.apk`. Le package iOS est unsigned et nécessite un signing/provisioning Apple séparé.

Guide complet : **[Guide utilisateur français](../user-guide/USER_GUIDE.fr.md)**.

## Vérification et limites PARKED

Le run de release #113 de v0.9.4 a réussi analyze, **218/218 tests**, smoke des ZIP Windows/macOS, packaging Android release, packaging iOS unsigned, START/source, checksums et notices légales.

Différé et non actif : validation physique Android SAF, build iOS signé + validation sur iPhone, signing/notarization/distribution store de production, installateurs et auto-update. Ces cas physiques ne sont pas déclarés `RUNTIME VALIDATED`.

## Confidentialité et licence

Le portefeuille privé reste local et chiffré. Les JSON legacy du workspace peuvent rester en clair; la migration ne supprime jamais automatiquement le JSON source.

Copyright © 2026 Roman Zavada. Tous droits réservés. Logiciel propriétaire; le dépôt public n’accorde pas de licence open-source. Voir [LICENSE.md](../../LICENSE.md).
