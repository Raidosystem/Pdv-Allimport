import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4';

console.log('🗑️ REMOVENDO USUÁRIO ADMIN@PDV.COM COMPLETAMENTE...');

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function removerAdminCompletamente() {
    try {
        console.log('🔍 Procurando usuário admin@pdv.com...');
        
        // 1. Buscar o usuário admin
        const { data: users, error: searchError } = await supabase.auth.admin.listUsers();
        
        if (searchError) {
            console.error('❌ Erro ao buscar usuários:', searchError.message);
            return;
        }
        
        console.log(`📊 Total de usuários encontrados: ${users.users.length}`);
        
        // 2. Encontrar o admin
        const adminUser = users.users.find(user => user.email === 'admin@pdv.com');
        
        if (!adminUser) {
            console.log('✅ Usuário admin@pdv.com não encontrado (já removido)');
            return;
        }
        
        console.log(`🎯 Encontrado admin: ID ${adminUser.id}`);
        
        // 3. Remover dados associados ao admin (se existirem)
        console.log('🗑️ Removendo dados associados ao admin...');
        
        // Remover clientes do admin
        const { error: clientesError } = await supabase
            .from('clientes')
            .delete()
            .eq('user_id', adminUser.id);
        
        if (clientesError) console.log('⚠️ Aviso clientes:', clientesError.message);
        
        // Remover produtos do admin
        const { error: produtosError } = await supabase
            .from('produtos')
            .delete()
            .eq('user_id', adminUser.id);
        
        if (produtosError) console.log('⚠️ Aviso produtos:', produtosError.message);
        
        // Remover vendas do admin
        const { error: vendasError } = await supabase
            .from('vendas')
            .delete()
            .eq('user_id', adminUser.id);
        
        if (vendasError) console.log('⚠️ Aviso vendas:', vendasError.message);
        
        // Remover caixa do admin
        const { error: caixaError } = await supabase
            .from('caixa')
            .delete()
            .eq('user_id', adminUser.id);
        
        if (caixaError) console.log('⚠️ Aviso caixa:', caixaError.message);
        
        // 4. Remover o usuário admin
        console.log('🗑️ Removendo usuário admin@pdv.com...');
        
        const { error: deleteError } = await supabase.auth.admin.deleteUser(adminUser.id);
        
        if (deleteError) {
            console.error('❌ Erro ao remover admin:', deleteError.message);
        } else {
            console.log('✅ Usuário admin@pdv.com REMOVIDO COMPLETAMENTE!');
        }
        
        // 5. Verificar usuários restantes
        console.log('📊 Verificando usuários restantes...');
        
        const { data: remainingUsers, error: listError } = await supabase.auth.admin.listUsers();
        
        if (listError) {
            console.error('❌ Erro ao listar usuários:', listError.message);
        } else {
            console.log(`📋 Usuários restantes: ${remainingUsers.users.length}`);
            remainingUsers.users.forEach(user => {
                console.log(`   👤 ${user.email} (ID: ${user.id})`);
            });
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error.message);
    }
}

removerAdminCompletamente();
