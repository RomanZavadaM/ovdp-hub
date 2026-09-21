import 'package:flutter_test/flutter_test.dart';
import 'package:ovdp_hub/pricing.dart';
import 'package:ovdp_hub/models.dart';

void main() {
  test(
    'reference discount bond matches TypeScript reference amounts and yield',
    () {
      final r = calculateBond(
        quantity: 117,
        cleanPrice: '850',
        accruedInterest: '0',
        fee: '100',
        settlement: '2026-09-22',
        payments: [
          {'date': '2027-09-22', 'amount': '1000'},
        ],
      );
      expect(r.cost.toStringAsFixed(2), '99550.00');
      expect(r.profit.toStringAsFixed(2), '17450.00');
      expect(r.yield, closeTo(17450 / 99550, 1e-9));
    },
  );
  test('coupon cashflows and accrued interest included exactly once', () {
    final r = calculateBond(
      quantity: 2,
      cleanPrice: '1000',
      accruedInterest: '30',
      fee: '10',
      settlement: '2026-09-22',
      payments: [
        {'date': '2027-03-22', 'amount': '80'},
        {'date': '2027-09-22', 'amount': '1080'},
      ],
    );
    expect(r.cost.toStringAsFixed(2), '2070.00');
    expect(r.receipts.toStringAsFixed(2), '2320.00');
    expect(r.profit.toStringAsFixed(2), '250.00');
  });
  test('rejects impossible dates and negative monetary input', () {
    expect(() => isoDate('2026-02-30'), throwsFormatException);
    expect(() => money('-1'), throwsFormatException);
    expect(() => money('NaN'), throwsFormatException);
  });
  test('loss and zero yield', () {
    for (final payment in ['90', '100']) {
      final r = calculateBond(
        quantity: 1,
        cleanPrice: '100',
        accruedInterest: '0',
        fee: '0',
        settlement: '2026-01-01',
        payments: [
          {'date': '2027-01-01', 'amount': payment},
        ],
      );
      expect(r.yield, closeTo(payment == '90' ? -0.1 : 0, 1e-9));
    }
  });
}
