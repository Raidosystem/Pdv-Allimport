export const config = {
  runtime: 'nodejs'
}

export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type,X-Signature,X-Request-Id');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'GET') {
    return res.status(200).json({ 
      message: "Webhook MP v3 - Status OK",
      timestamp: new Date().toISOString(),
      env: {
        hasMP_TOKEN: !!(process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN),
        hasMP_SECRET: !!process.env.MP_WEBHOOK_SECRET,
        hasSUPABASE_URL: !!(process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL),
        hasSUPABASE_KEY: !!(process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY)
      }
    });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log("🎯 Webhook POST recebido");
    
    // Ler body de forma simples
    let body = '';
    await new Promise((resolve, reject) => {
      req.on('data', chunk => body += chunk.toString());
      req.on('end', resolve);
      req.on('error', reject);
    });

    const payload = JSON.parse(body);
    const paymentId = payload?.data?.id;
    
    console.log("📦 Payload:", { type: payload?.type, action: payload?.action, paymentId });

    if (payload?.type === 'payment' && paymentId) {
      console.log("💳 Processando payment:", paymentId);
      
      // Buscar detalhes do pagamento
      const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || "process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN";
      
      const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
        headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` }
      });

      if (!mpResponse.ok) {
        console.log("❌ Erro MP API:", mpResponse.status);
        return res.status(200).json({ ok: true, error: "MP API error logged" });
      }

      const payment = await mpResponse.json();
      console.log("✅ Payment details:", { 
        id: payment.id, 
        status: payment.status,
        metadata: payment.metadata 
      });

      if (payment.status === 'approved') {
        console.log("🎉 Payment approved!");
        
        // Chamar função RPC se tiver company_id
        if (payment.metadata?.company_id) {
          const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "process.env.VITE_SUPABASE_URL";
          const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
          
          const rpcResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/extend_company_paid_until_v2`, {
            method: 'POST',
            headers: {
              apikey: SUPABASE_SERVICE_KEY,
              Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              p_mp_payment_id: parseInt(paymentId),
              p_company_id: payment.metadata.company_id,
              p_order_id: payment.metadata.order_id || null
            })
          });

          console.log("📡 RPC response:", rpcResponse.status);
          
          if (!rpcResponse.ok) {
            const errorText = await rpcResponse.text();
            console.error("❌ RPC error:", errorText);
          } else {
            console.log("✅ Company period extended!");
          }
        } else {
          console.log("⚠️ No company_id in metadata");
        }
      }
    }

    return res.status(200).json({ 
      ok: true, 
      processed: paymentId,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error("❌ Webhook error:", error);
    return res.status(200).json({ 
      ok: true, 
      error: "Logged but returning 200",
      timestamp: new Date().toISOString()
    });
  }
}