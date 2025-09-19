// 🚨 PROTEÇÃO SIMPLES PARA ENDPOINTS DE DEBUG

// Cole este código no INÍCIO de cada arquivo debug-*.js:

export default async function handler(req, res) {
  // BLOQUEAR COMPLETAMENTE EM PRODUÇÃO
  if (process.env.NODE_ENV === 'production') {
    return res.status(404).json({ error: 'Not Found' });
  }
  
  // Log de acesso para auditoria
  console.warn(`🚨 DEBUG ENDPOINT ACCESSED: ${req.url} from ${req.headers['x-forwarded-for'] || req.connection.remoteAddress}`);
  
  // Resto do código original aqui...
}