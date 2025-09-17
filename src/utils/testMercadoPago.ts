// Teste simples para validar credenciais do Mercado Pago
export async function testMercadoPagoCredentials() {
  const ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
  
  try {
    console.log('🧪 Testando credenciais do Mercado Pago...');
    
    // Teste básico: buscar informações da conta
    const response = await fetch('https://api.mercadopago.com/users/me', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
    });

    const responseText = await response.text();
    console.log('📥 Resposta do teste de credenciais:', responseText);

    if (!response.ok) {
      console.error('❌ Credenciais inválidas:', response.status, responseText);
      return { valid: false, error: responseText };
    }

    const userInfo = JSON.parse(responseText);
    console.log('✅ Credenciais válidas! Usuário:', userInfo.email || userInfo.id);
    
    return { valid: true, userInfo };
  } catch (error) {
    console.error('❌ Erro ao testar credenciais:', error);
    return { valid: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
  }
}

// Teste de criação de pagamento PIX simplificado
export async function testSimplePixCreation() {
  const ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
  
  try {
    console.log('🧪 Testando criação de PIX simples...');
    
    const pixData = {
      transaction_amount: 1.00, // R$ 1,00 para teste
      description: 'Teste PIX PDV Allimport',
      payment_method_id: 'pix',
      payer: {
        email: 'teste@pdvallimport.com',
        first_name: 'Teste',
        last_name: 'PDV'
      }
    };

    const response = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
        'X-Idempotency-Key': `test-pix-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
      },
      body: JSON.stringify(pixData),
    });

    const responseText = await response.text();
    console.log('📥 Resposta do teste PIX:', responseText);

    if (!response.ok) {
      console.error('❌ Erro ao criar PIX de teste:', response.status, responseText);
      return { success: false, error: responseText };
    }

    const result = JSON.parse(responseText);
    console.log('✅ PIX de teste criado com sucesso!');
    
    const qrData = result.point_of_interaction?.transaction_data;
    return { 
      success: true, 
      paymentId: result.id,
      status: result.status,
      hasQrCode: !!qrData?.qr_code,
      hasQrCodeBase64: !!qrData?.qr_code_base64,
      qrCode: qrData?.qr_code,
      result 
    };
  } catch (error) {
    console.error('❌ Erro ao testar PIX:', error);
    return { success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' };
  }
}