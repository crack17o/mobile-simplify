/// Taux de change défini par l'admin (USD ↔ CDF).
/// En production : chargé depuis l'API / config admin.
class ConversionRate {
  ConversionRate._();

  /// 1 USD = X CDF (taux admin, ex. 2850)
  static const double usdToCdf = 2850.0;

  /// 1 CDF = X USD (inverse)
  static double get cdfToUsd => 1.0 / usdToCdf;

  static String formatCdf(double amount) {
    final s = amount.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf} CDF';
  }

  static String formatUsd(double amount) =>
      '\$${amount.toStringAsFixed(2)} USD';
}
