import 'dart:io';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';
import 'package:lend/utilities/helpers/legal_links.helper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_down_button/pull_down_button.dart';

class LNDMenuItem<T> {
  final String label;
  final T value;
  final IconData icon;
  final void Function(T value) onTap;
  final bool isDestructive;

  LNDMenuItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

class LNDRadioItem<T> {
  final String text;
  final T value;
  final VoidCallback? onTap;

  LNDRadioItem({required this.text, required this.value, this.onTap});
}

class LNDShow {
  LNDShow._();

  static Widget tooltip({
    required String message,
    required Widget child,
    TooltipTriggerMode triggerMode = TooltipTriggerMode.tap,
    bool preferBelow = false,
    Duration showDuration = const Duration(seconds: 4),
  }) {
    return Builder(
      builder: (context) {
        final colors = context.lndTheme;
        return Tooltip(
          message: message,
          triggerMode: triggerMode,
          preferBelow: preferBelow,
          showDuration: showDuration,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.textPrimary.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: LNDText.regularStyle.copyWith(
            color: colors.textInverse,
            fontSize: 12,
            overflow: TextOverflow.visible,
          ),
          child: child,
        );
      },
    );
  }

  static Future<T?> bottomSheet<T>(
    Widget content, {
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final colors = Get.context!.lndTheme;
    return showBarModalBottomSheet(
      context: Get.context!,
      expand: expand,
      builder: (_) => content,
      backgroundColor: colors.surface,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> bottomSheetInfo<T>(
    List<LNDText> content, {
    required String title,
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
    bool isMoreInfoVisible = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final colors = Get.context!.lndTheme;
    return showBarModalBottomSheet(
      context: Get.context!,
      expand: expand,
      builder:
          (_) => Padding(
            padding:
                hasPadding
                    ? const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    )
                    : EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LNDText.bold(text: title, fontSize: 18.0),
                const SizedBox(height: 8.0),
                ...content,
                const SizedBox(height: 16.0),
                if (isMoreInfoVisible)
                  Wrap(
                    children: [
                      LNDText.regular(
                        text: 'For more information, read our ',
                        overflow: TextOverflow.visible,
                        fontSize: 12.0,
                      ),
                      LNDText.semibold(
                        text: 'Terms and Conditions',
                        color: colors.primary,
                        overflow: TextOverflow.visible,
                        fontSize: 12.0,
                        textDecoration: TextDecoration.underline,
                        onTap: LNDLegalLinks.openTermsAndConditions,
                      ),
                      LNDText.regular(
                        text: ' or ',
                        overflow: TextOverflow.visible,
                        fontSize: 12.0,
                      ),
                      LNDText.semibold(
                        text: 'Privacy Policy',
                        color: colors.primary,
                        overflow: TextOverflow.visible,
                        fontSize: 12.0,
                        textDecoration: TextDecoration.underline,
                        onTap: LNDLegalLinks.openPrivacyPolicy,
                      ),
                    ],
                  ),
              ],
            ).withSpacing(8.0),
          ),
      backgroundColor: colors.surface,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> menuBottomSheetVertical<T>({
    required List<LNDMenuItem<T>> items,
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final colors = Get.context!.lndTheme;
    return showBarModalBottomSheet(
      context: Get.context!,
      expand: expand,
      builder:
          (_) => SafeArea(
            child: Container(
              color: colors.surface,
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: crossAxisAlignment,
                  children:
                      items
                          .map(
                            (i) => ListTile(
                              dense: true,
                              onTap: () {
                                i.onTap(i.value);
                                Get.back(result: i.value);
                              },
                              leading: Icon(
                                i.icon,
                                color:
                                    i.isDestructive
                                        ? colors.danger
                                        : colors.textPrimary,
                              ),
                              title: LNDText.regular(
                                text: i.label,
                                color:
                                    i.isDestructive
                                        ? colors.danger
                                        : colors.textPrimary,
                              ),
                            ),
                          )
                          .toList(),
                ).paddingSymmetric(vertical: 8.0),
              ),
            ),
          ),
      backgroundColor: colors.surface,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> menuBottomSheetHorizontal<T>({
    required List<LNDMenuItem<T>> items,
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
  }) {
    final colors = Get.context!.lndTheme;
    return showBarModalBottomSheet(
      context: Get.context!,
      expand: expand,
      builder:
          (_) => SafeArea(
            child: Container(
              color: colors.surface,
              child: SizedBox(
                height: height,
                child: SingleChildScrollView(
                  padding:
                      hasPadding ? const EdgeInsets.all(16) : EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        items
                            .map(
                              (i) => _LNDHorizontalMenuItem<T>(
                                item: i,
                                onTap: () {
                                  i.onTap(i.value);
                                  Get.back(result: i.value);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ),
      backgroundColor: colors.surface,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> radioBottomSheet<T>({
    required String title,
    required List<LNDRadioItem<T>> items,
    T? selectedValue,
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final context = Get.context!;
    final colors = context.lndTheme;

    return showBarModalBottomSheet<T>(
      context: context,
      expand: expand,
      backgroundColor: colors.surface,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      builder: (sheetContext) {
        T? currentValue = selectedValue;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget content = Container(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: LNDText.bold(text: title, fontSize: 16.0),
                  ),

                  ...items.map((item) {
                    final isSelected = item.value == currentValue;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setSheetState(() {
                          currentValue = item.value;
                        });

                        item.onTap?.call();

                        Navigator.of(sheetContext).pop(item.value);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color:
                                  isSelected
                                      ? colors.primary
                                      : colors.textMuted,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(child: LNDText.regular(text: item.text)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ).paddingSymmetric(vertical: 8.0),
            );

            if (height != null) {
              content = SizedBox(height: height, child: content);
            }

            return SafeArea(
              child: Container(
                color: colors.surface,
                padding:
                    hasPadding ? const EdgeInsets.all(16) : EdgeInsets.zero,
                child: content,
              ),
            );
          },
        );
      },
    );
  }

  static Future<T?> modalSheet<T>(
    BuildContext context, {
    required Widget content,
    double? height,
    bool expand = false,
    bool enableDrag = true,
    bool hasPadding = true,
    bool isDismissible = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final colors = context.lndTheme;
    return CupertinoScaffold.showCupertinoModalBottomSheet(
      builder: (_) => content,
      backgroundColor: colors.surface,
      context: context,
      expand: expand,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      duration: const Duration(milliseconds: 300),
    );
  }

  static Future<T?> alertDialog<T>({
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'OK',
    String? tertiaryText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onTertiary,
    Color? confirmColor,
    Color? cancelColor,
    Color? tertiaryColor,
    dynamic tertiaryResult = false,
    dynamic cancelResult = false,
    dynamic confirmResult = true,
  }) {
    final colors = Get.context!.lndTheme;
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
        context: Get.context!,
        builder:
            (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                if (onTertiary != null || tertiaryText != null)
                  CupertinoDialogAction(
                    onPressed: () {
                      if (onTertiary == null) {
                        Get.back(result: tertiaryResult);
                      } else {
                        onTertiary.call();
                      }
                    },
                    child: Text(
                      tertiaryText ?? 'Close',
                      style: TextStyle(
                        color: tertiaryColor ?? colors.textPrimary,
                      ),
                    ),
                  ),
                CupertinoDialogAction(
                  onPressed: () {
                    if (onCancel == null) {
                      Get.back(result: cancelResult);
                    } else {
                      onCancel.call();
                    }
                  },
                  child: Text(
                    cancelText,
                    style: TextStyle(color: cancelColor ?? colors.textPrimary),
                  ),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    if (onConfirm == null) {
                      Get.back(result: confirmResult);
                    } else {
                      onConfirm.call();
                    }
                  },
                  isDefaultAction: true,
                  child: Text(
                    confirmText,
                    style: TextStyle(color: confirmColor ?? colors.primary),
                  ),
                ),
              ],
            ),
      );
    } else {
      return showDialog<T>(
        context: Get.context!,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                if (onTertiary != null || tertiaryText != null)
                  TextButton(
                    onPressed: () {
                      onTertiary?.call();
                      Get.back(result: tertiaryResult);
                    },
                    child: Text(
                      tertiaryText ?? 'Close',
                      style: TextStyle(
                        color: tertiaryColor ?? colors.textPrimary,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    onCancel?.call();
                    Get.back(result: false);
                  },
                  child: Text(
                    cancelText,
                    style: TextStyle(color: cancelColor ?? colors.textPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm?.call();
                    Get.back(result: true);
                  },
                  child: Text(
                    confirmText,
                    style: TextStyle(color: confirmColor ?? colors.primary),
                  ),
                ),
              ],
            ),
      );
    }
  }

  static Future<DateTime?> datePicker({
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? initialDate,
    String doneText = 'Done',
  }) async {
    final date = _clampDate(initialDate ?? DateTime.now(), firstDate, lastDate);

    if (Platform.isIOS) {
      return bottomSheet<DateTime>(
        _LNDCupertinoDatePicker(
          initialDate: date,
          firstDate: firstDate,
          lastDate: lastDate,
          doneText: doneText,
        ),
        expand: false,
        enableDrag: false,
        isDismissible: false,
      );
    }

    return showDatePicker(
      context: Get.context!,
      initialDate: date,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  static Future<TimeOfDay?> timePicker({
    TimeOfDay? initialTime,
    String doneText = 'Done',
  }) async {
    final time = initialTime ?? TimeOfDay.now();

    if (Platform.isIOS) {
      return bottomSheet<TimeOfDay>(
        _LNDCupertinoTimePicker(initialTime: time, doneText: doneText),
        expand: false,
        enableDrag: false,
        isDismissible: false,
      );
    }

    return showTimePicker(context: Get.context!, initialTime: time);
  }

  static Future<Duration?> timeDuration({
    Duration? initialDuration,
    String doneText = 'Done',
    Duration lowerBound = Duration.zero,
    Duration? upperBound,
  }) async {
    final duration = _clampDuration(
      initialDuration ?? Duration.zero,
      lowerBound,
      upperBound,
    );

    if (Platform.isIOS) {
      return bottomSheet<Duration>(
        _LNDCupertinoDurationPicker(
          initialDuration: duration,
          doneText: doneText,
        ),
        expand: false,
        enableDrag: false,
        isDismissible: false,
      );
    }

    return bottomSheet<Duration>(
      _LNDMaterialDurationPicker(
        initialDuration: duration,
        doneText: doneText,
        lowerBound: lowerBound,
        upperBound: upperBound,
      ),
      expand: false,
      enableDrag: false,
      isDismissible: false,
    );
  }

  static DateTime _clampDate(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    if (date.isBefore(firstDate)) return firstDate;
    if (date.isAfter(lastDate)) return lastDate;
    return date;
  }

  static Duration _clampDuration(
    Duration duration,
    Duration lowerBound,
    Duration? upperBound,
  ) {
    if (duration < lowerBound) return lowerBound;
    if (upperBound != null && duration > upperBound) return upperBound;
    return duration;
  }

  static Widget popupMenuIcon<T>({
    required IconData icon,
    required List<LNDMenuItem<T>> items,
    double size = 30.0,
    Color? color,
    Widget? child,
  }) {
    if (Platform.isIOS) {
      return PullDownButton(
        itemBuilder:
            (_) =>
                items
                    .map(
                      (i) => PullDownMenuItem(
                        onTap: () {
                          i.onTap(i.value);
                        },
                        title: i.label,
                        icon: i.icon,
                        isDestructive: i.isDestructive,
                        itemTheme: PullDownMenuItemTheme(
                          textStyle: LNDText.regularStyle.copyWith(
                            color:
                                i.isDestructive
                                    ? Get.context!.lndTheme.danger
                                    : Get.context!.lndTheme.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
        buttonBuilder: (_, fn) {
          if (child != null) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: fn,
              child: child,
            );
          }

          return LNDButton.icon(
            icon: icon,
            onPressed: fn,
            size: size,
            color: color,
          );
        },
      );
    } else {
      return PopupMenuButton(
        useRootNavigator: true,
        position: PopupMenuPosition.under,
        onSelected: (val) {
          final item = items.firstWhere((e) => e.value == val);
          item.onTap(val);
        },
        itemBuilder:
            (_) =>
                items
                    .map(
                      (i) => PopupMenuItem(
                        value: i.value,
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LNDText.regular(text: i.label),
                              Icon(i.icon),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
        child: child ?? Icon(icon, color: color, size: size),
      );
    }
  }

  static Widget popupMenuWidget<T>({
    required List<LNDMenuItem<T>> items,
    required Widget child,
    double size = 30.0,
    Color? color,
  }) {
    if (Platform.isIOS) {
      return PullDownButton(
        itemBuilder:
            (_) =>
                items
                    .map(
                      (i) => PullDownMenuItem(
                        onTap: () {
                          i.onTap(i.value);
                        },
                        title: i.label,
                        icon: i.icon,
                        isDestructive: i.isDestructive,
                        itemTheme: PullDownMenuItemTheme(
                          textStyle: LNDText.regularStyle.copyWith(
                            color:
                                i.isDestructive
                                    ? Get.context!.lndTheme.danger
                                    : Get.context!.lndTheme.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
        buttonBuilder: (_, fn) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: fn,
            child: child,
          );
        },
      );
    } else {
      return PopupMenuButton(
        useRootNavigator: true,
        position: PopupMenuPosition.under,
        onSelected: (val) {
          final item = items.firstWhere((e) => e.value == val);
          item.onTap(val);
        },
        itemBuilder:
            (_) =>
                items
                    .map(
                      (i) => PopupMenuItem(
                        value: i.value,
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LNDText.regular(text: i.label),
                              Icon(i.icon),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
        child: child,
      );
    }
  }
}

class _LNDHorizontalMenuItem<T> extends StatelessWidget {
  const _LNDHorizontalMenuItem({required this.item, required this.onTap});

  final LNDMenuItem<T> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final foregroundColor =
        item.isDestructive ? colors.danger : colors.textPrimary;
    final backgroundColor =
        item.isDestructive ? colors.dangerSoft : colors.surfaceMuted;

    return SizedBox(
      width: 92,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: foregroundColor, size: 24),
              ),
              const SizedBox(height: 8),
              LNDText.medium(
                text: item.label,
                color: foregroundColor,
                fontSize: 12,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LNDCupertinoDatePicker extends StatefulWidget {
  const _LNDCupertinoDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.doneText,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String doneText;

  @override
  State<_LNDCupertinoDatePicker> createState() =>
      _LNDCupertinoDatePickerState();
}

class _LNDCupertinoDatePickerState extends State<_LNDCupertinoDatePicker> {
  late DateTime _selectedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: LNDButton.text(
                text: widget.doneText,
                onPressed: () => Get.back(result: _selectedDate),
                enabled: true,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(
            height: 300.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoDatePicker(
                initialDateTime: _selectedDate,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged:
                    (value) => setState(() => _selectedDate = value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LNDCupertinoTimePicker extends StatefulWidget {
  const _LNDCupertinoTimePicker({
    required this.initialTime,
    required this.doneText,
  });

  final TimeOfDay initialTime;
  final String doneText;

  @override
  State<_LNDCupertinoTimePicker> createState() =>
      _LNDCupertinoTimePickerState();
}

class _LNDCupertinoTimePickerState extends State<_LNDCupertinoTimePicker> {
  late TimeOfDay _selectedTime = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final initialDate = DateTime(
      2000,
      1,
      1,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => Get.back(result: _selectedTime),
              child: LNDText.medium(
                text: widget.doneText,
                color: colors.primary,
              ),
            ),
          ).paddingOnly(right: 12, top: 8),
          SizedBox(
            height: 220,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: initialDate,
              onDateTimeChanged: (value) {
                _selectedTime = TimeOfDay(
                  hour: value.hour,
                  minute: value.minute,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LNDCupertinoDurationPicker extends StatefulWidget {
  const _LNDCupertinoDurationPicker({
    required this.initialDuration,
    required this.doneText,
  });

  final Duration initialDuration;
  final String doneText;

  @override
  State<_LNDCupertinoDurationPicker> createState() =>
      _LNDCupertinoDurationPickerState();
}

class _LNDCupertinoDurationPickerState
    extends State<_LNDCupertinoDurationPicker> {
  late Duration _selectedDuration = widget.initialDuration;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => Get.back(result: _selectedDuration),
              child: LNDText.medium(
                text: widget.doneText,
                color: colors.primary,
              ),
            ),
          ).paddingOnly(right: 12, top: 8),
          SizedBox(
            height: 220,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: _selectedDuration,
              onTimerDurationChanged: (value) {
                _selectedDuration = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LNDMaterialDurationPicker extends StatefulWidget {
  const _LNDMaterialDurationPicker({
    required this.initialDuration,
    required this.doneText,
    required this.lowerBound,
    this.upperBound,
  });

  final Duration initialDuration;
  final String doneText;
  final Duration lowerBound;
  final Duration? upperBound;

  @override
  State<_LNDMaterialDurationPicker> createState() =>
      _LNDMaterialDurationPickerState();
}

class _LNDMaterialDurationPickerState
    extends State<_LNDMaterialDurationPicker> {
  late Duration _selectedDuration = widget.initialDuration;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => Get.back(result: _selectedDuration),
              child: LNDText.medium(
                text: widget.doneText,
                color: colors.primary,
              ),
            ),
          ).paddingOnly(right: 12, top: 8),
          SizedBox(
            height: 300,
            child: DurationPicker(
              duration: _selectedDuration,
              baseUnit: BaseUnit.minute,
              lowerBound: widget.lowerBound,
              upperBound: widget.upperBound,
              onChange: (value) {
                setState(() => _selectedDuration = value);
              },
            ),
          ).paddingSymmetric(horizontal: 16),
        ],
      ),
    );
  }
}
