import 'package:sealed_countries/sealed_countries.dart';

class CountryOption {
  final WorldCountry country;
  final FiatCurrency? currency;

  const CountryOption({required this.country, this.currency});

  String get countryCode => country.codeShort;
  String get countryName => country.name.common;
  String get flag => country.emoji;
  String get phoneCode => country.idd.phoneCode();
  String get iddButtonText => '$flag $phoneCode';
  String get iddSearchText =>
      '$countryName ${country.code} ${country.codeShort} $phoneCode';
  String get phoneHint {
    final nationalPrefix = phoneCode.replaceAll(RegExp(r'[^0-9]'), '');
    final firstDigit = switch (country.codeShort) {
      'PH' => '9',
      'US' || 'CA' => '2',
      'GB' => '7',
      'AU' => '4',
      'SG' => '8',
      'MY' => '1',
      'ID' => '8',
      'JP' => '9',
      _ =>
        nationalPrefix.isEmpty
            ? '1'
            : nationalPrefix.substring(nationalPrefix.length - 1),
    };
    return '$firstDigit•• ••• ••••';
  }

  String get currencyCode => currency?.code ?? '';
  String get currencyName => currency?.name ?? '';
  String get currencySymbol => currency?.symbol ?? currencyCode;
  String get currencyValue =>
      currency == null
          ? 'No official currency'
          : '$currencyCode · $currencyName';
  String get currencyPrefix => currencyCode.isEmpty ? 'PHP ' : '$currencyCode ';
  String get currencySearchText =>
      '$countryName ${country.code} ${country.codeShort} $currencyCode $currencyName $currencySymbol';
}
