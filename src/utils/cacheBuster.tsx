import { useEffect } from 'react'

// Declarar tipo global para window
declare global {
  interface Window {
    showCacheClearButton: () => void
  }
}

/**
 * Hook para detectar e resolver problemas de cache
 */
export function useCacheBuster() {
  useEffect(() => {
    // Detectar se a página está em branco (possível problema de cache)
    const detectBlankPage = () => {
      const hasContent = document.body.children.length > 0
      const rootElement = document.getElementById('root')
      const hasReactRoot = rootElement ? rootElement.children.length > 0 : false
      
      if (!hasContent || !hasReactRoot) {
        console.warn('🔄 Página em branco detectada - possível problema de cache')
        
        // Limpar todos os caches do navegador
        if ('caches' in window) {
          caches.keys().then(names => {
            names.forEach(name => {
              caches.delete(name)
              console.log('🗑️ Cache removido:', name)
            })
          })
        }
        
        // Limpar localStorage e sessionStorage
        localStorage.clear()
        sessionStorage.clear()
        
        // Forçar reload sem cache
        setTimeout(() => {
          window.location.reload()
        }, 1000)
      }
    }
    
    // Verificar após 3 segundos se a página carregou
    const timer = setTimeout(detectBlankPage, 3000)
    
    return () => clearTimeout(timer)
  }, [])

  // Função manual para limpar cache
  const clearAllCache = async () => {
    try {
      // Limpar cache do service worker
      if ('caches' in window) {
        const cacheNames = await caches.keys()
        await Promise.all(
          cacheNames.map(cacheName => caches.delete(cacheName))
        )
        console.log('✅ Todos os caches removidos')
      }
      
      // Limpar storage
      localStorage.clear()
      sessionStorage.clear()
      
      // Forçar reload
      window.location.reload()
    } catch (error) {
      console.error('❌ Erro ao limpar cache:', error)
    }
  }
  
  return { clearAllCache }
}

/**
 * Componente para mostrar botão de limpeza de cache em caso de erro
 */
export function CacheErrorBoundary({ children }: { children: React.ReactNode }) {
  const { clearAllCache } = useCacheBuster()
  
  return (
    <div>
      {children}
      
      {/* Botão de emergência para limpar cache */}
      <div 
        style={{
          position: 'fixed',
          bottom: '10px',
          right: '10px',
          zIndex: 9999,
          display: 'none'
        }}
        id="cache-clear-button"
      >
        <button
          onClick={clearAllCache}
          style={{
            backgroundColor: '#ef4444',
            color: 'white',
            border: 'none',
            padding: '8px 12px',
            borderRadius: '4px',
            fontSize: '12px',
            cursor: 'pointer'
          }}
        >
          🔄 Limpar Cache
        </button>
      </div>
    </div>
  )
}

// Função global para mostrar botão de cache em caso de erro
window.showCacheClearButton = () => {
  const button = document.getElementById('cache-clear-button')
  if (button) {
    button.style.display = 'block'
  }
}