# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · **🇫🇷 Français** · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Version de test actuelle: [OVDP Hub v0.10.1](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.10.1) — 0.10.1+23**
>
> **Statut : ACTIVE — v0.10.1 est publiée ; le prochain checkpoint est en cours de vérification.**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/OVDP-Hub-0.10.1-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.10.1/SHA256SUMS.txt)

## Produit

OVDP Hub est une application Flutter/Dart local-first pour les OVDP ukrainiennes : sources de marché, planification de scénarios, comparaison neutre et portefeuille personnel chiffré factuel.

## Nouveautés v0.10.1

- migration Planner privée plus sûre : le plaintext n’est supprimé qu’après une nouvelle vérification de la copie chiffrée et de la source actuelle ;
- le verrouillage efface le Planner privé et annule les dialogues, sélecteurs de date et résultats asynchrones obsolètes ;
- lock/background/dispose annulent les opérations recovery/create/restore/migration inachevées et suppriment les clés tardives ;
- l’export CSV/ICS privé exige un consentement explicite au plaintext et affiche la destination exacte ;
- cryptographie, paramètres KDF et schéma payload inchangés ; le schéma reste v4.


## Après v0.10.1 — candidat au prochain checkpoint

- F5 est intégré à `main` : les collections privées avec nom et note sont chiffrées dans le portefeuille, modifiables et rouvrables ; le verrouillage efface le brouillon.
- Les listes ISIN publiques fonctionnent sans portefeuille et sans annotation privée.
- Le déplacement d’une ancienne collection en clair est explicite. La source n’est supprimée qu’après vérification de la copie chiffrée complète et de la source inchangée ; conflit, champ inconnu, verrouillage ou erreur préservent l’original.
- Le schéma payload v5 lit v1–v4 ; cryptographie et KDF restent inchangés.
- La PR #157 prépare une comparaison en lecture seule des offres publiques Inzhur, UNIVER et PrivatBank par ISIN, devise et échéance. Prix, rendement, quantité et heure de source restent distincts ; aucune valeur inconnue n’est inventée.
- Ce n’est pas encore une version publiée ; v0.10.1 reste le téléchargement actuel.

## Périmètre du produit

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

## Vérification et limites

Le run de release #116 de v0.10.1 (commit `933a7bd`) a réussi analyze, **314 tests**, smoke des ZIP Windows/macOS avec la liste des capacités, packaging Android release, packaging iOS unsigned, START/source, checksums et notices légales.

Différé : validation physique Android SAF et iOS signé, signature de production, notarisation, distribution store, installateurs et auto-update. Intérêts courus et rendements indicatifs ; pas de conseil en investissement.

## Confidentialité et licence

Le portefeuille privé reste local et chiffré. Les JSON legacy du workspace peuvent rester en clair; la migration ne supprime jamais automatiquement le JSON source.

Copyright © 2026 Roman Zavada. Tous droits réservés. Logiciel propriétaire; le dépôt public n’accorde pas de licence open-source. Voir [LICENSE.md](../../LICENSE.md).
