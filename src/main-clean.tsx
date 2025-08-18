import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

console.log('🚀 PDV Allimport v2.2.1 - PWA Limpo')

// Aguardar DOM estar completamente pronto
const waitForComplete = (): Promise<void> => {
  return new Promise((resolve) => {
    if (document.readyState === 'complete') {
      resolve()
    } else {
      window.addEventListener('load', () => resolve(), { once: true })
    }
  })
}

// Renderização direta sem modificações no DOM
const renderApp = async () => {
  console.log('🔍 Aguardando DOM completo...')
  await waitForComplete()
  
  const container = document.getElementById('root')
  if (!container) {
    console.error('❌ Container root não encontrado')
    showBasicError('Container não encontrado')
    return
  }

  console.log('✅ Container encontrado. Criando React Root...')
  
  try {
    // Criar root diretamente sem modificar o DOM
    const root = createRoot(container)
    
    // Renderizar com pequeno delay
    setTimeout(() => {
      try {
        root.render(<App />)
        console.log('✅ PDV renderizado!')
        
        // Verificar se funcionou
        setTimeout(() => {
          if (container.children.length > 0) {
            console.log('✅ Renderização confirmada')
          } else {
            console.warn('⚠️ Sem conteúdo após render')
            showBasicError('Conteúdo não carregou')
          }
        }, 1000)
        
      } catch (error) {
        console.error('❌ Erro no render:', error)
        showBasicError(`Erro render: ${error}`)
      }
    }, 100)
    
  } catch (error) {
    console.error('❌ Erro criar root:', error)
    showBasicError(`Erro root: ${error}`)
  }
}

// Interface básica de erro (sem botões PWA)
const showBasicError = (message: string) => {
  const body = document.body
  body.innerHTML = `
    <div style="
      font-family: system-ui, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      background: linear-gradient(135deg, #667eea, #764ba2);
      margin: 0;
      padding: 1rem;
    ">
      <div style="
        background: white;
        padding: 2rem;
        border-radius: 1rem;
        text-align: center;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        max-width: 400px;
        width: 100%;
      ">
        <h1 style="color: #1f2937; margin: 0 0 1rem 0;">
          🏪 PDV Allimport
        </h1>
        
        <p style="color: #6b7280; margin: 0 0 1rem 0;">
          Carregando sistema...
        </p>
        
        <p style="color: #ef4444; font-size: 0.8rem; margin: 0 0 1.5rem 0;">
          ${message}
        </p>
        
        <button onclick="location.reload()" style="
          background: #3b82f6;
          color: white;
          border: none;
          padding: 0.75rem 1.5rem;
          border-radius: 0.5rem;
          cursor: pointer;
          font-weight: 600;
          margin-right: 0.5rem;
        ">🔄 Tentar Novamente</button>
        
        <div style="
          margin-top: 1rem;
          padding-top: 1rem;
          border-top: 1px solid #e5e7eb;
          font-size: 0.7rem;
          color: #9ca3af;
        ">
          <div>v2.2.1 • ${new Date().toLocaleString()}</div>
          <div>${window.location.href}</div>
        </div>
      </div>
    </div>
  `
}

// Service Worker (mantido para PWA funcionar)
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
    .then(() => console.log('✅ SW ok'))
    .catch(() => console.log('⚠️ SW falhou'))
}

// Capturar erros sem preventDefault
window.addEventListener('error', (e) => {
  console.error('🚨 Erro:', e.error?.message)
})

window.addEventListener('unhandledrejection', (e) => {
  console.error('🚨 Promise:', e.reason)
})

// Iniciar
renderApp().catch((error) => {
  console.error('❌ Erro na inicialização:', error)
  showBasicError(`Init error: ${error}`)
})
