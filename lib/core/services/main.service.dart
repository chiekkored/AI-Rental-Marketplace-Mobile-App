import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lend/firebase_options.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/core/services/remote_config.service.dart';

class MainService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> intializeGetStorage() async {
    await GetStorage.init();
  }

  static Future<void> initializeRemoteConfig({required String env}) async {
    await LNDRemoteConfigService.initialize(env: env);
  }

  static Future<void> loadEnv(String env) async {
    _printColoredEnv(env);
    await dotenv.load(fileName: 'envs/.$env.env');
  }

  static Future<void> initializeDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> useFirebaseEmulator() async {
    String host = '127.0.0.1';

    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    LNDCloudFunctionsService.useFunctionsEmulator(host, 5001);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  static void _printColoredEnv(String env) {
    const reset = '\x1B[0m';
    const yellow = '\x1B[33m';
    const green = '\x1B[32m';
    const red = '\x1B[31m';

    late String color;
    switch (env) {
      case 'local':
        color = yellow;
        break;
      case 'dev':
        color = green;
        break;
      case 'prod':
        color = red;
        break;
      default:
        color = reset;
    }

    if (kDebugMode) print('$color🚀 Running in $env environment$reset');
  }
}
