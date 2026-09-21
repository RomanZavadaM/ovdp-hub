import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'collections_cubit.dart';
import 'editor_cubit.dart';
import '../planner/planner_cubit.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollectionsCubit>().state;
    final cubit = context.read<CollectionsCubit>();
    final editor = context.watch<CollectionEditorCubit>();
    final workspace = context.watch<WorkspaceCubit>().state;
    final busy = state.busy || editor.state.busy || workspace.busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Збережені добірки'),
        ErrorNotice(state.error, cubit.dismissError),
        const Text(
          'Добірка містить копію випусків на момент збереження. Оновлення каталогу її не змінює.',
        ),
        OutlinedButton(
          onPressed: busy || workspace.path == null ? null : cubit.reload,
          child: const Text('Перечитати папку'),
        ),
        if (state.sets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Поки немає добірок. Позначте випуски в каталозі та збережіть свій сценарій.',
            ),
          ),
        ...state.sets.map(
          (s) => Card(
            child: ExpansionTile(
              title: Text(s.name),
              subtitle: Text('${s.bonds.length} випусків · ${s.savedAt}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(s.note.isEmpty ? 'Без нотаток' : s.note),
                ),
                ...s.bonds.map(
                  (b) => ListTile(
                    title: Text(b.isin),
                    subtitle: Text(
                      '${b.currency} · ${b.rate}% · ${b.maturity}',
                    ),
                    onTap: () => showBondDetails(context, b),
                  ),
                ),
                if (s.scenario != null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final planner = context.read<PlannerCubit>(),
                                navigation = context.read<NavigationCubit>();
                            if (planner.state.dirty &&
                                !await confirmDiscard(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            planner.load(s);
                            navigation.select(4);
                          },
                    child: const Text('Відкрити план і календар коштів'),
                  ),
                if (s.scenario == null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final navigation = context.read<NavigationCubit>();
                            if (editor.state.dirty &&
                                !await confirmDiscard(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            editor.variant(s);
                            navigation.select(0);
                          },
                    child: const Text('Створити новий варіант'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
