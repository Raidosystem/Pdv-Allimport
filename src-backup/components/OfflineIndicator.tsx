import { useState, useEffect } from 'react'
import { 
  WifiOff, 
  Download, 
  RefreshCw, 
  CheckCircle, 
  Clock, 
  X,
  Smartphone
} from 'lucide-react'
import { Button } from './ui/Button'
import { Card } from './ui/Card'
import { useOfflineSync } from '../hooks/useOfflineSync'

export function OfflineIndicator() {
  const { isOnline, syncStatus, startSync, installPWA } = useOfflineSync()
  const [showInstallPrompt, setShowInstallPrompt] = useState(false)
  const [isInstallable, setIsInstallable] = useState(false)
  
  // Verificar se pode ser instalado
  useEffect(() => {
    const checkInstallable = () => {
      // Verificar se é PWA instalável
      const isStandalone = window.matchMedia('(display-mode: standalone)').matches
      const hasPrompt = (window as any).deferredPrompt
      
      setIsInstallable(!isStandalone && (hasPrompt || 'serviceWorker' in navigator))
    }
    
    checkInstallable()
    
    // Verificar periodicamente
    const interval = setInterval(checkInstallable, 5000)
    
    return () => clearInterval(interval)
  }, [])
  
  // Auto-mostrar prompt de instalação após algum tempo de uso
  useEffect(() => {
    const timer = setTimeout(() => {
      if (isInstallable && !localStorage.getItem('pdv-install-prompted')) {
        setShowInstallPrompt(true)
        localStorage.setItem('pdv-install-prompted', 'true')
      }
    }, 30000) // Mostrar após 30 segundos
    
    return () => clearTimeout(timer)
  }, [isInstallable])

  const handleInstall = () => {
    installPWA()
    setShowInstallPrompt(false)
  }

  const dismissInstallPrompt = () => {
    setShowInstallPrompt(false)
    localStorage.setItem('pdv-install-dismissed', 'true')
  }

  return (
    <>
      {/* Status de Sincronização - Apenas quando necessário */}
      {(syncStatus.isSyncing || syncStatus.pendingItems > 0 || !isOnline) && (
        <div className="fixed top-4 left-4 z-50">
          <div className={`flex items-center gap-2 px-3 py-2 rounded-full text-sm font-medium transition-all duration-300 ${
            !isOnline 
              ? 'bg-red-100 text-red-800 border border-red-200'
              : syncStatus.isSyncing 
                ? 'bg-blue-100 text-blue-800 border border-blue-200'
                : 'bg-yellow-100 text-yellow-800 border border-yellow-200'
          }`}>
            {!isOnline ? (
              <>
                <WifiOff className="w-4 h-4" />
                Offline
              </>
            ) : syncStatus.isSyncing ? (
              <>
                <RefreshCw className="w-4 h-4 animate-spin" />
                Sincronizando
              </>
            ) : syncStatus.pendingItems > 0 ? (
              <>
                <Clock className="w-4 h-4" />
                {syncStatus.pendingItems} pendente(s)
              </>
            ) : null}
          </div>
        </div>
      )}

      {/* Card de Status Detalhado (quando offline) */}
      {!isOnline && (
        <div className="fixed bottom-4 right-4 z-50 max-w-sm">
          <Card className="p-4 bg-orange-50 border-orange-200">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center flex-shrink-0">
                <WifiOff className="w-5 h-5 text-orange-600" />
              </div>
              
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-orange-900 text-sm">
                  Modo Offline Ativo
                </h3>
                <p className="text-orange-700 text-xs mt-1">
                  Suas vendas são salvas localmente e serão sincronizadas quando a conexão voltar.
                </p>
                
                {syncStatus.pendingItems > 0 && (
                  <div className="mt-2 text-xs text-orange-600">
                    📝 {syncStatus.pendingItems} operações aguardando sincronização
                  </div>
                )}
                
                <Button
                  size="sm"
                  variant="outline"
                  className="mt-2 text-orange-700 border-orange-300 hover:bg-orange-100"
                  onClick={startSync}
                  disabled={syncStatus.isSyncing}
                >
                  {syncStatus.isSyncing ? (
                    <>
                      <RefreshCw className="w-3 h-3 animate-spin mr-1" />
                      Sincronizando...
                    </>
                  ) : (
                    <>
                      <RefreshCw className="w-3 h-3 mr-1" />
                      Tentar Sincronizar
                    </>
                  )}
                </Button>
              </div>
            </div>
          </Card>
        </div>
      )}

      {/* Prompt de Instalação PWA */}
      {showInstallPrompt && isInstallable && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <Card className="max-w-md w-full p-6 relative">
            <button
              onClick={dismissInstallPrompt}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>
            
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Smartphone className="w-8 h-8 text-blue-600" />
              </div>
              
              <h3 className="text-xl font-bold text-gray-900 mb-2">
                Instalar PDV Allimport
              </h3>
              
              <p className="text-gray-600 mb-6">
                Instale o PDV Allimport no seu computador para:
              </p>
              
              <div className="text-left space-y-2 mb-6">
                <div className="flex items-center gap-2 text-sm text-gray-700">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  Funcionar offline sem internet
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-700">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  Sincronização automática
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-700">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  Acesso rápido na área de trabalho
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-700">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  Melhor performance
                </div>
              </div>
              
              <div className="flex gap-3">
                <Button
                  variant="outline"
                  onClick={dismissInstallPrompt}
                  className="flex-1"
                >
                  Agora Não
                </Button>
                <Button
                  onClick={handleInstall}
                  className="flex-1 gap-2"
                >
                  <Download className="w-4 h-4" />
                  Instalar
                </Button>
              </div>
            </div>
          </Card>
        </div>
      )}

      {/* Botão de Instalação Permanente */}
      {isInstallable && !showInstallPrompt && (
        <button
          onClick={() => setShowInstallPrompt(true)}
          className="fixed bottom-4 left-4 bg-blue-600 hover:bg-blue-700 text-white p-3 rounded-full shadow-lg transition-all duration-200 hover:scale-110 z-40"
          title="Instalar PDV Allimport"
        >
          <Download className="w-5 h-5" />
        </button>
      )}
    </>
  )
}
