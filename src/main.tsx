import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Registrar Service Worker para PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ SW registered: ', registration);
      })
      .catch((registrationError) => {
        console.log('❌ SW registration failed: ', registrationError);
      });
  });
}

// Verificar se as variáveis de ambiente estão disponíveis
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('🚨 Erro: Variáveis de ambiente do Supabase não encontradas')
  console.log('VITE_SUPABASE_URL:', supabaseUrl ? '✅ Definida' : '❌ Não definida')
  console.log('VITE_SUPABASE_ANON_KEY:', supabaseAnonKey ? '✅ Definida' : '❌ Não definida')
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
