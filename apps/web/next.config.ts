import type { NextConfig } from 'next';
const config: NextConfig = { output: 'export', transpilePackages: ['@ovdp/pricing'], poweredByHeader: false };
export default config;
