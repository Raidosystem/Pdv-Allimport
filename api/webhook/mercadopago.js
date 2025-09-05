import { MercadoPagoConfig, Payment } from 'mercadopago';
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
    console.log('🔔 Webhook Mercado Pago recebido:', req.body);

    const { type, data } = req.body;

    if (type === 'payment') {
      const paymentId = data.id;
      
      // Configurar Mercado Pago
      const client = new MercadoPagoConfig({
        accessToken: process.env.MP_ACCESS_TOKEN,
        options: {
          timeout: 5000
        }
      });

      const payment = new Payment(client);

      // Buscar dados do pagamento
      const response = await payment.get({
        id: paymentId
      });
      const paymentResult = response;

      console.log(`💳 Pagamento ${paymentId}: ${paymentResult.status}`);

      // Configurar Supabase
      const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_SERVICE_KEY
      );

      // Atualizar pagamento no Supabase
      const { data: updateData, error: updateError } = await supabase
        .from('payments')
        .update({
          mp_status: paymentResult.status,
          mp_status_detail: paymentResult.status_detail,
          webhook_data: paymentResult,
          updated_at: new Date().toISOString()
        })
        .eq('mp_payment_id', paymentId)
        .select()
        .single();

      if (updateError) {
        console.error('❌ Erro ao atualizar pagamento:', updateError);
      } else {
        console.log('💾 Pagamento atualizado no Supabase');
      }

      // Se pagamento aprovado, ativar assinatura
      if (paymentResult.status === 'approved' && updateData) {
        console.log(`✅ Ativando assinatura para: ${updateData.payer_email}`);
        
        try {
          await supabase.rpc('activate_subscription_after_payment', {
            user_email: updateData.payer_email,
            payment_id: paymentId,
            payment_method: updateData.payment_method
          });

          console.log(`🎉 Assinatura ativada para ${updateData.payer_email}`);
        } catch (activationError) {
          console.error('❌ Erro ao ativar assinatura:', activationError);
        }
      }
    }

    return res.status(200).json({ received: true });

  } catch (error) {
    console.error('❌ Erro no webhook:', error);
    return res.status(500).json({ error: 'Erro interno do servidor' });
  }
}
