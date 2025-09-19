export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Ler token exatamente como os outros endpoints fazem - FORÇANDO TOKEN CORRETO
    const MP_ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    // Verificar qual token está sendo usado REALMENTE
    const tokenInfo = {
      token_exists: !!MP_ACCESS_TOKEN,
      token_length: MP_ACCESS_TOKEN?.length || 0,
      token_first_20: MP_ACCESS_TOKEN?.substring(0, 20) || 'N/A',
      token_last_10: MP_ACCESS_TOKEN?.substring(MP_ACCESS_TOKEN.length - 10) || 'N/A',
      is_env_placeholder: MP_ACCESS_TOKEN?.includes('process.env') || false,
      is_app_usr: MP_ACCESS_TOKEN?.startsWith('APP_USR-') || false,
      env_vite_exists: !!process.env.VITE_MP_ACCESS_TOKEN,
      env_mp_exists: !!process.env.MP_ACCESS_TOKEN,
      all_env_vars: Object.keys(process.env).filter(key => key.includes('MP_')).sort()
    };

    res.status(200).json({
      success: true,
      message: 'Token debug info',
      token_debug: tokenInfo,
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