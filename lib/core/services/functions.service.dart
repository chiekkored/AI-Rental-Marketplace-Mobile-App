import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LNDCloudFunctionsService {
  LNDCloudFunctionsService._();

  static const String _defaultRegion = 'asia-southeast1';

  static FirebaseFunctions? _instance;
  static String? _emulatorHost;
  static int? _emulatorPort;
  static bool _emulatorConnected = false;

  static String get region {
    final configuredRegion = dotenv.env['FIREBASE_FUNCTIONS_REGION']?.trim();
    return configuredRegion?.isNotEmpty == true
        ? configuredRegion!
        : _defaultRegion;
  }

  static FirebaseFunctions get instance {
    final functions =
        _instance ??= FirebaseFunctions.instanceFor(region: region);

    final host = _emulatorHost;
    final port = _emulatorPort;
    if (host != null && port != null && !_emulatorConnected) {
      functions.useFunctionsEmulator(host, port);
      _emulatorConnected = true;
    }

    return functions;
  }

  static void useFunctionsEmulator(String host, int port) {
    _emulatorHost = host;
    _emulatorPort = port;
    if (_instance != null && !_emulatorConnected) {
      _instance!.useFunctionsEmulator(host, port);
      _emulatorConnected = true;
    }
  }
}
