// ========================================
// TIPOS PROFISSIONAIS - ADMINISTRAÇÃO DO SISTEMA
// PDV Allimport - Blueprint Profissional
// ========================================

// Tipos para Convites
export interface Convite {
  id: string
  empresa_id: string
  email: string
  funcao_id?: string
  status: 'pendente' | 'aceito' | 'expirado' | 'cancelado'
  token: string
  expires_at: string
  created_by?: string
  created_at: string
  
  // Relacionamentos
  funcao?: {
    nome: string
    descricao?: string
  }
  criado_por?: {
    nome: string
    email: string
  }
}

// Tipos para Backups
export interface Backup {
  id: string
  empresa_id: string
  status: 'pendente' | 'ok' | 'erro'
  arquivo_url?: string
  tamanho_bytes?: number
  mensagem?: string
  created_by?: string
  created_at: string
  
  // Relacionamentos
  criado_por?: {
    nome: string
    email: string
  }
  
  // Campos calculados
  tamanho_mb?: number
}

// Tipos adicionais para Dashboard
export interface UserStats {
  total: number
  ativos: number
  bloqueados: number
  pendentes: number
}

export interface IntegracaoStatus {
  tipo: 'mercadopago' | 'smtp' | 'whatsapp'
  status: 'ativo' | 'erro' | 'nao_configurado' | 'pendente'
  ultimo_teste?: string
  ultimo_erro?: string
}

export interface BackupInfo {
  id: string
  created_at: string
  status: 'ok' | 'erro' | 'processando'
  tamanho_mb: number
  tipo: 'automatico' | 'manual'
}

export interface SistemaInfo {
  versao: string
  uptime: string
  atualizado: boolean
  ultima_atualizacao?: string
  espaco_usado?: string
  usuarios_online?: number
}

export interface DashboardStats {
  users: UserStats
  integracoes: IntegracaoStatus[]
  backups: BackupInfo[]
  sistema: SistemaInfo
}

// Tipos para Convites de Usuários
export interface ConviteUser {
  id: string
  email: string
  nome?: string
  role: 'admin' | 'vendedor' | 'gerente'
  status: 'pendente' | 'aceito' | 'expirado' | 'cancelado'
  created_at: string
  expires_at: string
  invited_by: string
}

// Tipos para Configuração de Integrações
export interface ConfigIntegracao {
  tipo: 'mercadopago' | 'smtp' | 'whatsapp'
  ativo: boolean
  config: Record<string, any>
  ultima_atualizacao: string
}

export interface TesteIntegracao {
  tipo: string
  sucesso: boolean
  mensagem: string
  detalhes?: any
}

// Tipos para Integrações
export interface Integracao {
  id: string
  empresa_id: string
  tipo: 'mercadopago' | 'smtp' | 'whatsapp'
  status: 'nao_configurado' | 'configurado' | 'ativo' | 'erro'
  config: Record<string, any>
  teste_realizado_at?: string
  ultimo_erro?: string
  updated_at: string
}

// Configurações específicas por tipo de integração
export interface ConfigMercadoPago {
  access_token?: string
  public_key?: string
  client_id?: string
  client_secret?: string
  webhook_secret?: string
  ambiente: 'sandbox' | 'production'
}

export interface ConfigSMTP {
  host?: string
  port?: number
  secure?: boolean
  auth?: {
    user?: string
    pass?: string
  }
  from_email?: string
  from_name?: string
}

export interface ConfigWhatsApp {
  api_url?: string
  token?: string
  phone_number?: string
  webhook_verify_token?: string
}

// Tipos para Dashboard Administrativo
export interface DashboardStats {
  empresa: {
    nome: string
    plano: string
    ativo: boolean
    usuarios_total: number
    usuarios_limite: number
  }
  usuarios: {
    total: number
    ativos: number
    bloqueados: number
    pendentes: number
    convites: number
    online: number
  }
  atividade_hoje: {
    logins: number
    acoes: number
    ultimo_backup?: string
  }
}

// Tipos para Permissões Profissionais
export type PermissaoProfissional =
  | 'convites.read' | 'convites.create' | 'convites.delete'
  | 'backups.read' | 'backups.create' | 'backups.download'
  | 'integracoes.read' | 'integracoes.write' | 'integracoes.test'
  | 'dashboard.admin.read'
  | 'auditoria.read'

// Helper para verificar permissões
export function hasPermissionProfessional(
  userPerms: string[], 
  needed: PermissaoProfissional | PermissaoProfissional[]
): boolean {
  const required = Array.isArray(needed) ? needed : [needed]
  return required.every(p => userPerms.includes(p))
}

// Tipos para Formulários
export interface ConviteForm {
  email: string
  funcao_id: string
  mensagem_personalizada?: string
}

export interface BackupForm {
  incluir_produtos: boolean
  incluir_vendas: boolean
  incluir_clientes: boolean
  incluir_configuracoes: boolean
  compactar: boolean
}

export interface IntegracaoForm {
  tipo: 'mercadopago' | 'smtp' | 'whatsapp'
  config: ConfigMercadoPago | ConfigSMTP | ConfigWhatsApp
}

// Tipos para Componentes
export interface GuardProfessionalProps {
  perms: string[]
  need: PermissaoProfissional | PermissaoProfissional[]
  children: React.ReactNode
  fallback?: React.ReactNode
}

export interface CardDashboardProps {
  title: string
  value: string | number
  subtitle?: string
  icon?: React.ReactNode
  trend?: {
    value: number
    direction: 'up' | 'down' | 'stable'
  }
  className?: string
}

// Tipos para APIs
export interface ConviteAPI {
  criar: (data: ConviteForm) => Promise<Convite>
  listar: () => Promise<Convite[]>
  cancelar: (id: string) => Promise<void>
  reenviar: (id: string) => Promise<void>
}

export interface BackupAPI {
  executar: (config: BackupForm) => Promise<Backup>
  listar: () => Promise<Backup[]>
  baixar: (id: string) => Promise<string>
  excluir: (id: string) => Promise<void>
}

export interface IntegracaoAPI {
  listar: () => Promise<Integracao[]>
  configurar: (data: IntegracaoForm) => Promise<Integracao>
  testar: (tipo: string) => Promise<{ sucesso: boolean; mensagem: string }>
  desativar: (tipo: string) => Promise<void>
}

export interface DashboardAPI {
  obterStats: () => Promise<DashboardStats>
  obterAtividades: (dias?: number) => Promise<any[]>
  obterLogAuditoria: (filtros?: any) => Promise<any[]>
}

// Re-export dos tipos existentes que ainda são usados
export type { Permissao } from './admin'