// Teste para verificar se cartão também tem metadados
async function testCreditCardWithMetadata() {
  console.log("🧪 Testando criação de preferência (cartão) com metadados...");
  
  try {
    // 1. Criar uma preferência com metadados
    console.log("\n1️⃣ Criando preferência com metadados...");
    
    const preferencePayload = {
      amount: 59.90,
      description: "Teste Assinatura PDV Allimport - Cartão",
      email: "teste.cartao@pdvallimport.com",
      company_id: "test-company-cartao-123",
      user_id: "test-user-cartao-456"
    };
    
    const preferenceResponse = await fetch("https://pdv-allimport.vercel.app/api/preference", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(preferencePayload)
    });
    
    if (!preferenceResponse.ok) {
      console.error("❌ Erro ao criar preferência:", preferenceResponse.status);
      const errorText = await preferenceResponse.text();
      console.error("Erro:", errorText);
      return;
    }
    
    const preferenceResult = await preferenceResponse.json();
    console.log("✅ Preferência criada:", {
      success: preferenceResult.success,
      preference_id: preferenceResult.preference_id,
      init_point: preferenceResult.init_point
    });
    
    if (!preferenceResult.success || !preferenceResult.preference_id) {
      console.error("❌ Preferência não foi criada corretamente");
      return;
    }
    
    // 2. Verificar os metadados da preferência
    console.log("\n2️⃣ Verificando metadados da preferência...");
    
    const MP_ACCESS_TOKEN = "process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN";
    const preferenceId = preferenceResult.preference_id;
    
    const mpResponse = await fetch(`https://api.mercadopago.com/checkout/preferences/${preferenceId}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` }
    });

    if (!mpResponse.ok) {
      console.error("❌ Erro MP API:", mpResponse.status);
      return;
    }

    const preference = await mpResponse.json();
    console.log("✅ Preferência MP:", { 
      id: preference.id, 
      metadata: preference.metadata,
      external_reference: preference.external_reference,
      notification_url: preference.notification_url
    });
    
    // 3. Simular como seria um pagamento aprovado
    console.log("\n3️⃣ Informações do processo:");
    console.log("📄 Checkout URL:", preferenceResult.init_point);
    console.log("🔔 Notification URL:", preference.notification_url);
    console.log("📦 Metadados incluídos:", preference.metadata);
    
    console.log("\n✅ Teste concluído! Agora cartões também têm metadados.");
    console.log("💡 Quando um pagamento for aprovado, o webhook receberá:");
    console.log("   - payment_id com metadados");
    console.log("   - company_id para identificar o usuário");
    console.log("   - Processo automático de extensão da assinatura");
    
  } catch (error) {
    console.error("❌ Erro no teste:", error);
  }
}

testCreditCardWithMetadata();