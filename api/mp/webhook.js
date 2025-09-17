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
      message: "Webhook Mercado Pago - Funcionando!",
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
      const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || "APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193";
      
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
        
        // Buscar email do pagador
        const userEmail = payment.payer?.email || payment.metadata?.email;
        
        if (userEmail) {
          console.log("📧 Processando assinatura para:", userEmail);
          
          const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
          const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
          
          // Chamar função de ativação de assinatura
          const rpcResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
            method: 'POST',
            headers: {
              apikey: SUPABASE_SERVICE_KEY,
              Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              user_email: userEmail,
              payment_id: paymentId.toString(),
              payment_method: payment.payment_method_id === 'pix' ? 'pix' : 'credit_card'
            })
          });

          console.log("📡 RPC response:", rpcResponse.status);
          
          if (!rpcResponse.ok) {
            const errorText = await rpcResponse.text();
            console.error("❌ RPC error:", errorText);
          } else {
            const result = await rpcResponse.json();
            console.log("✅ Subscription activated:", result);
          }
        } else {
          console.log("⚠️ No user email found in payment");
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