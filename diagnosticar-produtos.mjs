import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.v3V4U6n5RMbLZJLNzOgwwZrnLxLf3Pg6aUFLnfOH2Qk';

const supabase = createClient(supabaseUrl, serviceKey, {
  auth: { persistSession: false }
});

async function diagnosticarProdutos() {
  console.log('🔍 DIAGNOSTICANDO PROBLEMA COM PRODUTOS...\n');

  try {
    // 1. Verificar políticas de produtos
    console.log('1. Verificando políticas de produtos...');
    const { data: politicas, error: polError } = await supabase
      .from('pg_policies')
      .select('*')
      .eq('tablename', 'produtos');

    if (politicas) {
      console.log(`📋 Políticas encontradas: ${politicas.length}`);
      politicas.forEach(p => {
        console.log(`   - ${p.policyname}: ${p.cmd} | Roles: ${p.roles} | Qual: ${p.qual}`);
      });
    }

    // 2. Verificar estrutura da tabela produtos
    console.log('\n2. Verificando estrutura da tabela produtos...');
    const { data: colunas, error: colError } = await supabase
      .from('information_schema.columns')
      .select('column_name, data_type')
      .eq('table_name', 'produtos')
      .eq('table_schema', 'public');

    if (colunas) {
      const hasUserId = colunas.find(c => c.column_name === 'user_id');
      console.log(`   🔑 Campo user_id: ${hasUserId ? '✅ Existe' : '❌ Não existe'}`);
      if (hasUserId) {
        console.log(`   📊 Tipo: ${hasUserId.data_type}`);
      }
    }

    // 3. Verificar dados de produtos
    console.log('\n3. Verificando dados de produtos...');
    const { data: produtos, error: prodError } = await supabase
      .from('produtos')
      .select('id, nome, user_id')
      .limit(5);

    if (produtos) {
      console.log(`📦 Total amostral: ${produtos.length} produtos`);
      const userIds = [...new Set(produtos.map(p => p.user_id))];
      console.log(`🔑 User IDs encontrados: ${userIds.join(', ')}`);
      
      produtos.forEach(p => {
        console.log(`   - ${p.nome} (ID: ${p.id}, User: ${p.user_id})`);
      });
    }

    // 4. Verificar RLS status
    console.log('\n4. Verificando status RLS...');
    const { data: rlsStatus } = await supabase
      .from('pg_tables')
      .select('tablename, rowsecurity')
      .eq('tablename', 'produtos');

    if (rlsStatus && rlsStatus[0]) {
      console.log(`🔒 RLS ativo: ${rlsStatus[0].rowsecurity ? '✅ SIM' : '❌ NÃO'}`);
    }

    // 5. Teste com usuário anônimo
    console.log('\n5. Testando acesso anônimo a produtos...');
    const anonClient = createClient(supabaseUrl, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4');
    
    const { data: testProdutos, error: testError } = await anonClient
      .from('produtos')
      .select('*')
      .limit(3);

    if (testError) {
      console.log('   ✅ Produtos bloqueados para anônimos:', testError.message);
    } else {
      console.log('   ❌ PROBLEMA: Produtos acessíveis para anônimos!');
      console.log('   📊 Quantidade:', testProdutos?.length);
    }

    console.log('\n📊 DIAGNÓSTICO COMPLETO:');
    if (testError && testError.message.includes('permission denied')) {
      console.log('✅ RLS funcionando para usuários anônimos');
      console.log('⚠️ Problema pode estar no frontend ou auth do usuário logado');
    } else {
      console.log('❌ RLS NÃO está funcionando adequadamente');
      console.log('🔧 Necessário recriar políticas de produtos');
    }

  } catch (error) {
    console.error('❌ Erro no diagnóstico:', error);
  }
}

diagnosticarProdutos();
