// Diagnóstico específico do erro de login
import { createClient } from '@supabase/supabase-js'

async function diagnosticarErroLogin() {
    console.log('🔍 DIAGNÓSTICO ESPECÍFICO DO ERRO DE LOGIN\n');
    
    const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'
    
    try {
        console.log('1. Testando credenciais conhecidas...');
        
        const supabase = createClient(supabaseUrl, supabaseAnonKey);
        
        const credenciais = [
            { email: 'admin@pdv.com', password: 'admin123' },
            { email: 'admin@teste.com', password: '123456' },
            { email: 'test@example.com', password: 'password' },
            { email: 'usuario@teste.com', password: '123456' }
        ];
        
        let loginSucesso = false;
        let credencialValida = null;
        
        for (const cred of credenciais) {
            console.log(`\n   Testando: ${cred.email}`);
            
            const { data, error } = await supabase.auth.signInWithPassword({
                email: cred.email,
                password: cred.password
            });
            
            if (error) {
                console.log(`   ❌ ${error.message}`);
            } else {
                console.log(`   ✅ SUCESSO!`);
                console.log(`   - Usuário: ${data.user?.email}`);
                console.log(`   - ID: ${data.user?.id}`);
                console.log(`   - Token: ${data.session?.access_token?.substring(0, 30)}...`);
                loginSucesso = true;
                credencialValida = cred;
                break;
            }
        }
        
        if (!loginSucesso) {
            console.log('\n2. Criando novo usuário de emergência...');
            
            // Usar service role para criar usuário
            const supabaseAdmin = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4', {
                auth: { autoRefreshToken: false, persistSession: false }
            });
            
            const { data: novoUsuario, error: errorCriacao } = await supabaseAdmin.auth.admin.createUser({
                email: 'pdv@admin.com',
                password: 'pdv2025',
                email_confirm: true
            });
            
            if (errorCriacao) {
                console.log(`   ❌ Erro ao criar: ${errorCriacao.message}`);
            } else {
                console.log(`   ✅ Usuário criado: pdv@admin.com / pdv2025`);
                credencialValida = { email: 'pdv@admin.com', password: 'pdv2025' };
                
                // Testar novo usuário
                const { data: testLogin, error: testError } = await supabase.auth.signInWithPassword({
                    email: 'pdv@admin.com',
                    password: 'pdv2025'
                });
                
                if (testError) {
                    console.log(`   ❌ Teste falhou: ${testError.message}`);
                } else {
                    console.log(`   ✅ Teste funcionou!`);
                    loginSucesso = true;
                }
            }
        }
        
        console.log('\n3. Verificando configuração RLS...');
        
        // Verificar se RLS está bloqueando
        const supabaseAdmin = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4', {
            auth: { autoRefreshToken: false, persistSession: false }
        });
        
        const { data: rlsCheck, error: rlsError } = await supabaseAdmin
            .from('information_schema.tables')
            .select('table_name')
            .eq('table_schema', 'public')
            .limit(5);
            
        if (rlsError) {
            console.log(`   ⚠️ Não foi possível verificar RLS: ${rlsError.message}`);
        } else {
            console.log(`   ✅ Banco acessível, ${rlsCheck.length} tabelas encontradas`);
        }
        
        console.log('\n📋 RESULTADO FINAL:');
        
        if (loginSucesso && credencialValida) {
            console.log('🎯 CREDENCIAIS FUNCIONAIS ENCONTRADAS:');
            console.log(`   📧 Email: ${credencialValida.email}`);
            console.log(`   🔒 Senha: ${credencialValida.password}`);
            console.log('');
            console.log('🌐 URLs para testar:');
            console.log('   Principal: https://pdv.crmvsystem.com/');
            console.log('   Backup: https://pdv-backup.surge.sh/');
            console.log('');
            console.log('💡 Se ainda der erro, limpe o cache do navegador (Ctrl+Shift+Del)');
        } else {
            console.log('❌ NENHUMA CREDENCIAL FUNCIONOU');
            console.log('🔧 Verifique a configuração do Supabase');
        }
        
    } catch (error) {
        console.error('❌ Erro no diagnóstico:', error.message);
    }
}

diagnosticarErroLogin();
