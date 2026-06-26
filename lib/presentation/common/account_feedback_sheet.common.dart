import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/textfields.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum LNDAccountFeedbackAction {
  deactivate('deactivate', 'Deactivate Account'),
  delete('delete', 'Delete Account');

  final String value;
  final String title;
  const LNDAccountFeedbackAction(this.value, this.title);
}

class LNDAccountFeedbackSubmission {
  const LNDAccountFeedbackSubmission({
    required this.action,
    required this.reason,
    required this.feedback,
  });

  final LNDAccountFeedbackAction action;
  final String reason;
  final String feedback;

  Map<String, dynamic> toMap() {
    return {
      'action': action.value,
      'reason': reason,
      if (feedback.trim().isNotEmpty) 'feedback': feedback.trim(),
    };
  }
}

class LNDAccountFeedbackSheet extends StatefulWidget {
  const LNDAccountFeedbackSheet({required this.action, super.key});

  final LNDAccountFeedbackAction action;

  @override
  State<LNDAccountFeedbackSheet> createState() =>
      _LNDAccountFeedbackSheetState();
}

class _LNDAccountFeedbackSheetState extends State<LNDAccountFeedbackSheet> {
  late String _reason = _reasons[widget.action]!.first;
  final TextEditingController _feedbackController = TextEditingController();

  static const Map<LNDAccountFeedbackAction, List<String>> _reasons = {
    LNDAccountFeedbackAction.deactivate: [
      'Taking a break',
      'Not renting or listing right now',
      'Too many notifications or messages',
      'Privacy or safety concern',
      'App issue or bug',
      'Other',
    ],
    LNDAccountFeedbackAction.delete: [
      'No longer need Lend',
      'Found another service',
      'Privacy or data concern',
      'Bad rental or listing experience',
      'App issue or bug',
      'Other',
    ],
  };

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    Get.back(
      result: LNDAccountFeedbackSubmission(
        action: widget.action,
        reason: _reason,
        feedback: _feedbackController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final reasons = _reasons[widget.action]!;
    final isDelete = widget.action == LNDAccountFeedbackAction.delete;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.0,
          12.0,
          16.0,
          16.0 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LNDText.bold(text: widget.action.title, fontSize: 18.0),
              const SizedBox(height: 16.0),
              LNDText.semibold(text: 'Reason', fontSize: 14.0),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children:
                      reasons
                          .map(
                            (reason) => InkWell(
                              onTap: () => setState(() => _reason = reason),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _reason == reason
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color:
                                          _reason == reason
                                              ? colors.primary
                                              : colors.textMuted,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: LNDText.regular(text: reason),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              if (isDelete) ...[
                const SizedBox(height: 16.0),
                LNDText.semibold(text: 'Feedback (optional)', fontSize: 14.0),
                const SizedBox(height: 8.0),
                LNDTextField.textBox(
                  controller: _feedbackController,
                  hintText: 'Share feedback without personal details',
                  borderRadius: 8.0,
                  maxLength: 1000,
                  maxLines: 4,
                ),
              ],
              const SizedBox(height: 20.0),
              LNDButton.primary(
                text: 'Continue',
                enabled: true,
                onPressed: _submit,
                color: isDelete ? colors.danger : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
