// Teste específico dos endpoints que precisam de POST
const BASE_URL = 'https://pdv.crmvsystem.com/api';

async function testSpecificEndpoints() {
    console.log('🧪 TESTE ESPECÍFICO - ENDPOINTS POST\n');
    
    // 1. Teste PIX com POST
    console.log('1. Testando PIX (POST)...');
    try {
        const pixResponse = await fetch(`${BASE_URL}/pix`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: 10.00,
                description: 'Teste PIX - Reversão',
                email: 'teste@exemplo.com'
            })
        });
        
        const pixData = await pixResponse.text();
        console.log(`   Status PIX: ${pixResponse.status}`);
        console.log(`   Resposta: ${pixData.substring(0, 150)}...`);
        
        if (pixResponse.status === 200) {
            console.log('   ✅ PIX FUNCIONANDO!');
        } else {
            console.log('   ❌ PIX ainda com erro');
        }
    } catch (error) {
        console.log(`   ❌ Erro no PIX: ${error.message}`);
    }
    
    // 2. Teste MP Diagnostic
    console.log('\n2. Testando MP Diagnostic (GET)...');
    try {
        const mpResponse = await fetch(`${BASE_URL}/mp-diagnostic`);
        const mpData = await mpResponse.text();
        console.log(`   Status MP: ${mpResponse.status}`);
        console.log(`   Resposta: ${mpData.substring(0, 150)}...`);
        
        if (mpResponse.status === 200) {
            console.log('   ✅ MP DIAGNOSTIC FUNCIONANDO!');
        } else {
            console.log('   ❌ MP Diagnostic ainda com erro');
        }
    } catch (error) {
        console.log(`   ❌ Erro no MP Diagnostic: ${error.message}`);
    }
    
    // 3. Teste Preference Basic com POST
    console.log('\n3. Testando Preference Basic (POST)...');
    try {
        const prefResponse = await fetch(`${BASE_URL}/preference-basic`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: 29.90,
                description: 'Teste Preference - Reversão',
                email: 'teste@exemplo.com'
            })
        });
        
        const prefData = await prefResponse.text();
        console.log(`   Status Preference: ${prefResponse.status}`);
        console.log(`   Resposta: ${prefData.substring(0, 150)}...`);
        
        if (prefResponse.status === 200) {
            console.log('   ✅ PREFERENCE FUNCIONANDO!');
        } else {
            console.log('   ❌ Preference ainda com erro');
        }
    } catch (error) {
        console.log(`   ❌ Erro no Preference: ${error.message}`);
    }
    
    console.log('\n📊 RESULTADO DA REVERSÃO:');
}

testSpecificEndpoints().catch(console.error);