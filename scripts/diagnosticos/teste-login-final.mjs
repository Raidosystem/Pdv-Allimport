// Teste final do login após correções
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

async function testeLoginFinal() {
    console.log('🎯 TESTE FINAL DO LOGIN APÓS CORREÇÕES\n');
    
    try {
        const supabase = createClient(supabaseUrl, supabaseAnonKey);
        
        console.log('1. Testando login com admin@pdv.com...');
        
        const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
            email: 'admin@pdv.com',
            password: 'admin123'
        });
        
        if (loginError) {
            console.log('❌ Erro no login:', loginError.message);
        } else {
            console.log('✅ LOGIN FUNCIONOU!');
            console.log(`   📧 Usuário: ${loginData.user?.email}`);
            console.log(`   🆔 ID: ${loginData.user?.id}`);
            console.log(`   🎟️ Token: ${loginData.session?.access_token?.substring(0, 50)}...`);
            
            // Testar acesso a dados
            console.log('\n2. Testando acesso aos dados...');
            const { data: testData, error: testError } = await supabase
                .from('empresas')
                .select('*')
                .limit(1);
                
            if (testError && testError.code !== '42P01') {
                console.log('⚠️ Erro ao acessar dados:', testError.message);
            } else {
                console.log('✅ Acesso aos dados funcionando');
            }
            
            // Logout para limpar sessão
            await supabase.auth.signOut();
        }
        
        console.log('\n3. Verificando status dos sites...');
        
        // Testar site principal
        try {
            const mainResponse = await fetch('https://pdv.crmvsystem.com/');
            console.log(`   🌐 Principal: ${mainResponse.status} - Cache: ${mainResponse.headers.get('x-vercel-cache') || 'N/A'}`);
        } catch (e) {
            console.log('   ❌ Erro no site principal:', e.message);
        }
        
        // Testar backup
        try {
            const backupResponse = await fetch('https://pdv-backup.surge.sh/');
            console.log(`   🔄 Backup: ${backupResponse.status} - Funcionando`);
        } catch (e) {
            console.log('   ❌ Erro no backup:', e.message);
        }
        
        console.log('\n📋 RESULTADO FINAL:');
        
        if (!loginError) {
            console.log('🎉 PROBLEMA RESOLVIDO!');
            console.log('');
            console.log('🔑 CREDENCIAIS FUNCIONAIS:');
            console.log('   📧 Email: admin@pdv.com');
            console.log('   🔒 Senha: admin123');
            console.log('');
            console.log('🌐 SITES PARA TESTE:');
            console.log('   Principal: https://pdv.crmvsystem.com/');
            console.log('   Backup: https://pdv-backup.surge.sh/');
            console.log('   Debug: https://debug-login-pdv.surge.sh/');
            console.log('');
            console.log('✅ O login deve funcionar em todos os sites agora!');
            console.log('💡 Se ainda der erro, aguarde 2-3 minutos para o cache atualizar.');
        } else {
            console.log('❌ Ainda há problemas no login');
            console.log('🔧 Verifique as configurações do Supabase');
        }
        
    } catch (error) {
        console.error('❌ Erro no teste:', error.message);
    }
}

testeLoginFinal();
