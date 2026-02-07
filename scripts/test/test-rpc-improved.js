// Teste da função RPC melhorada com pagamento real
async function testRPCFunction() {
  console.log("🧪 Testando função RPC melhorada...");
  
  try {
    // Usar o pagamento que criamos com metadados
    const paymentId = "126092291960"; // Do teste anterior
    const companyId = "teste@pdvallimport.com"; // Email do metadado
    
    console.log(`\n📞 Chamando RPC com payment_id=${paymentId} e company_id=${companyId}`);
    
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

    // Verificar o pagamento original (126091435880) também
    console.log("\n🔄 Testando pagamento original sem metadados...");
    
    const originalPayload = {
      type: "payment",
      action: "payment.updated",
      data: { id: "126091435880" }
    };
    
    const originalResponse = await fetch("https://pdv-allimport.vercel.app/api/mp/webhook", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(originalPayload)
    });
    
    console.log("📡 Original payment webhook response:", originalResponse.status);
    
    if (originalResponse.ok) {
      const originalResult = await originalResponse.json();
      console.log("✅ Original payment result:", originalResult);
    }
    
  } catch (error) {
    console.error("❌ Erro no teste:", error);
  }
}

testRPCFunction();