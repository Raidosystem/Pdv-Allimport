import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

async function testarRLSRestritivo() {
  console.log('🔒 Testando RLS restritivo após aplicação...\n');

  try {
    // TESTE 1: Acesso ANÔNIMO (deve ser bloqueado)
    console.log('1. Testando acesso ANÔNIMO (sem autenticação):');
    
    const { data: clientesAnonimo, error: clientesAnonError } = await supabase
      .from('clientes')
      .select('*')
      .limit(5);

    if (clientesAnonError) {
      console.log('✅ Clientes bloqueados para usuário anônimo:', clientesAnonError.message);
    } else {
      console.log('❌ PROBLEMA: Clientes acessíveis para usuário anônimo!', clientesAnonimo?.length);
    }

    const { data: produtosAnonimo, error: produtosAnonError } = await supabase
      .from('produtos')
      .select('*')
      .limit(5);

    if (produtosAnonError) {
      console.log('✅ Produtos bloqueados para usuário anônimo:', produtosAnonError.message);
    } else {
      console.log('❌ PROBLEMA: Produtos acessíveis para usuário anônimo!', produtosAnonimo?.length);
    }

    // TESTE 2: Verificar políticas ativas
    console.log('\n2. Verificando políticas RLS ativas:');
    
    const { data: politicas, error: politicasError } = await supabase
      .from('pg_policies')
      .select('schemaname, tablename, policyname, permissive, roles, cmd, qual')
      .in('tablename', ['clientes', 'produtos']);

    if (!politicasError && politicas) {
      console.log(`📋 Políticas encontradas: ${politicas.length}`);
      politicas.forEach(p => {
        console.log(`  - ${p.tablename}: ${p.policyname} (${p.cmd})`);
      });
    }

    // TESTE 3: Verificar RLS ativado
    console.log('\n3. Verificando status RLS:');
    
    const { data: rlsStatus, error: rlsError } = await supabase
      .from('pg_class')
      .select('relname, relrowsecurity')
      .in('relname', ['clientes', 'produtos']);

    if (!rlsError && rlsStatus) {
      rlsStatus.forEach(table => {
        const status = table.relrowsecurity ? '✅ Ativo' : '❌ Inativo';
        console.log(`  ${table.relname}: ${status}`);
      });
    }

    // RESUMO
    console.log('\n📊 RESUMO DOS TESTES:');
    
    const acessoBloqueado = clientesAnonError && produtosAnonError;
    
    if (acessoBloqueado) {
      console.log('🔐 ISOLAMENTO COMPLETO: RLS bloqueando acesso não autorizado');
      console.log('✅ Sistema pronto para uso multi-tenant!');
      console.log('\n🎯 PRÓXIMOS PASSOS:');
      console.log('1. Fazer login no sistema: http://localhost:5174');
      console.log('2. Verificar se clientes aparecem apenas para usuário logado');
      console.log('3. Confirmar isolamento entre usuários');
    } else {
      console.log('⚠️ Isolamento parcial - Verificar configuração');
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testarRLSRestritivo();
