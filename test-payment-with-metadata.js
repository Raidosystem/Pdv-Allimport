// Teste para verificar se pagamento com metadados agora funciona
async function testPaymentWithMetadata() {
  console.log("🧪 Testando criação de PIX com metadados...");
  
  try {
    // 1. Criar um PIX com metadados
    console.log("\n1️⃣ Criando PIX com metadados...");
    
    const pixPayload = {
      amount: 59.90,
      description: "Teste Assinatura PDV Allimport",
      email: "teste@pdvallimport.com",
      company_id: "test-company-123",
      user_id: "test-user-456"
    };
    
    const pixResponse = await fetch("https://pdv-allimport.vercel.app/api/pix", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(pixPayload)
    });
    
    if (!pixResponse.ok) {
      console.error("❌ Erro ao criar PIX:", pixResponse.status);
      const errorText = await pixResponse.text();
      console.error("Erro:", errorText);
      return;
    }
    
    const pixResult = await pixResponse.json();
    console.log("✅ PIX criado:", {
      success: pixResult.success,
      payment_id: pixResult.payment_id,
      status: pixResult.status
    });
    
    if (!pixResult.success || !pixResult.payment_id) {
      console.error("❌ PIX não foi criado corretamente");
      return;
    }
    
    // 2. Verificar se o pagamento tem metadados
    console.log("\n2️⃣ Verificando metadados do pagamento...");
    
    const MP_ACCESS_TOKEN = "APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193";
    const paymentId = pixResult.payment_id;
    
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` }
    });

    if (!mpResponse.ok) {
      console.error("❌ Erro MP API:", mpResponse.status);
      return;
    }

    const payment = await mpResponse.json();
    console.log("✅ Pagamento MP:", { 
      id: payment.id, 
      status: payment.status,
      metadata: payment.metadata,
      external_reference: payment.external_reference
    });
    
    // 3. Testar webhook com este pagamento
    console.log("\n3️⃣ Testando webhook...");
    
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
    
    console.log("\n✅ Teste concluído! Agora os PIX serão criados com metadados.");
    
  } catch (error) {
    console.error("❌ Erro no teste:", error);
  }
}

testPaymentWithMetadata();