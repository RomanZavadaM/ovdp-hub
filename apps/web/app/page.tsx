'use client';
import { useState, type FormEvent } from 'react';
import { compareDemo } from '@ovdp/pricing/demo';
type Result = ReturnType<typeof compareDemo>;
const amount = (value: string) => new Intl.NumberFormat('uk-UA', { maximumFractionDigits: 2 }).format(Number(value));

export default function Home() {
  const [budget, setBudget] = useState('100000');
  const [result, setResult] = useState<Result | null>(null);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  async function submit(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError(''); setResult(null);
    try {
      setResult(compareDemo(budget));
    } catch { setError('Перевірте суму: від 0,01 до 100 000 000 грн.'); }
    finally { setBusy(false); }
  }
  return <main>
    <nav aria-label="Головна навігація"><a className="brand" href="/">◈ ОВДП<span>hub</span></a><span className="badge">Демонстраційний режим</span></nav>
    <section className="hero"><p className="eyebrow">ВАШІ ІНВЕСТИЦІЇ. ПОВНА КАРТИНА.</p><h1>Дохідність,<br/>за якою видно <em>все.</em></h1><p className="intro">Порівняйте облігації з урахуванням ціни та комісій. Зрозумійте, скільки вкладаєте й що отримаєте до погашення.</p></section>
    <section className="workspace" aria-labelledby="compare-title">
      <div className="section-heading"><div><p className="eyebrow">01 / ПОРІВНЯННЯ</p><h2 id="compare-title">Знайдіть свій варіант</h2></div><span>UAH · до погашення</span></div>
      <form onSubmit={submit}><label htmlFor="budget">Сума інвестиції, грн<input id="budget" inputMode="decimal" type="number" min="0.01" max="100000000" step="0.01" required value={budget} onChange={e => setBudget(e.target.value)} /></label><button disabled={busy} type="submit">{busy ? 'Розраховуємо…' : 'Порівняти пропозиції →'}</button></form>
      <p className="notice">Синтетичний випуск DEMO-UAH-2027: розрахунок 22.09.2026, погашення 22.09.2027. Це навчальний сценарій, пропозиції недоступні для купівлі.</p>
      {error && <p role="alert" className="error">{error}</p>}
      <div aria-live="polite" aria-busy={busy}>
        {!result && !busy && <div className="empty"><span>↗</span><p>Введіть бюджет, щоб побачити кількість паперів,<br/>витрати та чистий результат за кожною пропозицією.</p></div>}
        {result && <><div className="table-wrap"><table><caption>Порівняння за річною дохідністю інвестованої суми</caption><thead><tr><th>Партнер</th><th>Папери</th><th>Повна вартість</th><th>Комісія</th><th>Чистий прибуток</th><th>Річна дохідність</th><th>Залишок</th></tr></thead><tbody>{result.results.map((r, index) => <tr key={r.quoteId}><td><strong>{r.broker}</strong>{index === 0 && r.eligible && <small>Найвища дохідність у сценарії</small>}</td>{r.eligible ? <><td>{r.quantity}</td><td>{amount(r.initialOutflow)} ₴</td><td>{amount(r.upfrontFee)} ₴</td><td>{amount(r.netProfit)} ₴</td><td className="yield">{(Number(r.netXirr) * 100).toFixed(2)}%</td><td>{amount(r.uninvestedCash)} ₴</td></> : <td colSpan={6}>Недостатньо бюджету для одного папера з комісією</td>}</tr>)}</tbody></table></div><p className="method">Метод: XIRR / ACT/365F. У сценарії податки й регулярні комісії дорівнюють нулю. Залишок коштів не входить у дохідність позиції. Це не персональна рекомендація.</p></>}
      </div>
    </section>
    <section className="principles"><article><span>01</span><h3>Повна вартість</h3><p>Ціна паперів і разові витрати показані окремо.</p></article><article><span>02</span><h3>Прозора методика</h3><p>Розрахунок за датами грошових потоків, з урахуванням комісії.</p></article><article><span>03</span><h3>Контроль даних</h3><p>Демонстраційні сценарії чітко відокремлені від реальних котирувань.</p></article></section>
    <footer>ОВДП Hub · Перший прототип <span>Розрахунок на вашому пристрої. Бюджет не надсилається на сервер.</span></footer>
  </main>;
}
