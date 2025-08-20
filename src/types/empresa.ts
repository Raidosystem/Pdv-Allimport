export interface Empresa {
  id: string;
  user_id: string;
  nome: string;
  cnpj?: string;
  telefone?: string;
  email?: string;
  endereco?: string;
  cidade?: string;
  estado?: string;
  cep?: string;
  logo_url?: string;
  created_at: string;
  updated_at: string;
}

export interface Funcionario {
  id: string;
  empresa_id: string;
  nome: string;
  email: string;
  telefone?: string;
  cargo: string;
  ativo: boolean;
  permissoes: FuncionarioPermissoes;
  created_at: string;
  updated_at: string;
}

export interface FuncionarioPermissoes {
  // Módulos principais
  vendas: boolean;
  produtos: boolean;
  clientes: boolean;
  caixa: boolean;
  ordens_servico: boolean;
  relatorios: boolean;
  configuracoes: boolean;
  backup: boolean;
  
  // Permissões específicas
  pode_criar_vendas: boolean;
  pode_editar_vendas: boolean;
  pode_cancelar_vendas: boolean;
  pode_aplicar_desconto: boolean;
  
  pode_criar_produtos: boolean;
  pode_editar_produtos: boolean;
  pode_deletar_produtos: boolean;
  pode_gerenciar_estoque: boolean;
  
  pode_criar_clientes: boolean;
  pode_editar_clientes: boolean;
  pode_deletar_clientes: boolean;
  
  pode_abrir_caixa: boolean;
  pode_fechar_caixa: boolean;
  pode_gerenciar_movimentacoes: boolean;
  
  pode_criar_os: boolean;
  pode_editar_os: boolean;
  pode_finalizar_os: boolean;
  
  pode_ver_todos_relatorios: boolean;
  pode_exportar_dados: boolean;
  
  pode_alterar_configuracoes: boolean;
  pode_gerenciar_funcionarios: boolean;
  pode_fazer_backup: boolean;
}

export const permissoesDefault: FuncionarioPermissoes = {
  vendas: true,
  produtos: true,
  clientes: true,
  caixa: false,
  ordens_servico: true,
  relatorios: false,
  configuracoes: false,
  backup: false,
  
  pode_criar_vendas: true,
  pode_editar_vendas: false,
  pode_cancelar_vendas: false,
  pode_aplicar_desconto: false,
  
  pode_criar_produtos: false,
  pode_editar_produtos: false,
  pode_deletar_produtos: false,
  pode_gerenciar_estoque: false,
  
  pode_criar_clientes: true,
  pode_editar_clientes: true,
  pode_deletar_clientes: false,
  
  pode_abrir_caixa: false,
  pode_fechar_caixa: false,
  pode_gerenciar_movimentacoes: false,
  
  pode_criar_os: true,
  pode_editar_os: true,
  pode_finalizar_os: false,
  
  pode_ver_todos_relatorios: false,
  pode_exportar_dados: false,
  
  pode_alterar_configuracoes: false,
  pode_gerenciar_funcionarios: false,
  pode_fazer_backup: false,
};

export interface LoginFuncionario {
  id: string;
  funcionario_id: string;
  usuario: string;
  senha: string;
  ativo: boolean;
  ultimo_acesso?: string;
  created_at: string;
}
