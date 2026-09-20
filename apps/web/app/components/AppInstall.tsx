'use client';
import { useEffect } from 'react';
export default function AppInstall() {
  useEffect(() => {
    if (!('serviceWorker' in navigator)) return;
    if (process.env.NODE_ENV !== 'production') {
      navigator.serviceWorker.getRegistrations().then(registrations => registrations.forEach(registration => registration.unregister())).catch(() => undefined);
      return;
    }
    navigator.serviceWorker.register('/sw.js').catch(() => undefined);
  }, []);
  return null;
}
