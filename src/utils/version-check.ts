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
        'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0'
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
      
      // ⚠️ NÃO limpar cache aqui - deixar para o usuário decidir
      // O UpdateCard vai limpar quando o usuário clicar em "Recarregar Agora"
      
      // Executar callback se fornecido
      onNewVersion?.()
    }
    
    // Salva a versão atual como vista
    localStorage.setItem(VERSION_KEY, currentVersion)
    
  } catch (error) {
    console.warn('⚠️ Erro ao verificar versão:', error)
  }
}

/**
 * Limpa todos os caches do navegador
 */
export async function clearAllCaches(): Promise<void> {
  try {
    // 1. Limpar Cache API
    if ('caches' in window) {
      const cacheNames = await caches.keys()
      await Promise.all(
        cacheNames.map(cacheName => caches.delete(cacheName))
      )
      console.log('✅ Cache API limpo:', cacheNames.length, 'caches removidos')
    }

    // 2. Limpar Service Workers antigos (de forma segura)
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations()
      for (const reg of registrations) {
        try {
          await reg.unregister()
        } catch {
          // Service Worker ativo pode dar erro - será removido no próximo reload
          console.log('⚠️ Service Worker ativo, será removido no próximo carregamento')
        }
      }
      console.log('✅ Service Workers processados:', registrations.length)
    }

    // 3. Limpar dados de versão antigos
    const keysToRemove = []
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key && (key.includes('pdv-cache') || key.includes('backup') || key.includes('offline'))) {
        keysToRemove.push(key)
      }
    }
    keysToRemove.forEach(key => localStorage.removeItem(key))
    console.log('✅ LocalStorage cache limpo:', keysToRemove.length, 'items removidos')

    // 4. Limpar sessionStorage
    sessionStorage.clear()
    console.log('✅ SessionStorage limpo')

  } catch (error) {
    console.error('❌ Erro ao limpar cache:', error)
  }
}

/**
 * Compatibilidade com sistema antigo
 */
export async function checkForUpdate(): Promise<void> {
  return checkVersion(() => {
    console.log('🚀 ATUALIZAÇÃO DETECTADA - Recarregando automaticamente...')
    
    // Mostrar notificação antes de recarregar
    const notification = document.createElement('div')
    notification.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px 30px;
      border-radius: 12px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.3);
      z-index: 999999;
      font-family: system-ui, -apple-system, sans-serif;
      font-size: 16px;
      font-weight: 600;
      animation: slideIn 0.3s ease-out;
    `
    notification.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px;">
        <div style="font-size: 24px;">🚀</div>
        <div>
          <div>Nova versão disponível!</div>
          <div style="font-size: 14px; font-weight: 400; opacity: 0.9; margin-top: 4px;">
            Atualizando em 3 segundos...
          </div>
        </div>
      </div>
    `
    
    // Adicionar animação
    const style = document.createElement('style')
    style.textContent = `
      @keyframes slideIn {
        from {
          transform: translateX(400px);
          opacity: 0;
        }
        to {
          transform: translateX(0);
          opacity: 1;
        }
      }
    `
    document.head.appendChild(style)
    document.body.appendChild(notification)
    
    // Recarregar após 3 segundos
    setTimeout(() => {
      notification.remove()
      // Forçar reload MANTENDO o login (não altera URL)
      window.location.reload()
    }, 3000)
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
 * ⚠️ DESABILITADO: Agora usamos UpdateCard com botão manual
 */
export function initVersionCheck(): void {
  console.log('ℹ️ Sistema de atualização automática desabilitado. Usando UpdateCard manual.')
  // O UpdateCard agora gerencia as verificações e exibição
  return
}

/**
 * Limpa dados de versão (útil para testes)
 */
export function clearVersionData(): void {
  localStorage.removeItem(VERSION_KEY)
  console.log('🗑️ Dados de versão limpos')
}