// Script para aprovar o usuário admin@pdv.com
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4'

async function corrigirAprovacaoUsuario() {
    console.log('🔧 CORRIGINDO SISTEMA DE APROVAÇÃO\n');
    
    try {
        const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
            auth: { autoRefreshToken: false, persistSession: false }
        });
        
        // 1. Buscar o usuário admin@pdv.com
        console.log('1. Buscando usuário admin@pdv.com...');
        const { data: users, error: userError } = await supabaseAdmin
            .from('auth.users')
            .select('id, email')
            .eq('email', 'admin@pdv.com');
            
        if (userError) {
            console.log('❌ Erro ao buscar usuário:', userError.message);
            return;
        }
        
        if (!users || users.length === 0) {
            console.log('❌ Usuário admin@pdv.com não encontrado');
            return;
        }
        
        const userId = users[0].id;
        console.log(`✅ Usuário encontrado: ${userId}`);
        
        // 2. Verificar se existe registro na tabela user_approvals
        console.log('\n2. Verificando aprovação...');
        const { data: approvals, error: approvalError } = await supabaseAdmin
            .from('user_approvals')
            .select('*')
            .eq('user_id', userId);
            
        if (approvalError) {
            console.log('❌ Erro ao verificar aprovação:', approvalError.message);
        } else {
            console.log(`✅ Registros de aprovação encontrados: ${approvals?.length || 0}`);
            if (approvals && approvals.length > 0) {
                console.log('   Status atual:', approvals[0].status);
            }
        }
        
        // 3. Criar/atualizar aprovação para approved
        console.log('\n3. Aprovando usuário...');
        const { error: upsertError } = await supabaseAdmin
            .from('user_approvals')
            .upsert({
                user_id: userId,
                email: 'admin@pdv.com',
                status: 'approved',
                approved_at: new Date().toISOString(),
                approved_by: 'system'
            }, {
                onConflict: 'user_id'
            });
            
        if (upsertError) {
            console.log('❌ Erro ao aprovar:', upsertError.message);
        } else {
            console.log('✅ Usuário aprovado com sucesso!');
        }
        
        // 4. Testar login após aprovação
        console.log('\n4. Testando login após aprovação...');
        const supabaseClient = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg');
        
        const { data: loginData, error: loginError } = await supabaseClient.auth.signInWithPassword({
            email: 'admin@pdv.com',
            password: 'admin123'
        });
        
        if (loginError) {
            console.log('❌ Login ainda falhando:', loginError.message);
        } else {
            console.log('✅ Login funcionando!');
            console.log(`   Token: ${loginData.session?.access_token?.substring(0, 30)}...`);
        }
        
        console.log('\n📋 RESULTADO FINAL:');
        console.log('🎯 Usuário admin@pdv.com aprovado no sistema');
        console.log('🔐 Credenciais: admin@pdv.com / admin123');
        console.log('🌐 Teste em: https://pdv.crmvsystem.com/');
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
    }
}

corrigirAprovacaoUsuario();
