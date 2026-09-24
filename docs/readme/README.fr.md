# OVDP Hub

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · **🇫🇷 Français** · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)

> **Current published prerelease / Поточний опублікований prerelease: [OVDP Hub v0.9.0](https://github.com/RomanZavadaM/ovdp-hub/releases/tag/v0.9.0) (0.9.0+17)**
>
> Downloads / Завантаження: [Windows x64](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-Windows-x64.zip) · [macOS](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-macOS.zip) · [Android test](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-Android-test.zip) · [iOS unsigned](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-iOS-unsigned.zip) · [START/source](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/OVDP-Hub-0.9.0-START.zip) · [SHA-256](https://github.com/RomanZavadaM/ovdp-hub/releases/download/v0.9.0/SHA256SUMS.txt)

---

### Présentation

**OVDP Hub** est une application Flutter/Dart installable pour consulter les obligations d’État ukrainiennes (OVDP), leurs sources de marché et créer des scénarios d’investissement personnels. Plateformes cibles : **Windows, macOS, Android et iOS**. Web/PWA ne fait pas partie du produit actif.

Code actif : `apps/native`. Checkpoint publié actuel : **0.9.0 « Marché »**. Le prochain slice ajoute l’apparence optionnelle **« Tableau clair »**, tout en conservant Classic et « Studio ».

### Fonctions disponibles

- catalogue local OVDP basé sur les données publiques de la NBU;
- recherche, filtres, calendriers de paiements et comparaison des émissions;
- couches distinctes **NBU / ministère des Finances / vendeurs** avec provenance, date de source, heure de récupération et état de fraîcheur;
- calendriers structurés des adjudications et résultats détaillés placement/switch;
- plusieurs sources de prix avec priorité explicite définie par l’utilisateur;
- planificateur de budget, réserve, échéances et dépenses futures;
- hypothèses explicites de frais d’achat : un frais inconnu n’est jamais considéré comme nul;
- un profil fiscal OVDP 2026 vérifié pour une personne physique résidente d’Ukraine, avec distinction explicite **inconnu / zéro vérifié**;
- une comparaison FX explicite avec taux, date et URL de source saisis manuellement, sans mélanger les devises du cash-flow de base;
- une vente anticipée par position avec date et prix de sortie BID/manuel propres;
- un besoin futur principal récurrent conservé comme règle typée, les besoins supplémentaires restant ponctuels;
- comparaison neutre **A/B/C** de 2 à 3 scénarios enregistrés, avec comparabilité stricte et sans gagnant automatique;
- le texte généré du planificateur / les libellés prédéfinis sont stockés comme identifiants stables puis localisés à l’affichage; les noms saisis par l’utilisateur restent littéraux;
- sauvegarde portable des scénarios au format JSON;
- interface active et principales erreurs utilisateur localisées en **UK / EN / FR / DE / ES / KO / JA**.

Le coupon nominal n’est pas assimilé au rendement de marché, une observation « yield-only » ne devient jamais automatiquement un prix, et les frais, impôts ou FX inconnus ne sont jamais remplacés silencieusement par zéro.

### Planificateur

Le planificateur reste volontairement mono-devise. Il prend en charge la répartition par échéance, le mode de profit calculé et la couverture des dépenses futures. Quantité et prix total peuvent être modifiés manuellement.

Route vers 0.9.0 :

1. **DONE** — priorité explicite des sources de prix;
2. **DONE** — hypothèses de frais d’achat;
3. **DONE** — hypothèses fiscales vérifiées;
4. **DONE** — hypothèses FX;
5. **DONE** — hypothèses de sortie;
6. **DONE** — comparaison neutre A/B/C;
7. **DONE** — localisation du texte généré / des libellés prédéfinis + régression;
8. **READY** — évaluation formelle 0.9.0 terminée : GO pour préparer le checkpoint prerelease.

OVDP Hub n’exécute aucune transaction et ne confirme pas la disponibilité d’un instrument chez un vendeur.

### Données et confidentialité

Les catalogues et scénarios sont stockés sur l’appareil. Sur desktop, l’utilisateur peut ouvrir ou copier un dossier de travail. OVDP Hub ne dispose pas d’un serveur central de données privées de portefeuille.

Le stockage JSON actuel **n’est pas chiffré**. Il n’est donc pas destiné aux clés de signature, documents KYC ou secrets. Un coffre chiffré et le stockage sécurisé des plateformes constituent une étape ultérieure séparée.

### Test rapide

Les changements ordinaires exécutent `flutter analyze`, `flutter test` et génèrent un paquet START. Sous Windows : `START.bat`; sous macOS : `START.command`. Le premier lancement local nécessite Flutter 3.47.5 et les outils de compilation de la plateforme.

Un prerelease formel produit Windows/macOS/Android/iOS, START/source, `SHA256SUMS.txt`, les notices légales, un tag immuable et une GitHub Release.

### Droits d’auteur

**Copyright © 2026 Roman Zavada. Tous droits réservés.**

OVDP Hub est un **logiciel propriétaire**. La visibilité publique du dépôt n’accorde aucune licence open source ni autorisation de copier, modifier, republier, vendre, redistribuer ou créer des versions dérivées.

Voir [LICENSE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/LICENSE.md), [COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/COPYRIGHT.md), [THIRD_PARTY_NOTICES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/THIRD_PARTY_NOTICES.md), [LEGAL_AND_COPYRIGHT.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/docs/LEGAL_AND_COPYRIGHT.md).

### Développement

```sh
cd apps/native
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Autres cibles : `flutter build macos --release`, `flutter build apk --release`, `flutter build ipa --release`.

État du projet : [START_HERE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/START_HERE.md), [PROJECT_STATE.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_STATE.md), [PROJECT_RULES.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/PROJECT_RULES.md), [WORKLOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/WORKLOG.md), [CHANGELOG.md](https://github.com/RomanZavadaM/ovdp-hub/blob/main/CHANGELOG.md).

---

[🇺🇦 Українська](../../README.md) · [🇬🇧 English](README.en.md) · **🇫🇷 Français** · [🇩🇪 Deutsch](README.de.md) · [🇪🇸 Español](README.es.md) · [🇰🇷 한국어](README.ko.md) · [🇯🇵 日本語](README.ja.md)
