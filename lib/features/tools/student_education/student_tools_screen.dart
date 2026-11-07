export 'student_provider/student_tools_provider.dart';
export 'student_screen/certificate_maker_screen.dart';
export 'student_screen/class_routine_maker_screen.dart';
export 'student_screen/leave_application_generator_screen.dart';
export 'student_screen/notice_circular_generator_screen.dart';
export 'student_screen/pomodoro_timer_screen.dart';
export 'student_screen/question_paper_generator_screen.dart';
export 'student_screen/student_gpa_screen.dart';
export 'student_screen/student_id_card_maker_screen.dart';
export 'student_screen/word_counter_screen.dart';
export 'student_utils/student_models.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tool_categories.dart';
import '../../../core/localization/localization_provider.dart';
import '../../common/widgets/responsive_container.dart';
import '../../common/widgets/tool_card.dart';
import 'student_utils/student_models.dart';

class StudentToolsScreen extends ConsumerWidget {
  const StudentToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final lang = ref.watch(languageProvider);
    final studentCategory = ToolCategories.getCategoryById('student_education');
    final studentTools = ToolCategories.getToolsForCategory('student_education');

    return Scaffold(
      appBar: AppBar(
        title: Text(studentCategory.getName(lang)),
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            studentHero(
              studentCategory.getName(lang),
              studentCategory.getDescription(lang),
              studentCategory.color,
              studentCategory.icon,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langNotifier.translate('all_tools'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${studentTools.length} Tools',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...studentTools.map((tool) => ToolCard(tool: tool)),
          ],
        ),
      ),
    );
  }
}
