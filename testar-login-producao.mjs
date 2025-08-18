import fetch from 'node-fetch';

async function testarLoginProducao() {
    console.log('🔍 Testando login na produção após deploy...\n');
    
    try {
        // 1. Verificar se o site carrega as configurações do Supabase
        console.log('1. Testando carregamento do site...');
        const siteResponse = await fetch('https://pdv.crmvsystem.com/');
        const html = await siteResponse.text();
        
        // Procurar por configurações do Supabase no HTML
        const supabaseMatches = html.match(/kmcaaqetxtwkdcczdomw/g) || [];
        console.log(`   - Configurações Supabase encontradas: ${supabaseMatches.length}`);
        
        if (supabaseMatches.length > 0) {
            console.log('   ✅ Site carregou com configurações atualizadas');
        } else {
            console.log('   ❌ Site ainda sem configurações do Supabase');
        }
        
        // 2. Testar login direto via API
        console.log('\n2. Testando login via API Supabase...');
        const loginData = {
            email: 'admin@teste.com',
            password: '123456'
        };
        
        const loginResponse = await fetch('https://kmcaaqetxtwkdcczdomw.supabase.co/auth/v1/token?grant_type=password', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg',
                'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'
            },
            body: JSON.stringify(loginData)
        });
        
        const loginResult = await loginResponse.json();
        console.log(`   - Status: ${loginResponse.status}`);
        
        if (loginResponse.ok && loginResult.access_token) {
            console.log('   ✅ Login via API funcionando');
            console.log(`   - Token gerado: ${loginResult.access_token.substring(0, 30)}...`);
        } else {
            console.log('   ❌ Falha no login via API');
            console.log('   - Erro:', loginResult.error_description || loginResult.message);
        }
        
        // 3. Verificar headers de cache
        console.log('\n3. Verificando cache...');
        console.log(`   - X-Vercel-Cache: ${siteResponse.headers.get('x-vercel-cache')}`);
        console.log(`   - X-Vercel-Id: ${siteResponse.headers.get('x-vercel-id')}`);
        
        console.log('\n📋 RESULTADO FINAL:');
        if (supabaseMatches.length > 0 && loginResponse.ok) {
            console.log('✅ LOGIN DEVE ESTAR FUNCIONANDO NA PRODUÇÃO');
            console.log('🔗 Teste em: https://pdv.crmvsystem.com/');
        } else if (supabaseMatches.length === 0) {
            console.log('⚠️  Cache ainda pode estar ativo. Aguarde alguns minutos e teste novamente.');
        } else {
            console.log('❌ Problema na configuração do backend');
        }
        
    } catch (error) {
        console.error('❌ Erro durante o teste:', error.message);
    }
}

testarLoginProducao();
