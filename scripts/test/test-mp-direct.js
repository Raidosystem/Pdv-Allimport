async function testPreference() {
  try {
    const MP_ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    const preferenceData = {
      items: [
        {
          title: "Teste Assinatura PDV",
          unit_price: 59.90,
          quantity: 1
        }
      ],
      back_urls: {
        success: 'https://pdv.crmvsystem.com/payment/success',
        failure: 'https://pdv.crmvsystem.com/payment/failure',
        pending: 'https://pdv.crmvsystem.com/payment/pending'
      },
      auto_return: 'approved',
      external_reference: `pref_${Date.now()}`,
      notification_url: 'https://pdv.crmvsystem.com/api/mp/webhook',
      payer: {
        email: 'teste@exemplo.com'
      },
      metadata: {
        company_id: 'teste_company',
        integration: 'pdv_allimport'
      }
    };

    console.log('📤 Enviando preferência:', JSON.stringify(preferenceData, null, 2));

    const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(preferenceData),
    });

    const responseText = await response.text();
    console.log('🔍 Status:', response.status);
    console.log('🔍 Resposta completa:', responseText);

    if (!response.ok) {
      console.error('❌ Erro:', response.status, responseText);
    } else {
      console.log('✅ Sucesso!');
    }

  } catch (error) {
    console.error('❌ Erro na requisição:', error);
  }
}

testPreference();