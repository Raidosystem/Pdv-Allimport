// 🔧 Tipos para Sistema de Ordens de Serviço
import type { Cliente } from './cliente'

export interface OrdemServico {
  id: string
  cliente_id: string
  
  // Informações do aparelho
  tipo: TipoEquipamento
  marca: string
  modelo: string
  cor?: string
  numero_serie?: string
  
  // Checklist técnico
  checklist: ChecklistOS
  observacoes?: string
  defeito_relatado?: string
  
  // Datas e status
  data_entrada: string
  data_previsao?: string
  data_entrega?: string
  status: StatusOS
  
  // Valores
  valor_orcamento?: number
  valor_final?: number
  
  // Controle
  usuario_id: string
  criado_em: string
  atualizado_em: string
  
  // Relacionamentos
  cliente?: Cliente
}

export type TipoEquipamento = 
  | 'Celular' 
  | 'Notebook' 
  | 'Console' 
  | 'Tablet' 
  | 'Outro'

export type StatusOS = 
  | 'Em análise'
  | 'Aguardando aprovação'
  | 'Aguardando peças'
  | 'Em conserto'
  | 'Pronto'
  | 'Entregue'
  | 'Cancelado'

export interface ChecklistOS {
  liga?: boolean
  tela_quebrada?: boolean
  molhado?: boolean
  com_senha?: boolean
  bateria_boa?: boolean
  tampa_presente?: boolean
  acessorios?: boolean
  carregador?: boolean
  fone_ouvido?: boolean
  capa_pelicula?: boolean
}

export interface NovaOrdemServicoForm {
  // Cliente
  cliente_id?: string
  cliente_nome?: string
  cliente_telefone?: string
  cliente_email?: string
  
  // Aparelho
  tipo: TipoEquipamento
  marca: string
  modelo: string
  cor?: string
  numero_serie?: string
  
  // Detalhes
  checklist: ChecklistOS
  observacoes?: string
  defeito_relatado?: string
  
  // Prazos
  data_previsao?: string
  valor_orcamento?: number
}

export interface FiltrosOS {
  status?: StatusOS[]
  tipo?: TipoEquipamento[]
  data_inicio?: string
  data_fim?: string
  cliente?: string
  busca?: string
}

// Status com cores para interface
export const STATUS_COLORS: Record<StatusOS, string> = {
  'Em análise': 'bg-yellow-100 text-yellow-800 border-yellow-200',
  'Aguardando aprovação': 'bg-orange-100 text-orange-800 border-orange-200',
  'Aguardando peças': 'bg-purple-100 text-purple-800 border-purple-200',
  'Em conserto': 'bg-blue-100 text-blue-800 border-blue-200',
  'Pronto': 'bg-green-100 text-green-800 border-green-200',
  'Entregue': 'bg-gray-100 text-gray-800 border-gray-200',
  'Cancelado': 'bg-red-100 text-red-800 border-red-200'
}

// Ícones para tipos de equipamento
export const TIPO_ICONS: Record<TipoEquipamento, string> = {
  'Celular': '📱',
  'Notebook': '💻',
  'Console': '🎮',
  'Tablet': '📱',
  'Outro': '🔧'
}
