// Teste de login direto no site principal
import fetch from 'node-fetch';

async function testarLoginDireto() {
    console.log('🔍 Testando login direto no site principal...\n');
    
    try {
        // 1. Primeiro, vamos simular o que o navegador faz
        console.log('1. Carregando a página principal...');
        const siteResponse = await fetch('https://pdv.crmvsystem.com/', {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache'
            }
        });
        
        const html = await siteResponse.text();
        console.log(`   - Status: ${siteResponse.status}`);
        console.log(`   - Tamanho HTML: ${html.length} caracteres`);
        
        // Verificar se há scripts JavaScript
        const scriptMatches = html.match(/<script[^>]*>/g) || [];
        console.log(`   - Scripts encontrados: ${scriptMatches.length}`);
        
        // Verificar se há referências ao Supabase
        const supabaseRef = html.includes('supabase') || html.includes('kmcaaqet');
        console.log(`   - Referências Supabase: ${supabaseRef ? 'Encontradas' : 'Não encontradas'}`);
        
        // 2. Tentar fazer uma requisição para o endpoint de login
        console.log('\n2. Testando endpoint de autenticação...');
        
        const authTest = await fetch('https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/token?grant_type=password', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': 'YOUR_SUPABASE_ANON_KEY'
                'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY
                'Origin': 'https://pdv.crmvsystem.com'
            },
            body: JSON.stringify({
                email: 'admin@pdv.com',
                password: 'admin123'
            })
        });
        
        const authResult = await authTest.json();
        console.log(`   - Status autenticação: ${authTest.status}`);
        
        if (authTest.ok && authResult.access_token) {
            console.log('   ✅ Autenticação funcionando');
            console.log(`   - Token: ${authResult.access_token.substring(0, 30)}...`);
        } else {
            console.log('   ❌ Falha na autenticação');
            console.log('   - Erro:', authResult.error_description || authResult.message);
        }
        
        // 3. Verificar headers de cache do CDN
        console.log('\n3. Analisando cache CDN...');
        console.log(`   - X-Vercel-Cache: ${siteResponse.headers.get('x-vercel-cache')}`);
        console.log(`   - X-Vercel-Id: ${siteResponse.headers.get('x-vercel-id')}`);
        console.log(`   - Cache-Control: ${siteResponse.headers.get('cache-control')}`);
        console.log(`   - ETag: ${siteResponse.headers.get('etag')}`);
        
        // 4. Resultado final
        console.log('\n📋 DIAGNÓSTICO FINAL:');
        
        if (authTest.ok && authResult.access_token) {
            console.log('✅ BACKEND FUNCIONANDO - Login OK');
            
            if (supabaseRef) {
                console.log('✅ FRONTEND ATUALIZADO - Configurações presentes');
                console.log('🎯 LOGIN DEVE FUNCIONAR NO NAVEGADOR!');
            } else {
                console.log('⚠️  FRONTEND COM CACHE - Aguarde alguns minutos');
                console.log('🔄 Use o backup: https://pdv-backup.surge.sh/');
            }
        } else {
            console.log('❌ PROBLEMA NO BACKEND - Verificar configurações');
        }
        
    } catch (error) {
        console.error('❌ Erro durante o teste:', error.message);
    }
}

testarLoginDireto();
