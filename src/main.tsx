import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Debug completo
console.log('🔍 Debug - Main.tsx carregado')
console.log('🔍 document.readyState:', document.readyState)
console.log('🔍 window.location.href:', window.location.href)

// Aguardar DOM estar pronto
const initApp = () => {
  console.log('🚀 initApp() chamada')
  const rootElement = document.getElementById('root')
  
  if (!rootElement) {
    console.error('❌ Elemento root não encontrado')
    return
  }

  console.log('✅ Root element encontrado:', rootElement)
  
  // Limpar qualquer conteúdo existente
  rootElement.innerHTML = ''
  
  console.log('🚀 Iniciando PDV Allimport...')
  
  try {
    const root = createRoot(rootElement)
    console.log('✅ Root criado com sucesso')
    
    root.render(<App />)
    console.log('✅ App renderizado com sucesso!')
    
    // Verificar se renderizou
    setTimeout(() => {
      console.log('🔍 Conteúdo após render:', rootElement.innerHTML.substring(0, 100))
    }, 1000)
    
  } catch (error) {
    console.error('❌ Erro ao renderizar:', error)
    console.error('❌ Stack trace:', (error as Error)?.stack || 'Stack não disponível')
    
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido'
    
    rootElement.innerHTML = `
      <div style="padding: 2rem; text-align: center; background: #fee2e2; min-height: 100vh; display: flex; align-items: center; justify-content: center;">
        <div style="max-width: 400px;">
          <h1 style="color: #dc2626; margin-bottom: 1rem;">Erro ao carregar</h1>
          <p style="color: #7f1d1d; margin-bottom: 1rem;">Não foi possível inicializar o aplicativo.</p>
          <p style="color: #7f1d1d; margin-bottom: 1rem; font-size: 0.8rem;">Erro: ${errorMessage}</p>
          <button onclick="window.location.reload()" style="background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.5rem; cursor: pointer;">Recarregar</button>
        </div>
      </div>
    `
  }
}

// Service Worker com debug
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    console.log('🔍 Registrando Service Worker...')
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ Service Worker registrado:', registration)
      })
      .catch((error) => {
        console.log('❌ Erro no Service Worker:', error)
      })
  })
}

// Capturar erros globais
window.addEventListener('error', (event) => {
  console.error('🚨 Erro global capturado:', event.error)
  console.error('🚨 Arquivo:', event.filename, 'Linha:', event.lineno)
})

window.addEventListener('unhandledrejection', (event) => {
  console.error('🚨 Promise rejeitada:', event.reason)
})

// Inicializar quando DOM estiver pronto
console.log('🔍 Verificando readyState...')
if (document.readyState === 'loading') {
  console.log('🔍 DOM ainda carregando, aguardando DOMContentLoaded')
  document.addEventListener('DOMContentLoaded', initApp)
} else {
  console.log('🔍 DOM já pronto, inicializando imediatamente')
  initApp()
}
