import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_section.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_tappable_field.dart';
import 'package:lend/presentation/pages/create_listing/widgets/forms/_form_fields.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingOptionCard extends StatelessWidget {
  const CreateListingOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? colors.primary.withValues(alpha: 0.08)
                  : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? colors.primary : colors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? colors.primary : colors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LNDText.medium(text: title, textAlign: TextAlign.start),
                  const SizedBox(height: 4),
                  LNDText.regular(
                    text: description,
                    color: colors.textMuted,
                    fontSize: 12,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? colors.primary : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class CreateListingNumberStepper extends StatelessWidget {
  const CreateListingNumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minimum = 0,
    this.subtitle = '',
  });

  final String label;
  final String subtitle;
  final int value;
  final int minimum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 4.0,
        children: [
          Row(
            children: [
              Expanded(
                child: LNDText.regular(
                  text: label,
                  // color: colors.textMuted,
                  textAlign: TextAlign.start,
                ),
              ),
              _StepperButton(
                icon: Icons.remove_rounded,
                enabled: value > minimum,
                onTap: () => onChanged(value - 1),
              ),
              SizedBox(
                width: 56,
                child: Center(
                  child: LNDText.medium(text: value.toString(), fontSize: 18),
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                enabled: true,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
          if (subtitle.isNotEmpty)
            LNDText.regular(
              text: subtitle,
              fontSize: 12.0,
              color: colors.textMuted,
            ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Material(
      color:
          enabled
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: enabled ? colors.primary : colors.textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class CreateListingRadioField extends StatelessWidget {
  const CreateListingRadioField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.placeholder,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final String placeholder;
  final List<LNDRadioItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedText =
        items.firstWhereOrNull((item) => item.value == value)?.text;
    return CreateListingTappableField(
      label: label,
      value: selectedText,
      icon: icon,
      placeholder: placeholder,
      onTap: () async {
        final selected = await LNDShow.radioBottomSheet<String>(
          title: label,
          selectedValue: value,
          items: items,
        );
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class CreateListingTimeField extends StatelessWidget {
  const CreateListingTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CreateListingTappableField(
      label: label,
      value: _displayTime(context, value),
      icon: icon,
      placeholder: 'Choose time',
      onTap: () async {
        final selected = await LNDShow.timePicker(
          initialTime: _parseTime(value),
        );
        if (selected != null) onChanged(_storageTime(selected));
      },
    );
  }
}

class CreateListingDurationField extends StatelessWidget {
  const CreateListingDurationField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.placeholder = 'Choose duration',
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return CreateListingTappableField(
          label: label,
          value: _displayDuration(value.text),
          icon: icon,
          placeholder: placeholder,
          onTap: () async {
            final selected = await LNDShow.timeDuration(
              initialDuration: _parseDuration(value.text),
            );
            if (selected != null) {
              controller.text = selected.inMinutes.toString();
            }
          },
        );
      },
    );
  }
}

class CreateListingTimeRangeField extends StatelessWidget {
  const CreateListingTimeRangeField({
    super.key,
    required this.title,
    required this.description,
    required this.enabledListenable,
    required this.onEnabledChanged,
    required this.startController,
    required this.endController,
    this.startLabel = 'Start time',
    this.endLabel = 'End time',
    this.startIcon = Icons.schedule_outlined,
    this.endIcon = Icons.schedule_outlined,
  });

  final String title;
  final String description;
  final ValueNotifier<bool> enabledListenable;
  final ValueChanged<bool> onEnabledChanged;
  final TextEditingController startController;
  final TextEditingController endController;
  final String startLabel;
  final String endLabel;
  final IconData startIcon;
  final IconData endIcon;

  @override
  Widget build(BuildContext context) {
    return CreateListingSection(
      title: title,
      description: description,
      child: Column(
        children: spaced([
          ValueListenableBuilder<bool>(
            valueListenable: enabledListenable,
            builder: (context, enabled, _) {
              return SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: LNDText.medium(
                  text: 'Enable ${title.toLowerCase()}',
                  overflow: TextOverflow.visible,
                ),
                subtitle: LNDText.regular(
                  text:
                      enabled
                          ? 'Start and end times are required.'
                          : 'Mark this as not applicable for this listing.',
                  fontSize: 12,
                  color: context.lndTheme.textMuted,
                  overflow: TextOverflow.visible,
                ),
                value: enabled,
                onChanged: (value) {
                  onEnabledChanged(value);
                  if (!value) {
                    startController.clear();
                    endController.clear();
                  }
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: enabledListenable,
            builder: (context, enabled, _) {
              if (!enabled) return const SizedBox.shrink();

              return Column(
                children: spaced([
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: startController,
                    builder: (context, value, _) {
                      return CreateListingTimeField(
                        label: startLabel,
                        value: value.text,
                        icon: startIcon,
                        onChanged: (next) => startController.text = next,
                      );
                    },
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: endController,
                    builder: (context, value, _) {
                      return CreateListingTimeField(
                        label: endLabel,
                        value: value.text,
                        icon: endIcon,
                        onChanged: (next) => endController.text = next,
                      );
                    },
                  ),
                ]),
              );
            },
          ),
        ]),
      ),
    );
  }
}

Widget createListingListEditor({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required List<String> values,
  required ValueChanged<List<String>> onChanged,
  String? hintText = 'Add item',
}) {
  return formChipEditor(
    context: context,
    label: label,
    controller: controller,
    values: values,
    onChanged: onChanged,
    hintText: hintText,
  );
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
}

String _storageTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String _displayTime(BuildContext context, String value) {
  return _parseTime(value).format(context);
}

Duration _parseDuration(String value) {
  final minutes = int.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  return Duration(minutes: minutes.clamp(0, 24 * 60));
}

String? _displayDuration(String value) {
  if (value.trim().isEmpty) return null;

  final duration = _parseDuration(value);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) return '$minutes min';
  if (minutes == 0) return hours == 1 ? '1 hr' : '$hours hrs';

  final hourText = hours == 1 ? '1 hr' : '$hours hrs';
  return '$hourText $minutes min';
}
