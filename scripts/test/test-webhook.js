/**
 * Script para testar o webhook do Mercado Pago com metadados
 */

async function testWebhookWithMetadata() {
  const webhook_url = "https://pdv-allimport.vercel.app/api/mp/webhook";
  
  // Simular payload que o MP envia com metadados
  const payload = {
    action: "payment.updated",
    api_version: "v1",
    data: {
      id: "125534421801"
    },
    date_created: "2024-12-28T21:28:18Z",
    id: 12345,
    live_mode: true,
    type: "payment",
    user_id: "1967416997"
  };

  console.log("🧪 Testando webhook com payload:", payload);
  console.log("💡 NOTA: O payment_id 125534421801 deve ter metadados com company_id");

  try {
    const response = await fetch(webhook_url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "MercadoPago Webhook",
        "X-Request-Id": "test-" + Date.now(),
        "X-Signature": "ts=1640995200,v1=dummy" // Assinatura dummy para teste
      },
      body: JSON.stringify(payload)
    });

    console.log("📡 Resposta:", {
      status: response.status,
      statusText: response.statusText,
      ok: response.ok
    });

    const responseText = await response.text();
    console.log("📄 Conteúdo da resposta:", responseText);

    if (response.ok) {
      console.log("✅ Webhook funcionando!");
    } else {
      console.log("❌ Webhook com problema!");
    }

  } catch (error) {
    console.error("❌ Erro ao testar webhook:", error);
  }
}

// Função para testar criação de pagamento com metadados
async function testPaymentCreationWithMetadata() {
  console.log("\n📋 Exemplo de como criar pagamento com metadados:");
  
  const paymentBody = {
    transaction_amount: 123.45,
    description: "Assinatura 30 dias",
    payment_method_id: "pix",
    payer: { 
      email: "cliente@exemplo.com" 
    },
    notification_url: "https://pdv-allimport.vercel.app/api/mp/webhook",
    external_reference: "company-123", // opcional: pode ser o companyId
    metadata: { 
      company_id: "company-uuid-here", // IMPORTANTE: ID da empresa
      order_id: "order-uuid-optional"  // opcional: ID do pedido se houver
    }
  };

  console.log("💳 Body para criar pagamento:", JSON.stringify(paymentBody, null, 2));
  console.log("\n🔗 Endpoint: https://api.mercadopago.com/v1/payments");
  console.log("📝 Headers: Authorization: Bearer YOUR_ACCESS_TOKEN");
}

// Executar testes
console.log("🚀 Testando webhook atualizado com metadados...\n");
testWebhookWithMetadata().then(() => {
  testPaymentCreationWithMetadata();
});