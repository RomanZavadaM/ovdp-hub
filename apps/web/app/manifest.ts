import type { MetadataRoute } from 'next';
export const dynamic = 'force-static';
export default function manifest(): MetadataRoute.Manifest {
  return { name: 'ОВДП Hub', short_name: 'ОВДП Hub', description: 'Публічний каталог ОВДП і локальні розрахунки.', start_url: '/', display: 'standalone', background_color: '#f5f6ef', theme_color: '#165d45', lang: 'uk', icons: [{ src: '/icon.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any' }] };
}
