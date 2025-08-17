import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Função para criar root de forma mais segura
const createSafeRoot = (container: Element) => {
  // Limpar completamente o container
  while (container.firstChild) {
    container.removeChild(container.firstChild)
  }
  
  // Criar um novo div como container seguro
  const safeContainer = document.createElement('div')
  safeContainer.id = 'react-root'
  container.appendChild(safeContainer)
  
  return createRoot(safeContainer)
}

// Aguardar DOM estar pronto com timeout de segurança
const initApp = () => {
  console.log('🚀 Iniciando PDV Allimport...')
  
  const rootElement = document.getElementById('root')
  if (!rootElement) {
    console.error('❌ Elemento root não encontrado')
    return
  }

  console.log('✅ Root element encontrado:', rootElement)
  
  try {
    // Usar método seguro para criar root
    const root = createSafeRoot(rootElement)
    console.log('✅ Root criado com método seguro')
    
    // Render com timeout para evitar conflitos
    setTimeout(() => {
      try {
        root.render(<App />)
        console.log('✅ App renderizado com sucesso!')
      } catch (renderError) {
        console.error('❌ Erro no render:', renderError)
        showErrorPage(rootElement, renderError instanceof Error ? renderError.message : 'Erro no render')
      }
    }, 100)
    
  } catch (error) {
    console.error('❌ Erro ao criar root:', error)
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido'
    showErrorPage(rootElement, errorMessage)
  }
}

// Função para mostrar página de erro
const showErrorPage = (container: Element, errorMessage: string) => {
  container.innerHTML = `
    <div style="padding: 2rem; text-align: center; background: #fee2e2; min-height: 100vh; display: flex; align-items: center; justify-content: center;">
      <div style="max-width: 400px;">
        <h1 style="color: #dc2626; margin-bottom: 1rem;">Erro ao carregar PDV</h1>
        <p style="color: #7f1d1d; margin-bottom: 1rem;">Não foi possível inicializar o aplicativo.</p>
        <p style="color: #7f1d1d; margin-bottom: 1rem; font-size: 0.8rem;">Erro: ${errorMessage}</p>
        <button onclick="window.location.reload()" style="background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.5rem; cursor: pointer;">Recarregar</button>
        <br><br>
        <p style="color: #6b7280; font-size: 0.7rem;">URL: ${window.location.href}</p>
      </div>
    </div>
  `
}

// Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ Service Worker registrado:', registration.scope)
      })
      .catch((error) => {
        console.log('❌ Erro no Service Worker:', error)
      })
  })
}

// Capturar erros globais para prevenir crash
window.addEventListener('error', (event) => {
  console.error('🚨 Erro global:', event.error)
  event.preventDefault() // Prevenir que o erro pare a aplicação
})

window.addEventListener('unhandledrejection', (event) => {
  console.error('🚨 Promise rejeitada:', event.reason)
  event.preventDefault() // Prevenir que a promise rejeitada pare a aplicação
})

// Inicializar de forma mais robusta
const startApp = () => {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initApp)
  } else {
    // Pequeno delay para garantir que tudo esteja pronto
    setTimeout(initApp, 50)
  }
}

// Iniciar aplicação
startApp()
