import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/maintenance_mode.model.dart';

void main() {
  test('maintenance mode defaults to disabled when enabled is missing', () {
    final mode = LNDMaintenanceMode.fromMap({});

    expect(mode.enabled, false);
    expect(mode.updatedAt, isNull);
    expect(mode.updatedBy, isNull);
  });

  test('maintenance mode parses enabled state and metadata', () {
    final timestamp = Timestamp(1710000000, 123);
    final mode = LNDMaintenanceMode.fromMap({
      'enabled': true,
      'updatedAt': timestamp,
      'updatedBy': 'admin-1',
    });

    expect(mode.enabled, true);
    expect(mode.updatedAt, timestamp);
    expect(mode.updatedBy, 'admin-1');
  });
}
