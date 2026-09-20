import { mkdir, writeFile, rename, unlink } from 'node:fs/promises';
import { fetchNbu } from '../packages/market-data/src/index.ts';
const target = new URL('../apps/web/data/nbu-snapshot.json', import.meta.url);
const temporary = new URL('../apps/web/data/nbu-snapshot.json.tmp', import.meta.url);
const snapshot = await fetchNbu(AbortSignal.timeout(30000));
if (snapshot.rejected.length) throw new Error('Snapshot has quarantined records; inspect source before publishing: ' + JSON.stringify(snapshot.rejected));
await mkdir(new URL('../apps/web/data/',import.meta.url),{recursive:true});
try {
  await writeFile(temporary, JSON.stringify(snapshot)+'\n');
  await rename(temporary,target);
} finally { await unlink(temporary).catch(() => {}); }
console.log(JSON.stringify({assets:snapshot.assets.length,excluded:snapshot.excludedCount,retrievedAt:snapshot.retrievedAt}));
