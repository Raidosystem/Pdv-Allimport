// Diagnóstico completo do sistema de autenticação

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://YOUR_SUPABASE_PROJECT.supabase.co'
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'

async function diagnosticoCompleto() {
    console.log('🔍 DIAGNÓSTICO COMPLETO DO SISTEMA DE AUTENTICAÇÃO\n');
    
    try {
        // 1. Teste do cliente Supabase
        console.log('1. Testando cliente Supabase...');
        const supabase = createClient(supabaseUrl, supabaseAnonKey)
        console.log('   ✅ Cliente criado com sucesso');
        
        // 2. Teste de conexão
        console.log('\n2. Testando conexão com o banco...');
        const { data: testData, error: testError } = await supabase
            .from('auth.users')
            .select('email')
            .limit(1);
            
        if (testError) {
            console.log('   ❌ Erro na conexão:', testError.message);
            
            // Tentar com RPC público
            console.log('   Tentando RPC alternativo...');
            const { data: rpcData, error: rpcError } = await supabase.rpc('get_current_user_count');
            if (rpcError) {
                console.log('   ❌ RPC também falhou:', rpcError.message);
            } else {
                console.log('   ✅ RPC funcionando, dados:', rpcData);
            }
        } else {
            console.log('   ✅ Conexão funcionando, encontrados usuários');
        }
        
        // 3. Teste de login específico
        console.log('\n3. Testando login com credenciais conhecidas...');
        
        const credenciaisParaTestar = [
            { email: 'admin@teste.com', password: '123456' },
            { email: 'test@example.com', password: 'password' },
            { email: 'usuario@teste.com', password: '123456' }
        ];
        
        for (const credencial of credenciaisParaTestar) {
            console.log(`   Testando: ${credencial.email}`);
            
            const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
                email: credencial.email,
                password: credencial.password,
            });
            
            if (loginError) {
                console.log(`   ❌ Falha: ${loginError.message}`);
            } else {
                console.log(`   ✅ Sucesso! Token: ${loginData.session?.access_token?.substring(0, 30)}...`);
                
                // Testar acesso a dados após login
                const { data: userData, error: userError } = await supabase
                    .from('profiles')
                    .select('*')
                    .limit(1);
                    
                if (userData) {
                    console.log(`   ✅ Acesso aos dados funcionando`);
                } else {
                    console.log(`   ⚠️ Login ok, mas sem acesso aos dados:`, userError?.message);
                }
                
                // Logout para próximo teste
                await supabase.auth.signOut();
                break;
            }
        }
        
        // 4. Verificar se o problema é de domínio
        console.log('\n4. Verificando configuração de domínio...');
        console.log(`   - URL Supabase: ${supabaseUrl}`);
        console.log(`   - Chave anônima: ${supabaseAnonKey.substring(0, 50)}...`);
        
        // 5. Testar se o problema é CORS
        console.log('\n5. Testando CORS...');
        try {
            const corsResponse = await fetch(`${supabaseUrl}/rest/v1/`, {
                method: 'HEAD',
                headers: {
                    'apikey': supabaseAnonKey,
                    'Origin': 'https://pdv.crmvsystem.com'
                }
            });
            console.log(`   - Status CORS: ${corsResponse.status}`);
            console.log(`   - Headers CORS: ${corsResponse.headers.get('access-control-allow-origin') || 'não definido'}`);
        } catch (corsError) {
            console.log(`   ❌ Erro CORS: ${corsError.message}`);
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
    }
}

diagnosticoCompleto();
