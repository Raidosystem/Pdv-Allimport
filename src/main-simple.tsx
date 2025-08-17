import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Aguardar DOM estar pronto
const initApp = () => {
  const rootElement = document.getElementById('root')
  
  if (!rootElement) {
    console.error('❌ Elemento root não encontrado')
    return
  }

  // Limpar qualquer conteúdo existente
  rootElement.innerHTML = ''
  
  console.log('🚀 Iniciando PDV Allimport...')
  
  try {
    const root = createRoot(rootElement)
    root.render(<App />)
    console.log('✅ App renderizado com sucesso!')
  } catch (error) {
    console.error('❌ Erro ao renderizar:', error)
    rootElement.innerHTML = `
      <div style="padding: 2rem; text-align: center; background: #fee2e2; min-height: 100vh; display: flex; align-items: center; justify-content: center;">
        <div style="max-width: 400px;">
          <h1 style="color: #dc2626; margin-bottom: 1rem;">Erro ao carregar</h1>
          <p style="color: #7f1d1d; margin-bottom: 1rem;">Não foi possível inicializar o aplicativo.</p>
          <button onclick="window.location.reload()" style="background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.5rem; cursor: pointer;">Recarregar</button>
        </div>
      </div>
    `
  }
}

// Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(() => console.log('✅ Service Worker registrado'))
      .catch(() => console.log('❌ Erro no Service Worker'))
  })
}

// Inicializar quando DOM estiver pronto
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initApp)
} else {
  initApp()
}
