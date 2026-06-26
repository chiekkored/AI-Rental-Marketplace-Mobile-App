import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lend/core/models/maintenance_mode.model.dart';
import 'package:lend/utilities/constants/collections.constant.dart';

class LNDMaintenanceModeService {
  LNDMaintenanceModeService._();

  static const documentId = 'maintenance';

  static Stream<LNDMaintenanceMode> watchMaintenanceMode() {
    return FirebaseFirestore.instance
        .collection(LNDCollections.appConfig.name)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return LNDMaintenanceMode.disabled;
          return LNDMaintenanceMode.fromFirestore(snapshot);
        });
  }
}
