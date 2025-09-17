export default async function handler(req, res) {
  // CORS headers mais permissivos para debugging
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE, PATCH');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent');
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');

  if (req.method === 'OPTIONS') {
    console.log('🔄 Test CORS Preflight handled successfully');
    res.status(200).end();
    return;
  }

  console.log('🧪 Test API accessed:', {
    method: req.method,
    origin: req.headers.origin,
    userAgent: req.headers['user-agent']?.substring(0, 100)
  });

  try {
    res.status(200).json({
      success: true,
      status: 'ok',
      message: 'API de teste funcionando perfeitamente!',
      timestamp: new Date().toISOString(),
      requestInfo: {
        method: req.method,
        origin: req.headers.origin,
        hasBody: !!req.body,
        contentType: req.headers['content-type']
      },
      environment: {
        hasSupabaseUrl: !!process.env.VITE_SUPABASE_URL,
        hasMPToken: !!process.env.VITE_MP_ACCESS_TOKEN,
        nodeEnv: process.env.NODE_ENV,
        vercelEnv: process.env.VERCEL_ENV
      }
    });
  } catch (error) {
    console.error('❌ Erro no endpoint de teste:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
}
