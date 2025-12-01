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

async function main() {
  console.log('🚀 Iniciando população de permissões...\n');

  // 1. Verificar permissões existentes
  const { data: existentes, error: errorCheck } = await supabase
    .from('permissoes')
    .select('recurso, acao');

  if (errorCheck) {
    console.error('❌ Erro ao verificar permissões existentes:', errorCheck);
    process.exit(1);
  }

  console.log(`📊 Permissões existentes: ${existentes?.length || 0}`);
  console.log(`📊 Permissões a inserir: ${permissoesSistema.length}\n`);

  // 2. Criar set de permissões existentes
  const existentesSet = new Set(
    (existentes || []).map(p => `${p.recurso}:${p.acao}`)
  );

  // 3. Filtrar apenas permissões novas
  const novasPermissoes = permissoesSistema.filter(
    p => !existentesSet.has(`${p.recurso}:${p.acao}`)
  );

  if (novasPermissoes.length === 0) {
    console.log('✅ Todas as permissões já existem! Nada a fazer.');
    process.exit(0);
  }

  console.log(`📦 Inserindo ${novasPermissoes.length} novas permissões...\n`);

  // 4. Inserir novas permissões
  const { data, error } = await supabase
    .from('permissoes')
    .insert(novasPermissoes)
    .select();

  if (error) {
    console.error('❌ Erro ao inserir permissões:', error);
    process.exit(1);
  }

  console.log(`✅ ${data?.length || 0} permissões inseridas com sucesso!\n`);

  // 5. Verificar totais por módulo
  const { data: totais, error: errorTotais } = await supabase
    .from('permissoes')
    .select('recurso');

  if (errorTotais) {
    console.error('❌ Erro ao contar permissões:', errorTotais);
    process.exit(1);
  }

  // Agrupar por módulo
  const porModulo = (totais || []).reduce((acc, p) => {
    acc[p.recurso] = (acc[p.recurso] || 0) + 1;
    return acc;
  }, {});

  console.log('📊 RESUMO POR MÓDULO:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  Object.entries(porModulo)
    .sort(([a], [b]) => a.localeCompare(b))
    .forEach(([modulo, qtd]) => {
      console.log(`  ${modulo.padEnd(30)} → ${qtd} permissões`);
    });
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`  TOTAL: ${totais?.length || 0} permissões\n`);

  console.log('🎉 Processo concluído com sucesso!');
}

main().catch(console.error);
