import { createClient } from '@supabase/supabase-js';

// Configurar CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function handler(req, res) {
  // Aplicar headers CORS
  Object.entries(corsHeaders).forEach(([key, value]) => {
    res.setHeader(key, value);
  });

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).json({});
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log('🔄 Extensão de assinatura - Dados recebidos:', req.body);

    const { email, payment_id } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email é obrigatório' });
    }

    // Configurar Supabase com fallback para múltiplas chaves
    const serviceKey = process.env.SUPABASE_SERVICE_KEY || 
                      process.env.SUPABASE_SERVICE_ROLE_KEY ||
                      process.env.SUPABASE_ANON_KEY;

    if (!process.env.SUPABASE_URL || !serviceKey) {
      return res.status(500).json({ 
        error: 'Configuração do Supabase incompleta',
        debug: {
          url_configured: !!process.env.SUPABASE_URL,
          service_key_configured: !!serviceKey
        }
      });
    }

    const supabase = createClient(
      process.env.SUPABASE_URL,
      serviceKey
    );

    // 1. Buscar assinatura atual
    const { data: subscription, error: subError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('email', email)
      .single();

    if (subError || !subscription) {
      console.error('❌ Erro ao buscar assinatura:', subError);
      return res.status(404).json({ 
        error: 'Assinatura não encontrada',
        details: subError?.message 
      });
    }

    console.log('📋 Assinatura atual:', {
      status: subscription.status,
      end_date: subscription.subscription_end_date
    });

    // 2. Calcular nova data de vencimento
    let newEndDate;
    const now = new Date();

    if (subscription.status === 'active' && subscription.subscription_end_date) {
      // Se tem assinatura ativa, somar 31 dias à data atual de vencimento
      const currentEndDate = new Date(subscription.subscription_end_date);
      
      // Se ainda não venceu, somar os dias restantes + 31 dias
      if (currentEndDate > now) {
        const daysRemaining = Math.ceil((currentEndDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
        console.log(`⏰ Dias restantes: ${daysRemaining}`);
        
        // Nova data = data atual + dias restantes + 31 dias novos
        newEndDate = new Date(now);
        newEndDate.setDate(newEndDate.getDate() + daysRemaining + 31);
        
        console.log(`✅ Extensão: ${daysRemaining} dias restantes + 31 dias novos = ${daysRemaining + 31} dias total`);
      } else {
        // Se já venceu, apenas adicionar 31 dias a partir de hoje
        newEndDate = new Date(now);
        newEndDate.setDate(newEndDate.getDate() + 31);
        
        console.log('🔄 Assinatura vencida, renovando por 31 dias a partir de hoje');
      }
    } else {
      // Se não tem assinatura ativa, criar nova com 31 dias
      newEndDate = new Date(now);
      newEndDate.setDate(newEndDate.getDate() + 31);
      
      console.log('🆕 Nova assinatura de 31 dias');
    }

    // 3. Atualizar assinatura
    const { data: updatedSub, error: updateError } = await supabase
      .from('subscriptions')
      .update({
        status: 'active',
        subscription_start_date: subscription.status === 'active' ? subscription.subscription_start_date : now.toISOString(),
        subscription_end_date: newEndDate.toISOString(),
        payment_status: 'paid',
        payment_id: payment_id || subscription.payment_id,
        updated_at: now.toISOString()
      })
      .eq('email', email)
      .select()
      .single();

    if (updateError) {
      console.error('❌ Erro ao atualizar assinatura:', updateError);
      return res.status(500).json({ 
        error: 'Erro ao estender assinatura',
        details: updateError.message 
      });
    }

    console.log('✅ Assinatura estendida com sucesso:', {
      new_end_date: newEndDate.toISOString(),
      status: 'active'
    });

    // 4. Calcular dias totais
    const totalDays = Math.ceil((newEndDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

    res.status(200).json({
      success: true,
      message: 'Assinatura estendida com sucesso',
      subscription: updatedSub,
      new_end_date: newEndDate.toISOString(),
      total_days: totalDays,
      extended_at: now.toISOString()
    });

  } catch (error) {
    console.error('❌ Erro interno:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}