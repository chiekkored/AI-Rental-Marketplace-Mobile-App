import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/controllers/settings/settings.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory storageDirectory;

  setUpAll(() {
    storageDirectory = Directory.systemTemp.createTempSync(
      'lend_settings_controller_theme_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return storageDirectory.path;
          }
          return null;
        });
  });

  tearDownAll(() {
    storageDirectory.deleteSync(recursive: true);
  });

  setUp(() async {
    Get.testMode = true;
    await GetStorage.init();
    await LNDStorageService.clear();
  });

  tearDown(() async {
    await LNDStorageService.clear();
    Get.reset();
  });

  test('initialThemeMode defaults to system when no preference is saved', () {
    expect(SettingsController.initialThemeMode, ThemeMode.system);
  });

  test('initialThemeMode maps saved theme preferences', () async {
    await LNDStorageService.write(LNDStorageConstants.themeMode, 'system');
    expect(SettingsController.initialThemeMode, ThemeMode.system);

    await LNDStorageService.write(LNDStorageConstants.themeMode, 'dark');
    expect(SettingsController.initialThemeMode, ThemeMode.dark);

    await LNDStorageService.write(LNDStorageConstants.themeMode, 'light');
    expect(SettingsController.initialThemeMode, ThemeMode.light);
  });

  test('setUseSystemTheme stores system when enabled', () async {
    final controller = SettingsController();

    await controller.setUseSystemTheme(true);

    expect(controller.themeMode.value, ThemeMode.system);
    expect(
      LNDStorageService.read<String>(LNDStorageConstants.themeMode),
      'system',
    );
  });

  test('setUseSystemTheme stores light when disabled', () async {
    final controller = SettingsController();

    await controller.setUseSystemTheme(false);

    expect(controller.themeMode.value, ThemeMode.light);
    expect(
      LNDStorageService.read<String>(LNDStorageConstants.themeMode),
      'light',
    );
  });

  test('setDarkMode stores manual dark and light preferences', () async {
    final controller = SettingsController();

    await controller.setDarkMode(true);
    expect(controller.themeMode.value, ThemeMode.dark);
    expect(
      LNDStorageService.read<String>(LNDStorageConstants.themeMode),
      'dark',
    );

    await controller.setDarkMode(false);
    expect(controller.themeMode.value, ThemeMode.light);
    expect(
      LNDStorageService.read<String>(LNDStorageConstants.themeMode),
      'light',
    );
  });
}
