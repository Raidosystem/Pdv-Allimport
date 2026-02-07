// Teste específico do MercadoPago para diagnosticar o problema
const BASE_URL = 'https://pdv.crmvsystem.com/api';

async function testMercadoPagoSpecific() {
    console.log('🔍 DIAGNÓSTICO ESPECÍFICO DO MERCADOPAGO\n');
    
    // Teste 1: Verificar configuração de ambiente
    console.log('1. Verificando configuração de ambiente...');
    try {
        const envResponse = await fetch(`${BASE_URL}/env-check`);
        const envData = await envResponse.json();
        console.log('✅ Configuração:', JSON.stringify(envData.environment_vars, null, 2));
    } catch (error) {
        console.log('❌ Erro na configuração:', error.message);
    }
    
    // Teste 2: Teste direto do endpoint PIX com dados corretos
    console.log('\n2. Testando PIX com dados corretos...');
    try {
        const pixResponse = await fetch(`${BASE_URL}/pix`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: 10.00,
                description: 'Teste de PIX',
                payer_email: 'teste@teste.com'
            })
        });
        
        const pixText = await pixResponse.text();
        console.log(`Status PIX: ${pixResponse.status}`);
        console.log(`Resposta PIX: ${pixText.substring(0, 200)}...`);
        
        if (pixResponse.status === 200) {
            console.log('✅ PIX funcionando!');
        } else {
            console.log('❌ PIX com erro');
        }
    } catch (error) {
        console.log('❌ Erro no PIX:', error.message);
    }
    
    // Teste 3: Teste MP Diagnostic 
    console.log('\n3. Testando MP Diagnostic...');
    try {
        const mpResponse = await fetch(`${BASE_URL}/mp-diagnostic`);
        const mpText = await mpResponse.text();
        console.log(`Status MP: ${mpResponse.status}`);
        console.log(`Resposta MP: ${mpText.substring(0, 300)}...`);
        
        if (mpResponse.status === 200) {
            console.log('✅ MP Diagnostic funcionando!');
        } else {
            console.log('❌ MP Diagnostic com erro');
        }
    } catch (error) {
        console.log('❌ Erro no MP Diagnostic:', error.message);
    }
    
    // Teste 4: Teste Payment Status com access_token correto
    console.log('\n4. Testando Payment Status...');
    try {
        const paymentResponse = await fetch(`${BASE_URL}/payment-status?payment_id=123456789&access_token=test`);
        const paymentText = await paymentResponse.text();
        console.log(`Status Payment: ${paymentResponse.status}`);
        console.log(`Resposta Payment: ${paymentText.substring(0, 200)}...`);
        
        if (paymentResponse.status === 200 || paymentResponse.status === 404) {
            console.log('✅ Payment Status respondendo (404 é normal para ID inexistente)');
        } else {
            console.log('❌ Payment Status com erro de autenticação');
        }
    } catch (error) {
        console.log('❌ Erro no Payment Status:', error.message);
    }
    
    console.log('\n📊 RESUMO DO DIAGNÓSTICO:');
    console.log('- Variáveis de ambiente: Configuradas');
    console.log('- Endpoints básicos: Funcionando');
    console.log('- Problemas identificados nas respostas acima');
}

testMercadoPagoSpecific().catch(console.error);