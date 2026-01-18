import { useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'

/**
 * Verifica se está no modo PWA
 */
export function isPWA(): boolean {
  return window.matchMedia('(display-mode: standalone)').matches ||
         (window.navigator as any).standalone === true ||
         document.referrer.includes('android-app://') ||
         window.matchMedia('(display-mode: fullscreen)').matches ||
         window.matchMedia('(display-mode: minimal-ui)').matches
}

/**
 * Componente que redireciona para login quando app está instalado como PWA
 * Funciona em qualquer rota se for PWA
 */
export function PWARedirect() {
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // Verificar se está no modo PWA
    const isStandalone = isPWA()

    console.log('🔍 PWARedirect - pathname:', location.pathname, 'isPWA:', isStandalone)
    console.log('🔍 User-Agent:', navigator.userAgent)
    console.log('🔍 Display mode:', window.matchMedia('(display-mode: standalone)').matches)

    // Se está no PWA e na raiz, redirecionar IMEDIATAMENTE
    if (location.pathname === '/' && isStandalone) {
      // Verificar se tem sessão ativa do Supabase
      const supabaseSession = localStorage.getItem('sb-kmcaaqetxtwkdcczdomw-auth-token')
      const hasSession = supabaseSession !== null
      
      if (!hasSession) {
        console.log('🚀 PWA detectado - redirecionando IMEDIATAMENTE para /login')
        navigate('/login', { replace: true })
      } else {
        console.log('🚀 PWA detectado - usuário já logado, indo para /dashboard')
        navigate('/dashboard', { replace: true })
      }
    }
  }, [location.pathname, navigate])

  return null // Componente invisível
}

