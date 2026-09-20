'use client';
import { useEffect, useMemo, useState } from 'react';
import { fetchNbu, filterAssets, freshness, SOURCE_PAGE, type Snapshot } from '@ovdp/market-data';
import initial from '../data/nbu-snapshot.json';
const labels = { COUPON:'Купон', REDEMPTION:'Погашення', EARLY_REDEMPTION:'Дострокове погашення' };
const formatDate = (value: string) => value.split('-').reverse().join('.');
const formatNumber = (value: number, maximumFractionDigits = 2) => new Intl.NumberFormat('uk-UA', { maximumFractionDigits }).format(value);
const daysUntil = (date: string, today: string) => Math.max(0, Math.ceil((Date.parse(date) - Date.parse(today)) / 86400000));
const mofCalendar = {
  publishedAt: '2026-09-17',
  documentUrl: 'https://www.mof.gov.ua/storage/files/%D0%93%D1%80%D0%B0%D1%84%D1%96%D0%BA%20%D0%BD%D0%B0%20%D0%B2%D0%B5%D1%80%D0%B5%D1%81%D0%B5%D0%BD%D1%8C%202026%20%2817_09_2026%29%20%E2%80%93%20%D0%BD%D0%B0%20%D1%81%D0%B0%D0%B9%D1%82.docx',
  events: [
    { date: '2026-09-01', label: 'Аукціон з розміщення' },
    { date: '2026-09-08', label: 'Аукціон з розміщення' },
    { date: '2026-09-15', label: 'Аукціон з розміщення' },
    { date: '2026-09-22', label: 'Аукціон з розміщення' },
    { date: '2026-09-29', label: 'Аукціон з розміщення' }
  ]
};
function download(name: string, content: string, type: string) {
  const url = URL.createObjectURL(new Blob([content], { type }));
  const link = document.createElement('a'); link.href = url; link.download = name; link.click();
  URL.revokeObjectURL(url);
}
function csvCell(value: string | number | null) {
  const text = value === null ? '' : String(value);
  return /[",\n]/.test(text) ? '"' + text.replaceAll('"', '""') + '"' : text;
}
export default function Catalog() {
  const [snapshot,setSnapshot] = useState(initial as Snapshot);
  const [query,setQuery] = useState('');
  const [currency,setCurrency] = useState('');
  const [activeOnly,setActiveOnly] = useState(true);
  const [limit,setLimit] = useState(25);
  const [now,setNow] = useState<number | null>(null);
  const [selectedIsin,setSelectedIsin] = useState<string | null>(null);
  const [busy,setBusy] = useState(false);
  const [error,setError] = useState('');
  useEffect(() => { setNow(Date.now()); const timer = setInterval(() => setNow(Date.now()),60000); return () => clearInterval(timer); },[]);
  const today = now === null ? initial.retrievedAt.slice(0,10) : new Date(now).toLocaleDateString('en-CA',{timeZone:'Europe/Kyiv'});
  const rows = filterAssets(snapshot.assets,{query,currency,activeOnly,today});
  const selected = rows.find(asset => asset.isin === selectedIsin) ?? null;
  const analysis = useMemo(() => {
    const currencies = ['UAH','USD','EUR'].map(value => ({ value, count: rows.filter(asset => asset.currency === value).length }));
    const rates = rows.map(asset => asset.nominalRate === null ? null : Number(asset.nominalRate)).filter((rate): rate is number => rate !== null && Number.isFinite(rate));
    const payments = rows.flatMap(asset => asset.payments.filter(payment => payment.date >= today).map(payment => ({ ...payment, isin: asset.isin, currency: asset.currency })));
    const nextMaturity = rows[0] ?? null;
    return { currencies, minRate: rates.length ? Math.min(...rates) : null, maxRate: rates.length ? Math.max(...rates) : null, nextMaturity, nextPayment: payments.sort((a,b) => a.date.localeCompare(b.date))[0] ?? null };
  }, [rows, today]);
  const state = now === null ? 'UNKNOWN' : freshness(snapshot.retrievedAt,now);
  function exportJson() {
    download('ovdp-nbu-snapshot.json', JSON.stringify(snapshot, null, 2) + '\n', 'application/json;charset=utf-8');
  }
  function exportCsv() {
    const csvRows = [['ISIN','Тип','Валюта','Номінал','Номінальна ставка','Дата погашення','Дата виплати','Тип виплати','Сума виплати']];
    for (const asset of snapshot.assets) for (const payment of asset.payments)
      csvRows.push([asset.isin, asset.description, asset.currency, asset.nominal, asset.nominalRate ?? '', asset.maturityDate, payment.date, labels[payment.kind], payment.amount]);
    download('ovdp-nbu-payments.csv', '\uFEFF' + csvRows.map(row => row.map(csvCell).join(',')).join('\n') + '\n', 'text/csv;charset=utf-8');
  }
  async function refresh() {
    setBusy(true); setError('');
    try { setSnapshot(await fetchNbu(AbortSignal.timeout(20000))); setNow(Date.now()); setLimit(25); }
    catch { setError('НБУ зараз недоступний або формат даних змінився. Збережено попередній знімок; перевірте час його отримання.'); }
    finally { setBusy(false); }
  }
  return <main>
    <nav aria-label="Головна навігація"><a className="brand" href="/">◈ ОВДП<span>hub</span></a><a href="/demo">Демо-калькулятор →</a></nav>
    <section className="hero"><p className="eyebrow">ПУБЛІЧНІ ДАНІ. ВАШ ПРИВАТНИЙ ПРОСТІР.</p><h1>Державні облігації.<br/><em>Відкрито про головне.</em></h1><p className="intro">Довідник ОВДП Національного банку України: валюта, номінал, строки та графіки виплат. Пошук і фільтри працюють на вашому пристрої.</p></section>
    <section className="workspace" aria-labelledby="catalog-title">
      <div className="section-heading"><div><p className="eyebrow">01 / ДОВІДНИК НБУ</p><h2 id="catalog-title">Оберіть випуск</h2></div><span className="badge">Офіційне джерело · {snapshot.assets.length} випусків</span></div>
      <div className="source-panel"><div><a href={SOURCE_PAGE} target="_blank" rel="noreferrer">Джерело: Національний банк України ↗</a><p>Отримано: <time dateTime={snapshot.retrievedAt}>{snapshot.retrievedAt.replace('T',' ').slice(0,19)} UTC</time></p><p>{state === 'STALE' ? 'Знімок старший за 24 години — оновіть дані.' : state === 'RECENT' ? 'Знімок отримано протягом останніх 24 годин.' : 'Актуальність часу отримання не визначена.'} Дату актуальності самого набору API не надає.</p></div><div className="source-actions"><button type="button" onClick={refresh} disabled={busy}>{busy ? 'Завантажуємо…' : 'Оновити з НБУ'}</button><button type="button" className="secondary" onClick={exportJson}>JSON</button><button type="button" className="secondary" onClick={exportCsv}>CSV виплат</button></div></div>
      <p className="notice">Оновлення звертається безпосередньо до НБУ. Ваші фільтри та бюджет не передаються. НБУ бачить звичайні мережеві дані запиту, зокрема IP-адресу.</p>
      {error && <p role="alert" className="error">{error}</p>}
      {snapshot.rejected.length > 0 && <p role="alert" className="error">Не показано {snapshot.rejected.length} некоректних записів джерела. Дані можуть бути неповними.</p>}
      <div className="filters"><label htmlFor="search">ISIN<input id="search" value={query} onChange={e=>{setQuery(e.target.value);setLimit(25);}} placeholder="Наприклад, UA400…" autoComplete="off"/></label><label htmlFor="currency">Валюта<select id="currency" value={currency} onChange={e=>{setCurrency(e.target.value);setLimit(25);}}><option value="">Усі валюти</option><option>UAH</option><option>USD</option><option>EUR</option></select></label><label className="checkbox"><input type="checkbox" checked={activeOnly} onChange={e=>{setActiveOnly(e.target.checked);setLimit(25);}}/>Термін погашення ще не минув</label></div>
      <p className="notice">Номінальна ставка — параметр випуску, не дохідність купівлі. Тут немає цін брокерів або пропозицій придбання. Відсортовано за датою погашення.</p>
      <p role="status" aria-live="polite">Знайдено {rows.length} · показано {Math.min(limit,rows.length)}</p>
      <div className="analysis-grid" aria-label="Локальний аналіз вибірки">
        <article className="analysis-card analysis-main"><span className="analysis-label">ШВИДКИЙ АНАЛІЗ ВИБІРКИ</span><strong>{rows.length} <small>випусків після фільтрів</small></strong><p>{analysis.nextMaturity ? <>Найближче погашення: <b>{formatDate(analysis.nextMaturity.maturityDate)}</b> · {analysis.nextMaturity.isin} ({daysUntil(analysis.nextMaturity.maturityDate, today)} днів)</> : 'Змініть фільтри, щоб отримати зріз.'}</p></article>
        <article className="analysis-card"><span className="analysis-label">ВАЛЮТИ</span><div className="metric-list">{analysis.currencies.map(item=><span key={item.value}><b>{item.value}</b>{item.count}</span>)}</div></article>
        <article className="analysis-card"><span className="analysis-label">НОМІНАЛЬНА СТАВКА</span><strong>{analysis.minRate === null ? '—' : `${formatNumber(analysis.minRate)}–${formatNumber(analysis.maxRate ?? analysis.minRate)}%`}</strong><p>Діапазон параметрів випуску; не YTM і не ціна угоди.</p></article>
        <article className="analysis-card"><span className="analysis-label">НАСТУПНА ВИПЛАТА</span><strong>{analysis.nextPayment ? formatDate(analysis.nextPayment.date) : '—'}</strong><p>{analysis.nextPayment ? `${analysis.nextPayment.isin} · ${analysis.nextPayment.amount} ${analysis.nextPayment.currency}` : 'У вибірці немає майбутніх виплат.'}</p></article>
      </div>
      {selected && <aside className="selected-analysis"><div className="selected-heading"><div><span className="analysis-label">ДЕТАЛЬНИЙ ОГЛЯД</span><h3>{selected.isin}</h3><p>{selected.description || 'Державна облігація'}</p></div><button type="button" className="secondary" onClick={()=>setSelectedIsin(null)}>Закрити</button></div><div className="selected-facts"><span><b>Валюта</b>{selected.currency}</span><span><b>Номінал</b>{selected.nominal} {selected.currency}</span><span><b>Ставка</b>{selected.nominalRate === null ? 'Немає даних' : `${selected.nominalRate}%`}</span><span><b>До погашення</b>{daysUntil(selected.maturityDate, today)} днів</span></div><h4>Графік виплат на 1 папір</h4><ul className="selected-payments">{selected.payments.map((payment,index)=><li key={`${payment.date}-${index}`}><time dateTime={payment.date}>{formatDate(payment.date)}</time><span>{labels[payment.kind]}</span><b>{payment.amount} {selected.currency}</b></li>)}</ul><p className="notice">Показано джерельні суми без податків, комісій, ціни купівлі та гарантії фактичного зарахування.</p></aside>}
      <div className="table-wrap"><table><caption>ОВДП за даними депозитарію НБУ</caption><thead><tr><th>ISIN / тип</th><th>Валюта</th><th>Номінал</th><th>Номінальна ставка</th><th>Погашення</th><th>Графік на 1 папір</th><th>Аналіз</th></tr></thead><tbody>{rows.slice(0,limit).map(a=><tr key={a.isin}><td><strong>{a.isin}</strong><small>{a.description}</small></td><td>{a.currency}</td><td>{a.nominal}</td><td>{a.nominalRate === null ? 'Немає даних' : a.nominalRate+'%'}</td><td>{formatDate(a.maturityDate)}</td><td><details><summary>Виплати</summary><p>Дані джерела; без податків і комісій. Майбутні дати не означають фактичне зарахування.</p><ul className="payments">{a.payments.filter(p=>p.date>=today).map((p,i)=><li key={i}>{formatDate(p.date)} · {labels[p.kind]} · {p.amount} {a.currency}</li>)}</ul>{!a.payments.some(p=>p.date>=today) && <p>Майбутніх виплат у наборі немає.</p>}</details></td><td><button type="button" className="row-action" onClick={()=>setSelectedIsin(a.isin)} aria-label={`Деталі ${a.isin}`}>Деталі</button></td></tr>)}</tbody></table></div>
      {!rows.length && <p className="empty">Нічого не знайдено. Змініть ISIN або фільтри.</p>}
      {rows.length>limit && <button className="load-more" onClick={()=>setLimit(v=>v+25)}>Показати ще 25</button>}
    </section>
    <section className="workspace calendar" aria-labelledby="calendar-title"><div className="section-heading"><div><p className="eyebrow">02 / КАЛЕНДАР МІНФІНУ</p><h2 id="calendar-title">Заплановані аукціони</h2></div><span className="badge">Редакція {formatDate(mofCalendar.publishedAt)}</span></div><p className="notice">Це план розміщень, опублікований Міністерством фінансів. Остаточний перелік випусків може змінюватися після оцінки попиту. Календар не є заявкою, ціною або гарантією проведення.</p><div className="auction-grid">{mofCalendar.events.map(event=><article key={event.date}><time dateTime={event.date}>{formatDate(event.date)}</time><strong>{event.label}</strong><small>Параметри — в офіційному оголошенні</small></article>)}</div><p className="source-line"><a href="https://www.mof.gov.ua/uk/kalendar-aukcioniv" target="_blank" rel="noreferrer">Сторінка календарів Мінфіну ↗</a> · <a href={mofCalendar.documentUrl} target="_blank" rel="noreferrer">Поточний документ ↗</a></p></section>
    <section className="principles"><article><span>01</span><h3>Відкрите джерело</h3><p>Офіційний довідник НБУ з атрибуцією та часом отримання.</p></article><article><span>02</span><h3>Локальний пошук</h3><p>Без акаунтів, збору портфелів та передачі інвестиційних планів.</p></article><article><span>03</span><h3>Прозорі межі</h3><p>Довідкові ставки відокремлені від цін і дохідності конкретної угоди.</p></article></section>
    <footer>ОВДП Hub · Агрегатор публічної інформації <a href="/demo">Навчальний калькулятор на синтетичних даних</a></footer>
  </main>;
}
