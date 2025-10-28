import { useEffect, useState } from 'react'
import { RefreshCw, X } from 'lucide-react'
import { checkVersion } from '../utils/version-check'

/**
 * Card de Atualização Disponível
 * Aparece de forma proeminente quando há nova versão
 */
export function UpdateCard() {
  const [show, setShow] = useState(false)
  const [isUpdating, setIsUpdating] = useState(false)

  useEffect(() => {
    // 🧪 TESTE: Pressione Ctrl+U para forçar exibição do card
    const handleKeyPress = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.key === 'u') {
        e.preventDefault()
        console.log('🧪 [TESTE] Forçando exibição do card de atualização')
        setShow(true)
      }
    }
    window.addEventListener('keydown', handleKeyPress)

    // Verificar nova versão ao montar o componente
    checkVersion(() => {
      console.log('🆕 Exibindo card de nova versão')
      setShow(true)
    })

    // Verificar a cada 2 minutos
    const interval = setInterval(() => {
      checkVersion(() => {
        setShow(true)
      })
    }, 2 * 60 * 1000) // 2 minutos

    // Verificar quando a janela ganha foco
    const handleFocus = () => {
      checkVersion(() => {
        setShow(true)
      })
    }

    window.addEventListener('focus', handleFocus)

    // Cleanup
    return () => {
      clearInterval(interval)
      window.removeEventListener('focus', handleFocus)
      window.removeEventListener('keydown', handleKeyPress)
    }
  }, [])

  const handleUpdate = () => {
    console.log('🔄 Usuário iniciou atualização')
    setIsUpdating(true)
    
    // 1. Salvar o estado de autenticação ANTES de limpar cache
    const authData = localStorage.getItem('supabase.auth.token')
    const hasAuth = !!authData
    
    console.log('💾 Estado de autenticação salvo:', hasAuth ? 'Usuário logado' : 'Sem login')
    
    // 2. Desregistrar Service Worker antigo
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(registrations => {
        console.log('🗑️ Desregistrando', registrations.length, 'Service Workers')
        registrations.forEach(registration => {
          registration.unregister()
        })
      })
    }
    
    // 3. Limpar TODO o cache (service worker + browser)
    if ('caches' in window) {
      caches.keys().then(names => {
        console.log('🧹 Limpando', names.length, 'caches')
        return Promise.all(
          names.map(name => {
            console.log('🗑️ Deletando cache:', name)
            return caches.delete(name)
          })
        )
      }).then(() => {
        console.log('✅ Todos os caches limpos!')
      })
    }
    
    // 4. Forçar reload SEM limpar localStorage (mantém login)
    setTimeout(() => {
      console.log('🔄 Recarregando página (mantendo login)...')
      // Hard reload: força buscar do servidor
      window.location.reload()
    }, 1000) // Aumentado para 1 segundo para dar tempo de limpar tudo
  }

  const handleDismiss = () => {
    console.log('⏸️ Atualização adiada pelo usuário')
    setShow(false)
    
    // Reaparecer em 10 minutos se não atualizar
    setTimeout(() => {
      setShow(true)
    }, 10 * 60 * 1000) // 10 minutos
  }

  if (!show) return null

  return (
    <>
      {/* Overlay semi-transparente */}
      <div 
        className="fixed inset-0 bg-black/30 backdrop-blur-sm z-[9998] animate-in fade-in duration-300"
        onClick={handleDismiss}
      />
      
      {/* Card de Atualização */}
      <div className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-[9999] animate-in zoom-in-95 fade-in duration-300">
        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl border border-gray-200 dark:border-gray-700 p-8 max-w-md w-full mx-4">
          {/* Botão fechar */}
          <button
            onClick={handleDismiss}
            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
            title="Fechar"
          >
            <X className="w-5 h-5" />
          </button>

          {/* Ícone de atualização */}
          <div className="flex justify-center mb-6">
            <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
              <RefreshCw className="w-10 h-10 text-white animate-pulse" />
            </div>
          </div>

          {/* Título e Descrição */}
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-3">
              Nova Atualização Disponível!
            </h2>
            <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
              Uma nova versão do sistema está pronta. Recarregue a página para aproveitar as últimas melhorias e correções.
            </p>
          </div>

          {/* Botões de ação */}
          <div className="flex flex-col gap-3">
            <button
              onClick={handleUpdate}
              disabled={isUpdating}
              className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-200 transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl flex items-center justify-center gap-2"
            >
              {isUpdating ? (
                <>
                  <RefreshCw className="w-5 h-5 animate-spin" />
                  <span>Atualizando...</span>
                </>
              ) : (
                <>
                  <RefreshCw className="w-5 h-5" />
                  <span>Recarregar Agora</span>
                </>
              )}
            </button>

            <button
              onClick={handleDismiss}
              disabled={isUpdating}
              className="w-full bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-medium py-3 px-6 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Mais Tarde
            </button>
          </div>

          {/* Aviso */}
          <p className="text-xs text-gray-500 dark:text-gray-500 text-center mt-4">
            A atualização leva apenas alguns segundos
          </p>

          {/* Debug Helper - Remover em produção */}
          {window.location.hostname === 'localhost' && (
            <p className="text-xs text-blue-500 text-center mt-2 font-mono">
              🧪 Dev: Pressione Ctrl+U para testar este card
            </p>
          )}
        </div>
      </div>
    </>
  )
}

/**
 * Hook para integração em qualquer componente
 */
export function useUpdateNotification() {
  const [hasUpdate, setHasUpdate] = useState(false)

  useEffect(() => {
    checkVersion(() => {
      setHasUpdate(true)
    })

    // Verificar periodicamente
    const interval = setInterval(() => {
      checkVersion(() => {
        setHasUpdate(true)
      })
    }, 2 * 60 * 1000)

    return () => clearInterval(interval)
  }, [])

  const updateNow = () => {
    // Salvar estado de autenticação
    const authData = localStorage.getItem('supabase.auth.token')
    console.log('💾 [Hook] Estado de autenticação salvo:', !!authData)
    
    // Desregistrar Service Worker
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(registrations => {
        registrations.forEach(registration => registration.unregister())
      })
    }
    
    // Limpar cache
    if ('caches' in window) {
      caches.keys().then(names => {
        return Promise.all(names.map(name => caches.delete(name)))
      })
    }
    
    // Recarregar mantendo login
    setTimeout(() => {
      window.location.reload()
    }, 1000)
  }

  const dismissUpdate = () => {
    setHasUpdate(false)
  }

  return {
    hasUpdate,
    updateNow,
    dismissUpdate
  }
}
