import type { Metadata } from 'next';
import './styles.css';
export const metadata: Metadata = { title: 'ОВДП Hub — прозоре порівняння', description: 'Прототип порівняння облігацій з урахуванням витрат. Демонстраційні дані.' };
export default function Layout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="uk"><body>{children}</body></html>;
}
