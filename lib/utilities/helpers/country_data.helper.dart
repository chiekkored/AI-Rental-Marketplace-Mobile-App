import 'package:lend/core/models/country_option.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:sealed_countries/sealed_countries.dart';

class LNDCountryData {
  LNDCountryData._();

  static final List<CountryOption> countries =
      WorldCountry.list
          .map(
            (country) => CountryOption(
              country: country,
              currency:
                  country.currencies?.isNotEmpty == true
                      ? country.currencies!.first
                      : null,
            ),
          )
          .toList()
        ..sort((a, b) => a.countryName.compareTo(b.countryName));

  static CountryOption get fallbackCountry => countryFromCode('PH');

  static CountryOption countryFromCode(String? countryCode) {
    final country =
        WorldCountry.maybeFromCodeShort(countryCode?.trim()) ??
        WorldCountry.maybeFromAnyCode(countryCode?.trim()) ??
        const CountryPhl();
    return optionForCountry(country);
  }

  static CountryOption countryFromLocation(Location? location) {
    final countryCode = location?.countryShortName?.trim();
    if (countryCode?.isNotEmpty == true) {
      return countryFromCode(countryCode);
    }

    final countryName = location?.country?.trim().toLowerCase();
    if (countryName?.isNotEmpty == true) {
      return countries.firstWhere(
        (option) => option.countryName.toLowerCase() == countryName,
        orElse: () => fallbackCountry,
      );
    }

    return fallbackCountry;
  }

  static CountryOption optionForCountry(WorldCountry country) {
    return countries.firstWhere(
      (option) => option.countryCode == country.codeShort,
      orElse:
          () => CountryOption(
            country: country,
            currency:
                country.currencies?.isNotEmpty == true
                    ? country.currencies!.first
                    : null,
          ),
    );
  }

  static List<CountryOption> search({
    required String query,
    required bool currencyOnly,
  }) {
    final normalized = query.trim().toLowerCase();
    final source =
        currencyOnly
            ? countries.where((option) => option.currency != null)
            : countries;

    if (normalized.isEmpty) return source.toList();

    return source.where((option) {
      final searchText =
          currencyOnly ? option.currencySearchText : option.iddSearchText;
      return searchText.toLowerCase().contains(normalized);
    }).toList();
  }

  static String e164PhoneNumber({
    required String localNumber,
    required CountryOption country,
  }) {
    final digits = localNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final prefix = country.phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith(prefix)) return '+$digits';
    return '+$prefix$digits';
  }
}
