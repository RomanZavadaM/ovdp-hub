import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import '../portfolio/portfolio_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'editor_cubit.dart';

class CollectionEditorView extends StatelessWidget {
  const CollectionEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollectionEditorCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final cubit = context.read<CollectionEditorCubit>();
    final portfolio = context.watch<PortfolioCubit>().state;
    final busy = state.busy || state.locked || context.watch<WorkspaceCubit>().state.busy || portfolio.busy;
    final annotationsEnabled = !busy && state.privateDraft && portfolio.unlocked;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              '${strings.text('editorTitle')} · ${state.selected.length}',
            ),
            ErrorNotice(state.error, cubit.dismissError),
            SwitchListTile(
              key: const ValueKey('collection-private-mode'),
              title: Text(strings.text('privateCollectionMode')),
              subtitle: Text(strings.text(state.privateDraft ? 'privateCollectionInfo' : 'publicCollectionInfo')),
              value: state.privateDraft,
              onChanged: busy ? null : cubit.selectPrivate,
            ),
            if (state.privateDraft && !portfolio.unlocked)
              Text(strings.text('collectionUnlockRequired')),
            Wrap(
              spacing: 8,
              children: state.selected.values
                  .map(
                    (b) => InputChip(
                      label: Text('${b.isin} · ${b.currency}'),
                      onDeleted: busy ? null : () => cubit.toggle(b, false),
                    ),
                  )
                  .toList(),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('ISIN')),
                  DataColumn(label: Text(strings.text('currency'))),
                  DataColumn(label: Text(strings.text('rate'))),
                  DataColumn(label: Text(strings.text('maturityColumn'))),
                ],
                rows: state.selected.values
                    .map(
                      (b) => DataRow(
                        cells: [
                          DataCell(Text(b.isin)),
                          DataCell(Text(b.currency)),
                          DataCell(Text('${b.rate}%')),
                          DataCell(Text(b.maturity)),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('name-${state.revision}'),
              initialValue: state.name,
              enabled: annotationsEnabled,
              decoration: InputDecoration(
                labelText: strings.text('collectionName'),
              ),
              onChanged: (v) => cubit.edit(name: v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('note-${state.revision}'),
              initialValue: state.note,
              enabled: annotationsEnabled,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: strings.text('notesAssumptions'),
              ),
              onChanged: (v) => cubit.edit(note: v),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final navigation = context.read<NavigationCubit>();
                      if (await cubit.save() && context.mounted) {
                        navigation.select(1);
                      }
                    },
              icon: const Icon(Icons.save_outlined),
              label: Text(strings.text(state.privateDraft ? 'savePrivateCollection' : 'savePublicCollection')),
            ),
          ],
        ),
      ),
    );
  }
}
