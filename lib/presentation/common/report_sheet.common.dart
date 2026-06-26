import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum LNDReportType {
  user('User'),
  listing('Listing'),
  message('Message'),
  other('Other concerns');

  final String label;
  const LNDReportType(this.label);
}

class LNDReportSubmission {
  const LNDReportSubmission({
    required this.type,
    required this.reason,
    required this.details,
    required this.archiveRequested,
  });

  final LNDReportType type;
  final String reason;
  final String details;
  final bool archiveRequested;
}

class LNDReportSheet extends StatefulWidget {
  const LNDReportSheet({
    required this.types,
    required this.showArchiveAction,
    this.description = 'Reporting this will automatically cancel the booking.',
    this.showTypeSelector = true,
    this.title = 'Report',
    super.key,
  });

  final List<LNDReportType> types;
  final String? description;
  final bool showArchiveAction;
  final bool showTypeSelector;
  final String title;

  @override
  State<LNDReportSheet> createState() => _LNDReportSheetState();
}

class _LNDReportSheetState extends State<LNDReportSheet> {
  late LNDReportType _type = widget.types.first;
  late String _reason = _reasons[_type]!.first;

  static const Map<LNDReportType, List<String>> _reasons = {
    LNDReportType.user: [
      'Harassment or bullying',
      'Threats or safety concern',
      'Hate or discrimination',
      'Impersonation',
      'Scam, fraud, or spam',
      'Inappropriate sexual behavior',
      'Other',
    ],
    LNDReportType.listing: [
      'Misleading details or photos',
      'Inappropriate content or photos',
      'Item does not exist or is unavailable',
      'Scam or phishing',
      'Unsafe or prohibited item',
      'Other',
    ],
    LNDReportType.message: [
      'Harassment or unwanted contact',
      'Threats',
      'Hate or discrimination',
      'Sexual or inappropriate content',
      'Scam, spam, or phishing',
      'Restricted goods or services',
      'Other',
    ],
    LNDReportType.other: [
      'Payment concern',
      'Privacy concern',
      'Safety concern',
      'Technical issue',
      'Other',
    ],
  };

  void _selectType(LNDReportType type) {
    setState(() {
      _type = type;
      _reason = _reasons[type]!.first;
    });
  }

  void _submit({required bool archiveRequested}) {
    Get.back(
      result: LNDReportSubmission(
        type: _type,
        reason: _reason,
        details: '',
        archiveRequested: archiveRequested,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final reasons = _reasons[_type]!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LNDText.bold(text: widget.title, fontSize: 18.0),
              if (widget.description != null) ...[
                const SizedBox(height: 16.0),
                LNDText.regular(
                  text: widget.description!,
                  fontStyle: FontStyle.italic,
                  color: context.lndTheme.textSecondary,
                  fontSize: 12.0,
                  overflow: TextOverflow.visible,
                ),
              ],
              if (widget.showTypeSelector) ...[
                const SizedBox(height: 16.0),
                LNDText.semibold(
                  text: 'What are you reporting?',
                  fontSize: 14.0,
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      widget.types
                          .map(
                            (type) => ChoiceChip(
                              showCheckmark: false,
                              label: LNDText.regular(text: type.label),
                              selected: _type == type,
                              onSelected: (_) => _selectType(type),
                            ),
                          )
                          .toList(),
                ),
              ],
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
              const SizedBox(height: 20.0),
              LNDButton.primary(
                text: 'Report',
                enabled: true,
                onPressed: () => _submit(archiveRequested: false),
              ),
              if (widget.showArchiveAction) ...[
                const SizedBox(height: 8.0),
                LNDButton.secondary(
                  text: 'Report and archive',
                  enabled: true,
                  onPressed: () => _submit(archiveRequested: true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
