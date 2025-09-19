// Middleware de segurança para bloquear endpoints de debug em produção
export function blockDebugInProduction(req, res, next) {
  // Se estiver em produção, bloquear completamente
  if (process.env.NODE_ENV === 'production') {
    return res.status(404).json({ 
      error: 'Not Found',
      message: 'Debug endpoints are disabled in production'
    });
  }

  // Em desenvolvimento, verificar se tem autorização de admin
  const authHeader = req.headers.authorization;
  const debugToken = process.env.DEBUG_TOKEN;
  
  // Se há token configurado, exigir autenticação
  if (debugToken && authHeader !== `Bearer ${debugToken}`) {
    return res.status(401).json({ 
      error: 'Unauthorized',
      message: 'Debug access requires valid token' 
    });
  }

  // Adicionar headers de segurança para debug
  res.setHeader('X-Robots-Tag', 'noindex, nofollow');
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');
  
  if (typeof next === 'function') {
    next();
  }
}

// Middleware específico para endpoints Vercel
export default function debugProtection(handler) {
  return async (req, res) => {
    // Aplicar proteção
    blockDebugInProduction(req, res, () => {
      // Se passou na proteção, executar o handler original
      return handler(req, res);
    });
  };
}

// Utilitário para sanitizar logs (remover secrets)
export function sanitizeForLog(obj) {
  const sanitized = { ...obj };
  const sensitiveKeys = [
    'token', 'key', 'secret', 'password', 'access_token', 
    'service_key', 'authorization', 'cookie'
  ];
  
  for (const [key, value] of Object.entries(sanitized)) {
    const lowerKey = key.toLowerCase();
    if (sensitiveKeys.some(sensitive => lowerKey.includes(sensitive))) {
      if (typeof value === 'string' && value.length > 10) {
        sanitized[key] = value.substring(0, 8) + '***HIDDEN***';
      } else {
        sanitized[key] = '***HIDDEN***';
      }
    }
  }
  
  return sanitized;
}