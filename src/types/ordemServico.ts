// 🔧 Tipos para Sistema de Ordens de Serviço
import type { Cliente } from './cliente'

export interface OrdemServico {
  id: string
  cliente_id: string
  numero_os?: string // Número da OS para identificação
  
  // Informações do aparelho
  tipo: TipoEquipamento
  marca: string
  modelo: string
  cor?: string
  numero_serie?: string
  equipamento?: string // Campo unificado para equipamento
  
  // Checklist técnico
  checklist?: ChecklistOS
  observacoes?: string
  defeito_relatado?: string
  descricao_problema?: string // Descrição completa do problema
  
  // Datas e status
  data_entrada: string
  data_previsao?: string
  data_entrega?: string
  data_finalizacao?: string // Data de finalização do serviço
  status: StatusOS
  
  // Valores e pagamento
  valor_orcamento?: number
  valor?: number // Valor final da OS
  valor_final?: number
  mao_de_obra?: number // Custo da mão de obra
  forma_pagamento?: string // Forma de pagamento principal
  forma_pagamento_2?: string // Segunda forma de pagamento
  valor_pagamento_1?: number // Valor do primeiro pagamento
  valor_pagamento_2?: number // Valor do segundo pagamento
  
  // Garantia
  garantia_meses?: number
  data_fim_garantia?: string
  
  // Controle
  usuario_id: string
  criado_em: string
  atualizado_em: string
  
  // Relacionamentos
  cliente?: Cliente
}

export type TipoEquipamento = string

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
  cliente_endereco?: string
  cliente_cidade?: string
  cliente_estado?: string
  
  // Aparelho
  tipo: TipoEquipamento
  marca: string
  modelo: string
  cor?: string
  numero_serie?: string
  
  // Detalhes
  checklist?: ChecklistOS
  observacoes?: string
  defeito_relatado?: string
  descricao_problema?: string
  
  // Prazos e Status
  data_entrada?: string
  data_previsao?: string
  status?: StatusOS
  
  // Financeiro
  valor_orcamento?: number
  mao_de_obra?: number
  valor_total?: number
  forma_pagamento?: string
  forma_pagamento_2?: string
  valor_pagamento_1?: number
  valor_pagamento_2?: number
  pago?: boolean
  garantia_meses?: number
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
export const getTipoIcon = (tipo: string): string => {
  const icons: Record<string, string> = {
    'Celular': '📱',
    'Notebook': '💻',
    'Console': '🎮',
    'Tablet': '📱',
    'Outro': '🔧'
  }
  
  // Busca exata ou por palavras similares
  const tipoLower = tipo.toLowerCase()
  
  if (icons[tipo]) return icons[tipo]
  if (tipoLower.includes('celular') || tipoLower.includes('smartphone') || tipoLower.includes('telefone')) return '📱'
  if (tipoLower.includes('notebook') || tipoLower.includes('laptop') || tipoLower.includes('computador')) return '💻'
  if (tipoLower.includes('console') || tipoLower.includes('game') || tipoLower.includes('playstation') || tipoLower.includes('xbox')) return '🎮'
  if (tipoLower.includes('tablet') || tipoLower.includes('ipad')) return '📱'
  
  // Ícone padrão
  return '🔧'
}
