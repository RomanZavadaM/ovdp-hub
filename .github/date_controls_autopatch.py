from pathlib import Path


def replace_once(path: Path, old: str, new: str, expected: int = 1) -> None:
    text = path.read_text()
    count = text.count(old)
    if count != expected:
        raise SystemExit(
            f"{path}: expected {expected} matches, found {count} for {old[:100]!r}"
        )
    path.write_text(text.replace(old, new, expected))


date_field = Path("apps/native/lib/ui/date_field.dart")
replace_once(
    date_field,
    "  final String controlKey;\n  final String canonicalValue;",
    "  final String controlKey;\n  final Key? inputKey;\n  final String canonicalValue;",
)
replace_once(
    date_field,
    "    required this.controlKey,\n    required this.canonicalValue,",
    "    required this.controlKey,\n    this.inputKey,\n    required this.canonicalValue,",
)
replace_once(
    date_field,
    "      key: ValueKey('${widget.controlKey}-input'),",
    "      key: widget.inputKey ?? ValueKey('${widget.controlKey}-input'),",
)

planner = Path("apps/native/lib/features/planner/planner_view.dart")
replace_once(
    planner,
    "import '../../ui/components.dart';\n",
    "import '../../ui/components.dart';\nimport '../../ui/date_field.dart';\n",
)
replace_once(
    planner,
    "    var sourceUrl = existing?.source?.sourceUrl ?? '';\n\n    final submitted = await showDialog<bool>(",
    "    var sourceUrl = existing?.source?.sourceUrl ?? '';\n    final asOfKey = GlobalKey<HubDateFieldState>();\n\n    final submitted = await showDialog<bool>(",
)
replace_once(
    planner,
    "                TextFormField(\n                  initialValue: asOf,\n                  decoration: InputDecoration(\n                    labelText: strings.text('fxAsOf'),\n                  ),\n                  onChanged: (value) => asOf = value,\n                ),",
    "                HubDateField(\n                  key: asOfKey,\n                  controlKey: 'planner-fx-asof',\n                  canonicalValue: asOf,\n                  label: strings.text('fxAsOf'),\n                  invalidDateText: strings.text('plannerCriteriaInvalidDate'),\n                  onCommit: (value) async {\n                    asOf = value;\n                    return true;\n                  },\n                ),",
)
replace_once(
    planner,
    "            FilledButton(\n              onPressed: () => Navigator.pop(dialogContext, true),\n              child: Text(strings.text('applyFxComparison')),\n            ),",
    "            FilledButton(\n              onPressed: () async {\n                final accepted =\n                    await asOfKey.currentState?.commitPending() ?? false;\n                if (!accepted || !dialogContext.mounted) return;\n                Navigator.pop(dialogContext, true);\n              },\n              child: Text(strings.text('applyFxComparison')),\n            ),",
)
replace_once(
    planner,
    "    var sourceUrl = existing?.price.meta.sourceUrl == 'local://manual-exit'\n        ? ''\n        : existing?.price.meta.sourceUrl ?? '';\n\n    final submitted = await showDialog<bool>(",
    "    var sourceUrl = existing?.price.meta.sourceUrl == 'local://manual-exit'\n        ? ''\n        : existing?.price.meta.sourceUrl ?? '';\n    final dateKey = GlobalKey<HubDateFieldState>();\n\n    final submitted = await showDialog<bool>(",
)
replace_once(
    planner,
    "                TextFormField(\n                  initialValue: date,\n                  decoration: InputDecoration(\n                    labelText: strings.text('exitDate'),\n                  ),\n                  onChanged: (value) => date = value,\n                ),",
    "                HubDateField(\n                  key: dateKey,\n                  controlKey: 'planner-exit-date',\n                  canonicalValue: date,\n                  label: strings.text('exitDate'),\n                  invalidDateText: strings.text('plannerCriteriaInvalidDate'),\n                  onCommit: (value) async {\n                    date = value;\n                    return true;\n                  },\n                ),",
)
replace_once(
    planner,
    "            FilledButton(\n              onPressed: () => Navigator.pop(dialogContext, true),\n              child: Text(strings.text('applyExit')),\n            ),",
    "            FilledButton(\n              onPressed: () async {\n                final accepted =\n                    await dateKey.currentState?.commitPending() ?? false;\n                if (!accepted || !dialogContext.mounted) return;\n                Navigator.pop(dialogContext, true);\n              },\n              child: Text(strings.text('applyExit')),\n            ),",
)
replace_once(
    planner,
    "                    SizedBox(\n                      width: 220,\n                      child: TextFormField(\n                        key: ValueKey('needDate-${state.revision}'),\n                        initialValue: c['needDate'],\n                        enabled: !disabled,\n                        decoration: InputDecoration(\n                          labelText: strings.text('needDateField'),\n                        ),\n                        onChanged: (v) => cubit.edit('needDate', v),\n                      ),\n                    ),",
    "                    SizedBox(\n                      width: 220,\n                      child: HubDateField(\n                        key: ValueKey('needDate-${state.revision}'),\n                        controlKey: 'planner-need-date',\n                        canonicalValue: c['needDate']!,\n                        label: strings.text('needDateField'),\n                        invalidDateText:\n                            strings.text('plannerCriteriaInvalidDate'),\n                        enabled: !disabled,\n                        onCommit: (value) async {\n                          cubit.edit('needDate', value);\n                          return true;\n                        },\n                      ),\n                    ),",
)
old_expense = """                  for (final field in {
                    'expenseName$i': strings.text('expenseName'),
                    'expenseDate$i': strings.text('dateYmd'),
                    'expenseAmount$i': '${strings.text('amount')}, $currency',
                  }.entries)
                    SizedBox(
                      width: 220,
                      child: TextFormField(
                        key: ValueKey(
                          '${field.key}-${state.revision}-${strings.language.code}',
                        ),
                        initialValue: field.key.startsWith('expenseName')
                            ? _generatedCopy(strings, c[field.key])
                            : c[field.key],
                        enabled: !disabled,
                        decoration: InputDecoration(labelText: field.value),
                        onChanged: (v) => cubit.edit(field.key, v),
                      ),
                    ),"""
new_expense = """                  for (final field in {
                    'expenseName$i': strings.text('expenseName'),
                    'expenseDate$i': strings.text('dateYmd'),
                    'expenseAmount$i': '${strings.text('amount')}, $currency',
                  }.entries)
                    SizedBox(
                      width: 220,
                      child: field.key.startsWith('expenseDate')
                          ? HubDateField(
                              key: ValueKey(
                                '${field.key}-${state.revision}-${strings.language.code}',
                              ),
                              controlKey: 'planner-${field.key}',
                              canonicalValue: c[field.key] ?? c['start']!,
                              label: field.value,
                              invalidDateText:
                                  strings.text('plannerCriteriaInvalidDate'),
                              enabled: !disabled,
                              onCommit: (value) async {
                                cubit.edit(field.key, value);
                                return true;
                              },
                            )
                          : TextFormField(
                              key: ValueKey(
                                '${field.key}-${state.revision}-${strings.language.code}',
                              ),
                              initialValue: field.key.startsWith('expenseName')
                                  ? _generatedCopy(strings, c[field.key])
                                  : c[field.key],
                              enabled: !disabled,
                              decoration:
                                  InputDecoration(labelText: field.value),
                              onChanged: (v) => cubit.edit(field.key, v),
                            ),
                    ),"""
replace_once(planner, old_expense, new_expense)
replace_once(
    planner,
    "                  SizedBox(\n                    width: 220,\n                    child: TextFormField(\n                      key: ValueKey('reserveFloorDate-${state.revision}'),\n                      initialValue: c['reserveFloorDate'],\n                      enabled: !disabled,\n                      decoration: InputDecoration(\n                        labelText: strings.text('reserveFloorDate'),\n                      ),\n                      onChanged: (v) => cubit.edit('reserveFloorDate', v),\n                    ),\n                  ),",
    "                  SizedBox(\n                    width: 220,\n                    child: HubDateField(\n                      key: ValueKey('reserveFloorDate-${state.revision}'),\n                      controlKey: 'planner-reserve-floor-date',\n                      canonicalValue: c['reserveFloorDate']!,\n                      label: strings.text('reserveFloorDate'),\n                      invalidDateText:\n                          strings.text('plannerCriteriaInvalidDate'),\n                      enabled: !disabled,\n                      onCommit: (value) async {\n                        cubit.edit('reserveFloorDate', value);\n                        return true;\n                      },\n                    ),\n                  ),",
)
text = planner.read_text()
marker = "class _CommittedPlannerDateFieldState\n    extends State<_CommittedPlannerDateField> {"
index = text.rfind(marker)
if index < 0:
    raise SystemExit("planner committed date state marker missing")
replacement = """class _CommittedPlannerDateFieldState
    extends State<_CommittedPlannerDateField> {
  @override
  Widget build(BuildContext context) => HubDateField(
        controlKey: 'planner-${widget.criterionKey}',
        canonicalValue: widget.value,
        label: widget.label,
        invalidDateText: widget.invalidDateText,
        enabled: widget.enabled,
        onCommit: widget.onCommit,
      );
}
"""
planner.write_text(text[:index] + replacement)

portfolio = Path("apps/native/lib/features/portfolio/portfolio_view.dart")
replace_once(
    portfolio,
    "import '../../models.dart';\n",
    "import '../../models.dart';\nimport '../../ui/date_field.dart';\n",
)
replace_once(
    portfolio,
    "    final date = TextEditingController(\n      text:\n          '${now.day.toString().padLeft(2, '0')}.'\n          '${now.month.toString().padLeft(2, '0')}.'\n          '${now.year}',\n    );\n    final amount = TextEditingController();",
    "    var date = hubDateToIso(now);\n    final dateKey = GlobalKey<HubDateFieldState>();\n    final amount = TextEditingController();",
)
replace_once(
    portfolio,
    "                  TextField(\n                    controller: date,\n                    decoration: InputDecoration(\n                      labelText: strings.text('portfolioPurchaseDate'),\n                      hintText: 'DD.MM.YYYY',\n                    ),\n                  ),",
    "                  HubDateField(\n                    key: dateKey,\n                    controlKey: 'portfolio-purchase-date',\n                    canonicalValue: date,\n                    label: strings.text('portfolioPurchaseDate'),\n                    invalidDateText: strings.text('portfolioInvalidInput'),\n                    onCommit: (value) async {\n                      date = value;\n                      return true;\n                    },\n                  ),",
)
replace_once(
    portfolio,
    "    final now = DateTime.now();\n    final date = TextEditingController(text: _todayDisplay(now));\n    final proceeds = TextEditingController();",
    "    final now = DateTime.now();\n    var date = hubDateToIso(now);\n    final dateKey = GlobalKey<HubDateFieldState>();\n    final proceeds = TextEditingController();",
)
replace_once(
    portfolio,
    "                    TextField(\n                      key: const ValueKey('portfolio-sale-date'),\n                      controller: date,\n                      decoration: InputDecoration(\n                        labelText: strings.text('portfolioSaleDate'),\n                        hintText: 'DD.MM.YYYY',\n                      ),\n                    ),",
    "                    HubDateField(\n                      key: dateKey,\n                      inputKey: const ValueKey('portfolio-sale-date'),\n                      controlKey: 'portfolio-sale-date',\n                      canonicalValue: date,\n                      label: strings.text('portfolioSaleDate'),\n                      invalidDateText: strings.text('portfolioInvalidInput'),\n                      onCommit: (value) async {\n                        date = value;\n                        return true;\n                      },\n                    ),",
)
replace_once(
    portfolio,
    "    final date = TextEditingController(text: _todayDisplay(DateTime.now()));\n    final amount = TextEditingController();",
    "    var date = hubDateToIso(DateTime.now());\n    final dateKey = GlobalKey<HubDateFieldState>();\n    final amount = TextEditingController();",
)
replace_once(
    portfolio,
    "                  TextField(\n                    key: const ValueKey('portfolio-coupon-date'),\n                    controller: date,\n                    decoration: InputDecoration(\n                      labelText: strings.text('portfolioCouponDate'),\n                      hintText: 'DD.MM.YYYY',\n                    ),\n                  ),",
    "                  HubDateField(\n                    key: dateKey,\n                    inputKey: const ValueKey('portfolio-coupon-date'),\n                    controlKey: 'portfolio-coupon-date',\n                    canonicalValue: date,\n                    label: strings.text('portfolioCouponDate'),\n                    invalidDateText: strings.text('portfolioInvalidInput'),\n                    onCommit: (value) async {\n                      date = value;\n                      return true;\n                    },\n                  ),",
)
replace_once(
    portfolio,
    "    final now = DateTime.now();\n    final date = TextEditingController(text: _todayDisplay(now));\n    final units = TextEditingController(text: '1');",
    "    final now = DateTime.now();\n    var date = hubDateToIso(now);\n    final dateKey = GlobalKey<HubDateFieldState>();\n    final units = TextEditingController(text: '1');",
)
replace_once(
    portfolio,
    "                    TextField(\n                      key: const ValueKey('portfolio-redemption-date'),\n                      controller: date,\n                      decoration: InputDecoration(\n                        labelText: strings.text('portfolioRedemptionDate'),\n                        hintText: 'DD.MM.YYYY',\n                      ),\n                    ),",
    "                    HubDateField(\n                      key: dateKey,\n                      inputKey: const ValueKey('portfolio-redemption-date'),\n                      controlKey: 'portfolio-redemption-date',\n                      canonicalValue: date,\n                      label: strings.text('portfolioRedemptionDate'),\n                      invalidDateText: strings.text('portfolioInvalidInput'),\n                      onCommit: (value) async {\n                        date = value;\n                        return true;\n                      },\n                    ),",
)
replace_once(
    portfolio,
    "                final parsedUnits = int.tryParse(units.text.trim());\n                final iso = _dateToIso(date.text.trim());",
    "                final dateAccepted =\n                    await dateKey.currentState?.commitPending() ?? false;\n                if (!dateAccepted) {\n                  setState(() {\n                    localError = strings.text('portfolioInvalidInput');\n                  });\n                  return;\n                }\n                final parsedUnits = int.tryParse(units.text.trim());\n                final iso = date;",
)
replace_once(
    portfolio,
    "                    parsedUnits < 1 ||\n                    iso == null ||\n                    amount.text.trim().isEmpty)",
    "                    parsedUnits < 1 ||\n                    amount.text.trim().isEmpty)",
)
replace_once(
    portfolio,
    "                  final iso = _dateToIso(date.text.trim());\n                  final allocations = <String, int>{};",
    "                  final dateAccepted =\n                      await dateKey.currentState?.commitPending() ?? false;\n                  if (!dateAccepted) {\n                    setState(() {\n                      localError = strings.text('portfolioInvalidInput');\n                    });\n                    return;\n                  }\n                  final iso = date;\n                  final allocations = <String, int>{};",
)
replace_once(
    portfolio,
    "                  if (iso == null ||\n                      proceeds.text.trim().isEmpty ||",
    "                  if (proceeds.text.trim().isEmpty ||",
)
replace_once(
    portfolio,
    "                final iso = _dateToIso(date.text.trim());\n                if (iso == null || amount.text.trim().isEmpty) {",
    "                final dateAccepted =\n                    await dateKey.currentState?.commitPending() ?? false;\n                final iso = date;\n                if (!dateAccepted || amount.text.trim().isEmpty) {",
)
replace_once(
    portfolio,
    "                  final iso = _dateToIso(date.text.trim());\n                  final parsedUnits = int.tryParse(units.text.trim());",
    "                  final dateAccepted =\n                      await dateKey.currentState?.commitPending() ?? false;\n                  final iso = date;\n                  final parsedUnits = int.tryParse(units.text.trim());",
)
replace_once(
    portfolio,
    "                  if (iso == null ||\n                      parsedUnits == null ||",
    "                  if (!dateAccepted ||\n                      parsedUnits == null ||",
)
helper = """String _todayDisplay(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.'
    '${value.year}';

String? _dateToIso(String value) {
  final match = RegExp(r'^(\\d{2})\\.(\\d{2})\\.(\\d{4})$').firstMatch(value);
  if (match == null) return null;
  final result = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
  try {
    isoDate(result);
    return result;
  } catch (_) {
    return null;
  }
}

"""
replace_once(portfolio, helper, "")

Path(".github/workflows/date-controls-autopatch.yml").unlink()
Path(__file__).unlink()
