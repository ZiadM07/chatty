import 'package:Chatty/core/constants/exports.dart';
import 'package:Chatty/features/shared/widgets/app_gradient_button.dart';

class AddStoryCaptionSheet extends StatelessWidget {
  final String? initialCaption;
  final ValueChanged<String?> onSave;

  const AddStoryCaptionSheet({
    super.key,
    this.initialCaption,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialCaption,
    required ValueChanged<String?> onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          AddStoryCaptionSheet(initialCaption: initialCaption, onSave: onSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialCaption);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: context.locale.addCaption,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: context.locale.done,
              onTap: () {
                final text = controller.text.trim();
                onSave(text.isEmpty ? null : text);
                Navigator.pop(context);
              },
              type: AppButtonType.gradient,
            ),
          ),
        ],
      ),
    );
  }
}
