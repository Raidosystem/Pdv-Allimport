/**
 * Teste específico para o pagamento 125538427331 que está falhando
 */

async function testSpecificPayment() {
  const webhook_url = "https://pdv-allimport.vercel.app/api/mp/webhook";
  
  // Payload exato que o MP está enviando
  const payload = {
    action: "payment.updated",
    api_version: "v1",
    data: {
      id: "125538427331"  // ID específico que está falhando
    },
    date_created: "2025-09-13T21:47:50Z",
    id: 12345,
    live_mode: true,
    type: "payment",
    user_id: "1967416997"
  };

  console.log("🔍 Testando pagamento específico que está falhando:", payload.data.id);

  try {
    const response = await fetch(webhook_url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "MercadoPago Webhook",
        "X-Request-Id": "test-specific-" + Date.now(),
        "X-Signature": "ts=1694728070,v1=dummysignature" // Assinatura dummy
      },
      body: JSON.stringify(payload)
    });

    console.log("📡 Resposta:", {
      status: response.status,
      statusText: response.statusText,
      ok: response.ok
    });

    const responseText = await response.text();
    console.log("📄 Conteúdo completo da resposta:");
    console.log(responseText);

    if (response.ok) {
      console.log("✅ Webhook funcionando para este pagamento!");
    } else {
      console.log("❌ Webhook ainda com problema para este pagamento!");
      
      // Vamos testar também o endpoint GET para ver se as variáveis estão OK
      console.log("\n🔧 Testando configuração das variáveis...");
      const getResponse = await fetch(webhook_url, { method: "GET" });
      const getContent = await getResponse.text();
      console.log("GET Response:", getContent);
    }

  } catch (error) {
    console.error("❌ Erro ao testar webhook:", error);
  }
}

// Função para testar a conectividade com Supabase diretamente
async function testSupabaseConnection() {
  console.log("\n🔌 Testando conectividade com Supabase...");
  
  const SUPABASE_URL = "https://kmcaaqetxtwkdcczdomw.supabase.co";
  const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || "CHAVE_NAO_CONFIGURADA";
  
  try {
    // Teste simples: listar companies
    const response = await fetch(`${SUPABASE_URL}/rest/v1/companies?limit=1`, {
      method: "GET",
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        "Content-Type": "application/json"
      }
    });

    console.log("📡 Resposta Supabase:", {
      status: response.status,
      statusText: response.statusText,
      ok: response.ok
    });

    if (response.ok) {
      const data = await response.json();
      console.log("✅ Supabase conectando OK, companies encontradas:", data.length);
    } else {
      const errorText = await response.text();
      console.error("❌ Erro Supabase:", errorText);
    }

  } catch (error) {
    console.error("❌ Erro ao conectar Supabase:", error);
  }
}

// Executar testes
console.log("🚀 Diagnosticando problema específico do pagamento 125538427331...\n");
testSpecificPayment().then(() => {
  return testSupabaseConnection();
}).then(() => {
  console.log("\n📋 Diagnóstico completo!");
});