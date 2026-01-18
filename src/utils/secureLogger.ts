/**
 * Sistema de Logs Seguro
 * 
 * Remove automaticamente logs detalhados em produção
 * Mantém apenas logs essenciais para debugging
 */

const isDev = import.meta.env.DEV
const isProd = import.meta.env.PROD

/**
 * Logger seguro que só exibe logs em desenvolvimento
 */
export const logger = {
  /**
   * Log de desenvolvimento (só aparece em DEV)
   */
  dev: (...args: any[]) => {
    if (isDev) {
      console.log(...args)
    }
  },

  /**
   * Log de informação (aparece sempre, mas sanitizado em PROD)
   */
  info: (...args: any[]) => {
    if (isDev) {
      console.log('ℹ️', ...args)
    } else {
      // Em produção, log simplificado
      console.log('ℹ️', args[0])
    }
  },

  /**
   * Log de aviso (aparece sempre)
   */
  warn: (...args: any[]) => {
    console.warn('⚠️', ...args)
  },

  /**
   * Log de erro (aparece sempre, mas sem dados sensíveis em PROD)
   */
  error: (...args: any[]) => {
    if (isDev) {
      console.error('❌', ...args)
    } else {
      // Em produção, não expor stack traces completos
      const errorMsg = args[0]
      console.error('❌', typeof errorMsg === 'string' ? errorMsg : 'Erro na aplicação')
    }
  },

  /**
   * Log de sucesso (aparece sempre)
   */
  success: (...args: any[]) => {
    if (isDev) {
      console.log('✅', ...args)
    } else {
      console.log('✅', args[0])
    }
  },

  /**
   * Log de debug detalhado (NUNCA aparece em produção)
   * Use para dados sensíveis, tokens, senhas, etc.
   */
  debug: (...args: any[]) => {
    if (isDev) {
      console.log('🔍 [DEBUG]', ...args)
    }
    // Em produção, completamente silencioso
  },

  /**
   * Log de performance (só em DEV)
   */
  perf: (label: string, fn: () => void) => {
    if (isDev) {
      console.time(`⏱️ ${label}`)
      fn()
      console.timeEnd(`⏱️ ${label}`)
    } else {
      fn()
    }
  },

  /**
   * Grupo de logs (só em DEV)
   */
  group: (label: string, fn: () => void) => {
    if (isDev) {
      console.group(label)
      fn()
      console.groupEnd()
    } else {
      fn()
    }
  }
}

/**
 * Helper para sanitizar dados antes de logar
 */
export function sanitizeForLog(data: any): any {
  if (isProd) {
    // Em produção, não logar nenhum dado sensível
    return '[DADOS OCULTOS EM PRODUÇÃO]'
  }

  // Em desenvolvimento, tentar remover campos sensíveis
  if (typeof data === 'object' && data !== null) {
    const sanitized = { ...data }
    const sensitiveKeys = ['password', 'token', 'secret', 'key', 'authorization', 'api_key']
    
    for (const key in sanitized) {
      if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk))) {
        sanitized[key] = '[REDACTED]'
      }
    }
    
    return sanitized
  }

  return data
}

/**
 * Exemplo de uso:
 * 
 * ```typescript
 * import { logger, sanitizeForLog } from '@/utils/secureLogger'
 * 
 * // Log de desenvolvimento (não aparece em produção)
 * logger.dev('🔄 Carregando dados:', data)
 * 
 * // Log de informação (simplificado em produção)
 * logger.info('Usuário logado com sucesso')
 * 
 * // Log de erro (sanitizado em produção)
 * logger.error('Erro ao salvar:', error)
 * 
 * // Log de debug (NUNCA aparece em produção)
 * logger.debug('Token recebido:', token)
 * 
 * // Sanitizar dados antes de logar
 * logger.info('Dados do usuário:', sanitizeForLog(userData))
 * ```
 */
