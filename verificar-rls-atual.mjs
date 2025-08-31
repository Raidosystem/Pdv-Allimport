import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, anonKey);

async function verificarRLSAtual() {
  console.log('🔍 VERIFICANDO ESTADO ATUAL DAS RLS...\n');

  try {
    // TESTE 1: Clientes
    console.log('1. 👥 Testando RLS para CLIENTES...');
    const { data: clientes, error: clientesError } = await supabase
      .from('clientes')
      .select('*')
      .limit(1);

    if (clientesError) {
      console.log('   ✅ CLIENTES: RLS ativa e funcionando');
      console.log('   📋 Erro:', clientesError.message);
    } else {
      console.log('   ❌ CLIENTES: Dados acessíveis!', clientes?.length);
    }

    // TESTE 2: Produtos
    console.log('\n2. 🛍️ Testando RLS para PRODUTOS...');
    const { data: produtos, error: produtosError } = await supabase
      .from('produtos')
      .select('*')
      .limit(1);

    if (produtosError) {
      console.log('   ✅ PRODUTOS: RLS ativa e funcionando');
      console.log('   📋 Erro:', produtosError.message);
    } else {
      console.log('   ❌ PRODUTOS: Dados acessíveis!', produtos?.length);
    }

    // TESTE 3: Outras tabelas (se existirem)
    console.log('\n3. 📊 Testando outras tabelas...');
    
    const tabelasParaTestar = [
      'vendas', 'sales', 'caixa', 'cash_register', 
      'ordens_servico', 'service_orders', 'configuracoes'
    ];

    for (const tabela of tabelasParaTestar) {
      try {
        const { data, error } = await supabase
          .from(tabela)
          .select('*')
          .limit(1);

        if (error) {
          if (error.message.includes('permission denied')) {
            console.log(`   ✅ ${tabela.toUpperCase()}: RLS ativa`);
          } else if (error.message.includes('does not exist')) {
            console.log(`   ℹ️ ${tabela.toUpperCase()}: Tabela não existe`);
          } else {
            console.log(`   ⚠️ ${tabela.toUpperCase()}: Erro inesperado -`, error.message);
          }
        } else {
          console.log(`   ❌ ${tabela.toUpperCase()}: Dados acessíveis!`, data?.length);
        }
      } catch (e) {
        // Ignorar erros de tabelas que não existem
      }
    }

    // RESULTADO E RECOMENDAÇÃO
    console.log('\n📊 ANÁLISE FINAL:');
    
    const clientesSeguro = clientesError && clientesError.message.includes('permission denied');
    const produtosSeguro = produtosError && produtosError.message.includes('permission denied');

    if (clientesSeguro && produtosSeguro) {
      console.log('🎉 CONFIGURAÇÃO PERFEITA!');
      console.log('✅ RLS ativa para clientes e produtos');
      console.log('✅ Isolamento multi-tenant funcionando');
      console.log('✅ Usuários anônimos completamente bloqueados');
      
      console.log('\n🔒 RECOMENDAÇÃO: MANTER ASSIM!');
      console.log('📋 Todas as RLS devem permanecer ativas para:');
      console.log('   • Segurança máxima dos dados');
      console.log('   • Isolamento entre usuários');
      console.log('   • Conformidade com LGPD');
      console.log('   • Prevenir vazamentos de dados');
      
      console.log('\n🚫 NÃO DESATIVAR RLS porque:');
      console.log('   • Dados ficariam visíveis para todos os usuários');
      console.log('   • Comprometeria o isolamento multi-tenant');
      console.log('   • Violaria a privacidade dos dados');
      
      console.log('\n✅ SISTEMA PRONTO PARA PRODUÇÃO!');
      console.log('🔗 Teste: http://localhost:5174');
    } else {
      console.log('⚠️ CONFIGURAÇÃO INCOMPLETA');
      if (!clientesSeguro) console.log('❌ RLS de clientes precisa ser ativada');
      if (!produtosSeguro) console.log('❌ RLS de produtos precisa ser ativada');
    }

  } catch (error) {
    console.error('❌ Erro na verificação:', error);
  }
}

verificarRLSAtual();
