/**
 * Teste para o webhook-v3 funcionando
 */

async function testWebhookV3() {
  const webhook_url = "https://pdv-allimport.vercel.app/api/mp/webhook-v3";
  
  const payload = {
    action: "payment.updated",
    api_version: "v1",
    data: {
      id: "125538427331"  // ID que está falhando no MP
    },
    date_created: "2025-09-13T21:58:00Z",
    id: 12345,
    live_mode: true,
    type: "payment",
    user_id: "1967416997"
  };

  console.log("🧪 Testando webhook-v3 com payload:", payload.data.id);

  try {
    const response = await fetch(webhook_url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "MercadoPago Webhook"
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
      console.log("✅ Webhook-v3 funcionando!");
    } else {
      console.log("❌ Webhook-v3 ainda com problema!");
    }

  } catch (error) {
    console.error("❌ Erro ao testar webhook-v3:", error);
  }
}

testWebhookV3();