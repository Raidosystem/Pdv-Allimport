// runtime node.js 
export const config = {
  runtime: 'nodejs',
  api: {
    bodyParser: false, // raw body necessário
  },
}

/**
 * Webhook simplificado para debug
 */
export default async function handler(req, res) {
  console.log("🎯 Webhook chamado - método:", req.method);
  
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,X-Signature,X-Request-Id');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    if (req.method === 'GET') {
      console.log("📋 GET request - retornando status");
      res.status(200).json({ 
        message: "Webhook MP - GET OK",
        timestamp: new Date().toISOString(),
        env: {
          hasMP_TOKEN: !!(process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN),
          hasMP_SECRET: !!process.env.MP_WEBHOOK_SECRET,
          hasSUPABASE_URL: !!(process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL),
          hasSUPABASE_KEY: !!(process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY),
          nodeEnv: process.env.NODE_ENV
        }
      });
      return;
    }

    if (req.method === 'POST') {
      console.log("📦 POST request - processando webhook");
      
      // Ler body simples
      let body = '';
      req.on('data', chunk => {
        body += chunk.toString();
      });
      
      req.on('end', () => {
        try {
          const payload = JSON.parse(body);
          console.log("✅ Payload recebido:", {
            type: payload?.type,
            action: payload?.action,
            data_id: payload?.data?.id
          });
          
          res.status(200).json({ 
            ok: true, 
            received: payload?.data?.id,
            timestamp: new Date().toISOString(),
            message: "Webhook processado com sucesso (modo debug)"
          });
        } catch (parseError) {
          console.error("❌ Erro ao parsear payload:", parseError);
          res.status(200).json({ 
            ok: true, 
            error: "Parse error but returning 200",
            timestamp: new Date().toISOString()
          });
        }
      });

      req.on('error', (error) => {
        console.error("❌ Erro ao ler request:", error);
        res.status(200).json({ 
          ok: true, 
          error: "Request error but returning 200",
          timestamp: new Date().toISOString()
        });
      });

      return;
    }

    // Método não suportado
    res.status(405).json({ error: 'Method not allowed' });

  } catch (error) {
    console.error("❌ Erro geral no webhook:", error);
    
    // SEMPRE retornar 200 para evitar reenvios
    res.status(200).json({ 
      ok: true, 
      error: "General error but returning 200",
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
}