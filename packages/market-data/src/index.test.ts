import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { normalizeNbu, freshness, filterAssets, fetchNbu } from './index.ts';
const fixture = JSON.parse(readFileSync(new URL('../fixtures/nbu-sample.json', import.meta.url), 'utf8'));
const at = '2026-09-20T19:43:04Z';
test('official fixture maps coupons and redemption without conflating yield', () => {
  const s = normalizeNbu(fixture, at);
  assert.equal(s.assets.length, 1); assert.equal(s.excludedCount, 1);
  assert.equal(s.assets[0].nominalRate, '12.5');
  assert.equal(s.assets[0].payments.at(-1)?.kind, 'REDEMPTION');
  assert.equal(s.assets[0].payments.at(-1)?.amount, '1000');
  assert.equal(s.sourceAsOf, null);
});
test('invalid row quarantined; unknown amounts are not zero', () => {
  const broken = {...fixture[0], cpcode:'UA4000187355', nominal:null};
  const s = normalizeNbu([...fixture, broken], at);
  assert.equal(s.assets.length,1); assert.equal(s.rejected.length,1);
  assert.throws(() => normalizeNbu([broken],at));
});
test('duplicates, invalid dates, payment types and envelopes fail safely', () => {
  assert.throws(() => normalizeNbu([fixture[0],fixture[0]],at));
  assert.throws(() => normalizeNbu([{...fixture[0],pgs_date:'2026-02-30'}],at));
  assert.throws(() => normalizeNbu([{...fixture[0],payments:[{pay_date:'2027-01-01',pay_val:1,pay_type:'9'}]}],at));
  assert.throws(() => normalizeNbu({error:'maintenance'},at));
});
test('source receipt freshness does not imply source as-of freshness', () => {
  assert.equal(freshness(at,Date.parse(at)+1000),'RECENT');
  assert.equal(freshness(at,Date.parse(at)+86400001),'STALE');
  assert.equal(freshness('bad',Date.parse(at)),'UNKNOWN');
  assert.equal(freshness(at,Date.parse(at)-600000),'UNKNOWN');
});
test('search, currency and maturity filters are local and compose', () => {
  const s = normalizeNbu(fixture,at);
  assert.equal(filterAssets(s.assets,{query:'  ua400018 ',currency:'UAH',activeOnly:true,today:'2026-09-20'}).length,1);
  assert.equal(filterAssets(s.assets,{query:'',currency:'USD',activeOnly:true,today:'2026-09-20'}).length,0);
  assert.equal(filterAssets(s.assets,{query:'',currency:'',activeOnly:true,today:'2030-01-01'}).length,0);
});
test('direct fetch omits credentials and referrer; source failure rejects', async t => {
  t.mock.method(globalThis,'fetch',async (url, options) => {
    assert.equal(url,'https://bank.gov.ua/depo_securities?json');
    assert.equal(options?.credentials,'omit'); assert.equal(options?.referrerPolicy,'no-referrer');
    return new Response(JSON.stringify(fixture));
  });
  assert.equal((await fetchNbu()).assets.length,1);
  t.mock.restoreAll();
  t.mock.method(globalThis,'fetch',async () => new Response('',{status:503}));
  await assert.rejects(fetchNbu);
});
