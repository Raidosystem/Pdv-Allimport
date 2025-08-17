import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

console.log('🚀 PDV Allimport v2.1.1 - Inicializando...')

// Função ultra-segura para limpar DOM
const createUltraSafeRoot = (container: Element) => {
  // Desconectar todos os observadores
  if (window.MutationObserver) {
    const observers = (window as any).__reactObservers__ || []
    observers.forEach((observer: MutationObserver) => observer.disconnect())
  }
  
  // Remover todos os event listeners
  const cloned = container.cloneNode(false) as Element
  container.parentNode?.replaceChild(cloned, container)
  
  // Criar container completamente novo
  const safeContainer = document.createElement('div')
  safeContainer.id = 'react-app-root'
  safeContainer.style.cssText = 'width: 100%; height: 100%; min-height: 100vh;'
  
  cloned.appendChild(safeContainer)
  
  return { root: createRoot(safeContainer), container: safeContainer }
}

// Inicialização ultra-robusta
const initApp = async () => {
  console.log('✅ Iniciando PDV com método ultra-seguro...')
  
  const rootElement = document.getElementById('root')
  if (!rootElement) {
    console.error('❌ Root element não encontrado')
    return
  }

  try {
    // Aguardar frame para garantir DOM estável
    await new Promise(resolve => requestAnimationFrame(resolve))
    
    const { root, container } = createUltraSafeRoot(rootElement)
    
    console.log('✅ Container ultra-seguro criado')
    
    // Aguardar mais um frame antes do render
    await new Promise(resolve => requestAnimationFrame(resolve))
    
    // Render com Promise para capturar erros async
    await new Promise<void>((resolve, reject) => {
      try {
        root.render(<App />)
        
        // Verificar se renderizou após timeout
        setTimeout(() => {
          if (container.children.length > 0) {
            console.log('✅ PDV renderizado com sucesso!')
            resolve()
          } else {
            reject(new Error('Render não produziu conteúdo'))
          }
        }, 500)
        
      } catch (error) {
        reject(error)
      }
    })
    
  } catch (error) {
    console.error('❌ Erro no ultra-safe render:', error)
    showEmergencyUI(rootElement, error)
  }
}

// UI de emergência quando tudo falha
const showEmergencyUI = (container: Element, error: any) => {
  const errorMsg = error instanceof Error ? error.message : 'Erro desconhecido'
  
  container.innerHTML = `
    <div style="
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
      padding: 2rem; 
      text-align: center; 
      background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%); 
      min-height: 100vh; 
      display: flex; 
      align-items: center; 
      justify-content: center;
    ">
      <div style="max-width: 500px; background: white; padding: 2rem; border-radius: 1rem; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
        <h1 style="color: #dc2626; margin-bottom: 1rem; font-size: 1.5rem;">⚠️ PDV Temporariamente Indisponível</h1>
        <p style="color: #7f1d1d; margin-bottom: 1rem;">O sistema está passando por uma atualização.</p>
        <p style="color: #6b7280; margin-bottom: 1.5rem; font-size: 0.9rem;">Erro técnico: ${errorMsg}</p>
        
        <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
          <button onclick="window.location.reload()" style="
            background: #3b82f6; 
            color: white; 
            padding: 0.75rem 1.5rem; 
            border: none; 
            border-radius: 0.5rem; 
            cursor: pointer;
            font-weight: 600;
          ">🔄 Recarregar</button>
          
          <button onclick="window.location.href='https://pdv-allimport.surge.sh'" style="
            background: #059669; 
            color: white; 
            padding: 0.75rem 1.5rem; 
            border: none; 
            border-radius: 0.5rem; 
            cursor: pointer;
            font-weight: 600;
          ">🚀 Versão Alternativa</button>
        </div>
        
        <p style="color: #9ca3af; font-size: 0.7rem; margin-top: 1rem;">
          URL: ${window.location.href}<br>
          Timestamp: ${new Date().toLocaleString()}
        </p>
      </div>
    </div>
  `
}

// Service Worker
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
    .then(() => console.log('✅ Service Worker ativo'))
    .catch(() => console.log('⚠️ Service Worker falhou'))
}

// Capturar TODOS os erros
window.addEventListener('error', (e) => {
  console.error('🚨 Erro capturado:', e.error)
  e.preventDefault()
})

window.addEventListener('unhandledrejection', (e) => {
  console.error('🚨 Promise rejeitada:', e.reason)
  e.preventDefault()
})

// Inicialização final
const bootstrap = () => {
  if (document.readyState !== 'complete') {
    window.addEventListener('load', initApp)
  } else {
    setTimeout(initApp, 100)
  }
}

bootstrap()
