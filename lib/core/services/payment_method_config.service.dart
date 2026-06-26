import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/payment_method_config.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class LNDPaymentMethodConfigService {
  LNDPaymentMethodConfigService._();

  static const documentId = 'paymentMethods';

  static Stream<LNDPaymentMethodConfig> watchPaymentMethodConfig() {
    return FirebaseFirestore.instance
        .collection(LNDCollections.appConfig.name)
        .doc(documentId)
        .snapshots()
        .map(LNDPaymentMethodConfig.fromFirestore);
  }
}
