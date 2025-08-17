import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'

// Diagnóstico completo
console.log('🔍 DIAGNÓSTICO PDV ALLIMPORT')
console.log('1. React DOM carregado')

// Verificar variáveis de ambiente
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

console.log('2. Variáveis de ambiente:')
console.log('   VITE_SUPABASE_URL:', supabaseUrl ? '✅ OK' : '❌ FALTA')
console.log('   VITE_SUPABASE_ANON_KEY:', supabaseAnonKey ? '✅ OK' : '❌ FALTA')

// Service Worker
if ('serviceWorker' in navigator) {
  console.log('3. Service Worker suportado')
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ SW registered: ', registration);
      })
      .catch((registrationError) => {
        console.log('❌ SW registration failed: ', registrationError);
      });
  });
} else {
  console.log('3. Service Worker NÃO suportado')
}

// Importar App dinamicamente para detectar erros
console.log('4. Tentando importar App...')

let App;
try {
  // Importação dinâmica para capturar erros
  const AppModule = await import('./App.tsx')
  App = AppModule.default
  console.log('✅ App importado com sucesso')
} catch (error) {
  console.error('❌ Erro ao importar App:', error)
  document.getElementById('root')!.innerHTML = `
    <div style="padding: 2rem; text-align: center; background: #fef2f2; min-height: 100vh; display: flex; align-items: center; justify-content: center;">
      <div>
        <h1 style="color: #dc2626; margin-bottom: 1rem;">❌ Erro ao carregar aplicação</h1>
        <p style="color: #6b7280;">Erro de importação: ${error instanceof Error ? error.message : 'Erro desconhecido'}</p>
        <button onclick="window.location.reload()" style="background: #3b82f6; color: white; padding: 0.5rem 1rem; border: none; border-radius: 0.5rem; cursor: pointer; margin-top: 1rem;">Recarregar</button>
      </div>
    </div>
  `
  throw error
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
