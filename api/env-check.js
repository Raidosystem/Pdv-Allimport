export default function handler(req, res) {
  try {
    // Verificar todas as variáveis de ambiente do MercadoPago
    const envVars = {
      MP_ACCESS_TOKEN: process.env.MP_ACCESS_TOKEN ? 'Configurado ✅' : 'Não encontrado ❌',
      VITE_MP_ACCESS_TOKEN: process.env.VITE_MP_ACCESS_TOKEN ? 'Configurado ✅' : 'Não encontrado ❌',
      MP_PUBLIC_KEY: process.env.MP_PUBLIC_KEY ? 'Configurado ✅' : 'Não encontrado ❌',
      MP_CLIENT_ID: process.env.MP_CLIENT_ID ? 'Configurado ✅' : 'Não encontrado ❌',
      MP_CLIENT_SECRET: process.env.MP_CLIENT_SECRET ? 'Configurado ✅' : 'Não encontrado ❌',
      
      // Verificar tamanhos das variáveis (sem expor valores)
      MP_ACCESS_TOKEN_length: process.env.MP_ACCESS_TOKEN?.length || 0,
      VITE_MP_ACCESS_TOKEN_length: process.env.VITE_MP_ACCESS_TOKEN?.length || 0,
      
      // Verificar se são strings válidas
      MP_ACCESS_TOKEN_valid: process.env.MP_ACCESS_TOKEN && !process.env.MP_ACCESS_TOKEN.includes('YOUR_') ? '✅' : '❌',
      VITE_MP_ACCESS_TOKEN_valid: process.env.VITE_MP_ACCESS_TOKEN && !process.env.VITE_MP_ACCESS_TOKEN.includes('YOUR_') ? '✅' : '❌',
    };

    res.status(200).json({
      success: true,
      message: 'Diagnóstico das variáveis de ambiente',
      environment_vars: envVars,
      node_env: process.env.NODE_ENV,
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