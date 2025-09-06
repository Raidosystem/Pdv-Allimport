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

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { email, admin_email } = req.body;

    // Verificar se quem está chamando é admin
    const adminEmails = [
      'admin@pdvallimport.com',
      'novaradiosystem@outlook.com',
      'cristiamribeiro@outlook.com'
    ];

    if (!admin_email || !adminEmails.includes(admin_email.toLowerCase())) {
      return res.status(403).json({ error: 'Acesso negado - apenas admins' });
    }

    if (!email) {
      return res.status(400).json({ error: 'Email do usuário é obrigatório' });
    }

    console.log('🆘 Bypass de emergência solicitado por:', admin_email, 'para:', email);

    // Configurar Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_KEY
    );

    // Criar ou atualizar assinatura para dar acesso imediato
    const subscriptionEnd = new Date();
    subscriptionEnd.setDate(subscriptionEnd.getDate() + 30); // 30 dias

    const { data: existingSubscription } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('email', email)
      .single();

    if (existingSubscription) {
      // Atualizar assinatura existente
      const { data, error } = await supabase
        .from('subscriptions')
        .update({
          status: 'active',
          subscription_start_date: new Date().toISOString(),
          subscription_end_date: subscriptionEnd.toISOString(),
          payment_status: 'paid',
          payment_method: 'admin_bypass',
          updated_at: new Date().toISOString()
        })
        .eq('email', email)
        .select()
        .single();

      if (error) {
        throw error;
      }

      console.log('✅ Assinatura atualizada via bypass');
      return res.status(200).json({
        success: true,
        message: 'Acesso liberado via bypass administrativo',
        subscription: data,
        bypass_type: 'update'
      });
    } else {
      // Criar nova assinatura
      const { data, error } = await supabase
        .from('subscriptions')
        .insert({
          email: email,
          status: 'active',
          subscription_start_date: new Date().toISOString(),
          subscription_end_date: subscriptionEnd.toISOString(),
          payment_status: 'paid',
          payment_method: 'admin_bypass',
          payment_amount: 59.90
        })
        .select()
        .single();

      if (error) {
        throw error;
      }

      console.log('✅ Nova assinatura criada via bypass');
      return res.status(200).json({
        success: true,
        message: 'Assinatura criada via bypass administrativo',
        subscription: data,
        bypass_type: 'create'
      });
    }

  } catch (error) {
    console.error('❌ Erro no bypass de emergência:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
}
