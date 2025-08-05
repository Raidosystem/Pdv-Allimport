import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { MercadoPagoConfig, Payment, Preference } from 'mercadopago';
import { createClient } from '@supabase/supabase-js';

// Carregar variáveis de ambiente
dotenv.config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors({
  origin: [
    'http://localhost:5173',
    'https://pdv-allimport.vercel.app',
    'https://pdv-allimport-*.vercel.app'
  ],
  credentials: true
}));

// Configurar Mercado Pago
const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN,
  options: {
    timeout: 5000
  }
});

const payment = new Payment(client);
const preference = new Preference(client);

// Configurar Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// =========================================
// 🔹 CRIAR PAGAMENTO PIX
// =========================================
app.post('/api/payments/pix', async (req, res) => {
  try {
    const { userEmail, userName, amount, description } = req.body;

    if (!userEmail || !amount) {
      return res.status(400).json({ 
        error: 'Email do usuário e valor são obrigatórios' 
      });
    }

    const paymentData = {
      transaction_amount: Number(amount),
      description: description || 'Assinatura PDV Allimport',
      payment_method_id: 'pix',
      payer: {
        email: userEmail,
        first_name: userName?.split(' ')[0] || 'Cliente',
        last_name: userName?.split(' ').slice(1).join(' ') || 'PDV'
      },
      external_reference: `pix_${userEmail}_${Date.now()}`,
      notification_url: `${process.env.API_BASE_URL}/api/webhook/mercadopago`
    };

    const response = await payment.create({
      body: paymentData
    });
    const paymentResult = response;

    // Salvar pagamento no Supabase
    await supabase.from('payments').insert({
      mp_payment_id: paymentResult.id.toString(),
      user_id: null, // Será atualizado quando soubermos o user_id
      mp_status: paymentResult.status,
      mp_status_detail: paymentResult.status_detail,
      amount: paymentResult.transaction_amount,
      currency: paymentResult.currency_id,
      payment_method: 'pix',
      payment_type: paymentResult.payment_type_id,
      payer_email: userEmail,
      payer_name: userName,
      webhook_data: paymentResult
    });

    // Retornar dados do PIX
    res.json({
      payment_id: paymentResult.id.toString(),
      status: paymentResult.status,
      qr_code: paymentResult.point_of_interaction?.transaction_data?.qr_code || '',
      qr_code_base64: paymentResult.point_of_interaction?.transaction_data?.qr_code_base64 || '',
      ticket_url: paymentResult.point_of_interaction?.transaction_data?.ticket_url || ''
    });

  } catch (error) {
    console.error('❌ Erro ao criar PIX:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
});

// =========================================
// 🔹 CRIAR PREFERÊNCIA PARA CARTÃO
// =========================================
app.post('/api/payments/preference', async (req, res) => {
  try {
    const { userEmail, userName, amount, planName } = req.body;

    if (!userEmail || !amount) {
      return res.status(400).json({ 
        error: 'Email do usuário e valor são obrigatórios' 
      });
    }

    const preferenceData = {
      items: [{
        id: 'pdv-subscription',
        title: planName || 'Assinatura PDV Allimport',
        description: 'Sistema PDV completo com todas as funcionalidades',
        quantity: 1,
        currency_id: 'BRL',
        unit_price: Number(amount)
      }],
      payer: {
        email: userEmail,
        name: userName || 'Cliente PDV'
      },
      payment_methods: {
        excluded_payment_types: [],
        excluded_payment_methods: [],
        installments: 12
      },
      back_urls: {
        success: `${process.env.FRONTEND_URL}/payment/success`,
        failure: `${process.env.FRONTEND_URL}/payment/failure`,
        pending: `${process.env.FRONTEND_URL}/payment/pending`
      },
      auto_return: 'approved',
      external_reference: `subscription_${userEmail}_${Date.now()}`,
      notification_url: `${process.env.API_BASE_URL}/api/webhook/mercadopago`,
      expires: true,
      expiration_date_from: new Date().toISOString(),
      expiration_date_to: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    };

    const response = await preference.create({
      body: preferenceData
    });
    const preferenceResult = response;

    res.json({
      id: preferenceResult.id,
      init_point: preferenceResult.init_point,
      sandbox_init_point: preferenceResult.sandbox_init_point
    });

  } catch (error) {
    console.error('❌ Erro ao criar preferência:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
});

// =========================================
// 🔹 VERIFICAR STATUS DO PAGAMENTO
// =========================================
app.get('/api/payments/:paymentId/status', async (req, res) => {
  try {
    const { paymentId } = req.params;

    const response = await payment.get({
      id: paymentId
    });
    const paymentResult = response;

    // Atualizar status no Supabase
    await supabase
      .from('payments')
      .update({
        mp_status: paymentResult.status,
        mp_status_detail: paymentResult.status_detail,
        webhook_data: paymentResult,
        updated_at: new Date().toISOString()
      })
      .eq('mp_payment_id', paymentId);

    res.json({
      payment_id: paymentResult.id,
      status: paymentResult.status,
      status_detail: paymentResult.status_detail,
      approved: paymentResult.status === 'approved'
    });

  } catch (error) {
    console.error('❌ Erro ao verificar pagamento:', error);
    res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
});

// =========================================
// 🔹 WEBHOOK DO MERCADO PAGO
// =========================================
app.post('/api/webhook/mercadopago', async (req, res) => {
  try {
    console.log('🔔 Webhook recebido:', req.body);

    const { type, data } = req.body;

    if (type === 'payment') {
      const paymentId = data.id;
      
      // Buscar dados do pagamento
      const response = await payment.get({
        id: paymentId
      });
      const paymentResult = response;

      console.log(`💳 Pagamento ${paymentId}: ${paymentResult.status}`);

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
      }

      // Se pagamento aprovado, ativar assinatura
      if (paymentResult.status === 'approved' && updateData) {
        console.log(`✅ Ativando assinatura para: ${updateData.payer_email}`);
        
        await supabase.rpc('activate_subscription_after_payment', {
          user_email: updateData.payer_email,
          payment_id: paymentId,
          payment_method: updateData.payment_method
        });

        console.log(`🎉 Assinatura ativada para ${updateData.payer_email}`);
      }
    }

    res.sendStatus(200);

  } catch (error) {
    console.error('❌ Erro no webhook:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// =========================================
// 🔹 ROTAS DE SAÚDE E INFO
// =========================================
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'PDV Allimport API',
    version: '1.0.0'
  });
});

app.get('/api/config', (req, res) => {
  res.json({
    mp_public_key: process.env.MP_PUBLIC_KEY,
    environment: process.env.NODE_ENV
  });
});

// Middleware para rotas não encontradas
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// Middleware para tratamento de erros
app.use((error, req, res, next) => {
  console.error('❌ Erro não tratado:', error);
  res.status(500).json({ 
    error: 'Erro interno do servidor',
    message: error.message 
  });
});

// Iniciar servidor
const PORT = process.env.PORT || 3333;
app.listen(PORT, () => {
  console.log(`🚀 API PDV Allimport rodando na porta ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log(`💳 Mercado Pago configurado: ${process.env.MP_ACCESS_TOKEN ? '✅' : '❌'}`);
});

export default app;
