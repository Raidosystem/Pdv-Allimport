/**
 * Utilitário para requisições críticas sem cache
 * Garante que dados importantes sempre vêm do servidor
 */

interface FetchOptions extends RequestInit {
  bypassCache?: boolean
}

/**
 * Fetch sem cache para dados críticos
 * @param url URL da requisição
 * @param options Opções do fetch
 * @returns Promise da resposta
 */
export async function fetchNoCache(url: string, options: FetchOptions = {}): Promise<Response> {
  const { bypassCache = true, ...fetchOptions } = options

  if (bypassCache) {
    // Adicionar timestamp para quebrar cache
    const separator = url.includes('?') ? '&' : '?'
    const timestampUrl = `${url}${separator}_t=${Date.now()}&_r=${Math.random()}`

    return fetch(timestampUrl, {
      ...fetchOptions,
      cache: 'no-store',
      headers: {
        'Cache-Control': 'no-store, no-cache, must-revalidate',
        'Pragma': 'no-cache',
        ...fetchOptions.headers
      }
    })
  }

  return fetch(url, fetchOptions)
}

/**
 * Fetch JSON sem cache
 * @param url URL da API
 * @param options Opções do fetch
 * @returns Promise dos dados JSON
 */
export async function fetchJsonNoCache<T = any>(url: string, options: FetchOptions = {}): Promise<T> {
  const response = await fetchNoCache(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    }
  })

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }

  return response.json()
}

/**
 * POST sem cache para dados críticos
 * @param url URL da API
 * @param data Dados para enviar
 * @param options Opções do fetch
 * @returns Promise da resposta
 */
export async function postNoCache<T = any>(
  url: string, 
  data: any, 
  options: FetchOptions = {}
): Promise<T> {
  return fetchJsonNoCache<T>(url, {
    method: 'POST',
    body: JSON.stringify(data),
    ...options
  })
}

/**
 * Configurar headers de no-cache para responses das APIs
 * @param response Response object do Vercel
 */
export function setNoCacheHeaders(response: any): void {
  if (response && response.setHeader) {
    response.setHeader('Cache-Control', 'no-store, must-revalidate')
    response.setHeader('Pragma', 'no-cache')
    response.setHeader('Expires', '0')
  }
}

/**
 * Verificar se dados estão em cache do navegador
 * @param key Chave para verificar
 * @returns true se possivelmente em cache
 */
export function isLikelyFromCache(response: Response): boolean {
  // Verificações heurísticas para cache
  const age = response.headers.get('age')
  const cacheControl = response.headers.get('cache-control')
  const etag = response.headers.get('etag')
  
  return !!(age || (cacheControl && !cacheControl.includes('no-cache')) || etag)
}

/**
 * Limpar cache específico do localStorage/sessionStorage
 * @param keys Chaves para limpar (opcional)
 */
export function clearLocalCache(keys?: string[]): void {
  if (keys) {
    keys.forEach(key => {
      localStorage.removeItem(key)
      sessionStorage.removeItem(key)
    })
  } else {
    // Limpar apenas chaves relacionadas ao PDV
    const pdvKeys = Object.keys(localStorage).filter(key => 
      key.startsWith('pdv_') || 
      key.startsWith('supabase') ||
      key.includes('auth') ||
      key.includes('version')
    )
    
    pdvKeys.forEach(key => {
      localStorage.removeItem(key)
      sessionStorage.removeItem(key)
    })
  }
  
  console.log('🗑️ Cache local limpo')
}

/**
 * Forçar reload completo sem cache
 */
export function forceReload(): void {
  // Limpar caches antes de recarregar
  clearLocalCache()
  
  // Recarregar forçando bypass do cache
  window.location.reload()
}