import 'package:flutter/material.dart';

/// Formats a persisted ISO calendar date using the active Material locale.
///
/// Persistence stays `YYYY-MM-DD`; only the user-facing representation changes.
String formatHubDate(BuildContext context, String isoValue) {
  final parsed = parseHubIsoDate(isoValue);
  if (parsed == null) return isoValue;
  return MaterialLocalizations.of(context).formatCompactDate(parsed);
}

/// Strict parser for the canonical persisted `YYYY-MM-DD` representation.
DateTime? parseHubIsoDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}

String hubDateToIso(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

/// Accepts the active locale's compact date format and canonical ISO as a
/// keyboard/paste fallback. Returns only canonical ISO.
String? parseHubDateInput(BuildContext context, String input) {
  final clean = input.trim();
  final iso = parseHubIsoDate(clean);
  if (iso != null) return hubDateToIso(iso);
  final localized = MaterialLocalizations.of(context).parseCompactDate(clean);
  if (localized == null) return null;
  return hubDateToIso(localized);
}

/// Removes the obsolete hard-coded `YYYY-MM-DD`-style suffix from legacy
/// translated labels. The field itself now shows the active locale's format.
String hubDateLabel(String value) => value.replaceFirst(
      RegExp(r'\s[A-Z]{4}-[A-Z]{2}-[A-Z]{2}$'),
      '',
    );

typedef HubDateCommit = Future<bool> Function(String canonicalIsoDate);

class HubDateField extends StatefulWidget {
  final String controlKey;
  final String canonicalValue;
  final String label;
  final String invalidDateText;
  final bool enabled;
  final HubDateCommit onCommit;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const HubDateField({
    super.key,
    required this.controlKey,
    required this.canonicalValue,
    required this.label,
    required this.invalidDateText,
    required this.onCommit,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<HubDateField> createState() => HubDateFieldState();
}

class HubDateFieldState extends State<HubDateField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _committedValue;
  String? _errorText;
  bool _committing = false;
  bool _suppressBlurCommit = false;
  Locale? _displayLocale;

  @override
  void initState() {
    super.initState();
    _committedValue = widget.canonicalValue;
    _controller = TextEditingController(text: widget.canonicalValue);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (!_focusNode.hasFocus && _displayLocale != locale) {
      _displayLocale = locale;
      _showCommittedValue();
    }
  }

  @override
  void didUpdateWidget(covariant HubDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.canonicalValue != oldWidget.canonicalValue) {
      _committedValue = widget.canonicalValue;
      if (!_focusNode.hasFocus) _showCommittedValue();
    }
  }

  void _showCommittedValue() {
    if (!mounted) return;
    final formatted = formatHubDate(context, _committedValue);
    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_suppressBlurCommit) {
      commitPending();
    }
  }

  Future<bool> commitPending() async {
    if (_committing || !widget.enabled) return !_committing;
    final value = parseHubDateInput(context, _controller.text);
    if (value == null) {
      if (mounted) setState(() => _errorText = widget.invalidDateText);
      return false;
    }
    if (value == _committedValue) {
      if (mounted) {
        setState(() => _errorText = null);
        _showCommittedValue();
      }
      return true;
    }

    setState(() {
      _committing = true;
      _errorText = null;
    });
    final accepted = await widget.onCommit(value);
    if (!mounted) return accepted;
    if (accepted) {
      _committedValue = value;
    }
    setState(() => _committing = false);
    _showCommittedValue();
    return accepted;
  }

  DateTime _clamp(DateTime value, DateTime first, DateTime last) {
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }

  Future<void> _pickDate() async {
    if (!widget.enabled || _committing) return;
    final first = widget.firstDate ?? DateTime(1900, 1, 1);
    final last = widget.lastDate ?? DateTime(2200, 12, 31);
    final canonical = parseHubIsoDate(_committedValue) ?? DateTime.now();

    _suppressBlurCommit = true;
    _focusNode.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clamp(canonical, first, last),
      firstDate: first,
      lastDate: last,
    );
    _suppressBlurCommit = false;
    if (picked == null || !mounted) return;

    final value = hubDateToIso(picked);
    setState(() {
      _committing = true;
      _errorText = null;
    });
    final accepted = await widget.onCommit(value);
    if (!mounted) return;
    if (accepted) _committedValue = value;
    setState(() => _committing = false);
    _showCommittedValue();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final sample = localizations.formatCompactDate(DateTime(2026, 9, 26));
    return TextFormField(
      key: ValueKey('${widget.controlKey}-input'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled && !_committing,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: hubDateLabel(widget.label),
        hintText: sample,
        errorText: _errorText,
        suffixIcon: IconButton(
          key: ValueKey('${widget.controlKey}-picker'),
          tooltip: hubDateLabel(widget.label),
          onPressed: widget.enabled && !_committing ? _pickDate : null,
          icon: const Icon(Icons.calendar_month_outlined),
        ),
      ),
      onChanged: (_) {
        if (_errorText != null) setState(() => _errorText = null);
      },
      onFieldSubmitted: (_) => commitPending(),
    );
  }
}
