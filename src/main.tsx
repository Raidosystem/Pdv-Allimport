import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

console.log('� Iniciando PDV Allimport...')

// Verificar variáveis de ambiente
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

console.log('Supabase URL:', supabaseUrl ? '✅' : '❌')
console.log('Supabase Key:', supabaseAnonKey ? '✅' : '❌')

// Registrar Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ Service Worker registrado:', registration.scope);
      })
      .catch((error) => {
        console.log('❌ Erro no Service Worker:', error);
      });
  });
}

try {
  const rootElement = document.getElementById('root')
  
  if (!rootElement) {
    throw new Error('Elemento root não encontrado')
  }

  console.log('✅ Elemento root encontrado')
  
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
  
  console.log('✅ App renderizado com sucesso!')
} catch (error) {
  console.error('🚨 Erro crítico:', error)
  
  const rootElement = document.getElementById('root')
  if (rootElement) {
    rootElement.innerHTML = `
      <div style="
        min-height: 100vh; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        background: #f9fafb;
        font-family: system-ui, sans-serif;
        padding: 2rem;
        text-align: center;
      ">
        <div style="
          background: white;
          padding: 3rem;
          border-radius: 1rem;
          box-shadow: 0 10px 25px rgba(0,0,0,0.1);
          max-width: 500px;
        ">
          <h1 style="color: #dc2626; margin-bottom: 1.5rem; font-size: 1.5rem;">
            ⚠️ Erro ao carregar o PDV
          </h1>
          <p style="color: #6b7280; margin-bottom: 2rem; line-height: 1.6;">
            ${error instanceof Error ? error.message : 'Erro desconhecido'}
          </p>
          <button 
            onclick="window.location.reload()" 
            style="
              background: #3b82f6; 
              color: white; 
              padding: 1rem 2rem; 
              border: none; 
              border-radius: 0.5rem; 
              cursor: pointer;
              font-size: 1rem;
              font-weight: 500;
            "
          >
            🔄 Recarregar Sistema
          </button>
        </div>
      </div>
    `
  }
}

try {
  const rootElement = document.getElementById('root')
  
  if (!rootElement) {
    throw new Error('Elemento root não encontrado')
  }

  console.log('🚀 Iniciando aplicação...')
  
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
  
  console.log('✅ Aplicação iniciada com sucesso!')
} catch (error) {
  console.error('🚨 Erro ao iniciar aplicação:', error)
  
  // Fallback para mostrar erro na tela
  const rootElement = document.getElementById('root')
  if (rootElement) {
    rootElement.innerHTML = `
      <div style="
        min-height: 100vh; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        background-color: #f9fafb;
        font-family: sans-serif;
      ">
        <div style="text-align: center; padding: 2rem;">
          <h1 style="color: #dc2626; margin-bottom: 1rem;">Erro ao carregar aplicação</h1>
          <p style="color: #6b7280; margin-bottom: 1rem;">${error instanceof Error ? error.message : 'Erro desconhecido'}</p>
          <button 
            onclick="window.location.reload()" 
            style="
              background-color: #3b82f6; 
              color: white; 
              padding: 0.5rem 1rem; 
              border: none; 
              border-radius: 0.5rem; 
              cursor: pointer;
            "
          >
            Recarregar página
          </button>
        </div>
      </div>
    `
  }
}
