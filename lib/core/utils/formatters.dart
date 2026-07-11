class Formatters {
  Formatters._();

  static String currency(double amount, {String symbol = '₦'}) {
    return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  static String phone(String s) {
    var d = s.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (d.startsWith('+234')) return d;
    if (d.startsWith('0')) d = d.substring(1);
    return '+234$d';
  }

  static String distance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String duration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    if (m < 60) return '$m min';
    return '${m ~/ 60}h ${m % 60}min';
  }
}
