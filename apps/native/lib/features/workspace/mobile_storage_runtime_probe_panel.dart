import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../platform/mobile_external_storage.dart';
import '../../platform/mobile_storage_runtime_probe.dart';
import 'mobile_storage_runtime_probe_strings.dart';

class MobileStorageRuntimeProbePanel extends StatefulWidget {
  const MobileStorageRuntimeProbePanel({super.key});

  @override
  State<MobileStorageRuntimeProbePanel> createState() =>
      _MobileStorageRuntimeProbePanelState();
}

class _MobileStorageRuntimeProbePanelState
    extends State<MobileStorageRuntimeProbePanel> {
  late final bool _supported;
  MobileStorageRuntimeProbe? _probe;
  MobileStorageRuntimeProbeSnapshot _snapshot =
      const MobileStorageRuntimeProbeSnapshot(
        MobileStorageRuntimeProbePhase.idle,
      );
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _supported = const MethodChannelMobileExternalStorage().supported;
    if (_supported) {
      unawaited(_load());
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    try {
      final probe = await MobileStorageRuntimeProbe.platform();
      final snapshot = await probe.load();
      if (!mounted) return;
      setState(() {
        _probe = probe;
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _snapshot = const MobileStorageRuntimeProbeSnapshot(
          MobileStorageRuntimeProbePhase.failed,
          errorCode: 'workspace.runtime_probe_failed',
        );
        _loading = false;
      });
    }
  }

  Future<void> _run(
    Future<MobileStorageRuntimeProbeSnapshot> Function(
      MobileStorageRuntimeProbe probe,
    ) action,
  ) async {
    final probe = _probe;
    if (probe == null || _busy) return;
    setState(() => _busy = true);
    final snapshot = await action(probe);
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return const SizedBox.shrink();

    final language = context.watch<LocaleCubit>().state.language;
    final strings = MobileStorageRuntimeProbeStrings(language);
    final theme = Theme.of(context);
    final phase = _snapshot.phase;
    final folderLabel = _snapshot.folderLabel;
    final errorCode = _snapshot.errorCode;

    final status = switch (phase) {
      MobileStorageRuntimeProbePhase.idle => strings.idle,
      MobileStorageRuntimeProbePhase.restartRequired =>
        strings.restartRequired,
      MobileStorageRuntimeProbePhase.readyAfterRestart =>
        strings.readyAfterRestart,
      MobileStorageRuntimeProbePhase.passed => strings.passed,
      MobileStorageRuntimeProbePhase.permissionLost => strings.permissionLost,
      MobileStorageRuntimeProbePhase.failed => strings.failed,
    };

    final icon = switch (phase) {
      MobileStorageRuntimeProbePhase.passed => Icons.verified_outlined,
      MobileStorageRuntimeProbePhase.permissionLost => Icons.lock_outline,
      MobileStorageRuntimeProbePhase.failed => Icons.error_outline,
      MobileStorageRuntimeProbePhase.restartRequired => Icons.restart_alt,
      MobileStorageRuntimeProbePhase.readyAfterRestart =>
        Icons.play_circle_outline,
      MobileStorageRuntimeProbePhase.idle => Icons.mobile_friendly_outlined,
    };

    return Card(
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(strings.intro),
            const SizedBox(height: 12),
            if (_loading || _busy)
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(strings.testing),
                ],
              )
            else ...[
              Text(status),
              if (folderLabel != null) ...[
                const SizedBox(height: 8),
                SelectableText(strings.folder(folderLabel)),
              ],
              if (errorCode != null) ...[
                const SizedBox(height: 8),
                SelectableText(strings.error(errorCode)),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (phase == MobileStorageRuntimeProbePhase.idle ||
                      phase == MobileStorageRuntimeProbePhase.failed ||
                      phase == MobileStorageRuntimeProbePhase.passed)
                    FilledButton.icon(
                      onPressed: () => _run((probe) => probe.begin()),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(strings.start),
                    ),
                  if (phase ==
                      MobileStorageRuntimeProbePhase.readyAfterRestart)
                    FilledButton.icon(
                      onPressed: () => _run((probe) => probe.complete()),
                      icon: const Icon(Icons.verified),
                      label: Text(strings.continueTest),
                    ),
                  if (phase ==
                          MobileStorageRuntimeProbePhase.restartRequired ||
                      phase == MobileStorageRuntimeProbePhase.readyAfterRestart ||
                      phase == MobileStorageRuntimeProbePhase.permissionLost ||
                      phase == MobileStorageRuntimeProbePhase.failed)
                    OutlinedButton.icon(
                      onPressed: () => _run((probe) => probe.reset()),
                      icon: const Icon(Icons.refresh),
                      label: Text(strings.reset),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
