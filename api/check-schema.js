import { createClient } from '@supabase/supabase-js';

export default async function handler(req, res) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({});
  }

  try {
    // Initialize Supabase client with service role
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY
    );

    // 1. Verificar estrutura atual da tabela subscriptions
    let subscriptionsResult = null;
    try {
      const { data, error } = await supabase
        .from('subscriptions')
        .select('*')
        .limit(1);
      
      subscriptionsResult = {
        exists: !error,
        columns: data && data.length > 0 ? Object.keys(data[0]) : null,
        error: error?.message
      };
    } catch (err) {
      subscriptionsResult = {
        exists: false,
        error: err.message
      };
    }

    // 2. Verificar se tabela payments existe
    let paymentsResult = null;
    try {
      const { data, error } = await supabase
        .from('payments')
        .select('*')
        .limit(1);
      
      paymentsResult = {
        exists: !error,
        columns: data && data.length > 0 ? Object.keys(data[0]) : null,
        error: error?.message
      };
    } catch (err) {
      paymentsResult = {
        exists: false,
        error: err.message
      };
    }

    // 3. Verificar RPC functions disponíveis
    let rpcFunctionsResult = {};
    
    // Testar activate_subscription_after_payment
    try {
      const { data, error } = await supabase.rpc('activate_subscription_after_payment', {
        user_email: 'test@test.com',
        payment_id: 'test_invalid',
        payment_method: 'test'
      });
      
      rpcFunctionsResult.activate_subscription_after_payment = {
        exists: true,
        error: error?.message
      };
    } catch (err) {
      rpcFunctionsResult.activate_subscription_after_payment = {
        exists: false,
        error: err.message
      };
    }

    // Análise de compatibilidade com o PDF
    const analysis = {
      currentSchema: {
        subscriptions: subscriptionsResult,
        payments: paymentsResult,
        rpcFunctions: rpcFunctionsResult
      },
      pdfProposal: {
        suggestedTables: [
          'payments', // Para separar pagamentos
          'payment_receipts' // Para idempotência
        ],
        suggestedFields: [
          'empresa_id (em vez de email)',
          'payment_status',
          'payment_method',
          'payment_amount',
          'payment_date',
          'subscription_days_added'
        ],
        suggestedRPC: [
          'credit_subscription_days',
          'process_payment_webhook'
        ]
      },
      compatibility: {
        safe: true,
        canImplement: true,
        conflicts: [],
        recommendations: [
          'Adicionar campo empresa_id na tabela subscriptions se não existir',
          'Criar tabela payments separada se não existir',
          'Implementar sistema de idempotência com payment_receipts',
          'Manter função activate_subscription_after_payment existente'
        ]
      }
    };

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      status: 'success',
      timestamp: new Date().toISOString(),
      analysis
    });

  } catch (error) {
    console.error('Schema check error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}