// Diagnóstico avançado do erro de login no navegador
import fetch from 'node-fetch';

async function diagnosticoAvancadoLogin() {
    console.log('🔧 DIAGNÓSTICO AVANÇADO DO LOGIN NO NAVEGADOR\n');
    
    try {
        // 1. Verificar se o site está carregando as configurações corretas
        console.log('1. Verificando configurações no HTML do site...');
        
        const siteResponse = await fetch('https://pdv.crmvsystem.com/', {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Cache-Control': 'no-cache'
            }
        });
        
        const html = await siteResponse.text();
        
        // Procurar por configurações específicas
        const hasSupabaseUrl = html.includes('your-project-ref.supabase.co');
        const hasSupabaseKey = html.includes('YOUR_SUPABASE_ANON_KEY'
        const hasAuthModule = html.includes('AuthContext') || html.includes('signIn');
        
        console.log(`   - URL Supabase no HTML: ${hasSupabaseUrl ? '✅' : '❌'}`);
        console.log(`   - Chave Supabase no HTML: ${hasSupabaseKey ? '✅' : '❌'}`);
        console.log(`   - Módulo de Auth: ${hasAuthModule ? '✅' : '❌'}`);
        console.log(`   - Cache Status: ${siteResponse.headers.get('x-vercel-cache')}`);
        
        // 2. Simular o que acontece quando o usuário faz login
        console.log('\n2. Simulando processo de login...');
        
        // Simular requisição que o frontend faria
        const loginResponse = await fetch('https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/token?grant_type=password', {
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
        
        const loginResult = await loginResponse.json();
        console.log(`   - Status da API: ${loginResponse.status}`);
        console.log(`   - Login Result:`, loginResult.access_token ? '✅ Token gerado' : `❌ ${loginResult.error_description || loginResult.message}`);
        
        // 3. Verificar CORS
        console.log('\n3. Verificando CORS...');
        const corsHeaders = [
            'access-control-allow-origin',
            'access-control-allow-credentials',
            'access-control-allow-methods',
            'access-control-allow-headers'
        ];
        
        corsHeaders.forEach(header => {
            const value = loginResponse.headers.get(header);
            console.log(`   - ${header}: ${value || 'não definido'}`);
        });
        
        // 4. Testar diferentes sites
        console.log('\n4. Testando sites alternativos...');
        
        const sites = [
            { name: 'Backup Surge', url: 'https://pdv-backup.surge.sh/' },
            { name: 'Debug Login', url: 'https://debug-login-pdv.surge.sh/' }
        ];
        
        for (const site of sites) {
            try {
                const response = await fetch(site.url);
                console.log(`   - ${site.name}: ${response.status} ✅`);
            } catch (error) {
                console.log(`   - ${site.name}: ❌ ${error.message}`);
            }
        }
        
        // 5. Recomendações baseadas no diagnóstico
        console.log('\n📋 DIAGNÓSTICO E RECOMENDAÇÕES:');
        
        if (loginResponse.ok && loginResult.access_token) {
            console.log('✅ Backend funcionando perfeitamente');
            
            if (hasSupabaseUrl && hasSupabaseKey) {
                console.log('✅ Frontend tem configurações corretas');
                console.log('');
                console.log('🔧 POSSÍVEIS CAUSAS DO ERRO:');
                console.log('   1. Cache do navegador ainda ativo');
                console.log('   2. Cookies/sessão anterior interferindo');
                console.log('   3. JavaScript sendo bloqueado');
                console.log('');
                console.log('🎯 SOLUÇÕES RECOMENDADAS:');
                console.log('   1. Limpar completamente cache e cookies');
                console.log('   2. Usar navegação privada/incógnita');
                console.log('   3. Testar no backup: https://pdv-backup.surge.sh/');
                console.log('   4. Testar debug: https://debug-login-pdv.surge.sh/');
            } else {
                console.log('⚠️ Frontend pode estar com cache antigo');
                console.log('');
                console.log('🎯 USE O BACKUP: https://pdv-backup.surge.sh/');
            }
        } else {
            console.log('❌ Problema no backend');
            console.log('🔧 Verificar configurações do Supabase');
        }
        
        console.log('\n🔑 CREDENCIAIS CORRETAS:');
        console.log('   📧 Email: admin@pdv.com');
        console.log('   🔒 Senha: admin123');
        
    } catch (error) {
        console.error('❌ Erro no diagnóstico:', error.message);
    }
}

diagnosticoAvancadoLogin();
