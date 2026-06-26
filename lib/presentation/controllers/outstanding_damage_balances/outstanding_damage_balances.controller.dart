import 'package:get/get.dart';
import 'package:lend/core/models/outstanding_damage_balance.model.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/damage_balance_payment/damage_balance_payment.controller.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class OutstandingDamageBalancesPageArgs {
  final List<OutstandingDamageBalance> balances;

  const OutstandingDamageBalancesPageArgs({required this.balances});
}

class OutstandingDamageBalancesController extends GetxController {
  final OutstandingDamageBalancesPageArgs args =
      Get.arguments as OutstandingDamageBalancesPageArgs;

  late final RxList<OutstandingDamageBalance> balances =
      args.balances.toList(growable: false).obs;

  num get total =>
      balances.fold<num>(0, (sum, balance) => sum + balance.amount);

  String get currency => balances.isEmpty ? 'PHP' : balances.first.currency;

  void pay(OutstandingDamageBalance balance) {
    if (!balance.canPay) {
      LNDSnackbar.showInfo(
        'Lend Support has not sent a payable request for this balance yet.',
      );
      return;
    }

    LNDNavigate.toDamageBalancePaymentPage(
      args: DamageBalancePaymentPageArgs(
        chat: balance.paymentChat,
        bookingId: balance.bookingId,
        chatId: balance.chatId!,
        damagePaymentRequestId: balance.damagePaymentRequestId!,
        amount: balance.amount.round(),
        currency: balance.currency,
      ),
    );
  }
}
