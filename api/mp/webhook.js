const crypto = require("crypto");

// Credenciais do Mercado Pago
const MP_WEBHOOK_SECRET = process.env.MP_WEBHOOK_SECRET; // Obter do painel do MP
const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || "APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193";

// Configuração do Supabase
const SUPABASE_URL = process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.VITE_SUPABASE_ANON_KEY;

/**
 * Verificar assinatura do webhook conforme documentação do Mercado Pago
 */
async function verifySignature(req, bodyText) {
  try {
    const sig = req.headers["x-signature"] || "";
    const reqId = req.headers["x-request-id"] || "";
    
    if (!sig) {
      console.log("⚠️ Webhook sem X-Signature header");
      return false;
    }

    // Parse da assinatura: ts=1234,v1=hash
    const parts = {};
    sig.split(",").forEach(p => {
      const [key, value] = p.trim().split("=");
      parts[key] = value;
    });
    
    const ts = parts.ts;
    const v1 = parts.v1;

    if (!ts || !v1) {
      console.log("⚠️ Formato de assinatura inválido");
      return false;
    }

    // Parse do body para obter o ID
    const body = JSON.parse(bodyText);
    const id = body?.data?.id ?? "";
    
    // Manifestar conforme orientação: id + request-id + ts
    const manifest = `id:${id};request-id:${reqId};ts:${ts};`;
    
    console.log("🔍 Verificando assinatura:", { manifest, v1 });

    // Criar HMAC SHA256
    const hmac = crypto.createHmac("sha256", MP_WEBHOOK_SECRET);
    hmac.update(manifest);
    const expected = hmac.digest("hex");

    // Comparação segura
    const isValid = crypto.timingSafeEqual(
      Buffer.from(v1, "hex"), 
      Buffer.from(expected, "hex")
    );

    console.log("🔐 Resultado da verificação:", { expected, received: v1, isValid });
    
    return isValid;
  } catch (error) {
    console.error("❌ Erro ao verificar assinatura:", error);
    return false;
  }
}

/**
 * Verificar se o pagamento já foi processado (idempotência)
 */
async function checkIdempotency(paymentId) {
  try {
    console.log("🔄 Verificando idempotência para payment:", paymentId);
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/payments_processed?payment_id=eq.${paymentId}`, {
      method: "GET",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json"
      }
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("❌ Erro ao verificar idempotência:", response.status, errorText);
      return false; // Em caso de erro, assumir não processado
    }

    const data = await response.json();
    const alreadyProcessed = data && data.length > 0;
    
    console.log(`🔄 Idempotência - Payment ${paymentId}:`, alreadyProcessed ? 'JÁ PROCESSADO' : 'NOVO');
    return alreadyProcessed;
  } catch (error) {
    console.error("❌ Erro na verificação de idempotência:", error);
    return false;
  }
}

/**
 * Marcar pagamento como processado
 */
async function markAsProcessed(paymentId, payerEmail) {
  try {
    console.log("✅ Marcando pagamento como processado:", paymentId);
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/payments_processed`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
      },
      body: JSON.stringify({
        payment_id: paymentId,
        payer_email: payerEmail,
        processed_at: new Date().toISOString()
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("❌ Erro ao marcar como processado:", response.status, errorText);
      return false;
    }

    console.log("✅ Pagamento marcado como processado com sucesso");
    return true;
  } catch (error) {
    console.error("❌ Erro ao marcar como processado:", error);
    return false;
  }
}

/**
 * Buscar detalhes do pagamento na API do Mercado Pago
 */
async function getPaymentDetails(paymentId) {
  try {
    console.log("🔍 Buscando detalhes do pagamento:", paymentId);
    
    const response = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
        "Content-Type": "application/json"
      }
    });

    if (!response.ok) {
      throw new Error(`MP API Error: ${response.status}`);
    }

    const payment = await response.json();
    console.log("✅ Detalhes do pagamento:", {
      id: payment.id,
      status: payment.status,
      status_detail: payment.status_detail,
      external_reference: payment.external_reference,
      payer_email: payment.payer?.email
    });

    return payment;
  } catch (error) {
    console.error("❌ Erro ao buscar pagamento:", error);
    throw error;
  }
}

/**
 * Ativar assinatura no Supabase quando pagamento for aprovado
 */
async function activateSubscription(paymentId, payerEmail) {
  try {
    console.log("🚀 Ativando assinatura:", { paymentId, payerEmail });

    // Usar a mesma função SQL que já existe
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=representation"
      },
      body: JSON.stringify({
        user_email: payerEmail,
        payment_id: paymentId,
        payment_method: "pix"
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Supabase Error: ${response.status} - ${errorText}`);
    }

    const result = await response.json();
    console.log("✅ Assinatura ativada via webhook:", result);

    return result;
  } catch (error) {
    console.error("❌ Erro ao ativar assinatura:", error);
    throw error;
  }
}

/**
 * Verificar se pagamento já foi processado (idempotência)
 */
async function isPaymentProcessed(paymentId) {
  try {
    // Verificar na tabela de pagamentos se já foi processado
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/payments_processed?payment_id=eq.${paymentId}`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        }
      }
    );

    const data = await response.json();
    return Array.isArray(data) && data.length > 0;
  } catch (error) {
    console.log("⚠️ Tabela payments_processed não existe, assumindo não processado");
    return false;
  }
}

/**
 * Marcar pagamento como processado
 */
async function markPaymentProcessed(paymentId, payerEmail) {
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/payments_processed`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal"
      },
      body: JSON.stringify({
        payment_id: paymentId,
        payer_email: payerEmail,
        processed_at: new Date().toISOString()
      })
    });
  } catch (error) {
    console.log("⚠️ Não foi possível marcar como processado (tabela pode não existir)");
  }
}

/**
 * Webhook endpoint principal - Vercel Serverless Function
 */
export default async function handler(req, res) {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, X-Signature, X-Request-Id'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method === 'GET') {
    res.status(200).json({ 
      message: "Webhook endpoint do Mercado Pago - apenas POST é permitido",
      timestamp: new Date().toISOString()
    });
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const startTime = Date.now();
  
  try {
    console.log("🎯 Webhook recebido do Mercado Pago");
    
    // 1. Ler o corpo da requisição
    const bodyText = JSON.stringify(req.body);
    let payload;
    
    try {
      payload = req.body;
    } catch {
      console.log("❌ Body inválido, ignorando");
      res.status(200).json({ ok: true });
      return;
    }

    console.log("📦 Payload recebido:", {
      type: payload?.type,
      action: payload?.action,
      data_id: payload?.data?.id
    });

    // 2. Validar assinatura (opcional em desenvolvimento, obrigatório em produção)
    const isProduction = process.env.NODE_ENV === "production";
    
    if (isProduction && MP_WEBHOOK_SECRET && MP_WEBHOOK_SECRET !== "webhook_secret_from_mp_dashboard") {
      try {
        const isValidSignature = await verifySignature(req, bodyText);
        if (!isValidSignature) {
          console.log("🚫 Assinatura inválida");
          res.status(401).json({ error: "Unauthorized" });
          return;
        }
        console.log("✅ Assinatura válida");
      } catch (error) {
        console.error("❌ Erro na validação da assinatura:", error);
        res.status(401).json({ error: "Signature validation failed" });
        return;
      }
    } else {
      console.log("⚠️ Modo desenvolvimento - validação de assinatura desabilitada");
    }

    // 3. Processar notificação de pagamento
    const type = payload?.type;
    const action = payload?.action;
    const paymentId = payload?.data?.id;

    if (type === "payment" && paymentId) {
      console.log("💳 Processando notificação de pagamento:", paymentId);

      // 4. Verificar idempotência
      const alreadyProcessed = await checkIdempotency(String(paymentId));
      if (alreadyProcessed) {
        console.log("✅ Pagamento já processado anteriormente");
        res.status(200).json({ ok: true, message: "Already processed" });
        return;
      }

      // 5. Buscar detalhes do pagamento
      const payment = await getPaymentDetails(paymentId);
      
      if (!payment) {
        console.log("❌ Não foi possível obter detalhes do pagamento");
        res.status(200).json({ ok: true, message: "Payment not found" });
        return;
      }

      // 6. Marcar como processado (idempotência)
      await markAsProcessed(String(paymentId), payment.payer?.email);
      
      // 7. Se pagamento foi aprovado, ativar assinatura
      if (payment.status === "approved") {
        const payerEmail = payment.payer?.email;
        
        if (payerEmail) {
          console.log("🎉 Pagamento aprovado! Ativando assinatura...");
          
          try {
            await activateSubscription(paymentId, payerEmail);
            console.log("✅ Webhook processado com sucesso!");
          } catch (activationError) {
            console.error("❌ Erro ao ativar assinatura:", activationError);
            // Não retornar erro para evitar reenvios do MP
            // O pagamento está aprovado, a ativação pode ser feita manualmente
          }
        } else {
          console.log("⚠️ Pagamento aprovado mas sem email do pagador");
        }
      } else {
        console.log("⏳ Pagamento não aprovado ainda:", payment.status);
      }
    } else {
      console.log("📋 Tipo de notificação não tratado:", { type, action });
    }

    // 7. SEMPRE responder 200 rapidamente
    const processTime = Date.now() - startTime;
    console.log(`⚡ Webhook processado em ${processTime}ms`);
    
    res.status(200).json({ 
      ok: true, 
      processed_in_ms: processTime,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    const processTime = Date.now() - startTime;
    console.error("❌ Erro no webhook:", error);
    
    // Ainda assim, retornar 200 para evitar reenvios em caso de erros não críticos
    res.status(200).json({ 
      ok: true, 
      error: "Internal error logged",
      processed_in_ms: processTime
    });
  }
}