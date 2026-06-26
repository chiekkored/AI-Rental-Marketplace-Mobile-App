import 'package:flutter_test/flutter_test.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/rates.model.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing_pricing.chunk.dart';

void main() {
  group('CreateListingPricingChunk', () {
    test('requires enabled optional rate fields', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '1000';
      expect(chunk.canContinue.value, isTrue);

      chunk.setWeeklyRateEnabled(true);
      expect(chunk.canContinue.value, isTrue);

      chunk.monthlyPriceController.text = '0';
      chunk.setMonthlyRateEnabled(true);
      expect(chunk.canContinue.value, isFalse);

      chunk.monthlyPriceController.text = '0';
      expect(chunk.canContinue.value, isFalse);

      chunk.monthlyPriceController.text = '2500';
      expect(chunk.canContinue.value, isTrue);
    });

    test('draft persists optional rate toggle states and field values', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '1000';
      chunk.setWeeklyRateEnabled(true);
      chunk.setMonthlyRateEnabled(true);
      chunk.setAnnualRateEnabled(true);

      final draft = chunk.toDraftMap();
      final restored = CreateListingPricingChunk()..onInit();
      addTearDown(restored.onClose);
      restored.loadFromDraft(draft);

      expect(restored.weeklyRateEnabled.value, isTrue);
      expect(restored.weeklyPriceController.text, '7,000');
      expect(restored.monthlyRateEnabled.value, isTrue);
      expect(restored.monthlyPriceController.text, '30,000');
      expect(restored.annualRateEnabled.value, isTrue);
      expect(restored.annualPriceController.text, '365,000');
      expect(restored.canContinue.value, isTrue);
    });

    test('auto fills enabled optional rates from daily rate', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '1000';

      chunk.setWeeklyRateEnabled(true);
      chunk.setMonthlyRateEnabled(true);
      chunk.setAnnualRateEnabled(true);

      expect(chunk.weeklyPriceController.text, '7,000');
      expect(chunk.monthlyPriceController.text, '30,000');
      expect(chunk.annualPriceController.text, '365,000');
      expect(chunk.canContinue.value, isTrue);
    });

    test(
      'auto fills enabled empty optional rates when daily rate is entered',
      () {
        final chunk = CreateListingPricingChunk()..onInit();
        addTearDown(chunk.onClose);

        chunk.setWeeklyRateEnabled(true);
        expect(chunk.weeklyPriceController.text, isEmpty);
        expect(chunk.canContinue.value, isFalse);

        chunk.dailyPriceController.text = '1000';

        expect(chunk.weeklyPriceController.text, '7,000');
        expect(chunk.canContinue.value, isTrue);
      },
    );

    test('clears auto filled optional rates when daily rate is emptied', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '1000';
      chunk.setWeeklyRateEnabled(true);
      chunk.setMonthlyRateEnabled(true);
      chunk.setAnnualRateEnabled(true);

      chunk.dailyPriceController.clear();

      expect(chunk.weeklyPriceController.text, isEmpty);
      expect(chunk.monthlyPriceController.text, isEmpty);
      expect(chunk.annualPriceController.text, isEmpty);
      expect(chunk.canContinue.value, isFalse);
    });

    test(
      'does not clear manually adjusted optional rates when daily is emptied',
      () {
        final chunk = CreateListingPricingChunk()..onInit();
        addTearDown(chunk.onClose);

        chunk.dailyPriceController.text = '1000';
        chunk.setWeeklyRateEnabled(true);
        chunk.weeklyPriceController.text = '6,500';

        chunk.dailyPriceController.clear();

        expect(chunk.weeklyPriceController.text, '6,500');
        expect(chunk.canContinue.value, isFalse);
      },
    );

    test(
      'repopulates still auto filled optional rates after daily is reentered',
      () {
        final chunk = CreateListingPricingChunk()..onInit();
        addTearDown(chunk.onClose);

        chunk.setWeeklyRateEnabled(true);
        chunk.dailyPriceController.text = '1000';
        chunk.dailyPriceController.clear();
        chunk.dailyPriceController.text = '2000';

        expect(chunk.weeklyPriceController.text, '14,000');
        expect(chunk.canContinue.value, isTrue);
      },
    );

    test('does not overwrite existing optional values when toggled on', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '100';
      chunk.weeklyPriceController.text = '650';

      chunk.setWeeklyRateEnabled(true);

      expect(chunk.weeklyPriceController.text, '650');
      expect(chunk.canContinue.value, isTrue);
    });

    test('refreshes auto filled rates when daily rate changes', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.dailyPriceController.text = '100';
      chunk.setWeeklyRateEnabled(true);
      chunk.setMonthlyRateEnabled(true);
      chunk.setAnnualRateEnabled(true);

      chunk.dailyPriceController.text = '200';

      expect(chunk.weeklyPriceController.text, '1,400');
      expect(chunk.monthlyPriceController.text, '6,000');
      expect(chunk.annualPriceController.text, '73,000');
      expect(chunk.canContinue.value, isTrue);
    });

    test(
      'preserves manually adjusted optional rates when daily rate changes',
      () {
        final chunk = CreateListingPricingChunk()..onInit();
        addTearDown(chunk.onClose);

        chunk.dailyPriceController.text = '100';
        chunk.setWeeklyRateEnabled(true);
        chunk.weeklyPriceController.text = '650';

        chunk.dailyPriceController.text = '200';

        expect(chunk.weeklyPriceController.text, '650');
        expect(chunk.canContinue.value, isTrue);
      },
    );

    test('edit hydration enables toggles for existing optional rates', () {
      final chunk = CreateListingPricingChunk()..onInit();
      addTearDown(chunk.onClose);

      chunk.populateFromAsset(
        Asset(
          id: 'asset-1',
          rates: Rates(daily: 100, weekly: 650, monthly: 2500, annually: 25000),
        ),
      );

      expect(chunk.dailyPriceController.text, '100');
      expect(chunk.weeklyRateEnabled.value, isTrue);
      expect(chunk.weeklyPriceController.text, '650');
      expect(chunk.monthlyRateEnabled.value, isTrue);
      expect(chunk.monthlyPriceController.text, '2500');
      expect(chunk.annualRateEnabled.value, isTrue);
      expect(chunk.annualPriceController.text, '25000');
      expect(chunk.canContinue.value, isTrue);
    });
  });
}
