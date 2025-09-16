// Sistema de detecção automática de versão
const CURRENT_VERSION = import.meta.env.VITE_APP_VERSION ?? 'dev'

export async function checkForUpdate() {
  // Em desenvolvimento, não verificar versões
  if (CURRENT_VERSION === 'dev' || window.location.hostname === 'localhost') {
    console.log('🔧 Desenvolvimento: version check desabilitado')
    return
  }

  try {
    const res = await fetch('/version.txt', { 
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate'
      }
    })
    
    if (!res.ok) {
      console.log('📱 Version check: version.txt não encontrado')
      return
    }
    
    const latest = (await res.text()).trim()
    
    if (latest && latest !== CURRENT_VERSION) {
      console.log(`🔄 Nova versão detectada: ${latest} (atual: ${CURRENT_VERSION})`)
      
      // Opção elegante: mostrar notificação e aguardar ação do usuário
      if (window.confirm('🚀 Nova versão disponível! Deseja atualizar agora?')) {
        window.location.reload()
      }
      
      // Para auto-reload silencioso, descomente a linha abaixo:
      // window.location.reload()
    } else {
      console.log(`✅ Versão atual: ${CURRENT_VERSION}`)
    }
  } catch (error) {
    console.log('📱 Version check error:', error)
  }
}

// Inicialização automática
export function initVersionCheck() {
  // Só funcionar em produção
  if (CURRENT_VERSION === 'dev' || window.location.hostname === 'localhost') {
    console.log('🔧 Version check desabilitado em desenvolvimento')
    return
  }
  
  // Verificar ao carregar a página
  checkForUpdate()
  
  // Verificar a cada 2 minutos (em produção)
  setInterval(checkForUpdate, 120_000) // 2 min
  
  // Verificar quando a janela ganha foco
  window.addEventListener('focus', checkForUpdate)
  
  // Verificar quando volta de visibilidade hidden
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
      checkForUpdate()
    }
  })
}