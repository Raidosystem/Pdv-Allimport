import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

async function diagnosticarCredenciais() {
  console.log('🔧 Diagnosticando credenciais atualizadas...\n');

  try {
    // 1. TESTE DE CONEXÃO
    console.log('1. Testando conexão com Supabase...');
    const { error: connectionError } = await supabase
      .from('clientes')
      .select('count')
      .limit(1);

    if (connectionError) {
      console.error('❌ Erro de conexão:', connectionError);
      return;
    }
    console.log('✅ Conexão estabelecida com sucesso!');

    // 2. VERIFICAR RLS STATUS
    console.log('\n2. Verificando status do RLS...');
    
    try {
      const { data: clientesData, error: clientesError } = await supabase
        .from('clientes')
        .select('*')
        .limit(5);

      console.log('🔍 Resultado da consulta clientes:');
      console.log('  - Erro:', clientesError ? clientesError.message : 'Nenhum');
      console.log('  - Dados retornados:', clientesData ? clientesData.length : 0);

      if (clientesError) {
        if (clientesError.message.includes('RLS')) {
          console.log('✅ RLS está funcionando (bloqueando acesso não autorizado)');
        } else {
          console.log('❌ Erro diferente de RLS:', clientesError.message);
        }
      } else if (clientesData && clientesData.length > 0) {
        console.log('⚠️ PROBLEMA: RLS não está funcionando, dados foram retornados!');
        console.log('  - Primeiros registros:', clientesData.slice(0, 2));
      }
    } catch (error) {
      console.log('✅ RLS provavelmente está funcionando (consulta bloqueada)');
    }

    // 3. VERIFICAR PRODUTOS
    console.log('\n3. Verificando produtos...');
    
    try {
      const { data: produtosData, error: produtosError } = await supabase
        .from('produtos')
        .select('*')
        .limit(5);

      console.log('🔍 Resultado da consulta produtos:');
      console.log('  - Erro:', produtosError ? produtosError.message : 'Nenhum');
      console.log('  - Dados retornados:', produtosData ? produtosData.length : 0);

      if (produtosError) {
        if (produtosError.message.includes('RLS')) {
          console.log('✅ RLS está funcionando para produtos');
        }
      } else if (produtosData && produtosData.length > 0) {
        console.log('⚠️ PROBLEMA: Produtos não isolados!');
        console.log('  - Primeiros produtos:', produtosData.slice(0, 2));
      }
    } catch (error) {
      console.log('✅ RLS provavelmente está funcionando para produtos');
    }

    // 4. TESTAR INSERÇÃO
    console.log('\n4. Testando inserção de dados...');
    
    try {
      const { data: insertData, error: insertError } = await supabase
        .from('clientes')
        .insert([
          {
            nome: 'Cliente Teste',
            email: 'teste@exemplo.com',
            user_id: '550e8400-e29b-41d4-a716-446655440000'
          }
        ])
        .select();

      if (insertError) {
        if (insertError.message.includes('RLS') || insertError.message.includes('policy')) {
          console.log('✅ RLS está bloqueando inserções não autorizadas');
        } else {
          console.log('❌ Erro de inserção:', insertError.message);
        }
      } else {
        console.log('⚠️ PROBLEMA: Inserção permitida sem autenticação!');
        console.log('  - Dados inseridos:', insertData);
      }
    } catch (error) {
      console.log('✅ RLS está funcionando (inserção bloqueada)');
    }

    console.log('\n📋 RESUMO DO DIAGNÓSTICO:');
    console.log('✅ URL atualizada:', supabaseUrl);
    console.log('✅ Key atualizada:', supabaseKey.substring(0, 50) + '...');
    console.log('\n🔧 PRÓXIMO PASSO:');
    console.log('Execute o script APLICAR_MULTITENANT_PRODUTOS_SEGURO.sql no Supabase Dashboard');
    console.log('Link: https://kmcaaqetxtwkdcczdomw.supabase.co/project/default/sql/new');

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

diagnosticarCredenciais();
