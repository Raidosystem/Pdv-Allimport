import { useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'

/**
 * Componente que redireciona para login quando app está instalado como PWA
 * Só funciona na raiz (/), permitindo landing page no navegador
 */
export function PWARedirect() {
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // Verificar se está no modo PWA (standalone)
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                        (window.navigator as any).standalone === true ||
                        document.referrer.includes('android-app://')

    // Só redirecionar se:
    // 1. Está na raiz (/)
    // 2. Está instalado como PWA
    // 3. Não está logado (sem token no localStorage)
    if (location.pathname === '/' && isStandalone) {
      const hasSession = localStorage.getItem('supabase.auth.token') !== null
      
      if (!hasSession) {
        console.log('🚀 PWA detectado - redirecionando para /login')
        navigate('/login', { replace: true })
      } else {
        console.log('🚀 PWA detectado - usuário já logado, indo para /dashboard')
        navigate('/dashboard', { replace: true })
      }
    }
  }, [location.pathname, navigate])

  return null // Componente invisível
}
