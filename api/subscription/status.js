import { createClient } from '@supabase/supabase-js';

// Configurar CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function handler(req, res) {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).json({});
  }

  // Only allow GET
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({ error: 'Email é obrigatório' });
    }

    console.log('🔍 Verificando status de assinatura para:', email);

    // Configurar Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_KEY
    );

    // Buscar assinatura
    const { data: subscription, error: subError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('email', email)
      .single();

    if (subError && subError.code !== 'PGRST116') {
      console.error('❌ Erro ao buscar assinatura:', subError);
      return res.status(500).json({ error: 'Erro ao buscar assinatura' });
    }

    // Buscar pagamentos
    const { data: payments, error: payError } = await supabase
      .from('payments')
      .select('*')
      .eq('payer_email', email)
      .order('created_at', { ascending: false });

    if (payError) {
      console.error('❌ Erro ao buscar pagamentos:', payError);
      return res.status(500).json({ error: 'Erro ao buscar pagamentos' });
    }

    const latestPayment = payments?.[0];

    const result = {
      subscription: subscription || null,
      latest_payment: latestPayment || null,
      subscription_active: subscription?.status === 'active',
      payment_approved: latestPayment?.mp_status === 'approved',
      needs_activation: subscription && latestPayment && 
                       latestPayment.mp_status === 'approved' && 
                       subscription.status !== 'active'
    };

    console.log('📊 Status resultado:', result);

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erro ao verificar status:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
