enum PaymentType { card, bankTransfer, wallet, cash }

class PaymentMethodEntity {
  final String id;
  final PaymentType type;
  final String label;      // e.g. '**** 4321', 'GTBank', 'Cash'
  final bool isDefault;

  const PaymentMethodEntity({
    required this.id, required this.type, required this.label, this.isDefault = false,
  });
}
