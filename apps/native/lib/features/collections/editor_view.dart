import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'editor_cubit.dart';

class CollectionEditorView extends StatelessWidget {
  const CollectionEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollectionEditorCubit>().state;
    final cubit = context.read<CollectionEditorCubit>();
    final busy = state.busy || context.watch<WorkspaceCubit>().state.busy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading('Добірка для роздумів · ${state.selected.length}'),
            ErrorNotice(state.error, cubit.dismissError),
            const Text(
              'Це власний сценарій, а не рекомендація або заявка на купівлю.',
            ),
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
                columns: const [
                  DataColumn(label: Text('ISIN')),
                  DataColumn(label: Text('Валюта')),
                  DataColumn(label: Text('Ставка')),
                  DataColumn(label: Text('Погашення')),
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
              enabled: !busy,
              decoration: const InputDecoration(labelText: 'Назва добірки'),
              onChanged: (v) => cubit.edit(name: v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('note-${state.revision}'),
              initialValue: state.note,
              enabled: !busy,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Нотатки та припущення',
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
              label: const Text('Зберегти в робочій папці'),
            ),
          ],
        ),
      ),
    );
  }
}
