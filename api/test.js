export default async function handler(req, res) {
  // Configurar CORS mais permissivo
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Resposta simples de teste
    res.status(200).json({
      status: 'ok',
      message: 'API funcionando',
      timestamp: new Date().toISOString(),
      environment: 'production',
      method: req.method,
      url: req.url
    });
  } catch (error) {
    console.error('❌ Erro no endpoint de teste:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
}
