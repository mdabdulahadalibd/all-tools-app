import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tool_categories.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/models/tool_model.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../tools/tool_screen_dispatcher.dart';

class ToolCard extends ConsumerWidget {
  final ToolModel tool;

  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final category = ToolCategories.getCategoryById(tool.categoryId);
    final isFav = ref.watch(favoritesProvider).contains(tool.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: category.color.withValues(alpha: 0.15),
          radius: 22,
          child: Icon(tool.icon, color: category.color, size: 22),
        ),
        title: Text(
          tool.getTitle(lang),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          tool.getDescription(lang),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFav ? Icons.star : Icons.star_border,
            color: isFav ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(tool.id);
          },
        ),
        onTap: () {
          ToolScreenDispatcher.openTool(context, ref, tool.id);
        },
      ),
    );
  }
}
