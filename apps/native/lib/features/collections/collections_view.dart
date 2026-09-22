import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/hub_locale.dart';
import '../../ui/components.dart';
import '../navigation/navigation_cubit.dart';
import '../planner/planner_cubit.dart';
import '../sellers/sellers_cubit.dart';
import '../workspace/workspace_cubit.dart';
import 'collections_cubit.dart';
import 'editor_cubit.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollectionsCubit>().state;
    final strings = HubStrings(context.watch<LocaleCubit>().state.language);
    final cubit = context.read<CollectionsCubit>();
    final editor = context.watch<CollectionEditorCubit>();
    final workspace = context.watch<WorkspaceCubit>().state;
    final busy = state.busy || editor.state.busy || workspace.busy;
    final seller = context.watch<SellersCubit>().state.snapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(strings.text('collectionsTitle')),
        ErrorNotice(state.error, cubit.dismissError),
        Text(strings.text('collectionImmutableInfo')),
        OutlinedButton(
          onPressed: busy || workspace.path == null ? null : cubit.reload,
          child: Text(strings.text('reloadFolder')),
        ),
        if (state.sets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(strings.text('noCollections')),
          ),
        ...state.sets.map(
          (s) => Card(
            child: ExpansionTile(
              title: Text(s.name),
              subtitle: Text(
                '${s.bonds.length} ${strings.text('issuesWord')} · ${s.savedAt}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    s.note.isEmpty ? strings.text('noNotes') : s.note,
                  ),
                ),
                ...s.bonds.map(
                  (b) => ListTile(
                    title: Text(b.isin),
                    subtitle: Text(
                      '${b.currency} · ${b.rate}% · ${b.maturity}',
                    ),
                    onTap: () => showBondDetails(
                      context,
                      b,
                      seller: seller,
                    ),
                  ),
                ),
                if (s.scenario != null)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final planner = context.read<PlannerCubit>();
                            final navigation = context.read<NavigationCubit>();
                            if (planner.state.dirty &&
                                !await confirmDiscard(context)) {
                              return;
                            }
                            if (!context.mounted) return;
                            planner.load(s);
                            navigation.select(4);
                          },
                    child: Text(strings.text('openPlan')),
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
                    child: Text(strings.text('newVariant')),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
