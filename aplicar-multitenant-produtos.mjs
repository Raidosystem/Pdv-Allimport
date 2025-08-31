import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

const USER_UUID = '550e8400-e29b-41d4-a716-446655440000';

async function aplicarMultiTenantProdutos() {
  console.log('🔧 Iniciando configuração multi-tenant para produtos...\n');

  try {
    // 1. ADICIONAR COLUNA USER_ID NA TABELA PRODUTOS
    console.log('1. Adicionando coluna user_id na tabela produtos...');
    const { error: addColumnError } = await supabase.rpc('exec_sql', {
      sql_query: `ALTER TABLE produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);`
    });

    if (addColumnError) {
      console.error('❌ Erro ao adicionar coluna:', addColumnError);
      return;
    }
    console.log('✅ Coluna user_id adicionada com sucesso!');

    // 2. ASSOCIAR PRODUTOS EXISTENTES AO USUÁRIO
    console.log('\n2. Associando produtos existentes ao usuário...');
    const { error: updateError } = await supabase.rpc('exec_sql', {
      sql_query: `UPDATE produtos SET user_id = '${USER_UUID}'::uuid WHERE user_id IS NULL;`
    });

    if (updateError) {
      console.error('❌ Erro ao associar produtos:', updateError);
      return;
    }
    console.log('✅ Produtos associados com sucesso!');

    // 3. HABILITAR RLS
    console.log('\n3. Habilitando RLS na tabela produtos...');
    const { error: rlsError } = await supabase.rpc('exec_sql', {
      sql_query: `ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;`
    });

    if (rlsError) {
      console.error('❌ Erro ao habilitar RLS:', rlsError);
      return;
    }
    console.log('✅ RLS habilitado!');

    // 4. REMOVER POLÍTICAS ANTIGAS
    console.log('\n4. Removendo políticas antigas...');
    const dropPolicies = [
      `DROP POLICY IF EXISTS "Usuários podem ver apenas seus produtos" ON produtos;`,
      `DROP POLICY IF EXISTS "Usuários podem inserir seus próprios produtos" ON produtos;`,
      `DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios produtos" ON produtos;`,
      `DROP POLICY IF EXISTS "Usuários podem deletar seus próprios produtos" ON produtos;`
    ];

    for (const policy of dropPolicies) {
      await supabase.rpc('exec_sql', { sql_query: policy });
    }
    console.log('✅ Políticas antigas removidas!');

    // 5. CRIAR POLÍTICAS RESTRITIVAS
    console.log('\n5. Criando políticas RLS restritivas...');
    const createPolicies = [
      `CREATE POLICY "Isolamento_produtos_SELECT" ON produtos FOR SELECT USING (user_id = '${USER_UUID}'::uuid);`,
      `CREATE POLICY "Isolamento_produtos_INSERT" ON produtos FOR INSERT WITH CHECK (user_id = '${USER_UUID}'::uuid);`,
      `CREATE POLICY "Isolamento_produtos_UPDATE" ON produtos FOR UPDATE USING (user_id = '${USER_UUID}'::uuid) WITH CHECK (user_id = '${USER_UUID}'::uuid);`,
      `CREATE POLICY "Isolamento_produtos_DELETE" ON produtos FOR DELETE USING (user_id = '${USER_UUID}'::uuid);`
    ];

    for (const policy of createPolicies) {
      const { error } = await supabase.rpc('exec_sql', { sql_query: policy });
      if (error) {
        console.error('❌ Erro ao criar política:', error);
        return;
      }
    }
    console.log('✅ Políticas RLS criadas!');

    // 6. VERIFICAR CONFIGURAÇÃO
    console.log('\n6. Verificando configuração...');
    
    // Contar produtos
    const { data: produtos, error: countError } = await supabase
      .from('produtos')
      .select('id, nome, user_id')
      .limit(5);

    if (countError) {
      console.error('❌ Erro ao verificar produtos:', countError);
      return;
    }

    console.log(`✅ Produtos encontrados: ${produtos?.length || 0}`);
    if (produtos && produtos.length > 0) {
      console.log('📋 Primeiros produtos:');
      produtos.forEach(produto => {
        console.log(`  - ${produto.nome} (user_id: ${produto.user_id ? 'OK' : 'FALTANDO'})`);
      });
    }

    console.log('\n🎉 Configuração multi-tenant para produtos concluída com sucesso!');
    console.log('\n📝 Próximo passo: Atualizar o frontend (ProductService) com filtros por user_id');

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

aplicarMultiTenantProdutos();
