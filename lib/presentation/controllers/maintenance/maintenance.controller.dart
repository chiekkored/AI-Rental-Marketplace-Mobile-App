import 'dart:async';

import 'package:get/get.dart';
import 'package:lend/core/models/maintenance_mode.model.dart';
import 'package:lend/core/services/maintenance_mode.service.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class MaintenanceController extends GetxController {
  static MaintenanceController get instance =>
      Get.find<MaintenanceController>();

  final Rx<LNDMaintenanceMode> maintenanceMode =
      LNDMaintenanceMode.disabled.obs;

  StreamSubscription<LNDMaintenanceMode>? _subscription;

  bool get isEnabled => maintenanceMode.value.enabled;

  @override
  void onInit() {
    super.onInit();
    bindMaintenanceMode();
  }

  void bindMaintenanceMode() {
    if (_subscription != null) return;
    _subscription = LNDMaintenanceModeService.watchMaintenanceMode().listen(
      (mode) => maintenanceMode.value = mode,
      onError: (Object e, StackTrace st) {
        maintenanceMode.value = LNDMaintenanceMode.disabled;
        LNDLogger.e(
          'Maintenance mode listener failed',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    maintenanceMode.close();
    super.onClose();
  }
}
