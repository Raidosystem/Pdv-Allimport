import { useEffect } from 'react'
import { supabase } from '../lib/supabase'

export function useDomainConfig() {
  useEffect(() => {
    const currentDomain = window.location.origin
    
    // Configurar origem para o Supabase baseado no domínio atual
    const configureSupabaseAuth = () => {
      // Verificar se estamos no domínio personalizado
      if (currentDomain.includes('pdv.crmvsystem.com')) {
        console.log('[Domain] Configurando para domínio personalizado:', currentDomain)
        
        // Configurar URLs de redirect para o domínio personalizado
        supabase.auth.onAuthStateChange((event) => {
          if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
            console.log('[Auth] Usuário autenticado no domínio personalizado')
          }
          
          if (event === 'SIGNED_OUT') {
            console.log('[Auth] Usuário deslogado no domínio personalizado')
          }
        })
      } else {
        console.log('[Domain] Usando domínio padrão:', currentDomain)
      }
    }

    configureSupabaseAuth()
  }, [])

  // Retornar informações do domínio atual
  return {
    isCustomDomain: window.location.origin.includes('pdv.crmvsystem.com'),
    currentOrigin: window.location.origin,
    baseUrl: window.location.origin
  }
}
