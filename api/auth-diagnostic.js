export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';
    
    // Verificar se o token está correto (sem expor o valor)
    const tokenInfo = {
      exists: !!MP_ACCESS_TOKEN,
      length: MP_ACCESS_TOKEN?.length || 0,
      startsWithTest: MP_ACCESS_TOKEN?.startsWith('TEST-') || false,
      startsWithApp: MP_ACCESS_TOKEN?.startsWith('APP_USR-') || false,
      isPlaceholder: MP_ACCESS_TOKEN?.includes('process.env') || false,
      first10chars: MP_ACCESS_TOKEN?.substring(0, 10) || 'N/A',
      last4chars: MP_ACCESS_TOKEN?.substring(MP_ACCESS_TOKEN.length - 4) || 'N/A'
    };

    // Teste simples da API do MP
    res.status(200).json({
      success: true,
      message: 'Token diagnosis',
      token_info: tokenInfo,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}