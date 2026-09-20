export const NBU_URL = 'https://bank.gov.ua/depo_securities?json';
export const SOURCE_PAGE = 'https://bank.gov.ua/ua/markets/ovdp';
export type Payment = { date: string; kind: 'COUPON' | 'REDEMPTION' | 'EARLY_REDEMPTION'; amount: string };
export type Asset = { isin: string; currency: string; nominal: string; nominalRate: string | null; issueDate: string; maturityDate: string; description: string; couponPeriodDays: number | null; payments: Payment[] };
export type Snapshot = { schemaVersion: 1; source: string; sourcePage: string; retrievedAt: string; sourceAsOf: null; assets: Asset[]; excludedCount: number; rejected: { index: number; reason: string }[] };
type Row = Record<string, unknown>;
function row(value: unknown): Row {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error('Expected object');
  return value as Row;
}
function date(value: unknown): string {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) throw new Error('Invalid date');
  const stamp = Date.parse(value + 'T00:00:00Z');
  if (!Number.isFinite(stamp) || new Date(stamp).toISOString().slice(0,10) !== value) throw new Error('Invalid calendar date');
  return value;
}
function decimal(value: unknown): string {
  if (typeof value !== 'number' && typeof value !== 'string') throw new Error('Missing decimal');
  const text = String(value);
  if (!/^\d{1,15}(\.\d{1,10})?$/.test(text) || !Number.isFinite(Number(text))) throw new Error('Invalid decimal');
  return text;
}
export function normalizeNbu(payload: unknown, retrievedAt: string): Snapshot {
  if (!Number.isFinite(Date.parse(retrievedAt))) throw new Error('Invalid retrieval timestamp');
  if (!Array.isArray(payload) || !payload.length || payload.length > 10000) throw new Error('Invalid source envelope');
  const assets: Asset[] = [];
  const rejected: Snapshot['rejected'] = [];
  const seen = new Set<string>();
  let excludedCount = 0;
  payload.forEach((value, index) => {
    let item: Asset;
    try {
      const r = row(value);
      if (r.cptype === 'OZDP' || r.cptype === 'OMP') { excludedCount++; return; }
      if (r.cptype !== 'DCP' || r.emit_okpo !== '00013480') throw new Error('Unsupported instrument or issuer');
      if (typeof r.cpcode !== 'string' || !/^UA[A-Z0-9]{9}\d$/.test(r.cpcode)) throw new Error('Invalid domestic ISIN');
      if (!['UAH','USD','EUR'].includes(String(r.val_code))) throw new Error('Unsupported currency');
      if (!Array.isArray(r.payments)) throw new Error('Missing payment schedule');
      const payments = r.payments.map(value => {
        const p = row(value);
        const kinds: Record<string, Payment['kind']> = { '1':'COUPON', '2':'REDEMPTION', '3':'EARLY_REDEMPTION' };
        const kind = kinds[String(p.pay_type)];
        if (!kind) throw new Error('Unknown payment type');
        return { date: date(p.pay_date), kind, amount: decimal(p.pay_val) };
      }).sort((a,b) => a.date.localeCompare(b.date) || a.kind.localeCompare(b.kind));
      const issueDate = date(r.razm_date), maturityDate = date(r.pgs_date);
      if (issueDate >= maturityDate) throw new Error('Invalid instrument dates');
      const nominal = decimal(r.nominal);
      if (Number(nominal) <= 0) throw new Error('Nonpositive nominal');
      item = { isin:r.cpcode, currency:String(r.val_code), nominal, nominalRate:r.auk_proc == null ? null : decimal(r.auk_proc),
        issueDate, maturityDate, description:typeof r.cpdescr === 'string' ? r.cpdescr : '',
        couponPeriodDays:Number.isInteger(r.pay_period) && Number(r.pay_period) > 0 ? Number(r.pay_period) : null, payments };
    } catch (error) { rejected.push({index,reason:error instanceof Error ? error.message : 'Invalid record'}); return; }
    if (seen.has(item.isin)) throw new Error('Duplicate ISIN: source snapshot rejected');
    seen.add(item.isin); assets.push(item);
  });
  if (!assets.length) throw new Error('No valid domestic government bonds');
  assets.sort((a,b) => a.maturityDate.localeCompare(b.maturityDate) || a.isin.localeCompare(b.isin));
  return { schemaVersion:1, source:NBU_URL, sourcePage:SOURCE_PAGE, retrievedAt, sourceAsOf:null, assets, excludedCount, rejected };
}
export function freshness(retrievedAt: string, now: number): 'RECENT' | 'STALE' | 'UNKNOWN' {
  const stamp = Date.parse(retrievedAt), age = now - stamp;
  if (!Number.isFinite(age) || age < -300000) return 'UNKNOWN';
  return age > 86400000 ? 'STALE' : 'RECENT';
}
export function filterAssets(assets: Asset[], options: { query: string; currency: string; activeOnly: boolean; today: string }) {
  const q = options.query.trim().toUpperCase();
  return assets.filter(a => a.isin.includes(q) && (!options.currency || a.currency === options.currency) &&
    (!options.activeOnly || a.maturityDate >= options.today));
}
export async function fetchNbu(signal?: AbortSignal): Promise<Snapshot> {
  const response = await fetch(NBU_URL, { signal, credentials:'omit', referrerPolicy:'no-referrer', cache:'no-store' });
  if (!response.ok) throw new Error('NBU HTTP ' + response.status);
  return normalizeNbu(await response.json(), new Date().toISOString());
}
