import { Decimal } from 'decimal.js';

const D = Decimal.clone({ precision: 40, rounding: Decimal.ROUND_HALF_UP });
export type Cashflow = { date: string; amount: string };
export type BondInput = {
  quantity: number;
  cleanPrice: string;
  accruedInterest: string;
  upfrontFee: string;
  settlementDate: string;
  payments: Cashflow[]; // Net, per-unit payments. Tax/fee policy is caller-owned.
};
export class InputError extends Error {}

export function dateValue(value: string): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) throw new InputError('Invalid ISO date');
  const time = Date.parse(value + 'T00:00:00Z');
  if (!Number.isFinite(time) || new Date(time).toISOString().slice(0, 10) !== value)
    throw new InputError('Invalid calendar date');
  return time;
}

export function money(value: string): Decimal {
  if (typeof value !== 'string' || !/^\d{1,12}(\.\d{1,8})?$/.test(value))
    throw new InputError('Money must be a non-negative decimal string');
  return new D(value);
}

// Restricted to conventional investments: one initial outflow, later non-negative receipts.
// This gives a unique root; arbitrary multi-sign cashflows are intentionally rejected.
export function xirr(flows: Cashflow[]): string {
  if (flows.length < 2) throw new InputError('At least two cashflows required');
  const start = dateValue(flows[0].date);
  const initial = new D(flows[0].amount);
  if (!initial.isFinite() || initial.gte(0)) throw new InputError('Initial outflow required');
  const future = flows.slice(1).map(f => {
    const days = (dateValue(f.date) - start) / 86400000;
    const amount = money(f.amount);
    if (days <= 0) throw new InputError('Payment must follow settlement');
    return { years: new D(days).div(365), amount };
  });
  if (!future.some(f => f.amount.gt(0))) throw new InputError('Positive receipt required');
  const npv = (rate: Decimal) => future.reduce(
    (sum, f) => sum.plus(f.amount.div(rate.plus(1).pow(f.years))), initial);
  let low = new D('-0.999999');
  let high = new D(1);
  while (npv(high).gt(0) && high.lt('1000000')) high = high.mul(2);
  if (npv(low).lt(0) || npv(high).gt(0)) throw new InputError('Yield outside supported range');
  for (let i = 0; i < 150; i++) {
    const middle = low.plus(high).div(2);
    if (npv(middle).gt(0)) low = middle; else high = middle;
  }
  const result = low.plus(high).div(2).toDecimalPlaces(10);
  return result.isZero() ? '0.0000000000' : result.toFixed(10);
}

export function calculateBond(input: BondInput) {
  if (!Number.isSafeInteger(input.quantity) || input.quantity < 1 || input.quantity > 1000000)
    throw new InputError('Quantity must be an integer from 1 to 1000000');
  dateValue(input.settlementDate);
  if (!Array.isArray(input.payments) || input.payments.length < 1 || input.payments.length > 100)
    throw new InputError('Provide 1 to 100 payments');
  const dirty = money(input.cleanPrice).plus(money(input.accruedInterest));
  if (dirty.lte(0)) throw new InputError('Price must be positive');
  const cost = dirty.mul(input.quantity).toDecimalPlaces(2);
  const total = cost.plus(money(input.upfrontFee).toDecimalPlaces(2));
  const cashflows = [
    { date: input.settlementDate, amount: total.neg().toFixed(2) },
    ...input.payments.map(p => ({ date: p.date, amount: money(p.amount).mul(input.quantity).toFixed(2) }))
  ];
  const receipts = cashflows.slice(1).reduce((sum, f) => sum.plus(f.amount), new D(0));
  return {
    quantity: input.quantity,
    dirtyPrice: dirty.toFixed(8),
    securitiesCost: cost.toFixed(2),
    upfrontFee: money(input.upfrontFee).toFixed(2),
    initialOutflow: total.toFixed(2),
    futureNetReceipts: receipts.toFixed(2),
    netProfit: receipts.minus(total).toFixed(2),
    netXirr: xirr(cashflows),
    cashflows,
    methodology: 'NET_XIRR_ACT_365F',
    engineVersion: '0.1.0'
  };
}

