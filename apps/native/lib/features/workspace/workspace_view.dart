import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final busy =
        state.busy || context.watch<CollectionEditorCubit>().state.busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading('Робоча папка'),
        SelectableText(state.path ?? 'Папка ще не відкрита'),
        const SizedBox(height: 16),
        const Text(
          'Тут зберігаються каталоги, добірки та нотатки. Дані не передаються на сервер ОВДП Hub.',
        ),
        const SizedBox(height: 16),
        if (state.externalFolders) ...[
          const Text(
            'Можна вибрати локальну папку, підключений мережевий диск або папку OneDrive / iCloud / Dropbox. Синхронізацію виконує ваш провайдер. JSON не зашифрований; не додавайте сюди ключі або документи.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: busy ? null : () => choose(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Відкрити / створити робочу папку'),
              ),
              OutlinedButton(
                onPressed: busy || state.path == null
                    ? null
                    : () => choose(context, copy: true),
                child: const Text('Копіювати дані й перейти'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Копіювання потребує порожньої папки. Оригінал зберігається, а перемикання відбувається після перевірки копії.',
          ),
        ] else
          const Text(
            'На телефоні використовується приватна папка застосунку. Зовнішні та хмарні папки ще потребують інтеграції з файловим провайдером ОС.',
          ),
        const SizedBox(height: 20),
        const Text(
          'При втраті доступу запис завершиться помилкою, чернетка залишиться. Зміни з іншого пристрою видно після перечитування папки; автоматичного злиття немає.',
        ),
        OutlinedButton(
          onPressed: busy ? null : context.read<WorkspaceCubit>().initialize,
          child: const Text('Повторно відкрити поточну папку'),
        ),
      ],
    );
  }
}
