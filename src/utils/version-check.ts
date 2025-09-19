/**
 * Sistema de Verificação de Versão - Anti Cache
 * Detecta novas versões e exibe banner de atualização
 */

const VERSION_KEY = 'pdv_version_seen'
const CURRENT_VERSION = import.meta.env.VITE_APP_VERSION ?? 'dev'

export interface VersionInfo {
  version: string
  commit?: string
  build?: string
}

/**
 * Verifica se há nova versão disponível
 * @param onNewVersion Callback executado quando nova versão é detectada
 */
export async function checkVersion(onNewVersion?: () => void): Promise<void> {
  // Em desenvolvimento, não verificar versões
  if (CURRENT_VERSION === 'dev' || window.location.hostname === 'localhost') {
    console.log('🔧 Desenvolvimento: version check desabilitado')
    return
  }

  try {
    console.log('🔍 Verificando nova versão...')
    
    const response = await fetch('/version.json', { 
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-store, no-cache, must-revalidate'
      }
    })
    
    if (!response.ok) {
      console.warn('⚠️ Não foi possível verificar versão')
      return
    }
    
    const versionInfo: VersionInfo = await response.json()
    const lastSeenVersion = localStorage.getItem(VERSION_KEY)
    const currentVersion = `${versionInfo.version}-${versionInfo.commit ?? ''}-${versionInfo.build ?? ''}`
    
    console.log('📋 Versão atual:', currentVersion)
    console.log('📋 Última vista:', lastSeenVersion)
    
    // Se já viu uma versão e agora é diferente = nova versão
    if (lastSeenVersion && lastSeenVersion !== currentVersion) {
      console.log('🆕 Nova versão detectada!')
      onNewVersion?.()
    }
    
    // Salva a versão atual como vista
    localStorage.setItem(VERSION_KEY, currentVersion)
    
  } catch (error) {
    console.warn('⚠️ Erro ao verificar versão:', error)
  }
}

/**
 * Compatibilidade com sistema antigo
 */
export async function checkForUpdate(): Promise<void> {
  return checkVersion(() => {
    if (window.confirm('🚀 Nova versão disponível! Deseja atualizar agora?')) {
      window.location.reload()
    }
  })
}

/**
 * Força verificação de versão a cada N minutos
 * @param intervalMinutes Intervalo em minutos (padrão: 5)
 * @param onNewVersion Callback para nova versão
 */
export function startVersionCheck(
  intervalMinutes: number = 5,
  onNewVersion?: () => void
): () => void {
  // Verifica imediatamente
  checkVersion(onNewVersion)
  
  // Configura intervalo
  const intervalId = setInterval(() => {
    checkVersion(onNewVersion)
  }, intervalMinutes * 60 * 1000)
  
  // Retorna função para limpar o intervalo
  return () => clearInterval(intervalId)
}

/**
 * Inicialização automática do sistema de versão
 */
export function initVersionCheck(): void {
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

/**
 * Limpa dados de versão (útil para testes)
 */
export function clearVersionData(): void {
  localStorage.removeItem(VERSION_KEY)
  console.log('🗑️ Dados de versão limpos')
}