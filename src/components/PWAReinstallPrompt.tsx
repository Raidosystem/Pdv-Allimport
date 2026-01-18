import { useState, useEffect } from 'react'
import { AlertTriangle, X } from 'lucide-react'
import { isPWA } from './PWARedirect'

/**
 * Prompt para reinstalação do PWA quando há mudanças críticas
 * no manifest.json (display mode, orientation, etc)
 */
export function PWAReinstallPrompt() {
  const [showPrompt, setShowPrompt] = useState(false)

  useEffect(() => {
    // Só verificar em PWA
    if (!isPWA()) {
      return
    }

    // Verificar se precisa reinstalar (mudanças no manifest)
    const needsReinstall = localStorage.getItem('pwa-needs-reinstall')
    
    if (needsReinstall === 'true') {
      console.log('⚠️ PWA precisa ser reinstalado para aplicar mudanças!')
      setShowPrompt(true)
    }

    // Verificar manifest atual vs esperado
    const checkDisplayMode = () => {
      const isFullscreen = window.matchMedia('(display-mode: fullscreen)').matches
      const isStandalone = window.matchMedia('(display-mode: standalone)').matches
      
      console.log('🔍 Display mode atual:', { isFullscreen, isStandalone })
      
      // Se não está em fullscreen, provavelmente precisa reinstalar
      if (!isFullscreen && isStandalone) {
        console.log('⚠️ PWA em standalone, deveria estar em fullscreen!')
        localStorage.setItem('pwa-needs-reinstall', 'true')
        setShowPrompt(true)
      }
    }

    checkDisplayMode()
  }, [])

  const handleDismiss = () => {
    console.log('❌ Usuário dispensou prompt de reinstalação')
    setShowPrompt(false)
    localStorage.setItem('pwa-reinstall-dismissed', Date.now().toString())
  }

  const handleReinstall = () => {
    console.log('🔄 Instruindo usuário a reinstalar PWA')
    
    // Mostrar instruções de reinstalação
    if (confirm(
      '📱 COMO REINSTALAR O APP:\n\n' +
      '1️⃣ Desinstale o app atual (pressione e segure o ícone)\n' +
      '2️⃣ Abra pdv.gruporaval.com.br no navegador\n' +
      '3️⃣ Instale novamente\n\n' +
      '✨ O app será reinstalado com modo fullscreen e melhorias!\n\n' +
      'Clique OK para abrir o site no navegador.'
    )) {
      // Abrir site no navegador
      window.open('https://pdv.gruporaval.com.br', '_blank')
      
      // Marcar como resolvido
      localStorage.removeItem('pwa-needs-reinstall')
      setShowPrompt(false)
    }
  }

  if (!showPrompt) {
    return null
  }

  return (
    <div className="fixed top-16 left-4 right-4 z-[9999] animate-slideDown">
      <div className="bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-lg shadow-2xl p-4">
        <div className="flex items-start gap-3">
          <div className="flex-shrink-0">
            <AlertTriangle className="w-6 h-6" />
          </div>
          
          <div className="flex-1 min-w-0">
            <h3 className="font-bold text-base mb-1">
              ⚠️ Reinstalação Necessária
            </h3>
            <p className="text-sm text-white/90 mb-3">
              Para ver o modo fullscreen e outras melhorias, você precisa <strong>reinstalar o app</strong>.
            </p>
            
            <div className="flex flex-wrap gap-2">
              <button
                onClick={handleReinstall}
                className="px-4 py-2 bg-white text-orange-600 font-bold text-sm rounded-lg hover:bg-orange-50 transition-all shadow-lg"
              >
                📱 Ver instruções
              </button>
              
              <button
                onClick={handleDismiss}
                className="px-3 py-2 bg-white/20 text-white text-sm rounded-lg hover:bg-white/30 transition-all"
              >
                Depois
              </button>
            </div>
          </div>
          
          <button
            onClick={handleDismiss}
            className="flex-shrink-0 p-1 hover:bg-white/10 rounded transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  )
}
