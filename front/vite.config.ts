import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

// En desarrollo, /api/* se redirige a la raíz del backend Flask (por defecto
// http://localhost:5000): /api/casos → /casos. Así el front no necesita CORS.
export default defineConfig(({ mode }) => {
  // Carpeta del proyecto aunque Vite se lance desde otro directorio.
  const root = (import.meta as { dirname?: string }).dirname ?? '.';
  const env = loadEnv(mode, root, '');
  return {
    plugins: [react()],
    server: {
      port: 5173,
      proxy: {
        '/api': {
          target: env.BACKEND_URL || 'http://localhost:5000',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
  };
});
