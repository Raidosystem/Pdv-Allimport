// Vamos conectar diretamente no banco para ver os usuários

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4'

async function verificarUsuarios() {
    console.log('🔍 VERIFICANDO USUÁRIOS NO BANCO DE DADOS\n');
    
    try {
        // Usar service role para acessar tabelas auth
        const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
            auth: {
                autoRefreshToken: false,
                persistSession: false
            }
        });
        
        console.log('1. Listando todos os usuários...');
        
        // Usar SQL direto
        const { data: usuarios, error } = await supabaseAdmin
            .from('auth.users')
            .select('id, email, email_confirmed_at, created_at')
            .order('created_at', { ascending: false });
            
        if (error) {
            console.log('❌ Erro ao buscar usuários:', error.message);
            
            // Tentar com RPC
            console.log('\nTentando com RPC...');
            const { data: rpcUsuarios, error: rpcError } = await supabaseAdmin
                .rpc('get_users_list');
                
            if (rpcError) {
                console.log('❌ RPC falhou:', rpcError.message);
            } else {
                console.log('✅ Usuários via RPC:', rpcUsuarios);
            }
        } else {
            console.log(`✅ Encontrados ${usuarios.length} usuários:`);
            usuarios.forEach((user, index) => {
                console.log(`   ${index + 1}. Email: ${user.email}`);
                console.log(`      ID: ${user.id}`);
                console.log(`      Confirmado: ${user.email_confirmed_at ? 'Sim' : 'Não'}`);
                console.log(`      Criado: ${new Date(user.created_at).toLocaleString()}`);
                console.log('');
            });
        }
        
        // 2. Criar um usuário de teste se não existir
        console.log('2. Criando usuário de teste...');
        
        const { data: novoUsuario, error: errorCriacao } = await supabaseAdmin.auth.admin.createUser({
            email: 'admin@pdv.com',
            password: 'admin123',
            email_confirm: true
        });
        
        if (errorCriacao) {
            console.log('❌ Erro ao criar usuário:', errorCriacao.message);
        } else {
            console.log('✅ Usuário admin@pdv.com criado com sucesso!');
            console.log('   Senha: admin123');
        }
        
        // 3. Testar login com o usuário criado
        console.log('\n3. Testando login com usuário criado...');
        
        const supabaseClient = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg');
        
        const { data: loginData, error: loginError } = await supabaseClient.auth.signInWithPassword({
            email: 'admin@pdv.com',
            password: 'admin123'
        });
        
        if (loginError) {
            console.log('❌ Login falhou:', loginError.message);
        } else {
            console.log('✅ Login funcionou!');
            console.log(`   Token: ${loginData.session?.access_token?.substring(0, 50)}...`);
            console.log(`   Usuário: ${loginData.user?.email}`);
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
        console.error('Stack:', error.stack);
    }
}

verificarUsuarios();
