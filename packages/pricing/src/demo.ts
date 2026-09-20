import { calculateBond, InputError, money } from './index.ts';

export const demoQuotes = [
  { id: 'demo-a', broker: 'Демо-партнер A', asset: 'DEMO-UAH-2027', price: '850.00', fee: '100.00', available: 500 },
  { id: 'demo-b', broker: 'Демо-партнер B', asset: 'DEMO-UAH-2027', price: '852.00', fee: '0.00', available: 800 },
  { id: 'demo-c', broker: 'Демо-партнер C', asset: 'DEMO-UAH-2027', price: '848.00', fee: '500.00', available: 200 }
] as const;

export function compareDemo(budget: string) {
  const amount = money(budget);
  if (amount.lte(0) || amount.gt('100000000')) throw new InputError('Budget must be between 0.01 and 100000000');
  const results = demoQuotes.map(quote => {
    const affordable = amount.minus(quote.fee).div(quote.price).floor().toNumber();
    const quantity = Math.max(0, Math.min(affordable, quote.available));
    if (!quantity) return { quoteId: quote.id, broker: quote.broker, eligible: false as const, reason: 'INSUFFICIENT_BUDGET' };
    const calculation = calculateBond({
      quantity, cleanPrice: quote.price, accruedInterest: '0', upfrontFee: quote.fee,
      settlementDate: '2026-09-22', payments: [{ date: '2027-09-22', amount: '1000.00' }]
    });
    return { quoteId: quote.id, broker: quote.broker, eligible: true as const,
      ...calculation, uninvestedCash: amount.minus(calculation.initialOutflow).toFixed(2) };
  }).sort((a, b) => {
    if (!a.eligible) return b.eligible ? 1 : 0;
    if (!b.eligible) return -1;
    return Number(b.netXirr) - Number(a.netXirr);
  });
  return { dataMode: 'SYNTHETIC', executable: false, currency: 'UAH',
    settlementDate: '2026-09-22', maturityDate: '2027-09-22',
    assumptions: ['Discount bond; nominal 1000 UAH', 'Zero tax scenario; no recurring fees', 'Idle cash excluded from position XIRR'],
    results };
}
