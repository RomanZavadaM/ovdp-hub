import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../collections/editor_cubit.dart';
import 'workspace_cubit.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({super.key});

  Future<void> choose(BuildContext context, {bool copy = false}) async {
    final cubit = context.read<WorkspaceCubit>();
    final discard = cubit.needsDraftDecision
        ? await confirmDiscard(context)
        : false;
    if (!context.mounted || (cubit.needsDraftDecision && !discard)) return;
    await cubit.choose(copy: copy, discardDraft: discard);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WorkspaceCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final busy =
        state.busy || context.watch<CollectionEditorCubit>().state.busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('workspaceTitle')),
        SelectableText(state.path ?? strings.text('folderNotOpen')),
        const SizedBox(height: 16),
        Text(strings.text('workspaceIntro')),
        const SizedBox(height: 16),
        if (state.externalFolders) ...[
          Text(strings.text('externalFoldersInfo')),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: busy ? null : () => choose(context),
                icon: const Icon(Icons.folder_open),
                label: Text(strings.text('openCreateWorkspace')),
              ),
              OutlinedButton(
                onPressed: busy || state.path == null
                    ? null
                    : () => choose(context, copy: true),
                child: Text(strings.text('copyAndSwitch')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(strings.text('copyRequiresEmpty')),
        ] else
          Text(strings.text('phonePrivateFolder')),
        const SizedBox(height: 20),
        Text(strings.text('workspaceFailureInfo')),
        OutlinedButton(
          onPressed: busy ? null : context.read<WorkspaceCubit>().initialize,
          child: Text(strings.text('reopenCurrent')),
        ),
      ],
    );
  }
}
