import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/paymongo_payment.model.dart';
import 'package:lend/presentation/controllers/owner_payout_destination/owner_payout_destination.controller.dart';
import 'package:lend/presentation/controllers/payout_institution_picker/payout_institution_picker.controller.dart';

void main() {
  const bankInstitutions = [
    LNDPayoutInstitution(
      id: '1',
      code: 'BDO',
      name: 'BDO Unibank, Inc.',
      destinationType: 'bank',
      supportedProviders: ['instapay'],
    ),
    LNDPayoutInstitution(
      id: '2',
      code: 'MBT',
      name: 'Metrobank',
      destinationType: 'bank',
      supportedProviders: ['instapay'],
    ),
    LNDPayoutInstitution(
      id: '3',
      code: 'BPI',
      name: 'Bank of the Philippine Islands',
      destinationType: 'bank',
      supportedProviders: ['instapay'],
    ),
  ];

  group('PayoutInstitutionPickerController search', () {
    test('matches only against institution names', () {
      final results = PayoutInstitutionPickerController.searchInstitutions(
        institutions: const [
          LNDPayoutInstitution(
            id: '1',
            code: 'BPI',
            name: 'Bank of the Philippine Islands',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
          LNDPayoutInstitution(
            id: '2',
            code: 'BDO',
            name: 'BDO Unibank, Inc.',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
        ],
        query: 'bdo',
      );

      expect(results, hasLength(1));
      expect(results.first.name, 'BDO Unibank, Inc.');

      expect(
        PayoutInstitutionPickerController.searchInstitutions(
          institutions: bankInstitutions,
          query: 'bpi',
        ),
        isEmpty,
      );
    });

    test('ranks prefix matches before contains-only matches', () {
      final results = PayoutInstitutionPickerController.searchInstitutions(
        institutions: const [
          LNDPayoutInstitution(
            id: '1',
            code: 'SMB',
            name: 'Savings Metro Bank',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
          LNDPayoutInstitution(
            id: '2',
            code: 'MBT',
            name: 'Metrobank',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
        ],
        query: 'metro',
      );

      expect(results.first.name, 'Metrobank');
    });

    test('normalizes punctuation and spaces for e-wallet names', () {
      const institutions = [
        LNDPayoutInstitution(
          id: '1',
          code: 'GCASH',
          name: 'G-Cash',
          destinationType: 'ewallet',
          supportedProviders: ['instapay'],
        ),
      ];

      expect(
        PayoutInstitutionPickerController.searchInstitutions(
          institutions: institutions,
          query: 'gcash',
        ),
        hasLength(1),
      );
      expect(
        PayoutInstitutionPickerController.searchInstitutions(
          institutions: institutions,
          query: 'g cash',
        ),
        hasLength(1),
      );
      expect(
        PayoutInstitutionPickerController.searchInstitutions(
          institutions: institutions,
          query: 'G-Cash',
        ),
        hasLength(1),
      );
    });

    test('returns no results for unknown searches', () {
      final results = PayoutInstitutionPickerController.searchInstitutions(
        institutions: const [
          LNDPayoutInstitution(
            id: '1',
            code: 'BPI',
            name: 'Bank of the Philippine Islands',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
        ],
        query: 'not a bank',
      );

      expect(results, isEmpty);
    });

    test('multi-word searches require all words to match the name', () {
      final results = PayoutInstitutionPickerController.searchInstitutions(
        institutions: const [
          LNDPayoutInstitution(
            id: '1',
            code: 'ALIPAY',
            name: 'Alipay Philippines',
            destinationType: 'ewallet',
            supportedProviders: ['instapay'],
          ),
          LNDPayoutInstitution(
            id: '2',
            code: 'BOC',
            name: 'Bank of Commerce',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
          LNDPayoutInstitution(
            id: '3',
            code: 'BPI',
            name: 'Bank of the Philippine Islands',
            destinationType: 'bank',
            supportedProviders: ['instapay'],
          ),
        ],
        query: 'bank of commerce',
      );

      expect(results, hasLength(1));
      expect(results.first.name, 'Bank of Commerce');
    });

    test('applySearch matches institution names only', () {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(bankInstitutions);
      controller.query.value = 'bdo';
      controller.applySearch();

      expect(controller.displayedInstitutions, hasLength(1));
      expect(controller.displayedInstitutions.first.name, 'BDO Unibank, Inc.');

      controller.query.value = 'bpi';
      controller.applySearch();

      expect(controller.displayedInstitutions, isEmpty);
    });

    test('applySearch normalizes punctuation and spaces', () {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(const [
        LNDPayoutInstitution(
          id: '1',
          code: 'GCASH',
          name: 'G-Cash',
          destinationType: 'ewallet',
          supportedProviders: ['instapay'],
        ),
      ]);

      for (final query in ['gcash', 'g cash', 'G-Cash']) {
        controller.query.value = query;
        controller.applySearch();

        expect(controller.displayedInstitutions, hasLength(1));
        expect(controller.displayedInstitutions.first.code, 'GCASH');
      }
    });

    test('scheduleApplySearch debounces filtering', () async {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(bankInstitutions);
      controller.displayedInstitutions.addAll(bankInstitutions);

      controller.query.value = 'bdo';
      controller.scheduleApplySearch();
      controller.query.value = 'metro';
      controller.scheduleApplySearch();

      expect(controller.displayedInstitutions, bankInstitutions);

      await Future<void>.delayed(
        PayoutInstitutionPickerController.searchDebounceDuration +
            const Duration(milliseconds: 50),
      );

      expect(controller.displayedInstitutions, hasLength(1));
      expect(controller.displayedInstitutions.first.name, 'Metrobank');
    });

    test('clearSearch cancels pending debounced filtering', () async {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(bankInstitutions);
      controller.displayedInstitutions.addAll(bankInstitutions);

      controller.query.value = 'metro';
      controller.scheduleApplySearch();
      controller.clearSearch();

      expect(controller.searchController.text, isEmpty);
      expect(controller.query.value, isEmpty);
      expect(controller.displayedInstitutions, bankInstitutions);

      await Future<void>.delayed(
        PayoutInstitutionPickerController.searchDebounceDuration +
            const Duration(milliseconds: 50),
      );

      expect(controller.displayedInstitutions, bankInstitutions);
    });

    test('clearing a narrowed search restores all institutions', () {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(bankInstitutions);
      controller.query.value = 'metro';
      controller.applySearch();

      expect(controller.displayedInstitutions, hasLength(1));
      expect(controller.displayedInstitutions.first.name, 'Metrobank');

      controller.query.value = '';
      controller.applySearch();

      expect(controller.displayedInstitutions, bankInstitutions);
    });

    test('clearSearch clears the field and restores all institutions', () {
      final controller = PayoutInstitutionPickerController();
      addTearDown(controller.onClose);

      controller.institutions.addAll(bankInstitutions);
      controller.searchController.text = 'bdo';
      controller.query.value = 'bdo';
      controller.applySearch();

      expect(controller.displayedInstitutions, hasLength(1));

      controller.clearSearch();

      expect(controller.searchController.text, isEmpty);
      expect(controller.query.value, isEmpty);
      expect(controller.displayedInstitutions, bankInstitutions);
    });
  });

  group('OwnerPayoutDestinationController provider selection', () {
    void fillRequiredPayoutFields(OwnerPayoutDestinationController controller) {
      controller.bankIdController.text = 'bdo';
      controller.bankCodeController.text = 'BDO';
      controller.bankNameController.text = 'BDO Unibank, Inc.';
      controller.accountNameController.text = 'Juan Dela Cruz';
      controller.accountNumberController.text = '1234567890';
      controller.confirmAccountNumberController.text = '1234567890';
    }

    test('enables save when all required fields are filled and matched', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      expect(controller.canSaveDestination, isFalse);

      fillRequiredPayoutFields(controller);

      expect(controller.canSaveDestination, isTrue);
    });

    test('disables save when account numbers do not match', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      fillRequiredPayoutFields(controller);
      controller.confirmAccountNumberController.text = '9876543210';

      expect(controller.canSaveDestination, isFalse);
    });

    test('disables save when any required field is missing', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      fillRequiredPayoutFields(controller);

      for (final textController in [
        controller.bankIdController,
        controller.bankNameController,
        controller.accountNameController,
        controller.accountNumberController,
        controller.confirmAccountNumberController,
      ]) {
        final originalText = textController.text;

        textController.clear();
        expect(controller.canSaveDestination, isFalse);

        textController.text = originalText;
        expect(controller.canSaveDestination, isTrue);
      }
    });

    test('matching empty account fields do not enable save', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      controller.bankIdController.text = 'bdo';
      controller.bankNameController.text = 'BDO Unibank, Inc.';
      controller.accountNameController.text = 'Juan Dela Cruz';
      controller.accountNumberController.text = '';
      controller.confirmAccountNumberController.text = '';

      expect(controller.canSaveDestination, isFalse);
    });

    test('deposit return mode uses deposit return labels', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      controller.purpose.value = OwnerPayoutDestinationPurpose.depositReturn;

      expect(controller.pageTitle, 'Deposit Return Destination');
      expect(controller.sectionTitle, 'Deposit return destination');
      expect(controller.savedMessage, 'Deposit return destination saved.');
      expect(controller.transferNoticeText, contains('deposit return timing'));
    });

    test('changing provider clears institution and account fields', () {
      final controller = OwnerPayoutDestinationController();
      addTearDown(controller.onClose);

      fillRequiredPayoutFields(controller);
      controller.supportedProviders.addAll(['instapay']);

      expect(controller.canSaveDestination, isTrue);

      controller.setProvider('pesonet');

      expect(controller.provider.value, 'pesonet');
      expect(controller.bankIdController.text, isEmpty);
      expect(controller.bankCodeController.text, isEmpty);
      expect(controller.bankNameController.text, isEmpty);
      expect(controller.accountNumberController.text, isEmpty);
      expect(controller.confirmAccountNumberController.text, isEmpty);
      expect(controller.supportedProviders, isEmpty);
      expect(controller.canSaveDestination, isFalse);
    });
  });
}
