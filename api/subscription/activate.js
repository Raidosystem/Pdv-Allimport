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

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email, payment_id } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email é obrigatório' });
    }

    console.log('🔄 Forçando ativação para:', { email, payment_id });

    // Configurar Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_KEY
    );

    // Se payment_id foi fornecido, verificar o pagamento primeiro
    if (payment_id) {
      console.log('🔍 Verificando pagamento:', payment_id);
      
      const { data: payment, error: paymentError } = await supabase
        .from('payments')
        .select('*')
        .eq('mp_payment_id', payment_id)
        .eq('payer_email', email)
        .single();

      if (paymentError || !payment) {
        return res.status(404).json({ 
          error: 'Pagamento não encontrado',
          details: paymentError?.message 
        });
      }

      if (payment.mp_status !== 'approved') {
        return res.status(400).json({ 
          error: 'Pagamento ainda não foi aprovado',
          status: payment.mp_status 
        });
      }

      console.log('✅ Pagamento confirmado como aprovado');
    } else {
      // Buscar o último pagamento aprovado
      const { data: payments, error: payError } = await supabase
        .from('payments')
        .select('*')
        .eq('payer_email', email)
        .eq('mp_status', 'approved')
        .order('created_at', { ascending: false })
        .limit(1);

      if (payError || !payments || payments.length === 0) {
        return res.status(404).json({ 
          error: 'Nenhum pagamento aprovado encontrado',
          details: payError?.message 
        });
      }

      payment_id = payments[0].mp_payment_id;
      console.log('📋 Usando último pagamento aprovado:', payment_id);
    }

    // Ativar assinatura
    console.log('🚀 Ativando assinatura via RPC...');
    
    const { data: activationResult, error: activationError } = await supabase.rpc(
      'activate_subscription_after_payment',
      {
        user_email: email,
        payment_id: payment_id,
        payment_method: 'pix'
      }
    );

    if (activationError) {
      console.error('❌ Erro na ativação RPC:', activationError);
      return res.status(500).json({ 
        error: 'Erro ao ativar assinatura',
        details: activationError.message 
      });
    }

    console.log('✅ Ativação concluída:', activationResult);

    // Verificar resultado final
    const { data: finalSubscription, error: finalError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('email', email)
      .single();

    if (finalError) {
      console.error('❌ Erro ao verificar resultado final:', finalError);
    }

    return res.status(200).json({
      success: true,
      message: 'Assinatura ativada com sucesso',
      activation_result: activationResult,
      subscription: finalSubscription,
      payment_id: payment_id
    });

  } catch (error) {
    console.error('❌ Erro ao forçar ativação:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
