// ========================================
// TIPOS TYPESCRIPT - SISTEMA DE ADMINISTRAÇÃO
// ========================================

export interface Empresa {
  id: string;
  nome: string;
  cnpj?: string;
  email?: string;
  telefone?: string;
  endereco?: string;
  logo_url?: string;
  plano: 'basic' | 'professional' | 'enterprise';
  status: 'ativo' | 'suspenso' | 'cancelado';
  max_usuarios: number;
  max_lojas: number;
  features: Record<string, any>;
  assinatura_id?: string;
  assinatura_expires_at?: string;
  tema: {
    primaryColor: string;
    mode: 'light' | 'dark';
  };
  configuracoes: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface Funcionario {
  id: string;
  user_id: string;
  empresa_id: string;
  nome: string;
  email: string;
  telefone?: string;
  documento?: string;
  cargo?: string;
  status: 'ativo' | 'bloqueado' | 'pendente';
  tipo_admin: 'super_admin' | 'admin_empresa' | 'funcionario'; // Novo campo
  lojas: string[];
  limite_desconto_pct: number;
  limite_cancelamentos_dia: number;
  permite_estorno: boolean;
  two_factor_enabled: boolean;
  last_login_at?: string;
  session_expires_at?: string;
  convite_token?: string;
  convite_expires_at?: string;
  created_at: string;
  updated_at: string;
  // Relacionamentos
  funcoes?: Funcao[];
  empresa?: Empresa;
}

export interface Funcao {
  id: string;
  empresa_id: string;
  nome: string;
  descricao?: string;
  is_system: boolean;
  escopo_lojas: string[];
  created_at: string;
  updated_at: string;
  // Relacionamentos
  permissoes?: Permissao[];
  funcionarios?: Funcionario[];
}

export interface Permissao {
  id: string;
  recurso: string;
  acao: string;
  descricao?: string;
  categoria: string;
  created_at: string;
}

export interface FuncaoPermissao {
  funcao_id: string;
  permissao_id: string;
  empresa_id: string;
  created_at: string;
}

export interface FuncionarioFuncao {
  funcionario_id: string;
  funcao_id: string;
  empresa_id: string;
  created_at: string;
}

export interface AuditLog {
  id: number;
  empresa_id: string;
  user_id?: string;
  funcionario_id?: string;
  recurso: string;
  acao: string;
  entidade_tipo?: string;
  entidade_id?: string;
  dados_anteriores?: Record<string, any>;
  dados_novos?: Record<string, any>;
  ip_address?: string;
  user_agent?: string;
  sucesso: boolean;
  erro_message?: string;
  created_at: string;
  // Relacionamentos
  funcionario?: Funcionario;
}

export interface UserSession {
  id: string;
  user_id: string;
  empresa_id: string;
  funcionario_id?: string;
  jwt_jti?: string;
  ip_address?: string;
  user_agent?: string;
  is_active: boolean;
  last_activity_at: string;
  expires_at?: string;
  created_at: string;
  // Relacionamentos
  funcionario?: Funcionario;
}

// ========================================
// TIPOS PARA FORMULÁRIOS
// ========================================

export interface FuncionarioFormData {
  nome: string;
  email: string;
  telefone?: string;
  documento?: string;
  cargo?: string;
  lojas: string[];
  funcoes: string[]; // IDs das funções
  limite_desconto_pct: number;
  limite_cancelamentos_dia: number;
  permite_estorno: boolean;
  two_factor_enabled: boolean;
  permissoes_extras?: {
    permissao_id: string;
    habilitada: boolean;
  }[];
}

export interface FuncaoFormData {
  nome: string;
  descricao?: string;
  escopo_lojas: string[];
  permissoes: string[]; // IDs das permissões
}

export interface EmpresaFormData {
  nome: string;
  cnpj?: string;
  email?: string;
  telefone?: string;
  endereco?: string;
  logo_url?: string;
  tema: {
    primaryColor: string;
    mode: 'light' | 'dark';
  };
  configuracoes: {
    // PDV
    obrigar_cliente: boolean;
    limite_desconto_geral: number;
    permite_venda_sem_estoque: boolean;
    
    // Fiscal
    regime_tributario: string;
    inscricao_estadual?: string;
    serie_nfe?: string;
    serie_nfce?: string;
    
    // Integração
    mercado_pago_public_key?: string;
    mercado_pago_access_token?: string;
    
    // Impressão
    impressora_padrao?: string;
    formato_cupom: 'a4' | 'bobina_80mm' | 'bobina_58mm';
    
    // Notificações
    email_smtp_host?: string;
    email_smtp_port?: number;
    email_smtp_user?: string;
    email_smtp_pass?: string;
    whatsapp_api_url?: string;
    whatsapp_api_token?: string;
    
    // Backup
    backup_automatico: boolean;
    backup_frequencia: 'diario' | 'semanal' | 'mensal';
    backup_retencao_dias: number;
  };
}

export interface ConviteFormData {
  email: string;
  nome?: string;
  funcoes: string[];
  lojas: string[];
  mensagem_personalizada?: string;
}

// ========================================
// TIPOS PARA PERMISSÕES
// ========================================

export interface MatrizPermissao {
  recurso: string;
  categoria: string;
  acoes: {
    acao: string;
    descricao: string;
    habilitada: boolean;
  }[];
}

export interface PermissaoContext {
  empresa_id: string;
  user_id: string;
  funcionario_id: string;
  funcoes: string[];
  permissoes: string[];
  is_admin: boolean;
  is_super_admin: boolean; // Novo: Admin do sistema (desenvolvedor)
  is_admin_empresa: boolean; // Novo: Admin da empresa (cliente)
  tipo_admin: 'super_admin' | 'admin_empresa' | 'funcionario';
  escopo_lojas: string[];
}

export interface UsePermissionsReturn {
  can: (recurso: string, acao: string) => boolean;
  isAdmin: boolean;
  isSuperAdmin: boolean; // Novo
  isAdminEmpresa: boolean; // Novo
  tipoAdmin: 'super_admin' | 'admin_empresa' | 'funcionario';
  loading: boolean;
  permissoes: string[];
  refresh: () => void;
  user: {
    id: string;
    email?: string;
  } | null;
}

// ========================================
// TIPOS PARA DASHBOARD ADMIN
// ========================================

export interface AdminDashboardStats {
  empresa: {
    nome: string;
    plano: string;
    status: string;
    dias_restantes?: number;
  };
  usuarios: {
    total: number;
    ativos: number;
    convites_pendentes: number;
    sessoes_ativas: number;
  };
  atividade: {
    logins_hoje: number;
    acoes_hoje: number;
    ultimo_backup?: string;
    proxima_cobranca?: string;
  };
  sistema: {
    versao: string;
    atualizacao_disponivel: boolean;
    uptime: number;
  };
}

export interface LogAuditoria extends AuditLog {
  funcionario_nome?: string;
  icon: string;
  color: string;
  description: string;
}

export interface UseAdminStatsReturn {
  stats: AdminDashboardStats | null;
  loading: boolean;
  error: string | null;
  refresh: () => void;
}

export interface UseFuncionariosReturn {
  funcionarios: Funcionario[];
  loading: boolean;
  error: string | null;
  create: (data: FuncionarioFormData) => Promise<Funcionario>;
  update: (id: string, data: Partial<FuncionarioFormData>) => Promise<Funcionario>;
  delete: (id: string) => Promise<void>;
  invite: (data: ConviteFormData) => Promise<void>;
  revokeSession: (sessionId: string) => Promise<void>;
  impersonate: (funcionarioId: string) => Promise<void>;
  refresh: () => void;
}

export interface UseFuncoesReturn {
  funcoes: Funcao[];
  loading: boolean;
  error: string | null;
  create: (data: FuncaoFormData) => Promise<Funcao>;
  update: (id: string, data: Partial<FuncaoFormData>) => Promise<Funcao>;
  delete: (id: string) => Promise<void>;
  refresh: () => void;
}

// ========================================
// TIPOS PARA COMPONENTES
// ========================================

export interface PermissionMatrixProps {
  funcaoId: string;
  permissoes: Permissao[];
  permissoesHabilitadas: string[];
  onChange: (permissoes: string[]) => void;
  readOnly?: boolean;
}

export interface UserInviteModalProps {
  isOpen: boolean;
  onClose: () => void;
  onInvite: (data: ConviteFormData) => Promise<void>;
  funcoes: Funcao[];
  lojas?: { id: string; nome: string }[];
}

export interface RoleFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (data: FuncaoFormData) => Promise<void>;
  funcao?: Funcao;
  permissoes: Permissao[];
}

export interface SessionsTableProps {
  sessions: UserSession[];
  onRevoke: (sessionId: string) => void;
  loading?: boolean;
}

export interface AuditLogTableProps {
  logs: LogAuditoria[];
  loading?: boolean;
  onRefresh?: () => void;
  filters?: {
    funcionario?: string;
    recurso?: string;
    acao?: string;
    data_inicio?: string;
    data_fim?: string;
  };
  onFilterChange?: (filters: any) => void;
}

// ========================================
// TIPOS PARA NAVEGAÇÃO
// ========================================

export interface AdminMenuItem {
  id: string;
  title: string;
  icon: React.ComponentType<{ className?: string }>;
  href: string;
  description: string;
  permission?: {
    recurso: string;
    acao: string;
  };
  badge?: string | number;
}

export interface AdminLayout {
  menuItems: AdminMenuItem[];
  currentPath: string;
  empresa: Empresa;
  funcionario: Funcionario;
}

// ========================================
// TIPOS PARA BACKUP
// ========================================

export interface BackupInfo {
  id: string;
  empresa_id: string;
  tipo: 'manual' | 'automatico';
  formato: 'json' | 'csv' | 'sql';
  tamanho_bytes: number;
  status: 'processando' | 'concluido' | 'erro';
  download_url?: string;
  expires_at: string;
  created_at: string;
  tabelas_incluidas: string[];
  erro_message?: string;
}

export interface BackupConfig {
  automatico: boolean;
  frequencia: 'diario' | 'semanal' | 'mensal';
  horario: string; // HH:mm
  formato: 'json' | 'csv' | 'sql';
  retencao_dias: number;
  incluir_tabelas: string[];
  criptografia: boolean;
  chave_criptografia?: string;
  webhook_url?: string;
}

// ========================================
// TIPOS PARA VALIDAÇÃO
// ========================================

export interface ValidationError {
  field: string;
  message: string;
}

export interface ApiResponse<T = any> {
  data?: T;
  error?: string;
  errors?: ValidationError[];
  message?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  per_page: number;
  total_pages: number;
}

// ========================================
// TIPOS PARA CONFIGURAÇÕES ESPECÍFICAS
// ========================================

export interface PrinterConfig {
  nome: string;
  tipo: 'termica' | 'matricial' | 'laser';
  largura_papel: number;
  endereco_ip?: string;
  porta?: number;
  modelo?: string;
  padrao: boolean;
}

export interface TaxConfig {
  regime: 'simples' | 'lucro_presumido' | 'lucro_real';
  inscricao_estadual?: string;
  inscricao_municipal?: string;
  aliquota_icms?: number;
  aliquota_iss?: number;
  certificado_digital?: {
    tipo: 'a1' | 'a3';
    arquivo?: string;
    senha?: string;
    validade?: string;
  };
}

export interface IntegrationConfig {
  mercado_pago?: {
    public_key: string;
    access_token: string;
    webhook_url?: string;
    sandbox: boolean;
  };
  nfe?: {
    ambiente: 'producao' | 'homologacao';
    serie: string;
    numeracao_atual: number;
  };
  email?: {
    smtp_host: string;
    smtp_port: number;
    smtp_user: string;
    smtp_pass: string;
    from_name: string;
    from_email: string;
    ssl: boolean;
  };
  whatsapp?: {
    api_url: string;
    api_token: string;
    numero_remetente: string;
  };
}