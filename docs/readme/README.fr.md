# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · **🇫🇷 Français** · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Prerelease de test actuel : [OVDP Hub v0.9.3](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.3) — 0.9.3+20**
>
> [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.3/OVDP-Hub-0.9.3-START.zip)

## Produit
OVDP Hub est une application Flutter/Dart local-first pour les OVDP ukrainiennes : sources de marché, planification de scénarios, comparaison neutre et portefeuille personnel chiffré factuel.

## Points forts v0.9.3
- couches NBU / MinFin / vendeurs avec provenance et freshness;
- Planner avec frais, fiscalité, FX, vente anticipée, reserve floor et besoins récurrents;
- comparaison A/B/C sans gagnant automatique;
- exports CSV/ICS déterministes;
- Economic Pulse permanent;
- portefeuille chiffré avec achat, vente, coupon et remboursement factuels;
- allocation explicite aux lots d’acquisition, sans FIFO/LIFO inventé;
- ledger par ISIN et positions clôturées;
- résumé de trésorerie factuel avec frais inconnus conservés comme inconnus;
- assistant de migration legacy non destructif avec vérification de la copie chiffrée;
- trois apparences et UI en UK/EN/FR/DE/ES/KO/JA.

Le résumé de trésorerie n’inclut pas la valeur de marché actuelle des positions ouvertes : ce n’est pas une mesure de performance.

## Installation
Windows : extraire tout le ZIP et lancer `ovdp_hub.exe`. macOS : extraire et ouvrir `ovdp_hub.app`; le prerelease n’est pas notarized. Android : installer `OVDP-Hub.apk`. Le package iOS est unsigned.

Guide complet : **[Guide utilisateur français](../user-guide/USER_GUIDE.fr.md)**.

## Confidentialité
Le portefeuille privé reste local et chiffré. Les JSON legacy du workspace peuvent rester en clair; la migration ne supprime jamais automatiquement le JSON source. Faire des sauvegardes avant les mises à jour importantes.

## Vérification et licence
v0.9.3 a passé analyze/tests, packaging Windows/macOS avec smoke de l’exécutable réellement distribué, Android, iOS unsigned, START/source, checksums et notices légales.

Copyright © 2026 Roman Zavada. Tous droits réservés. Logiciel propriétaire; voir [LICENSE.md](../../LICENSE.md).
