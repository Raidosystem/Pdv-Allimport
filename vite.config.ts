import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    assetsDir: 'assets',
    chunkSizeWarningLimit: 1000,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
      },
    },
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name]-[hash].js',
        chunkFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash][extname]',
        manualChunks: {
          // Core vendors
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          // Supabase
          'vendor-supabase': ['@supabase/supabase-js'],
          // Forms
          'vendor-forms': ['react-hook-form', 'zod', '@hookform/resolvers'],
          // UI/Charts
          'vendor-charts': ['recharts'],
          // PDF generation (lazy loaded)
          'vendor-pdf': ['jspdf', '@react-pdf/renderer', 'html2canvas'],
          // Tables
          'vendor-tables': ['@tanstack/react-table', '@tanstack/react-query'],
        },
      },
    },
  },
  server: {
    port: 5174,
    host: true,
  },
  preview: {
    port: 4173,
    host: true,
  },
  // Configuração específica para PWA
  define: {
    '__DEV__': JSON.stringify(process.env.NODE_ENV === 'development')
  },
  publicDir: 'public',
})
