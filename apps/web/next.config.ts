import type { NextConfig } from 'next';
const config: NextConfig = { output: 'export', transpilePackages: ['@ovdp/pricing', '@ovdp/market-data'], poweredByHeader: false };
export default config;
