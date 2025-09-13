// Endpoint de teste para debug do webhook
// Acesse: https://seu-dominio.vercel.app/api/mp/test-webhook?email=seu-email@exemplo.com

export default async function handler(req, res) {
  const startTime = Date.now();
  
  try {
    // Configuração do Supabase
    const SUPABASE_URL = process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.VITE_SUPABASE_ANON_KEY;

    const email = req.query.email;
    const paymentId = req.query.payment_id || `test-payment-${Date.now()}`;
    
    if (!email) {
      return res.status(400).json({
        error: "Parâmetro 'email' é obrigatório",
        example: "/api/mp/test-webhook?email=seu-email@exemplo.com"
      });
    }

    console.log("🧪 TESTE: Ativando assinatura para:", { email, paymentId });

    // Chamar a função SQL diretamente
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=representation"
      },
      body: JSON.stringify({
        user_email: email,
        payment_id: paymentId,
        payment_method: "pix"
      })
    });

    const responseText = await response.text();
    console.log("🔍 Resposta do Supabase:", {
      status: response.status,
      statusText: response.statusText,
      body: responseText
    });

    if (!response.ok) {
      return res.status(500).json({
        error: "Erro na chamada do Supabase",
        status: response.status,
        statusText: response.statusText,
        body: responseText,
        url: `${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`
      });
    }

    let result;
    try {
      result = JSON.parse(responseText);
    } catch (e) {
      result = responseText;
    }

    const processTime = Date.now() - startTime;

    res.status(200).json({
      success: true,
      message: "Teste de ativação de assinatura",
      input: { email, paymentId },
      result: result,
      processTime: `${processTime}ms`,
      timestamp: new Date().toISOString(),
      supabaseUrl: SUPABASE_URL,
      hasServiceKey: !!SUPABASE_SERVICE_KEY
    });

  } catch (error) {
    const processTime = Date.now() - startTime;
    console.error("❌ Erro no teste:", error);
    
    res.status(500).json({
      error: "Erro interno",
      message: error.message,
      stack: error.stack,
      processTime: `${processTime}ms`
    });
  }
}