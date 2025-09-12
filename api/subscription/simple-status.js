import { createClient } from '@supabase/supabase-js';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function handler(req, res) {
  // Handle CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).json({});
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({ error: 'Email é obrigatório' });
    }

    console.log('🔍 Verificando status simples para:', email);

    // Verificar se as variáveis de ambiente estão configuradas
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
      console.error('❌ Variáveis do Supabase não configuradas:', {
        SUPABASE_URL: !!process.env.SUPABASE_URL,
        SUPABASE_SERVICE_KEY: !!process.env.SUPABASE_SERVICE_KEY
      });
      
      return res.status(500).json({ 
        error: 'Configuração do servidor incompleta',
        debug: {
          supabase_url_configured: !!process.env.SUPABASE_URL,
          supabase_key_configured: !!process.env.SUPABASE_SERVICE_KEY
        }
      });
    }

    // Configurar Supabase com service key para acesso completo
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

    // Buscar pagamentos (últimos 5)
    const { data: payments, error: payError } = await supabase
      .from('payments')
      .select('*')
      .eq('payer_email', email)
      .order('created_at', { ascending: false })
      .limit(5);

    console.log('📊 Dados encontrados:', {
      subscription: !!subscription,
      payments: payments?.length || 0,
      subError: subError?.message,
      payError: payError?.message
    });

    const latestPayment = payments?.[0];
    const now = new Date();

    // Calcular status da assinatura
    let subscriptionActive = false;
    let accessAllowed = false;

    if (subscription) {
      if (subscription.status === 'active' && subscription.subscription_end_date) {
        const endDate = new Date(subscription.subscription_end_date);
        subscriptionActive = endDate > now;
        accessAllowed = subscriptionActive;
      } else if (subscription.status === 'trial' && subscription.trial_end_date) {
        const trialEnd = new Date(subscription.trial_end_date);
        accessAllowed = trialEnd > now;
      }
    }

    const result = {
      subscription: subscription || null,
      latest_payment: latestPayment || null,
      payments_history: payments || [],
      subscription_active: subscriptionActive,
      payment_approved: latestPayment?.mp_status === 'approved',
      access_allowed: accessAllowed,
      needs_activation: subscription && 
                       latestPayment && 
                       latestPayment.mp_status === 'approved' && 
                       !subscriptionActive,
      debug_info: {
        has_subscription: !!subscription,
        subscription_status: subscription?.status,
        payment_count: payments?.length || 0,
        latest_payment_status: latestPayment?.mp_status,
        errors: {
          subscription_error: subError?.message,
          payment_error: payError?.message
        }
      }
    };

    console.log('✅ Resultado final:', result);

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erro no status simples:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message,
      debug: 'Erro na API de status simples'
    });
  }
}
