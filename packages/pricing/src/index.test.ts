import test from 'node:test';
import assert from 'node:assert/strict';
import { calculateBond, dateValue, xirr } from './index.ts';
import { compareDemo } from './demo.ts';

const base = { quantity: 117, cleanPrice: '850.00', accruedInterest: '0', upfrontFee: '100.00', settlementDate: '2026-09-22', payments: [{ date: '2027-09-22', amount: '1000.00' }] };
test('reference discount bond includes fees exactly', () => {
  const result = calculateBond(base);
  assert.equal(result.initialOutflow, '99550.00');
  assert.equal(result.netProfit, '17450.00');
  assert.ok(Math.abs(Number(result.netXirr) - 17450 / 99550) < 1e-9);
});
test('coupon cashflows and accrued interest are included once', () => {
  const result = calculateBond({ ...base, quantity: 2, cleanPrice: '1000', accruedInterest: '30', upfrontFee: '10', payments: [{ date: '2027-03-22', amount: '80' }, { date: '2027-09-22', amount: '1080' }] });
  assert.equal(result.initialOutflow, '2070.00');
  assert.equal(result.futureNetReceipts, '2320.00');
  assert.equal(result.netProfit, '250.00');
});
test('reject invalid dates, fractions and same-day payments', () => {
  assert.throws(() => dateValue('2026-02-30'));
  assert.throws(() => calculateBond({ ...base, quantity: 1.5 }));
  assert.throws(() => calculateBond({ ...base, payments: [{ date: base.settlementDate, amount: '1000' }] }));
});
test('supports losses and zero yield', () => {
  assert.equal(xirr([{date:'2026-01-01',amount:'-100'},{date:'2027-01-01',amount:'90'}]), '-0.1000000000');
  assert.equal(xirr([{date:'2026-01-01',amount:'-100'},{date:'2027-01-01',amount:'100'}]), '0.0000000000');
});
test('rejects unsupported multi-sign flows', () => {
  assert.throws(() => xirr([{date:'2026-01-01',amount:'-100'},{date:'2027-01-01',amount:'-10'}]));
});
test('comparison respects budget, fees and liquidity', () => {
  const response = compareDemo('100000');
  assert.equal(response.results[0].quoteId, 'demo-a');
  for (const item of response.results) if(item.eligible) assert.ok(Number(item.initialOutflow) <= 100000);
  assert.ok(compareDemo('1').results.every(r => !r.eligible));
  assert.ok(compareDemo('1000000').results.some(r => r.eligible && r.quantity === 200));
  assert.throws(() => compareDemo('NaN'));
  assert.throws(() => compareDemo('-1'));
});
