class EarningsEntity {
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double total;
  final List<EarningsEntry> entries;

  const EarningsEntity({
    required this.today, required this.thisWeek,
    required this.thisMonth, required this.total, required this.entries,
  });
}

class EarningsEntry {
  final String rideId;
  final double amount;
  final DateTime date;
  const EarningsEntry({required this.rideId, required this.amount, required this.date});
}
