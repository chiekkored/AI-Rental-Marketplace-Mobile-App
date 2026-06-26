import 'package:cloud_functions/cloud_functions.dart';
import 'package:lend/core/services/functions.service.dart';
import 'package:lend/utilities/constants/functions.constant.dart';

enum ListingShareMode {
  attributed('attributed'),
  generic('generic');

  const ListingShareMode(this.value);

  final String value;
}

enum ListingShareResolveContext {
  appOpen('app_open'),
  qrScan('qr_scan');

  const ListingShareResolveContext(this.value);

  final String value;
}

class ListingShareLinkResult {
  const ListingShareLinkResult({
    required this.code,
    required this.url,
    required this.mode,
    required this.assetId,
    this.title,
  });

  final String code;
  final String url;
  final String mode;
  final String assetId;
  final String? title;

  factory ListingShareLinkResult.fromMap(Map<String, dynamic> map) {
    return ListingShareLinkResult(
      code: map['code']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      mode: map['mode']?.toString() ?? '',
      assetId: map['assetId']?.toString() ?? '',
      title: map['title']?.toString(),
    );
  }
}

class ListingShareResolveResult {
  const ListingShareResolveResult({
    required this.code,
    required this.assetId,
    required this.url,
    this.mode,
    this.sharerId,
  });

  final String code;
  final String assetId;
  final String url;
  final String? mode;
  final String? sharerId;

  factory ListingShareResolveResult.fromMap(Map<String, dynamic> map) {
    return ListingShareResolveResult(
      code: map['code']?.toString() ?? '',
      assetId: map['assetId']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      mode: map['mode']?.toString(),
      sharerId: map['sharerId']?.toString(),
    );
  }
}

class LNDListingShareService {
  LNDListingShareService._();

  static Future<ListingShareLinkResult> createListingShareLink({
    required String assetId,
    ListingShareMode mode = ListingShareMode.attributed,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.createListingShareLink,
    );

    final response = await callable.call<Map<String, dynamic>>({
      'assetId': assetId,
      'mode': mode.value,
    });

    return ListingShareLinkResult.fromMap(
      Map<String, dynamic>.from(response.data),
    );
  }

  static Future<ListingShareResolveResult> resolveListingShareLink({
    required String code,
    ListingShareResolveContext context = ListingShareResolveContext.appOpen,
  }) async {
    final callable = LNDCloudFunctionsService.instance.httpsCallable(
      LNDFunctions.resolveListingShareLink,
    );

    final response = await callable.call<Map<String, dynamic>>({
      'code': code,
      'context': context.value,
    });

    return ListingShareResolveResult.fromMap(
      Map<String, dynamic>.from(response.data),
    );
  }

  static bool isUnavailableError(Object error) {
    return error is FirebaseFunctionsException &&
        (error.code == 'not-found' || error.code == 'failed-precondition');
  }
}
