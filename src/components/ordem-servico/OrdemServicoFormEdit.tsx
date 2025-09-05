import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  User,
  Phone,
  Mail,
  MapPin,
  Building2,
  Smartphone,
  AlertTriangle,
  Calendar,
  DollarSign,
  ShieldCheck,
  Edit3,
  Eye
} from 'lucide-react'
import { BackButton } from '../ui/BackButton'
import { handleCapitalizeInput, handleCapitalizeTextarea } from '../../utils/textUtils'
import { ordemServicoService } from '../../services/ordemServicoService'
import type { StatusOS, OrdemServico } from '../../types/ordemServico'
import { getTipoIcon } from '../../types/ordemServico'

// Função para formatar valor monetário
const formatCurrency = (value: string): string => {
  // Remove tudo que não é dígito
  const numbers = value.replace(/\D/g, '')
  
  // Se está vazio, retorna vazio
  if (!numbers) return ''
  
  // Converte para número e divide por 100 para ter centavos
  const numberValue = parseInt(numbers) / 100
  
  // Formata com vírgula decimal
  return numberValue.toFixed(2).replace('.', ',')
}

// Função para converter valor formatado para número
const parseCurrencyToNumber = (value: string): number | undefined => {
  if (!value || value.trim() === '') return undefined
  
  // Remove pontos de milhares e converte vírgula para ponto
  const normalizedValue = value.replace(/\./g, '').replace(',', '.')
  const numberValue = parseFloat(normalizedValue)
  
  return isNaN(numberValue) ? undefined : numberValue
}

// Função para converter número para formato brasileiro
const formatNumberToBrazilian = (value: number): string => {
  return value.toFixed(2).replace('.', ',')
}

const editarOrdemSchema = z.object({
  // Dados do Cliente
  cliente_nome: z.string().min(2, 'Nome do cliente é obrigatório'),
  cliente_telefone: z.string().optional(),
  cliente_email: z.string().email('Email inválido').optional().or(z.literal('')),
  cliente_endereco: z.string().optional(),
  cliente_cidade: z.string().optional(),
  cliente_estado: z.string().optional(),
  
  // Equipamento
  tipo: z.string().min(1, 'Tipo de equipamento é obrigatório'),
  marca: z.string().min(1, 'Marca é obrigatória'),
  modelo: z.string().min(1, 'Modelo é obrigatório'),
  cor: z.string().optional(),
  numero_serie: z.string().optional(),
  
  // Problema e Observações
  defeito_relatado: z.string().min(5, 'Defeito deve ter pelo menos 5 caracteres'),
  descricao_problema: z.string().optional(),
  observacoes: z.string().optional(),
  
  // Datas
  data_entrada: z.string().min(1, 'Data de entrada é obrigatória'),
  data_previsao: z.string().optional(),
  status: z.enum(['Em análise', 'Aguardando aprovação', 'Aguardando peças', 'Em conserto', 'Pronto', 'Entregue', 'Cancelado']),
  
  // Financeiro
  valor_orcamento: z.string().optional(),
  mao_de_obra: z.string().optional(),
  forma_pagamento: z.string().optional(),
  forma_pagamento_2: z.string().optional(),
  valor_pagamento_1: z.string().optional(),
  valor_pagamento_2: z.string().optional(),
  valor_total: z.string().optional(),
  
  // Garantia
  garantia_meses: z.number().min(0, 'Garantia deve ser positiva').optional(),
})

type FormData = z.infer<typeof editarOrdemSchema>

interface OrdemServicoFormEditProps {
  ordem: OrdemServico
  onSuccess?: () => void
  onCancel?: () => void
}

const STATUS_OPTIONS = [
  { value: 'Em análise' as StatusOS, label: 'Em análise', color: 'bg-yellow-100 text-yellow-800' },
  { value: 'Aguardando aprovação' as StatusOS, label: 'Aguardando aprovação', color: 'bg-orange-100 text-orange-800' },
  { value: 'Aguardando peças' as StatusOS, label: 'Aguardando peças', color: 'bg-purple-100 text-purple-800' },
  { value: 'Em conserto' as StatusOS, label: 'Em conserto', color: 'bg-blue-100 text-blue-800' },
  { value: 'Pronto' as StatusOS, label: 'Pronto', color: 'bg-green-100 text-green-800' },
  { value: 'Entregue' as StatusOS, label: 'Entregue', color: 'bg-gray-100 text-gray-800' },
  { value: 'Cancelado' as StatusOS, label: 'Cancelado', color: 'bg-red-100 text-red-800' }
]

export function OrdemServicoFormEdit({ ordem, onSuccess, onCancel }: OrdemServicoFormEditProps) {
  const [loading, setLoading] = useState(false)
  const [isEditing, setIsEditing] = useState(false)

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors }
  } = useForm<FormData>({
    resolver: zodResolver(editarOrdemSchema),
    defaultValues: {
      cliente_nome: ordem.cliente?.nome || '',
      cliente_telefone: ordem.cliente?.telefone || '',
      cliente_email: ordem.cliente?.email || '',
      cliente_endereco: ordem.cliente?.endereco || '',
      cliente_cidade: ordem.cliente?.cidade || '',
      cliente_estado: ordem.cliente?.estado || '',
      tipo: ordem.tipo || '',
      marca: ordem.marca || '',
      modelo: ordem.modelo || '',
      cor: ordem.cor || '',
      numero_serie: ordem.numero_serie || '',
      defeito_relatado: ordem.descricao_problema || ordem.defeito_relatado || '',
      descricao_problema: ordem.descricao_problema || '',
      observacoes: ordem.observacoes || '',
      data_entrada: ordem.data_entrada ? new Date(ordem.data_entrada).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
      data_previsao: ordem.data_previsao ? new Date(ordem.data_previsao).toISOString().split('T')[0] : '',
      status: ordem.status || 'Em análise',
      valor_orcamento: ordem.valor_orcamento ? formatNumberToBrazilian(ordem.valor_orcamento) : '',
      mao_de_obra: ordem.mao_de_obra ? formatNumberToBrazilian(ordem.mao_de_obra) : '',
      forma_pagamento: ordem.forma_pagamento || '',
      forma_pagamento_2: ordem.forma_pagamento_2 || '',
      valor_pagamento_1: ordem.valor_pagamento_1 ? formatNumberToBrazilian(ordem.valor_pagamento_1) : '',
      valor_pagamento_2: ordem.valor_pagamento_2 ? formatNumberToBrazilian(ordem.valor_pagamento_2) : '',
      valor_total: ordem.valor ? formatNumberToBrazilian(ordem.valor) : '',
      garantia_meses: ordem.garantia_meses || 0,
    }
  })

  const onSubmit = async (data: FormData) => {
    try {
      setLoading(true)
      
      const ordemAtualizada = {
        ...ordem,
        cliente_id: ordem.cliente_id,
        cliente_nome: data.cliente_nome,
        cliente_telefone: data.cliente_telefone,
        cliente_email: data.cliente_email,
        cliente_endereco: data.cliente_endereco,
        cliente_cidade: data.cliente_cidade,
        cliente_estado: data.cliente_estado,
        tipo: data.tipo,
        marca: data.marca,
        modelo: data.modelo,
        cor: data.cor,
        numero_serie: data.numero_serie,
        defeito_relatado: data.defeito_relatado,
        descricao_problema: data.descricao_problema,
        observacoes: data.observacoes,
        data_entrada: data.data_entrada,
        data_previsao: data.data_previsao,
        status: data.status,
        valor_orcamento: parseCurrencyToNumber(data.valor_orcamento || ''),
        mao_de_obra: parseCurrencyToNumber(data.mao_de_obra || ''),
        forma_pagamento: data.forma_pagamento,
        forma_pagamento_2: data.forma_pagamento_2,
        valor_pagamento_1: parseCurrencyToNumber(data.valor_pagamento_1 || ''),
        valor_pagamento_2: parseCurrencyToNumber(data.valor_pagamento_2 || ''),
        valor_total: parseCurrencyToNumber(data.valor_total || ''),
        garantia_meses: data.garantia_meses,
      }

      await ordemServicoService.atualizarOrdem(ordem.id, ordemAtualizada)
      
      toast.success('✅ Ordem de serviço atualizada com sucesso!')
      onSuccess?.()
    } catch (error) {
      console.error('Erro ao atualizar ordem:', error)
      toast.error('Erro ao atualizar ordem de serviço')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <BackButton customAction={onCancel} />
            <h1 className="text-3xl font-bold text-gray-900">
              {isEditing ? 'Editar' : 'Visualizar'} Ordem de Serviço #{ordem.numero_os}
            </h1>
            <div className="flex gap-2">
              {!isEditing ? (
                <button
                  onClick={() => setIsEditing(true)}
                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  <Edit3 className="w-4 h-4" />
                  Editar
                </button>
              ) : (
                <button
                  onClick={() => setIsEditing(false)}
                  className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
                >
                  <Eye className="w-4 h-4" />
                  Visualizar
                </button>
              )}
            </div>
          </div>
          <p className="text-gray-600">
            {isEditing ? 'Atualize as informações da ordem de serviço' : 'Visualize todos os dados salvos da ordem de serviço'}
          </p>
        </div>

        {/* Modo Visualização */}
        {!isEditing ? (
          <div className="space-y-6">
            {/* Seção Cliente - Visualização */}
            <div className="bg-white rounded-xl shadow-sm border-l-4 border-blue-500 p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <User className="w-5 h-5 text-blue-600" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900">Dados do Cliente</h3>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div className="flex items-start gap-3">
                  <User className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Nome</p>
                    <p className="text-gray-900">{ordem.cliente?.nome || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Phone className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Telefone</p>
                    <p className="text-gray-900">{ordem.cliente?.telefone || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Mail className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Email</p>
                    <p className="text-gray-900">{ordem.cliente?.email || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <MapPin className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Endereço</p>
                    <p className="text-gray-900">{ordem.cliente?.endereco || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Building2 className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Cidade</p>
                    <p className="text-gray-900">{ordem.cliente?.cidade || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <MapPin className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Estado</p>
                    <p className="text-gray-900">{ordem.cliente?.estado || 'Não informado'}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Seção Equipamento - Visualização */}
            <div className="bg-white rounded-xl shadow-sm border-l-4 border-green-500 p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                  <Smartphone className="w-5 h-5 text-green-600" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900">Equipamento</h3>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div className="flex items-start gap-3">
                  <span className="text-2xl mt-1">{getTipoIcon(ordem.tipo || '')}</span>
                  <div>
                    <p className="text-sm font-medium text-gray-500">Tipo</p>
                    <p className="text-gray-900">{ordem.tipo || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Smartphone className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Marca</p>
                    <p className="text-gray-900">{ordem.marca || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Smartphone className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Modelo</p>
                    <p className="text-gray-900">{ordem.modelo || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <div className="w-5 h-5 rounded-full bg-gray-400 mt-1"></div>
                  <div>
                    <p className="text-sm font-medium text-gray-500">Cor</p>
                    <p className="text-gray-900">{ordem.cor || 'Não informado'}</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-3">
                  <Smartphone className="w-5 h-5 text-gray-400 mt-1" />
                  <div>
                    <p className="text-sm font-medium text-gray-500">Número de Série</p>
                    <p className="text-gray-900">{ordem.numero_serie || 'Não informado'}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Seção Problema - Visualização */}
            <div className="bg-white rounded-xl shadow-sm border-l-4 border-orange-500 p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                  <AlertTriangle className="w-5 h-5 text-orange-600" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900">Problema e Observações</h3>
              </div>
              
              <div className="space-y-4">
                <div>
                  <p className="text-sm font-medium text-gray-500 mb-2">Defeito Relatado</p>
                  <p className="text-gray-900 bg-gray-50 p-3 rounded-lg">{ordem.descricao_problema || ordem.defeito_relatado || 'Não informado'}</p>
                </div>
                
                {ordem.observacoes && (
                  <div>
                    <p className="text-sm font-medium text-gray-500 mb-2">Observações</p>
                    <p className="text-gray-900 bg-gray-50 p-3 rounded-lg">{ordem.observacoes}</p>
                  </div>
                )}
              </div>
            </div>

            {/* Seção Status e Datas - Visualização */}
            <div className="bg-white rounded-xl shadow-sm border-l-4 border-purple-500 p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                  <Calendar className="w-5 h-5 text-purple-600" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900">Status e Datas</h3>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <p className="text-sm font-medium text-gray-500 mb-2">Status Atual</p>
                  <span className={`px-3 py-1 rounded-full text-sm font-medium ${STATUS_OPTIONS.find(s => s.value === ordem.status)?.color || 'bg-gray-100 text-gray-800'}`}>
                    {ordem.status}
                  </span>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500 mb-2">Data de Entrada</p>
                  <p className="text-gray-900">{ordem.data_entrada ? new Date(ordem.data_entrada).toLocaleDateString('pt-BR') : 'Não informado'}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium text-gray-500 mb-2">Data Previsão</p>
                  <p className="text-gray-900">{ordem.data_previsao ? new Date(ordem.data_previsao).toLocaleDateString('pt-BR') : 'Não informado'}</p>
                </div>
              </div>
            </div>

            {/* Seção Financeiro - Visualização */}
            {(ordem.valor_orcamento || ordem.mao_de_obra || ordem.valor || ordem.forma_pagamento) && (
              <div className="bg-white rounded-xl shadow-sm border-l-4 border-red-500 p-6">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                    <DollarSign className="w-5 h-5 text-red-600" />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900">Informações Financeiras</h3>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {ordem.valor_orcamento && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">Valor Orçamento</p>
                      <p className="text-gray-900 font-semibold">R$ {formatNumberToBrazilian(ordem.valor_orcamento)}</p>
                    </div>
                  )}
                  
                  {ordem.mao_de_obra && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">Mão de Obra</p>
                      <p className="text-gray-900 font-semibold">R$ {formatNumberToBrazilian(ordem.mao_de_obra)}</p>
                    </div>
                  )}
                  
                  {ordem.valor && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">Valor Total</p>
                      <p className="text-gray-900 font-semibold text-lg">R$ {formatNumberToBrazilian(ordem.valor)}</p>
                    </div>
                  )}
                  
                  {ordem.forma_pagamento && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">Forma de Pagamento</p>
                      <p className="text-gray-900">{ordem.forma_pagamento}</p>
                      {ordem.valor_pagamento_1 && (
                        <p className="text-sm text-gray-600">R$ {formatNumberToBrazilian(ordem.valor_pagamento_1)}</p>
                      )}
                    </div>
                  )}
                  
                  {ordem.forma_pagamento_2 && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">2ª Forma de Pagamento</p>
                      <p className="text-gray-900">{ordem.forma_pagamento_2}</p>
                      {ordem.valor_pagamento_2 && (
                        <p className="text-sm text-gray-600">R$ {formatNumberToBrazilian(ordem.valor_pagamento_2)}</p>
                      )}
                    </div>
                  )}
                  
                  {ordem.garantia_meses && (
                    <div>
                      <p className="text-sm font-medium text-gray-500 mb-2">Garantia</p>
                      <p className="text-gray-900">{ordem.garantia_meses} meses</p>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ) : (

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
          {/* Seção 1: Cliente (Azul) */}
          <div className="bg-white rounded-xl shadow-sm border-l-4 border-blue-500 p-6">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <User className="w-5 h-5 text-blue-600" />
              </div>
              <h2 className="text-xl font-semibold text-gray-900">Informações do Cliente</h2>
            </div>

            <div className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <User className="w-4 h-4 inline mr-1" />
                    Nome do Cliente *
                  </label>
                  <input
                    {...register('cliente_nome')}
                    type="text"
                    onChange={(e) => {
                      handleCapitalizeInput(e)
                      setValue('cliente_nome', e.target.value)
                    }}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Nome completo"
                  />
                  {errors.cliente_nome && (
                    <p className="text-red-500 text-sm mt-1">{errors.cliente_nome.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Phone className="w-4 h-4 inline mr-1" />
                    Telefone
                  </label>
                  <input
                    {...register('cliente_telefone')}
                    type="tel"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="(11) 99999-9999"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Mail className="w-4 h-4 inline mr-1" />
                    E-mail
                  </label>
                  <input
                    {...register('cliente_email')}
                    type="email"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="email@exemplo.com"
                  />
                  {errors.cliente_email && (
                    <p className="text-red-500 text-sm mt-1">{errors.cliente_email.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Building2 className="w-4 h-4 inline mr-1" />
                    Cidade
                  </label>
                  <input
                    {...register('cliente_cidade')}
                    type="text"
                    onChange={(e) => {
                      handleCapitalizeInput(e)
                      setValue('cliente_cidade', e.target.value)
                    }}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Cidade"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Building2 className="w-4 h-4 inline mr-1" />
                    Estado
                  </label>
                  <select
                    {...register('cliente_estado')}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
                  >
                    <option value="">Selecione o estado</option>
                    <option value="AC">AC - Acre</option>
                    <option value="AL">AL - Alagoas</option>
                    <option value="AP">AP - Amapá</option>
                    <option value="AM">AM - Amazonas</option>
                    <option value="BA">BA - Bahia</option>
                    <option value="CE">CE - Ceará</option>
                    <option value="DF">DF - Distrito Federal</option>
                    <option value="ES">ES - Espírito Santo</option>
                    <option value="GO">GO - Goiás</option>
                    <option value="MA">MA - Maranhão</option>
                    <option value="MT">MT - Mato Grosso</option>
                    <option value="MS">MS - Mato Grosso do Sul</option>
                    <option value="MG">MG - Minas Gerais</option>
                    <option value="PA">PA - Pará</option>
                    <option value="PB">PB - Paraíba</option>
                    <option value="PR">PR - Paraná</option>
                    <option value="PE">PE - Pernambuco</option>
                    <option value="PI">PI - Piauí</option>
                    <option value="RJ">RJ - Rio de Janeiro</option>
                    <option value="RN">RN - Rio Grande do Norte</option>
                    <option value="RS">RS - Rio Grande do Sul</option>
                    <option value="RO">RO - Rondônia</option>
                    <option value="RR">RR - Roraima</option>
                    <option value="SC">SC - Santa Catarina</option>
                    <option value="SP">SP - São Paulo</option>
                    <option value="SE">SE - Sergipe</option>
                    <option value="TO">TO - Tocantins</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <MapPin className="w-4 h-4 inline mr-1" />
                  Endereço
                </label>
                <input
                  {...register('cliente_endereco')}
                  type="text"
                  onChange={(e) => {
                    handleCapitalizeInput(e)
                    setValue('cliente_endereco', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Endereço completo"
                />
              </div>
            </div>
          </div>

          {/* Seção 2: Equipamento (Verde) */}
          <div className="bg-white rounded-xl shadow-sm border-l-4 border-green-500 p-6">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Smartphone className="w-5 h-5 text-green-600" />
              </div>
              <h2 className="text-xl font-semibold text-gray-900">Dados do Equipamento</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo de Equipamento *
                </label>
                <input
                  type="text"
                  {...register('tipo')}
                  onChange={(e) => {
                    handleCapitalizeInput(e)
                    setValue('tipo', e.target.value)
                  }}
                  placeholder="Ex: Celular, Notebook, Console, Tablet, etc."
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Marca *
                </label>
                <input
                  {...register('marca')}
                  type="text"
                  onChange={(e) => {
                    handleCapitalizeInput(e)
                    setValue('marca', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  placeholder="Ex: Samsung, Apple, Dell"
                />
                {errors.marca && (
                  <p className="text-red-500 text-sm mt-1">{errors.marca.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Modelo *
                </label>
                <input
                  {...register('modelo')}
                  type="text"
                  onChange={(e) => {
                    handleCapitalizeInput(e)
                    setValue('modelo', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  placeholder="Ex: Galaxy S21, iPhone 13"
                />
                {errors.modelo && (
                  <p className="text-red-500 text-sm mt-1">{errors.modelo.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cor
                </label>
                <input
                  {...register('cor')}
                  type="text"
                  onChange={(e) => {
                    handleCapitalizeInput(e)
                    setValue('cor', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  placeholder="Ex: Preto, Branco, Azul"
                />
              </div>
            </div>

            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Série / IMEI
              </label>
              <input
                {...register('numero_serie')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                placeholder="Número de série ou IMEI do equipamento"
              />
            </div>
          </div>

          {/* Seção 3: Problema Relatado (Vermelho) */}
          <div className="bg-white rounded-xl shadow-sm border-l-4 border-red-500 p-6">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <AlertTriangle className="w-5 h-5 text-red-600" />
              </div>
              <h2 className="text-xl font-semibold text-gray-900">Problema Relatado</h2>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Descrição do Defeito *
                </label>
                <textarea
                  {...register('defeito_relatado')}
                  rows={3}
                  onChange={(e) => {
                    handleCapitalizeTextarea(e)
                    setValue('defeito_relatado', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  placeholder="Descreva detalhadamente o problema relatado pelo cliente..."
                />
                {errors.defeito_relatado && (
                  <p className="text-red-500 text-sm mt-1">{errors.defeito_relatado.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Descrição Técnica do Problema
                </label>
                <textarea
                  {...register('descricao_problema')}
                  rows={2}
                  onChange={(e) => {
                    handleCapitalizeTextarea(e)
                    setValue('descricao_problema', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  placeholder="Análise técnica do problema (opcional)..."
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Observações Gerais
                </label>
                <textarea
                  {...register('observacoes')}
                  rows={2}
                  onChange={(e) => {
                    handleCapitalizeTextarea(e)
                    setValue('observacoes', e.target.value)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  placeholder="Observações adicionais sobre o equipamento ou serviço..."
                />
              </div>
            </div>
          </div>

          {/* Seção 4: Datas e Status (Amarelo) */}
          <div className="bg-white rounded-xl shadow-sm border-l-4 border-yellow-500 p-6">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
                <Calendar className="w-5 h-5 text-yellow-600" />
              </div>
              <h2 className="text-xl font-semibold text-gray-900">Datas e Status</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Data de Entrada *
                </label>
                <input
                  {...register('data_entrada')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
                {errors.data_entrada && (
                  <p className="text-red-500 text-sm mt-1">{errors.data_entrada.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Previsão de Entrega
                </label>
                <input
                  {...register('data_previsao')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Status Atual *
                </label>
                <select
                  {...register('status')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                >
                  {STATUS_OPTIONS.map((status) => (
                    <option key={status.value} value={status.value}>
                      {status.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {/* Seção 5: Financeiro (Roxo) */}
          <div className="bg-white rounded-xl shadow-sm border-l-4 border-purple-500 p-6">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                <DollarSign className="w-5 h-5 text-purple-600" />
              </div>
              <h2 className="text-xl font-semibold text-gray-900">Informações Financeiras</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor Orçamento (R$)
                </label>
                <input
                  {...register('valor_orcamento')}
                  type="text"
                  onChange={(e) => {
                    const formatted = formatCurrency(e.target.value)
                    e.target.value = formatted
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0,00"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Mão de Obra (R$)
                </label>
                <input
                  {...register('mao_de_obra')}
                  type="text"
                  onChange={(e) => {
                    const formatted = formatCurrency(e.target.value)
                    e.target.value = formatted
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0,00"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor Total (R$)
                </label>
                <input
                  {...register('valor_total')}
                  type="number"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0,00"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <ShieldCheck className="w-4 h-4 inline mr-1" />
                  Garantia (meses)
                </label>
                <input
                  {...register('garantia_meses', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Valor Total (R$)
                </label>
                <input
                  {...register('valor_total')}
                  type="number"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0,00"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <ShieldCheck className="w-4 h-4 inline mr-1" />
                  Garantia (meses)
                </label>
                <input
                  {...register('garantia_meses', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="0"
                />
              </div>
            </div>

            {/* Seção de Pagamentos */}
            <div className="border-t border-purple-200 pt-4 mt-6">
              <h4 className="text-md font-medium text-purple-800 mb-4 flex items-center gap-2">
                💳 Formas de Pagamento
              </h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Forma de Pagamento 1
                  </label>
                  <select
                    {...register('forma_pagamento')}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  >
                    <option value="">Selecione...</option>
                    <option value="Dinheiro">💵 Dinheiro</option>
                    <option value="Pix">🔄 Pix</option>
                    <option value="Cartão de Débito">💳 Cartão de Débito</option>
                    <option value="Cartão de Crédito">💳 Cartão de Crédito</option>
                    <option value="Transferência">🏦 Transferência</option>
                    <option value="Parcelado">📅 Parcelado</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Valor Pagamento 1 (R$)
                  </label>
                  <input
                    {...register('valor_pagamento_1')}
                    type="number"
                    step="0.01"
                    min="0"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    placeholder="0,00"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Forma de Pagamento 2 (Opcional)
                  </label>
                  <select
                    {...register('forma_pagamento_2')}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  >
                    <option value="">Selecione...</option>
                    <option value="Dinheiro">💵 Dinheiro</option>
                    <option value="Pix">🔄 Pix</option>
                    <option value="Cartão de Débito">💳 Cartão de Débito</option>
                    <option value="Cartão de Crédito">💳 Cartão de Crédito</option>
                    <option value="Transferência">🏦 Transferência</option>
                    <option value="Parcelado">📅 Parcelado</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Valor Pagamento 2 (R$)
                  </label>
                  <input
                    {...register('valor_pagamento_2')}
                    type="number"
                    step="0.01"
                    min="0"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    placeholder="0,00"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="flex flex-col sm:flex-row gap-3 pt-6">
            <button
              type="button"
              onClick={onCancel}
              className="flex-1 px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? 'Atualizando...' : 'Atualizar Ordem de Serviço'}
            </button>
          </div>
        </form>
        )}
        
      </div>
    </div>
  )
}
