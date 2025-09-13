// Testar se pagamento 126091435880 foi processado corretamente
async function testSpecificPayment() {
  const paymentId = "126091435880";
  
  console.log("🧪 Testando pagamento:", paymentId);
  
  try {
    // 1. Verificar se pagamento foi registrado na tabela payments_processed
    console.log("\n1️⃣ Verificando se pagamento foi registrado...");
    
    // 2. Verificar detalhes do pagamento no MP
    console.log("\n2️⃣ Consultando Mercado Pago...");
    const MP_ACCESS_TOKEN = "APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193";
    
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` }
    });

    if (!mpResponse.ok) {
      console.error("❌ Erro MP API:", mpResponse.status);
      return;
    }

    const payment = await mpResponse.json();
    console.log("✅ Payment details:", { 
      id: payment.id, 
      status: payment.status,
      status_detail: payment.status_detail,
      metadata: payment.metadata,
      date_approved: payment.date_approved,
      date_created: payment.date_created
    });

    // 3. Testar webhook novamente para garantir processamento
    if (payment.status === 'approved' && payment.metadata?.company_id) {
      console.log("\n3️⃣ Reprocessando via webhook...");
      
      const webhookPayload = {
        type: "payment",
        action: "payment.updated",
        data: { id: paymentId }
      };
      
      const webhookResponse = await fetch("https://pdv-allimport.vercel.app/api/mp/webhook", {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(webhookPayload)
      });
      
      console.log("📡 Webhook response:", webhookResponse.status);
      
      if (!webhookResponse.ok) {
        const errorText = await webhookResponse.text();
        console.error("❌ Webhook error:", errorText);
      } else {
        const result = await webhookResponse.json();
        console.log("✅ Webhook result:", result);
      }
    } else {
      console.log("⚠️ Payment not approved or missing company_id");
    }
    
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

testSpecificPayment();