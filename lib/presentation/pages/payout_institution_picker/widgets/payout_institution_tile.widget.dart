import 'package:flutter/material.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PayoutInstitutionTile extends StatelessWidget {
  final LNDPayoutInstitution institution;

  const PayoutInstitutionTile({super.key, required this.institution});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return ListTile(
      onTap:
          () => PayoutInstitutionPickerController.instance.selectInstitution(
            institution,
          ),
      title: LNDText.medium(
        text: institution.name,
        color: colors.textPrimary,
        maxLines: 2,
      ),
      subtitle:
          institution.code.isEmpty
              ? null
              : LNDText.regular(
                text: institution.code,
                color: colors.textMuted,
                fontSize: 12.0,
              ),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
    );
  }
}
