export default async function handler(req, res) {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    // Verificar variáveis de ambiente (mascaradas por segurança)
    const serviceKey = process.env.SUPABASE_SERVICE_KEY || 
                      process.env.SUPABASE_SERVICE_ROLE_KEY ||
                      process.env.SUPABASE_ANON_KEY;

    const envCheck = {
      SUPABASE_URL: process.env.SUPABASE_URL ? 
        `${process.env.SUPABASE_URL.substring(0, 20)}...` : 
        'NÃO CONFIGURADA',
      SUPABASE_SERVICE_KEY: process.env.SUPABASE_SERVICE_KEY ? 
        `${process.env.SUPABASE_SERVICE_KEY.substring(0, 20)}...` : 
        'NÃO CONFIGURADA',
      SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY ? 
        `${process.env.SUPABASE_SERVICE_ROLE_KEY.substring(0, 20)}...` : 
        'NÃO CONFIGURADA',
      SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY ? 
        `${process.env.SUPABASE_ANON_KEY.substring(0, 20)}...` : 
        'NÃO CONFIGURADA',
      SERVICE_KEY_USADO: serviceKey ? 
        `${serviceKey.substring(0, 20)}...` : 
        'NENHUMA DISPONÍVEL',
      MP_ACCESS_TOKEN: process.env.MP_ACCESS_TOKEN ? 
        `${process.env.MP_ACCESS_TOKEN.substring(0, 20)}...` : 
        'NÃO CONFIGURADA',
      API_BASE_URL: process.env.API_BASE_URL || 'NÃO CONFIGURADA'
    };

    // Testar conexão com Supabase
    let supabaseTest = 'Erro: variáveis não configuradas';
    
    if (process.env.SUPABASE_URL && serviceKey) {
      try {
        const { createClient } = await import('@supabase/supabase-js');
        const supabase = createClient(
          process.env.SUPABASE_URL,
          serviceKey
        );
        
        // Teste simples - tentar listar tabelas
        const { data, error } = await supabase
          .from('subscriptions')
          .select('count')
          .limit(1);
        
        if (error) {
          supabaseTest = `Erro de conexão: ${error.message}`;
        } else {
          supabaseTest = 'Conexão OK ✅';
        }
      } catch (testError) {
        supabaseTest = `Erro no teste: ${testError.message}`;
      }
    }

    res.status(200).json({
      status: 'API Funcionando',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      variables: envCheck,
      supabase_test: supabaseTest,
      vercel_region: process.env.VERCEL_REGION || 'N/A'
    });

  } catch (error) {
    console.error('Erro no diagnóstico:', error);
    res.status(500).json({ 
      error: 'Erro interno',
      details: error.message 
    });
  }
}