import type { Metadata } from 'next';
import './styles.css';
import AppInstall from './components/AppInstall';
export const metadata: Metadata = { title: 'ОВДП Hub — застосунок', description: 'Публічний каталог ОВДП і локальні розрахунки без серверного профілю.', applicationName: 'ОВДП Hub', appleWebApp: { capable: true, statusBarStyle: 'default', title: 'ОВДП Hub' } };
export default function Layout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="uk"><body><AppInstall />{children}</body></html>;
}
