import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/core/services/payment.service.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';

class PayoutInstitutionPickerPageArgs {
  final String destinationType;
  final String provider;

  const PayoutInstitutionPickerPageArgs({
    required this.destinationType,
    this.provider = 'instapay',
  });
}

class PayoutInstitutionPickerController extends GetxController {
  static PayoutInstitutionPickerController instance =
      Get.find<PayoutInstitutionPickerController>();

  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<LNDPayoutInstitution> institutions =
      <LNDPayoutInstitution>[].obs;
  final RxList<LNDPayoutInstitution> displayedInstitutions =
      <LNDPayoutInstitution>[].obs;

  Timer? _searchDebounce;

  PayoutInstitutionPickerPageArgs get args =>
      Get.arguments as PayoutInstitutionPickerPageArgs? ??
      const PayoutInstitutionPickerPageArgs(
        destinationType: 'bank',
        provider: 'instapay',
      );

  bool get isBank => args.destinationType == 'bank';
  String get title => isBank ? 'Select Bank' : 'Select E-wallet';
  String get searchHint => isBank ? 'Search bank' : 'Search e-wallet';
  String get emptyText => isBank ? 'No banks found' : 'No e-wallets found';

  static List<LNDPayoutInstitution> searchInstitutions({
    required Iterable<LNDPayoutInstitution> institutions,
    required String query,
  }) {
    final normalizedQuery = _normalizeSearchText(query);
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    if (compactQuery.isEmpty) return institutions.toList(growable: false);
    final queryWords =
        normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

    final matches = <_InstitutionSearchMatch>[];
    for (final institution in institutions) {
      final rank = _rankInstitutionMatch(
        institution: institution,
        normalizedQuery: normalizedQuery,
        compactQuery: compactQuery,
        queryWords: queryWords,
      );
      if (rank == null) continue;
      matches.add(
        _InstitutionSearchMatch(institution: institution, rank: rank),
      );
    }

    matches.sort((a, b) {
      final rankComparison = a.rank.compareTo(b.rank);
      if (rankComparison != 0) return rankComparison;
      return a.institution.name.toLowerCase().compareTo(
        b.institution.name.toLowerCase(),
      );
    });
    return matches.map((match) => match.institution).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(_onSearchChanged);

    loadInstitutions();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final text = searchController.text;
    query.value = text;

    _searchDebounce?.cancel();

    final normalized = _normalizeSearchText(text);

    if (normalized.isEmpty) {
      applySearch(text);
      return;
    }

    _searchDebounce = Timer(searchDebounceDuration, () {
      applySearch(searchController.text);
    });
  }

  Future<void> loadInstitutions() async {
    try {
      isLoading.value = true;

      final results = await LNDPaymentService.listPayoutInstitutions(
        destinationType: args.destinationType,
        provider: args.provider,
      );

      institutions.assignAll(results);

      applySearch(searchController.text);
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
      LNDSnackbar.showError('Unable to load supported payout accounts.');
    } finally {
      isLoading.value = false;
    }
  }

  void selectInstitution(LNDPayoutInstitution institution) {
    Get.back(result: institution);
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();

    query.value = '';
    displayedInstitutions.assignAll(institutions.toList(growable: true));
    displayedInstitutions.refresh();
  }

  void scheduleApplySearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(searchDebounceDuration, () {
      applySearch(query.value);
    });
  }

  void applySearch([String? rawQuery]) {
    final currentQuery = rawQuery ?? query.value;

    final results = searchInstitutions(
      institutions: institutions,
      query: currentQuery,
    );

    displayedInstitutions.value = results.toList(growable: true);
    displayedInstitutions.refresh();
  }

  static int? _rankInstitutionMatch({
    required LNDPayoutInstitution institution,
    required String normalizedQuery,
    required String compactQuery,
    required List<String> queryWords,
  }) {
    final normalizedName = _normalizeSearchText(institution.name);
    final compactName = normalizedName.replaceAll(' ', '');
    final nameWords =
        normalizedName.split(' ').where((word) => word.isNotEmpty).toList();

    if (compactName == compactQuery) return 0;
    if (normalizedName.startsWith(normalizedQuery) ||
        compactName.startsWith(compactQuery)) {
      return 1;
    }

    final allQueryWordsHaveNameWordPrefix = queryWords.every(
      (queryWord) =>
          nameWords.any((nameWord) => nameWord.startsWith(queryWord)),
    );
    if (allQueryWordsHaveNameWordPrefix) return 2;

    final allQueryWordsAreInName = queryWords.every(normalizedName.contains);
    if (allQueryWordsAreInName) {
      return 3;
    }

    if (normalizedName.contains(normalizedQuery)) {
      return 4;
    }
    return null;
  }

  static String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _InstitutionSearchMatch {
  final LNDPayoutInstitution institution;
  final int rank;

  const _InstitutionSearchMatch({
    required this.institution,
    required this.rank,
  });
}
