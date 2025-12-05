import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Debug de autenticação - REMOVIDO para permitir login normal
// import './debug-auth.js'

console.log('🚀 RaVal pdv v2.2.3 - PWA Install Direto')

// ===== SISTEMA DE CACHE MOVIDO PARA index.html =====
// O controle de cache agora é feito inline no index.html
// para evitar conflitos e loops de reload
// ===== FIM DO SISTEMA DE LIMPEZA =====

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
          🏪 RaVal pdv
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

// Service Worker e PWA Install (Desabilitado em desenvolvimento)
let deferredPrompt: any = null

// Só registrar Service Worker em produção
if ('serviceWorker' in navigator && import.meta.env.PROD) {
  navigator.serviceWorker.register('/sw.js')
    .then(() => {
      console.log('✅ SW ok')
      // Após SW registrar, verificar PWA install
      setTimeout(setupPWAInstall, 2000)
    })
    .catch(() => console.log('⚠️ SW falhou'))
} else if ('serviceWorker' in navigator && import.meta.env.DEV) {
  // Em desenvolvimento, desregistrar qualquer SW existente
  navigator.serviceWorker.getRegistrations().then(registrations => {
    for (let registration of registrations) {
      registration.unregister().then(() => {
        console.log('🧹 Service Worker removido (desenvolvimento)')
      })
    }
  })
  console.log('⚙️ Service Worker desabilitado em desenvolvimento')
}

// Capturar evento de instalação PWA (Só em produção)
if (import.meta.env.PROD) {
  window.addEventListener('beforeinstallprompt', (e) => {
    console.log('🚀 PWA Install disponível!')
    e.preventDefault()
    deferredPrompt = e
    showInstallButton()
  })

  // Verificar se já está instalado
  window.addEventListener('appinstalled', () => {
    console.log('✅ PWA Instalado!')
    hideInstallButton()
  })
}

// Adicionar CSS para animações
const addPWAStyles = () => {
  if (document.getElementById('pwa-styles')) return
  
  const style = document.createElement('style')
  style.id = 'pwa-styles'
  style.textContent = `
    @keyframes fadeInUp {
      0% {
        opacity: 0;
        transform: translateX(-50%) translateY(10px);
      }
      100% {
        opacity: 1;
        transform: translateX(-50%) translateY(0);
      }
    }
    
    @keyframes pulse {
      0%, 100% {
        box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.4);
      }
      50% {
        box-shadow: 0 0 0 10px rgba(37, 99, 235, 0);
      }
    }
    
    #pwa-install-btn {
      animation: pulse 2s infinite;
    }
  `
  document.head.appendChild(style)
}

// Setup do sistema PWA (Só em produção)
const setupPWAInstall = () => {
  // Só mostrar PWA em produção
  if (import.meta.env.DEV) {
    console.log('⚙️ PWA desabilitado em desenvolvimento')
    return
  }
  
  addPWAStyles()
  
  // Se não capturou o evento mas está em produção, mostrar botão
  if (!deferredPrompt && location.hostname !== 'localhost') {
    console.log('🔧 Forçando botão PWA para produção...')
    setTimeout(showInstallButton, 1000)
  }
}

// Mostrar botão de instalação
const showInstallButton = () => {
  // Verificar se já existe
  if (document.getElementById('pwa-install-btn')) return
  
  // Verificar se já está instalado
  if (window.matchMedia('(display-mode: standalone)').matches) {
    console.log('✅ PWA já instalado, não mostrando botão')
    return
  }
  
  const installBtn = document.createElement('button')
  installBtn.id = 'pwa-install-btn'
  installBtn.innerHTML = '📱'
  installBtn.className = 'fixed bottom-4 left-4 bg-blue-600 hover:bg-blue-700 text-white p-3 rounded-full shadow-lg transition-all duration-200 hover:scale-110 z-40'
  installBtn.style.cssText = `
    position: fixed !important;
    bottom: 1rem !important;
    left: 1rem !important;
    background: #2563eb !important;
    color: white !important;
    border: none !important;
    padding: 0.75rem !important;
    border-radius: 50% !important;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
    cursor: pointer !important;
    z-index: 9999 !important;
    font-size: 1.2rem !important;
    width: 3rem !important;
    height: 3rem !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    transition: all 0.2s ease !important;
  `
  
  // Hover effects
  installBtn.addEventListener('mouseenter', () => {
    installBtn.style.background = '#1d4ed8 !important'
    installBtn.style.transform = 'scale(1.1) !important'
  })
  
  installBtn.addEventListener('mouseleave', () => {
    installBtn.style.background = '#2563eb !important'
    installBtn.style.transform = 'scale(1) !important'
  })
  
  // Click handler - instalar PWA diretamente
  installBtn.addEventListener('click', async () => {
    console.log('🚀 Tentando instalar PWA...')
    
    if (deferredPrompt) {
      try {
        // Método nativo - dispara popup de instalação
        installBtn.innerHTML = '⏳'
        installBtn.style.pointerEvents = 'none'
        
        await deferredPrompt.prompt()
        const { outcome } = await deferredPrompt.userChoice
        
        console.log(`✅ Resultado instalação: ${outcome}`)
        
        if (outcome === 'accepted') {
          deferredPrompt = null
          hideInstallButton()
        } else {
          // Usuário cancelou
          installBtn.innerHTML = '📱'
          installBtn.style.pointerEvents = 'auto'
        }
        
      } catch (error) {
        console.error('❌ Erro na instalação:', error)
        installBtn.innerHTML = '📱'
        installBtn.style.pointerEvents = 'auto'
      }
    } else {
      // Fallback - mostrar tooltip com instruções
      showQuickTooltip(installBtn)
    }
  })
  
  document.body.appendChild(installBtn)
  console.log('✅ Botão PWA adicionado')
}

// Ocultar botão de instalação
const hideInstallButton = () => {
  const btn = document.getElementById('pwa-install-btn')
  if (btn) {
    btn.style.opacity = '0'
    btn.style.transform = 'scale(0.8)'
    setTimeout(() => btn.remove(), 300)
  }
}

// Tooltip rápido com instruções
const showQuickTooltip = (button: HTMLElement) => {
  const tooltip = document.createElement('div')
  tooltip.innerHTML = `
    <div style="
      background: rgba(0,0,0,0.9);
      color: white;
      padding: 8px 12px;
      border-radius: 6px;
      font-size: 12px;
      white-space: nowrap;
      position: absolute;
      bottom: 100%;
      left: 50%;
      transform: translateX(-50%);
      margin-bottom: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      animation: fadeInUp 0.3s ease;
    ">
      Menu → Instalar RaVal pdv
      <div style="
        position: absolute;
        top: 100%;
        left: 50%;
        transform: translateX(-50%);
        width: 0;
        height: 0;
        border-left: 5px solid transparent;
        border-right: 5px solid transparent;
        border-top: 5px solid rgba(0,0,0,0.9);
      "></div>
    </div>
  `
  
  button.appendChild(tooltip)
  
  // Remover após 3 segundos
  setTimeout(() => {
    tooltip.style.opacity = '0'
    setTimeout(() => tooltip.remove(), 300)
  }, 3000)
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
