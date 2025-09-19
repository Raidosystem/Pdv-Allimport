// API para verificar status detalhado de um pagamento específico
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const { paymentId } = req.query;
    
    if (!paymentId) {
      return res.status(400).json({ error: 'paymentId é obrigatório' });
    }

    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';
    
    console.log(`🔍 Verificando pagamento ${paymentId} no MP...`);

    // Buscar detalhes completos no MP
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    if (!mpResponse.ok) {
      const errorText = await mpResponse.text();
      throw new Error(`MP API Error: ${mpResponse.status} - ${errorText}`);
    }

    const payment = await mpResponse.json();
    
    console.log('📊 Dados completos do pagamento:', {
      id: payment.id,
      status: payment.status,
      status_detail: payment.status_detail,
      date_created: payment.date_created,
      date_approved: payment.date_approved,
      metadata: payment.metadata
    });

    // Verificar se há dados no Supabase
    let supabaseData = null;
    try {
      const SUPABASE_URL = process.env.VITE_SUPABASE_URL || "process.env.VITE_SUPABASE_URL";
      const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;
      
      if (SUPABASE_ANON_KEY) {
        const supabaseResponse = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?payment_id=eq.${paymentId}&select=*`, {
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json'
          }
        });
        
        if (supabaseResponse.ok) {
          const data = await supabaseResponse.json();
          supabaseData = data.length > 0 ? data[0] : null;
          console.log('📊 Dados do Supabase:', supabaseData);
        }
      }
    } catch (supabaseError) {
      console.log('⚠️ Erro ao verificar Supabase:', supabaseError.message);
    }

    res.status(200).json({
      success: true,
      mercadoPago: {
        id: payment.id,
        status: payment.status,
        status_detail: payment.status_detail,
        payment_method_id: payment.payment_method_id,
        transaction_amount: payment.transaction_amount,
        date_created: payment.date_created,
        date_approved: payment.date_approved,
        date_last_updated: payment.date_last_updated,
        metadata: payment.metadata,
        notification_url: payment.notification_url
      },
      supabase: supabaseData,
      analysis: {
        isPaid: payment.status === 'approved',
        isPending: payment.status === 'pending',
        hasSupabaseRecord: !!supabaseData,
        syncStatus: supabaseData ? 
          (payment.status === 'approved' && supabaseData.status === 'active' ? 'sync' : 'desync') 
          : 'no_record'
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro ao verificar pagamento:', error);
    
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}