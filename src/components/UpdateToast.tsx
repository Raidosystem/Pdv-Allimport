import { useEffect, useState } from 'react'
import { checkVersion } from '../utils/version-check'

/**
 * Banner de Nova Versão Disponível
 * Aparece automaticamente quando detecta atualização
 */
export function UpdateToast() {
  const [show, setShow] = useState(false)

  useEffect(() => {
    // Verificar nova versão ao montar o componente
    checkVersion(() => {
      console.log('🆕 Exibindo banner de nova versão')
      setShow(true)
    })

    // Verificar a cada 3 minutos
    const interval = setInterval(() => {
      checkVersion(() => {
        setShow(true)
      })
    }, 3 * 60 * 1000) // 3 minutos

    // Cleanup
    return () => clearInterval(interval)
  }, [])

  const handleUpdate = () => {
    console.log('🔄 Usuário solicitou atualização')
    // Forçar reload sem cache
    window.location.reload()
  }

  const handleDismiss = () => {
    setShow(false)
    // Reaparecer em 10 minutos se não atualizar
    setTimeout(() => {
      setShow(true)
    }, 10 * 60 * 1000) // 10 minutos
  }

  if (!show) return null

  return (
    <div className="fixed bottom-4 left-1/2 transform -translate-x-1/2 z-50">
      <div className="bg-gray-900 text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-4 animate-in slide-in-from-bottom duration-300">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
          <span className="font-medium">Nova versão disponível!</span>
        </div>
        
        <div className="flex gap-2">
          <button
            onClick={handleUpdate}
            className="bg-blue-600 hover:bg-blue-700 px-4 py-1 rounded text-sm font-medium transition-colors"
          >
            Atualizar agora
          </button>
          <button
            onClick={handleDismiss}
            className="text-gray-300 hover:text-white px-2 py-1 rounded text-sm transition-colors"
          >
            Depois
          </button>
        </div>
      </div>
    </div>
  )
}

/**
 * Hook para integração em qualquer componente
 */
export function useUpdateCheck() {
  const [hasUpdate, setHasUpdate] = useState(false)

  useEffect(() => {
    checkVersion(() => {
      setHasUpdate(true)
    })
  }, [])

  const updateNow = () => {
    window.location.reload()
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