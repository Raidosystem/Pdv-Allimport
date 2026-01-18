import { useState, useEffect } from 'react'
import { X, RefreshCw } from 'lucide-react'
import { isPWA } from './PWARedirect'

/**
 * Componente que mostra notificação quando há atualização disponível no PWA
 * Aparece como um banner no topo da tela
 */
export function PWAUpdateNotification() {
  const [showUpdate, setShowUpdate] = useState(false)
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    // Só mostrar em PWA
    if (!isPWA()) {
      return
    }

    // Verificar se há Service Worker registrado
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.ready.then((reg) => {
        setRegistration(reg)

        // Verificar por atualizações a cada 30 segundos
        const interval = setInterval(() => {
          reg.update().catch((err) => {
            console.log('Erro ao verificar atualização:', err)
          })
        }, 30000)

        // Listener para quando há nova versão esperando
        reg.addEventListener('updatefound', () => {
          const newWorker = reg.installing
          if (newWorker) {
            newWorker.addEventListener('statechange', () => {
              if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                // Nova versão disponível
                console.log('🆕 Nova versão disponível!')
                setShowUpdate(true)
              }
            })
          }
        })

        return () => clearInterval(interval)
      })
    }

    // Verificar versão no servidor a cada minuto
    const versionCheck = setInterval(async () => {
      try {
        const response = await fetch('/version.json?' + Date.now())
        const data = await response.json()
        const currentVersion = localStorage.getItem('app-version')
        
        if (currentVersion && data.version !== currentVersion) {
          console.log('🆕 Nova versão detectada:', data.version)
          setShowUpdate(true)
        }
      } catch (error) {
        console.log('Erro ao verificar versão:', error)
      }
    }, 60000)

    return () => clearInterval(versionCheck)
  }, [])

  const handleUpdate = async () => {
    setUpdating(true)

    try {
      // Se há Service Worker, atualizar
      if (registration?.waiting) {
        registration.waiting.postMessage({ type: 'SKIP_WAITING' })
        
        // Esperar Service Worker ativar e recarregar
        navigator.serviceWorker.addEventListener('controllerchange', () => {
          window.location.reload()
        })
      } else {
        // Forçar reload do cache
        if ('caches' in window) {
          const cacheNames = await caches.keys()
          await Promise.all(cacheNames.map(name => caches.delete(name)))
        }
        window.location.reload()
      }
    } catch (error) {
      console.error('Erro ao atualizar:', error)
      // Fallback: recarregar página
      window.location.reload()
    }
  }

  const handleDismiss = () => {
    setShowUpdate(false)
    // Lembrar que usuário dispensou (mostrar novamente em 1 hora)
    localStorage.setItem('update-dismissed', Date.now().toString())
  }

  if (!showUpdate) {
    return null
  }

  return (
    <div className="fixed top-0 left-0 right-0 z-[10000] animate-slideDown">
      <div className="bg-gradient-to-r from-blue-600 via-blue-700 to-purple-600 text-white shadow-2xl">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3 flex-1">
              <div className="flex-shrink-0 w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
                <RefreshCw className="w-5 h-5 animate-spin" />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-sm md:text-base">
                  🎉 Nova atualização disponível!
                </p>
                <p className="text-xs md:text-sm text-blue-100 mt-0.5">
                  Atualize agora para ter acesso às melhorias e correções
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-2 flex-shrink-0">
              <button
                onClick={handleUpdate}
                disabled={updating}
                className="px-4 py-2 bg-white text-blue-600 font-bold text-sm rounded-lg hover:bg-blue-50 transition-all shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
              >
                {updating ? (
                  <>
                    <RefreshCw className="w-4 h-4 inline mr-1 animate-spin" />
                    Atualizando...
                  </>
                ) : (
                  '✨ Atualizar agora'
                )}
              </button>
              
              <button
                onClick={handleDismiss}
                className="p-2 hover:bg-white/10 rounded-lg transition-colors"
                title="Dispensar"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Estilo CSS inline para animação
const style = document.createElement('style')
style.textContent = `
  @keyframes slideDown {
    from {
      transform: translateY(-100%);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
  
  .animate-slideDown {
    animation: slideDown 0.3s ease-out;
  }
`
if (!document.querySelector('style[data-pwa-update]')) {
  style.setAttribute('data-pwa-update', 'true')
  document.head.appendChild(style)
}
