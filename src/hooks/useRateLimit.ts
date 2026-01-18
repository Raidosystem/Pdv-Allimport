import { useState, useCallback, useRef } from 'react'
import { toast } from 'react-hot-toast'

/**
 * Rate Limiter - Previne requisições excessivas
 * 
 * Protege contra ataques de força bruta e DDoS
 */

interface RateLimitConfig {
  maxAttempts: number // Número máximo de tentativas
  windowMs: number // Janela de tempo em milissegundos
  blockDurationMs?: number // Tempo de bloqueio após exceder limite
}

interface RateLimitState {
  attempts: number
  firstAttempt: number
  isBlocked: boolean
  blockUntil?: number
}

const rateLimitStore = new Map<string, RateLimitState>()

/**
 * Hook para rate limiting em operações sensíveis
 * 
 * @example
 * ```tsx
 * function LoginForm() {
 *   const { checkRateLimit, remainingAttempts } = useRateLimit('login', {
 *     maxAttempts: 5,
 *     windowMs: 60000, // 1 minuto
 *     blockDurationMs: 300000 // 5 minutos de bloqueio
 *   })
 * 
 *   const handleLogin = async () => {
 *     if (!checkRateLimit()) {
 *       toast.error('Muitas tentativas. Aguarde alguns minutos.')
 *       return
 *     }
 *     // Continuar com login...
 *   }
 * }
 * ```
 */
export function useRateLimit(key: string, config: RateLimitConfig) {
  const [state, setState] = useState<RateLimitState>(() => {
    return rateLimitStore.get(key) || {
      attempts: 0,
      firstAttempt: Date.now(),
      isBlocked: false
    }
  })

  const timerRef = useRef<NodeJS.Timeout | undefined>(undefined)

  /**
   * Verifica se a operação pode ser executada
   * Retorna true se permitido, false se bloqueado
   */
  const checkRateLimit = useCallback((): boolean => {
    const now = Date.now()

    // Verificar se está bloqueado
    if (state.blockUntil && now < state.blockUntil) {
      const remainingSeconds = Math.ceil((state.blockUntil - now) / 1000)
      toast.error(`Bloqueado temporariamente. Aguarde ${remainingSeconds}s`)
      return false
    }

    // Resetar contador se a janela de tempo passou
    if (now - state.firstAttempt > config.windowMs) {
      const newState = {
        attempts: 1,
        firstAttempt: now,
        isBlocked: false
      }
      rateLimitStore.set(key, newState)
      setState(newState)
      return true
    }

    // Incrementar tentativas
    const newAttempts = state.attempts + 1

    // Verificar se excedeu o limite
    if (newAttempts > config.maxAttempts) {
      const blockUntil = now + (config.blockDurationMs || config.windowMs * 5)
      const newState = {
        ...state,
        attempts: newAttempts,
        isBlocked: true,
        blockUntil
      }
      rateLimitStore.set(key, newState)
      setState(newState)

      // Resetar após o bloqueio
      if (timerRef.current) clearTimeout(timerRef.current)
      timerRef.current = setTimeout(() => {
        const resetState = {
          attempts: 0,
          firstAttempt: Date.now(),
          isBlocked: false
        }
        rateLimitStore.set(key, resetState)
        setState(resetState)
      }, config.blockDurationMs || config.windowMs * 5)

      return false
    }

    // Atualizar estado
    const newState = {
      ...state,
      attempts: newAttempts
    }
    rateLimitStore.set(key, newState)
    setState(newState)

    return true
  }, [key, config, state])

  /**
   * Reseta o contador de tentativas
   */
  const reset = useCallback(() => {
    const newState = {
      attempts: 0,
      firstAttempt: Date.now(),
      isBlocked: false
    }
    rateLimitStore.set(key, newState)
    setState(newState)
    if (timerRef.current) clearTimeout(timerRef.current)
  }, [key])

  /**
   * Tentativas restantes antes do bloqueio
   */
  const remainingAttempts = Math.max(0, config.maxAttempts - state.attempts)

  /**
   * Tempo restante de bloqueio (em segundos)
   */
  const blockTimeRemaining = state.blockUntil
    ? Math.max(0, Math.ceil((state.blockUntil - Date.now()) / 1000))
    : 0

  return {
    checkRateLimit,
    reset,
    remainingAttempts,
    isBlocked: state.isBlocked,
    blockTimeRemaining,
    attempts: state.attempts
  }
}

/**
 * Função helper para rate limiting em APIs
 */
export function createRateLimiter(config: RateLimitConfig) {
  const store = new Map<string, RateLimitState>()

  return {
    check: (identifier: string): { allowed: boolean; retryAfter?: number } => {
      const now = Date.now()
      const state = store.get(identifier)

      if (!state) {
        store.set(identifier, {
          attempts: 1,
          firstAttempt: now,
          isBlocked: false
        })
        return { allowed: true }
      }

      // Verificar se está bloqueado
      if (state.blockUntil && now < state.blockUntil) {
        return {
          allowed: false,
          retryAfter: Math.ceil((state.blockUntil - now) / 1000)
        }
      }

      // Resetar se passou a janela de tempo
      if (now - state.firstAttempt > config.windowMs) {
        store.set(identifier, {
          attempts: 1,
          firstAttempt: now,
          isBlocked: false
        })
        return { allowed: true }
      }

      // Incrementar tentativas
      const newAttempts = state.attempts + 1

      if (newAttempts > config.maxAttempts) {
        const blockUntil = now + (config.blockDurationMs || config.windowMs * 5)
        store.set(identifier, {
          ...state,
          attempts: newAttempts,
          isBlocked: true,
          blockUntil
        })
        return {
          allowed: false,
          retryAfter: Math.ceil((blockUntil - now) / 1000)
        }
      }

      store.set(identifier, {
        ...state,
        attempts: newAttempts
      })

      return { allowed: true }
    },

    reset: (identifier: string) => {
      store.delete(identifier)
    }
  }
}

/**
 * Rate limiters pré-configurados para operações comuns
 */
export const rateLimiters = {
  login: createRateLimiter({
    maxAttempts: 5,
    windowMs: 60000, // 1 minuto
    blockDurationMs: 300000 // 5 minutos
  }),

  api: createRateLimiter({
    maxAttempts: 100,
    windowMs: 60000, // 100 requisições por minuto
    blockDurationMs: 60000 // 1 minuto
  }),

  payment: createRateLimiter({
    maxAttempts: 3,
    windowMs: 300000, // 3 tentativas em 5 minutos
    blockDurationMs: 600000 // 10 minutos
  }),

  export: createRateLimiter({
    maxAttempts: 10,
    windowMs: 3600000, // 10 exportações por hora
    blockDurationMs: 3600000 // 1 hora
  })
}
