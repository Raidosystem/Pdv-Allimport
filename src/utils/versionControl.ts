// Sistema automático de detecção de nova versão e limpeza de cache
let currentVersion: string | null = null;
let versionCheckInterval: NodeJS.Timeout | null = null;

export interface VersionInfo {
  version: string;
  commit: string;
  branch: string;
  build: string;
  environment: string;
}

export async function checkVersionAndReload(): Promise<void> {
  try {
    console.log('🔍 Verificando nova versão...');
    
    // Força bypass de cache
    const res = await fetch('/version.json', { 
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      }
    });
    
    if (!res.ok) {
      console.warn('⚠️ Falha ao verificar versão');
      return;
    }
    
    const data: VersionInfo = await res.json();
    
    if (!currentVersion) {
      currentVersion = data.version;
      console.log(`✅ Versão atual: ${currentVersion}`);
      return;
    }
    
    if (currentVersion !== data.version) {
      console.log(`🔄 Nova versão detectada: ${data.version} (atual: ${currentVersion})`);
      
      // Limpar tudo antes de recarregar
      await hardResetCaches();
      
      // Mostrar notificação opcional
      showUpdateNotification();
      
      // Recarregar após 2 segundos
      setTimeout(() => {
        window.location.reload();
      }, 2000);
    }
    
  } catch (error) {
    console.warn('⚠️ Erro ao verificar versão:', error);
  }
}

export async function hardResetCaches(): Promise<void> {
  try {
    console.log('🧹 Limpando todos os caches...');
    
    // 1. Limpar Cache Storage (PWA/Service Worker)
    if ('caches' in window) {
      const cacheNames = await caches.keys();
      await Promise.all(
        cacheNames.map(cacheName => {
          console.log(`🗑️ Removendo cache: ${cacheName}`);
          return caches.delete(cacheName);
        })
      );
    }
    
    // 2. Desregistrar Service Workers
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(
        registrations.map(registration => {
          console.log('🗑️ Desregistrando Service Worker');
          return registration.unregister();
        })
      );
    }
    
    // 3. Limpar Session Storage (temporário)
    try {
      sessionStorage.clear();
      console.log('🗑️ Session Storage limpo');
    } catch (e) {
      console.warn('⚠️ Erro ao limpar sessionStorage:', e);
    }
    
    console.log('✅ Cache reset completo');
    
  } catch (error) {
    console.error('❌ Erro ao resetar cache:', error);
  }
}

export function showUpdateNotification(): void {
  // Criar toast de notificação
  const toast = document.createElement('div');
  toast.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: #10b981;
    color: white;
    padding: 12px 20px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    z-index: 9999;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 14px;
    font-weight: 500;
  `;
  toast.textContent = '🔄 Nova versão disponível! Atualizando...';
  
  document.body.appendChild(toast);
  
  // Remover após 3 segundos
  setTimeout(() => {
    toast.remove();
  }, 3000);
}

export function startVersionChecking(): void {
  // Verificar imediatamente
  checkVersionAndReload();
  
  // Verificar a cada 60 segundos
  versionCheckInterval = setInterval(checkVersionAndReload, 60000);
  
  console.log('✅ Sistema de auto-update iniciado');
}

export function stopVersionChecking(): void {
  if (versionCheckInterval) {
    clearInterval(versionCheckInterval);
    versionCheckInterval = null;
    console.log('⏹️ Sistema de auto-update parado');
  }
}

// Auto-iniciar em produção
if (typeof window !== 'undefined' && window.location.hostname !== 'localhost') {
  startVersionChecking();
}