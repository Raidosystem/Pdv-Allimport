#!/usr/bin/env node

/**
 * =====================================================
 * SCRIPT: POPULAR PERMISSÕES DO SISTEMA
 * =====================================================
 * Popula a tabela 'permissoes' com todas as permissões
 * necessárias para o sistema PDV.
 * =====================================================
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente não configuradas!');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

const permissoesSistema = [
  // =====================================================
  // MÓDULO: VENDAS
  // =====================================================
  { recurso: 'vendas', acao: 'create', descricao: 'Criar nova venda' },
  { recurso: 'vendas', acao: 'read', descricao: 'Visualizar vendas' },
  { recurso: 'vendas', acao: 'update', descricao: 'Editar vendas' },
  { recurso: 'vendas', acao: 'delete', descricao: 'Excluir vendas' },
  { recurso: 'vendas', acao: 'cancel', descricao: 'Cancelar vendas' },
  { recurso: 'vendas', acao: 'discount', descricao: 'Aplicar descontos em vendas' },

  // =====================================================
  // MÓDULO: PRODUTOS
  // =====================================================
  { recurso: 'produtos', acao: 'create', descricao: 'Cadastrar novos produtos' },
  { recurso: 'produtos', acao: 'read', descricao: 'Visualizar produtos' },
  { recurso: 'produtos', acao: 'update', descricao: 'Editar produtos' },
  { recurso: 'produtos', acao: 'delete', descricao: 'Excluir produtos' },
  { recurso: 'produtos', acao: 'import', descricao: 'Importar produtos' },
  { recurso: 'produtos', acao: 'export', descricao: 'Exportar produtos' },
  { recurso: 'produtos', acao: 'manage_stock', descricao: 'Gerenciar estoque' },

  // =====================================================
  // MÓDULO: CLIENTES
  // =====================================================
  { recurso: 'clientes', acao: 'create', descricao: 'Cadastrar novos clientes' },
  { recurso: 'clientes', acao: 'read', descricao: 'Visualizar clientes' },
  { recurso: 'clientes', acao: 'update', descricao: 'Editar clientes' },
  { recurso: 'clientes', acao: 'delete', descricao: 'Excluir clientes' },
  { recurso: 'clientes', acao: 'export', descricao: 'Exportar clientes' },
  { recurso: 'clientes', acao: 'view_history', descricao: 'Ver histórico de compras' },

  // =====================================================
  // MÓDULO: FINANCEIRO
  // =====================================================
  { recurso: 'financeiro', acao: 'read', descricao: 'Visualizar informações financeiras' },
  { recurso: 'financeiro', acao: 'create', descricao: 'Criar movimentações financeiras' },
  { recurso: 'financeiro', acao: 'update', descricao: 'Editar movimentações' },
  { recurso: 'financeiro', acao: 'delete', descricao: 'Excluir movimentações' },
  { recurso: 'financeiro', acao: 'open_cashier', descricao: 'Abrir caixa' },
  { recurso: 'financeiro', acao: 'close_cashier', descricao: 'Fechar caixa' },
  { recurso: 'financeiro', acao: 'manage_payments', descricao: 'Gerenciar formas de pagamento' },

  // =====================================================
  // MÓDULO: RELATÓRIOS
  // =====================================================
  { recurso: 'relatorios', acao: 'read', descricao: 'Visualizar relatórios' },
  { recurso: 'relatorios', acao: 'export', descricao: 'Exportar relatórios' },
  { recurso: 'relatorios', acao: 'sales', descricao: 'Relatórios de vendas' },
  { recurso: 'relatorios', acao: 'financial', descricao: 'Relatórios financeiros' },
  { recurso: 'relatorios', acao: 'products', descricao: 'Relatórios de produtos' },
  { recurso: 'relatorios', acao: 'customers', descricao: 'Relatórios de clientes' },

  // =====================================================
  // MÓDULO: CONFIGURAÇÕES
  // =====================================================
  { recurso: 'configuracoes', acao: 'read', descricao: 'Visualizar configurações' },
  { recurso: 'configuracoes', acao: 'update', descricao: 'Alterar configurações' },
  { recurso: 'configuracoes', acao: 'print_settings', descricao: 'Configurar impressão' },
  { recurso: 'configuracoes', acao: 'company_info', descricao: 'Editar informações da empresa' },
  { recurso: 'configuracoes', acao: 'integrations', descricao: 'Gerenciar integrações' },
  { recurso: 'configuracoes', acao: 'backup', descricao: 'Fazer backup de dados' },

  // =====================================================
  // MÓDULO: ADMINISTRAÇÃO
  // =====================================================
  { recurso: 'administracao', acao: 'read', descricao: 'Visualizar área administrativa' },
  { recurso: 'administracao', acao: 'users', descricao: 'Gerenciar usuários' },
  { recurso: 'administracao', acao: 'funcoes', descricao: 'Gerenciar funções' },
  { recurso: 'administracao', acao: 'permissoes', descricao: 'Gerenciar permissões' },
  { recurso: 'administracao', acao: 'logs', descricao: 'Visualizar logs do sistema' },
  { recurso: 'administracao', acao: 'subscription', descricao: 'Gerenciar assinatura' },
  { recurso: 'administracao', acao: 'full_access', descricao: 'Acesso total administrativo' },
  
  // Adicionar CREATE para funções
  { recurso: 'administracao.funcoes', acao: 'create', descricao: 'Criar novas funções' },
  { recurso: 'administracao.funcoes', acao: 'read', descricao: 'Visualizar funções' },
  { recurso: 'administracao.funcoes', acao: 'update', descricao: 'Editar funções' },
  { recurso: 'administracao.funcoes', acao: 'delete', descricao: 'Excluir funções' },
];
    
    console.log('📝 Inserindo usuários de teste...');
    
    for (const usuario of usuariosSimulados) {
      try {
        const { data, error } = await supabase
          .from('user_approvals')
          .insert(usuario)
          .select();
        
        if (error) {
          console.log(`❌ Erro ao inserir ${usuario.email}:`, error.message);
        } else {
          console.log(`✅ Inserido: ${usuario.email}`);
        }
      } catch (e) {
        console.log(`⚠️ Problema com ${usuario.email}:`, e.message);
      }
    }
    
    // Verificar resultado
    console.log('\n📋 Verificando registros inseridos...');
    
    const { data: registros, error: selectError } = await supabase
      .from('user_approvals')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (selectError) {
      console.log('❌ Erro ao verificar registros:', selectError.message);
    } else {
      console.log(`✅ Total de registros: ${registros?.length || 0}`);
      
      if (registros && registros.length > 0) {
        console.log('\n👤 Usuários na tabela:');
        registros.forEach((user, index) => {
          console.log(`  ${index + 1}. ${user.email} - Status: ${user.status}`);
          console.log(`     Criado: ${new Date(user.created_at).toLocaleString('pt-BR')}`);
          console.log(`     Nome: ${user.full_name || 'N/A'}`);
          console.log('');
        });
        
        console.log('🎉 SISTEMA FUNCIONANDO!');
        console.log('📋 Agora acesse: https://pdv.crmvsystem.com/admin');
        console.log('🔑 Login: novaradiosystem@outlook.com');
        console.log('🔒 Senha: @qw12aszx##');
        console.log('👀 Você deve ver os usuários pendentes de aprovação!');
      }
    }
    
  } catch (error) {
    console.log('❌ Erro geral:', error.message);
    
    console.log('\n🛠️ SOLUÇÕES ALTERNATIVAS:');
    console.log('1. Executar SQL manualmente no Supabase Dashboard');
    console.log('2. Verificar se RLS não está bloqueando inserção');
    console.log('3. Conferir permissões da service_role_key');
  }
}

popularTabelaAprovacao();
