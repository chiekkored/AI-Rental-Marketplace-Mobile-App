import 'package:flutter/material.dart';
import 'package:lend/utilities/enums/booking_status.enum.dart';
import 'package:lend/utilities/theme/lnd_theme.dart';

extension BookingStatusColor on BookingStatus {
  Color themedColor(LNDTheme colors) {
    switch (this) {
      case BookingStatus.pending:
        return colors.warning;
      case BookingStatus.confirmed:
      case BookingStatus.handedOver:
      case BookingStatus.returned:
      case BookingStatus.completed:
        return colors.success;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return colors.danger;
      case BookingStatus.cancellationRequested:
        return colors.warning;
    }
  }
}
