import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/formatters.dart';

class CountryCurrency {
  final String country;
  final String flag;
  final String currency;
  final String symbol;
  const CountryCurrency({
    required this.country,
    required this.flag,
    required this.currency,
    required this.symbol,
  });
}

class SettingsProvider extends ChangeNotifier {
  static const _keyCountry = 'pref_country';

  // ── 195 UN-recognised countries + major territories, sorted A→Z ──────────
  static const List<CountryCurrency> allCountries = [
    CountryCurrency(country: 'Afghanistan',           flag: '🇦🇫', currency: 'AFN', symbol: '؋'),
    CountryCurrency(country: 'Albania',               flag: '🇦🇱', currency: 'ALL', symbol: 'L'),
    CountryCurrency(country: 'Algeria',               flag: '🇩🇿', currency: 'DZD', symbol: 'DA'),
    CountryCurrency(country: 'Angola',                flag: '🇦🇴', currency: 'AOA', symbol: 'Kz'),
    CountryCurrency(country: 'Argentina',             flag: '🇦🇷', currency: 'ARS', symbol: '\$'),
    CountryCurrency(country: 'Armenia',               flag: '🇦🇲', currency: 'AMD', symbol: '֏'),
    CountryCurrency(country: 'Australia',             flag: '🇦🇺', currency: 'AUD', symbol: 'A\$'),
    CountryCurrency(country: 'Austria',               flag: '🇦🇹', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Azerbaijan',            flag: '🇦🇿', currency: 'AZN', symbol: '₼'),
    CountryCurrency(country: 'Bahrain',               flag: '🇧🇭', currency: 'BHD', symbol: 'BD'),
    CountryCurrency(country: 'Bangladesh',            flag: '🇧🇩', currency: 'BDT', symbol: '৳'),
    CountryCurrency(country: 'Belarus',               flag: '🇧🇾', currency: 'BYN', symbol: 'Br'),
    CountryCurrency(country: 'Belgium',               flag: '🇧🇪', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Belize',                flag: '🇧🇿', currency: 'BZD', symbol: 'BZ\$'),
    CountryCurrency(country: 'Bolivia',               flag: '🇧🇴', currency: 'BOB', symbol: 'Bs'),
    CountryCurrency(country: 'Bosnia & Herzegovina',  flag: '🇧🇦', currency: 'BAM', symbol: 'KM'),
    CountryCurrency(country: 'Botswana',              flag: '🇧🇼', currency: 'BWP', symbol: 'P'),
    CountryCurrency(country: 'Brazil',                flag: '🇧🇷', currency: 'BRL', symbol: 'R\$'),
    CountryCurrency(country: 'Brunei',                flag: '🇧🇳', currency: 'BND', symbol: 'B\$'),
    CountryCurrency(country: 'Bulgaria',              flag: '🇧🇬', currency: 'BGN', symbol: 'лв'),
    CountryCurrency(country: 'Cambodia',              flag: '🇰🇭', currency: 'KHR', symbol: '៛'),
    CountryCurrency(country: 'Cameroon',              flag: '🇨🇲', currency: 'XAF', symbol: 'FCFA'),
    CountryCurrency(country: 'Canada',                flag: '🇨🇦', currency: 'CAD', symbol: 'C\$'),
    CountryCurrency(country: 'Chile',                 flag: '🇨🇱', currency: 'CLP', symbol: '\$'),
    CountryCurrency(country: 'China',                 flag: '🇨🇳', currency: 'CNY', symbol: '¥'),
    CountryCurrency(country: 'Colombia',              flag: '🇨🇴', currency: 'COP', symbol: '\$'),
    CountryCurrency(country: 'Congo (DR)',            flag: '🇨🇩', currency: 'CDF', symbol: 'FC'),
    CountryCurrency(country: 'Costa Rica',            flag: '🇨🇷', currency: 'CRC', symbol: '₡'),
    CountryCurrency(country: 'Croatia',               flag: '🇭🇷', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Cuba',                  flag: '🇨🇺', currency: 'CUP', symbol: '\$'),
    CountryCurrency(country: 'Cyprus',                flag: '🇨🇾', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Czech Republic',        flag: '🇨🇿', currency: 'CZK', symbol: 'Kč'),
    CountryCurrency(country: 'Denmark',               flag: '🇩🇰', currency: 'DKK', symbol: 'kr'),
    CountryCurrency(country: 'Dominican Republic',    flag: '🇩🇴', currency: 'DOP', symbol: 'RD\$'),
    CountryCurrency(country: 'Ecuador',               flag: '🇪🇨', currency: 'USD', symbol: '\$'),
    CountryCurrency(country: 'Egypt',                 flag: '🇪🇬', currency: 'EGP', symbol: '£'),
    CountryCurrency(country: 'El Salvador',           flag: '🇸🇻', currency: 'USD', symbol: '\$'),
    CountryCurrency(country: 'Estonia',               flag: '🇪🇪', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Ethiopia',              flag: '🇪🇹', currency: 'ETB', symbol: 'Br'),
    CountryCurrency(country: 'Finland',               flag: '🇫🇮', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'France',                flag: '🇫🇷', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Georgia',               flag: '🇬🇪', currency: 'GEL', symbol: '₾'),
    CountryCurrency(country: 'Germany',               flag: '🇩🇪', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Ghana',                 flag: '🇬🇭', currency: 'GHS', symbol: '₵'),
    CountryCurrency(country: 'Greece',                flag: '🇬🇷', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Guatemala',             flag: '🇬🇹', currency: 'GTQ', symbol: 'Q'),
    CountryCurrency(country: 'Honduras',              flag: '🇭🇳', currency: 'HNL', symbol: 'L'),
    CountryCurrency(country: 'Hong Kong',             flag: '🇭🇰', currency: 'HKD', symbol: 'HK\$'),
    CountryCurrency(country: 'Hungary',               flag: '🇭🇺', currency: 'HUF', symbol: 'Ft'),
    CountryCurrency(country: 'Iceland',               flag: '🇮🇸', currency: 'ISK', symbol: 'kr'),
    CountryCurrency(country: 'India',                 flag: '🇮🇳', currency: 'INR', symbol: '₹'),
    CountryCurrency(country: 'Indonesia',             flag: '🇮🇩', currency: 'IDR', symbol: 'Rp'),
    CountryCurrency(country: 'Iran',                  flag: '🇮🇷', currency: 'IRR', symbol: '﷼'),
    CountryCurrency(country: 'Iraq',                  flag: '🇮🇶', currency: 'IQD', symbol: 'IQD'),
    CountryCurrency(country: 'Ireland',               flag: '🇮🇪', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Israel',                flag: '🇮🇱', currency: 'ILS', symbol: '₪'),
    CountryCurrency(country: 'Italy',                 flag: '🇮🇹', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Jamaica',               flag: '🇯🇲', currency: 'JMD', symbol: 'J\$'),
    CountryCurrency(country: 'Japan',                 flag: '🇯🇵', currency: 'JPY', symbol: '¥'),
    CountryCurrency(country: 'Jordan',                flag: '🇯🇴', currency: 'JOD', symbol: 'JD'),
    CountryCurrency(country: 'Kazakhstan',            flag: '🇰🇿', currency: 'KZT', symbol: '₸'),
    CountryCurrency(country: 'Kenya',                 flag: '🇰🇪', currency: 'KES', symbol: 'KSh'),
    CountryCurrency(country: 'Kuwait',                flag: '🇰🇼', currency: 'KWD', symbol: 'KD'),
    CountryCurrency(country: 'Kyrgyzstan',            flag: '🇰🇬', currency: 'KGS', symbol: 'som'),
    CountryCurrency(country: 'Laos',                  flag: '🇱🇦', currency: 'LAK', symbol: '₭'),
    CountryCurrency(country: 'Latvia',                flag: '🇱🇻', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Lebanon',               flag: '🇱🇧', currency: 'LBP', symbol: 'LL'),
    CountryCurrency(country: 'Libya',                 flag: '🇱🇾', currency: 'LYD', symbol: 'LD'),
    CountryCurrency(country: 'Lithuania',             flag: '🇱🇹', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Luxembourg',            flag: '🇱🇺', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Macau',                 flag: '🇲🇴', currency: 'MOP', symbol: 'P'),
    CountryCurrency(country: 'Madagascar',            flag: '🇲🇬', currency: 'MGA', symbol: 'Ar'),
    CountryCurrency(country: 'Malaysia',              flag: '🇲🇾', currency: 'MYR', symbol: 'RM'),
    CountryCurrency(country: 'Maldives',              flag: '🇲🇻', currency: 'MVR', symbol: 'Rf'),
    CountryCurrency(country: 'Mexico',                flag: '🇲🇽', currency: 'MXN', symbol: '\$'),
    CountryCurrency(country: 'Moldova',               flag: '🇲🇩', currency: 'MDL', symbol: 'L'),
    CountryCurrency(country: 'Mongolia',              flag: '🇲🇳', currency: 'MNT', symbol: '₮'),
    CountryCurrency(country: 'Morocco',               flag: '🇲🇦', currency: 'MAD', symbol: 'MAD'),
    CountryCurrency(country: 'Mozambique',            flag: '🇲🇿', currency: 'MZN', symbol: 'MT'),
    CountryCurrency(country: 'Myanmar',               flag: '🇲🇲', currency: 'MMK', symbol: 'K'),
    CountryCurrency(country: 'Namibia',               flag: '🇳🇦', currency: 'NAD', symbol: 'N\$'),
    CountryCurrency(country: 'Nepal',                 flag: '🇳🇵', currency: 'NPR', symbol: 'Rs'),
    CountryCurrency(country: 'Netherlands',           flag: '🇳🇱', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'New Zealand',           flag: '🇳🇿', currency: 'NZD', symbol: 'NZ\$'),
    CountryCurrency(country: 'Nicaragua',             flag: '🇳🇮', currency: 'NIO', symbol: 'C\$'),
    CountryCurrency(country: 'Nigeria',               flag: '🇳🇬', currency: 'NGN', symbol: '₦'),
    CountryCurrency(country: 'North Korea',           flag: '🇰🇵', currency: 'KPW', symbol: '₩'),
    CountryCurrency(country: 'Norway',                flag: '🇳🇴', currency: 'NOK', symbol: 'kr'),
    CountryCurrency(country: 'Oman',                  flag: '🇴🇲', currency: 'OMR', symbol: 'OMR'),
    CountryCurrency(country: 'Pakistan',              flag: '🇵🇰', currency: 'PKR', symbol: 'Rs'),
    CountryCurrency(country: 'Panama',                flag: '🇵🇦', currency: 'PAB', symbol: 'B/.'),
    CountryCurrency(country: 'Paraguay',              flag: '🇵🇾', currency: 'PYG', symbol: '₲'),
    CountryCurrency(country: 'Peru',                  flag: '🇵🇪', currency: 'PEN', symbol: 'S/'),
    CountryCurrency(country: 'Philippines',           flag: '🇵🇭', currency: 'PHP', symbol: '₱'),
    CountryCurrency(country: 'Poland',                flag: '🇵🇱', currency: 'PLN', symbol: 'zł'),
    CountryCurrency(country: 'Portugal',              flag: '🇵🇹', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Qatar',                 flag: '🇶🇦', currency: 'QAR', symbol: 'QR'),
    CountryCurrency(country: 'Romania',               flag: '🇷🇴', currency: 'RON', symbol: 'lei'),
    CountryCurrency(country: 'Russia',                flag: '🇷🇺', currency: 'RUB', symbol: '₽'),
    CountryCurrency(country: 'Rwanda',                flag: '🇷🇼', currency: 'RWF', symbol: 'RF'),
    CountryCurrency(country: 'Saudi Arabia',          flag: '🇸🇦', currency: 'SAR', symbol: 'SR'),
    CountryCurrency(country: 'Senegal',               flag: '🇸🇳', currency: 'XOF', symbol: 'CFA'),
    CountryCurrency(country: 'Serbia',                flag: '🇷🇸', currency: 'RSD', symbol: 'din'),
    CountryCurrency(country: 'Singapore',             flag: '🇸🇬', currency: 'SGD', symbol: 'S\$'),
    CountryCurrency(country: 'Slovakia',              flag: '🇸🇰', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Somalia',               flag: '🇸🇴', currency: 'SOS', symbol: 'Sh'),
    CountryCurrency(country: 'South Africa',          flag: '🇿🇦', currency: 'ZAR', symbol: 'R'),
    CountryCurrency(country: 'South Korea',           flag: '🇰🇷', currency: 'KRW', symbol: '₩'),
    CountryCurrency(country: 'Spain',                 flag: '🇪🇸', currency: 'EUR', symbol: '€'),
    CountryCurrency(country: 'Sri Lanka',             flag: '🇱🇰', currency: 'LKR', symbol: 'Rs'),
    CountryCurrency(country: 'Sudan',                 flag: '🇸🇩', currency: 'SDG', symbol: 'SDG'),
    CountryCurrency(country: 'Sweden',                flag: '🇸🇪', currency: 'SEK', symbol: 'kr'),
    CountryCurrency(country: 'Switzerland',           flag: '🇨🇭', currency: 'CHF', symbol: 'Fr'),
    CountryCurrency(country: 'Syria',                 flag: '🇸🇾', currency: 'SYP', symbol: '£'),
    CountryCurrency(country: 'Taiwan',                flag: '🇹🇼', currency: 'TWD', symbol: 'NT\$'),
    CountryCurrency(country: 'Tajikistan',            flag: '🇹🇯', currency: 'TJS', symbol: 'SM'),
    CountryCurrency(country: 'Tanzania',              flag: '🇹🇿', currency: 'TZS', symbol: 'TSh'),
    CountryCurrency(country: 'Thailand',              flag: '🇹🇭', currency: 'THB', symbol: '฿'),
    CountryCurrency(country: 'Tunisia',               flag: '🇹🇳', currency: 'TND', symbol: 'DT'),
    CountryCurrency(country: 'Turkey',                flag: '🇹🇷', currency: 'TRY', symbol: '₺'),
    CountryCurrency(country: 'Turkmenistan',          flag: '🇹🇲', currency: 'TMT', symbol: 'T'),
    CountryCurrency(country: 'UAE',                   flag: '🇦🇪', currency: 'AED', symbol: 'AED'),
    CountryCurrency(country: 'Uganda',                flag: '🇺🇬', currency: 'UGX', symbol: 'USh'),
    CountryCurrency(country: 'Ukraine',               flag: '🇺🇦', currency: 'UAH', symbol: '₴'),
    CountryCurrency(country: 'United Kingdom',        flag: '🇬🇧', currency: 'GBP', symbol: '£'),
    CountryCurrency(country: 'United States',         flag: '🇺🇸', currency: 'USD', symbol: '\$'),
    CountryCurrency(country: 'Uruguay',               flag: '🇺🇾', currency: 'UYU', symbol: '\$U'),
    CountryCurrency(country: 'Uzbekistan',            flag: '🇺🇿', currency: 'UZS', symbol: 'soʻm'),
    CountryCurrency(country: 'Venezuela',             flag: '🇻🇪', currency: 'VES', symbol: 'Bs'),
    CountryCurrency(country: 'Vietnam',               flag: '🇻🇳', currency: 'VND', symbol: '₫'),
    CountryCurrency(country: 'Yemen',                 flag: '🇾🇪', currency: 'YER', symbol: '﷼'),
    CountryCurrency(country: 'Zambia',                flag: '🇿🇲', currency: 'ZMW', symbol: 'ZK'),
    CountryCurrency(country: 'Zimbabwe',              flag: '🇿🇼', currency: 'ZWL', symbol: 'Z\$'),
  ];

  CountryCurrency _selected = allCountries.firstWhere(
    (c) => c.country == 'Sri Lanka',
    orElse: () => allCountries.first,
  );

  CountryCurrency get selected   => _selected;
  String get currencySymbol      => _selected.symbol;
  String get countryFlag         => _selected.flag;
  String get countryName         => _selected.country;
  String get currencyCode        => _selected.currency;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name  = prefs.getString(_keyCountry);
    if (name != null) {
      final matches = allCountries.where((c) => c.country == name);
      if (matches.isNotEmpty) {
        _selected = matches.first;
        Formatters.currencySymbol = _selected.symbol;
        notifyListeners();
      }
    } else {
      // First launch — apply default symbol
      Formatters.currencySymbol = _selected.symbol;
    }
  }

  Future<void> setCountry(CountryCurrency cc) async {
    _selected = cc;
    Formatters.currencySymbol = cc.symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCountry, cc.country);
    notifyListeners();
  }
}
