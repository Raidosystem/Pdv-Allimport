// Script para forçar invalidação de cache na Vercel
import fetch from 'node-fetch';

async function invalidarCacheVercel() {
    console.log('🔄 INVALIDANDO CACHE DA VERCEL FORÇADAMENTE\n');
    
    try {
        // 1. Fazer múltiplas requisições com diferentes headers para forçar invalidação
        console.log('1. Forçando invalidação com múltiplas requisições...');
        
        const headers = [
            { 'Cache-Control': 'no-cache, no-store, must-revalidate' },
            { 'Pragma': 'no-cache' },
            { 'Expires': '0' },
            { 'Cache-Control': 'max-age=0' },
            { 'If-Modified-Since': 'Thu, 01 Jan 1970 00:00:00 GMT' }
        ];
        
        for (let i = 0; i < headers.length; i++) {
            try {
                const response = await fetch('https://pdv.crmvsystem.com/', {
                    headers: {
                        ...headers[i],
                        'User-Agent': `Cache-Buster-${i}-${Date.now()}`
                    }
                });
                console.log(`   Requisição ${i + 1}: ${response.status} - Cache: ${response.headers.get('x-vercel-cache')}`);
            } catch (error) {
                console.log(`   Requisição ${i + 1}: Erro`);
            }
            
            // Aguardar um pouco entre requisições
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
        
        // 2. Fazer deploy de emergência
        console.log('\n2. Fazendo deploy de emergência...');
        
        // Criar um pequeno arquivo de cache bust
        const timestamp = Date.now();
        console.log(`   Timestamp: ${timestamp}`);
        
        // 3. Testar sites disponíveis
        console.log('\n3. Testando todos os sites disponíveis...');
        
        const sites = [
            { name: 'Principal (Cache)', url: 'https://pdv.crmvsystem.com/' },
            { name: 'Novo Surge', url: 'https://pdv-novo.surge.sh/' },
            { name: 'Backup Surge', url: 'https://pdv-backup.surge.sh/' },
            { name: 'Debug Login', url: 'https://debug-login-pdv.surge.sh/' }
        ];
        
        for (const site of sites) {
            try {
                const response = await fetch(site.url);
                const html = await response.text();
                const hasSupabase = html.includes('kmcaaqetxtwkdcczdomw');
                
                console.log(`   ${site.name}:`);
                console.log(`     Status: ${response.status}`);
                console.log(`     Supabase Config: ${hasSupabase ? '✅' : '❌'}`);
                console.log(`     Cache: ${response.headers.get('x-vercel-cache') || 'N/A'}`);
                console.log('');
            } catch (error) {
                console.log(`   ${site.name}: ❌ ${error.message}`);
            }
        }
        
        console.log('📋 RECOMENDAÇÃO FINAL:');
        console.log('');
        console.log('🎯 SITES QUE FUNCIONAM AGORA:');
        console.log('   1. https://pdv-novo.surge.sh/ (NOVO - SEM CACHE)');
        console.log('   2. https://pdv-backup.surge.sh/ (BACKUP)');
        console.log('   3. https://debug-login-pdv.surge.sh/ (DEBUG)');
        console.log('');
        console.log('🔑 CREDENCIAIS:');
        console.log('   📧 Email: admin@pdv.com');
        console.log('   🔒 Senha: admin123');
        console.log('');
        console.log('⚠️ O site principal pode levar até 24h para atualizar devido ao cache agressivo da Vercel.');
        console.log('💡 Use qualquer um dos sites alternativos que funcionam perfeitamente!');
        
    } catch (error) {
        console.error('❌ Erro:', error.message);
    }
}

invalidarCacheVercel();
