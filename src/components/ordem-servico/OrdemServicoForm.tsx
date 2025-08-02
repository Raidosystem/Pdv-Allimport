import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  User, 
  Phone, 
  Mail, 
  Smartphone, 
  Laptop, 
  Gamepad2, 
  Tablet,
  Settings,
  Calendar,
  DollarSign,
  Save,
  Search
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ordemServicoService } from '../../services/ordemServicoService'
import type { 
  NovaOrdemServicoForm, 
  TipoEquipamento, 
  ChecklistOS 
} from '../../types/ordemServico'
import type { Cliente } from '../../types/cliente'

// Schema de validação
const ordemServicoSchema = z.object({
  cliente_nome: z.string().min(3, 'Nome deve ter pelo menos 3 caracteres'),
  cliente_telefone: z.string().min(10, 'Telefone deve ter pelo menos 10 dígitos'),
  cliente_email: z.string().email('Email inválido').optional().or(z.literal('')),
  tipo: z.enum(['Celular', 'Notebook', 'Console', 'Tablet', 'Outro']),
  marca: z.string().min(2, 'Marca é obrigatória'),
  modelo: z.string().min(2, 'Modelo é obrigatório'),
  cor: z.string().optional(),
  numero_serie: z.string().optional(),
  defeito_relatado: z.string().min(10, 'Descreva o defeito relatado'),
  observacoes: z.string().optional(),
  data_previsao: z.string().optional(),
  valor_orcamento: z.number().min(0, 'Valor deve ser positivo').optional()
})

type FormData = z.infer<typeof ordemServicoSchema>

interface OrdemServicoFormProps {
  onSuccess?: (ordem: any) => void
  onCancel?: () => void
}

const TIPOS_EQUIPAMENTO: { value: TipoEquipamento; label: string; icon: any }[] = [
  { value: 'Celular', label: 'Celular', icon: Smartphone },
  { value: 'Notebook', label: 'Notebook', icon: Laptop },
  { value: 'Console', label: 'Console', icon: Gamepad2 },
  { value: 'Tablet', label: 'Tablet', icon: Tablet },
  { value: 'Outro', label: 'Outro', icon: Settings }
]

export function OrdemServicoForm({ onSuccess, onCancel }: OrdemServicoFormProps) {
  const [loading, setLoading] = useState(false)
  const [clientesSugeridos, setClientesSugeridos] = useState<Cliente[]>([])
  const [mostrarSugestoes, setMostrarSugestoes] = useState(false)
  const [checklist, setChecklist] = useState<ChecklistOS>({})

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors }
  } = useForm<FormData>({
    resolver: zodResolver(ordemServicoSchema),
    defaultValues: {
      tipo: 'Celular'
    }
  })

  const nomeCliente = watch('cliente_nome')

  // Buscar clientes conforme digita
  useEffect(() => {
    const buscarClientes = async () => {
      if (nomeCliente && nomeCliente.length >= 3) {
        try {
          const clientes = await ordemServicoService.buscarClientes(nomeCliente)
          setClientesSugeridos(clientes)
          setMostrarSugestoes(true)
        } catch (error) {
          console.error('Erro ao buscar clientes:', error)
        }
      } else {
        setMostrarSugestoes(false)
      }
    }

    const timeoutId = setTimeout(buscarClientes, 300)
    return () => clearTimeout(timeoutId)
  }, [nomeCliente])

  // Selecionar cliente sugerido
  const selecionarCliente = (cliente: Cliente) => {
    setValue('cliente_nome', cliente.nome)
    setValue('cliente_telefone', cliente.telefone)
    setValue('cliente_email', cliente.email || '')
    setMostrarSugestoes(false)
  }

  // Atualizar checklist
  const atualizarChecklist = (campo: keyof ChecklistOS, valor: boolean) => {
    setChecklist(prev => ({
      ...prev,
      [campo]: valor
    }))
  }

  // Submeter formulário
  const onSubmit = async (data: FormData) => {
    setLoading(true)
    
    try {
      const novaOrdem: NovaOrdemServicoForm = {
        cliente_nome: data.cliente_nome,
        cliente_telefone: data.cliente_telefone,
        cliente_email: data.cliente_email,
        tipo: data.tipo,
        marca: data.marca,
        modelo: data.modelo,
        cor: data.cor,
        numero_serie: data.numero_serie,
        checklist,
        observacoes: data.observacoes,
        defeito_relatado: data.defeito_relatado,
        data_previsao: data.data_previsao,
        valor_orcamento: data.valor_orcamento
      }

      const ordem = await ordemServicoService.criarOrdem(novaOrdem)
      
      toast.success('Ordem de serviço criada com sucesso!')
      
      if (onSuccess) {
        onSuccess(ordem)
      }
    } catch (error: any) {
      console.error('Erro ao criar ordem:', error)
      toast.error(error.message || 'Erro ao criar ordem de serviço')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Nova Ordem de Serviço</h1>
        {onCancel && (
          <Button variant="outline" onClick={onCancel}>
            Cancelar
          </Button>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        
        {/* Seção: Cliente */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <User className="w-5 h-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-gray-900">Dados do Cliente</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="relative">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome do Cliente *
              </label>
              <div className="relative">
                <input
                  {...register('cliente_nome')}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Digite o nome do cliente"
                />
                <Search className="w-4 h-4 text-gray-400 absolute right-3 top-3" />
              </div>
              
              {/* Sugestões de clientes */}
              {mostrarSugestoes && clientesSugeridos.length > 0 && (
                <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-48 overflow-y-auto">
                  {clientesSugeridos.map((cliente) => (
                    <button
                      key={cliente.id}
                      type="button"
                      onClick={() => selecionarCliente(cliente)}
                      className="w-full px-3 py-2 text-left hover:bg-gray-50 flex items-center justify-between"
                    >
                      <div>
                        <div className="font-medium">{cliente.nome}</div>
                        <div className="text-sm text-gray-500">{cliente.telefone}</div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
              
              {errors.cliente_nome && (
                <span className="text-red-500 text-sm">{errors.cliente_nome.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Telefone *
              </label>
              <div className="relative">
                <Phone className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('cliente_telefone')}
                  type="tel"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="(11) 99999-9999"
                />
              </div>
              {errors.cliente_telefone && (
                <span className="text-red-500 text-sm">{errors.cliente_telefone.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email (opcional)
              </label>
              <div className="relative">
                <Mail className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('cliente_email')}
                  type="email"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="cliente@email.com"
                />
              </div>
              {errors.cliente_email && (
                <span className="text-red-500 text-sm">{errors.cliente_email.message}</span>
              )}
            </div>
          </div>
        </Card>

        {/* Seção: Informações do Aparelho */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Smartphone className="w-5 h-5 text-green-600" />
            <h2 className="text-lg font-semibold text-gray-900">Informações do Aparelho</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Equipamento *
              </label>
              <select
                {...register('tipo')}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {TIPOS_EQUIPAMENTO.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
                  </option>
                ))}
              </select>
              {errors.tipo && (
                <span className="text-red-500 text-sm">{errors.tipo.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Marca *
              </label>
              <input
                {...register('marca')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Samsung, Apple, Dell..."
              />
              {errors.marca && (
                <span className="text-red-500 text-sm">{errors.marca.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Modelo *
              </label>
              <input
                {...register('modelo')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Galaxy S21, iPhone 13..."
              />
              {errors.modelo && (
                <span className="text-red-500 text-sm">{errors.modelo.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cor
              </label>
              <input
                {...register('cor')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Preto, Branco, Azul..."
              />
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Série
              </label>
              <input
                {...register('numero_serie')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="IMEI ou número de série"
              />
            </div>
          </div>
        </Card>

        {/* Seção: Checklist Técnico */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Settings className="w-5 h-5 text-purple-600" />
            <h2 className="text-lg font-semibold text-gray-900">Checklist Técnico</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {[
              { key: 'liga', label: 'Aparelho liga?' },
              { key: 'tela_quebrada', label: 'Tela quebrada?' },
              { key: 'molhado', label: 'Aparelho molhado?' },
              { key: 'com_senha', label: 'Com senha?' },
              { key: 'bateria_boa', label: 'Bateria boa?' },
              { key: 'tampa_presente', label: 'Tampa presente?' },
              { key: 'acessorios', label: 'Acessórios entregues?' },
              { key: 'carregador', label: 'Carregador?' }
            ].map((item) => (
              <label key={item.key} className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={checklist[item.key as keyof ChecklistOS] || false}
                  onChange={(e) => atualizarChecklist(item.key as keyof ChecklistOS, e.target.checked)}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <span className="text-sm text-gray-700">{item.label}</span>
              </label>
            ))}
          </div>
        </Card>

        {/* Seção: Detalhes do Problema */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Detalhes do Problema</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Defeito Relatado *
              </label>
              <textarea
                {...register('defeito_relatado')}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Descreva o problema relatado pelo cliente..."
              />
              {errors.defeito_relatado && (
                <span className="text-red-500 text-sm">{errors.defeito_relatado.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações Adicionais
              </label>
              <textarea
                {...register('observacoes')}
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Observações gerais, estado do aparelho, etc..."
              />
            </div>
          </div>
        </Card>

        {/* Seção: Prazos e Valores */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Prazos e Valores</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Previsão de Entrega
              </label>
              <div className="relative">
                <Calendar className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('data_previsao')}
                  type="date"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor do Orçamento (R$)
              </label>
              <div className="relative">
                <DollarSign className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('valor_orcamento', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  step="0.01"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="0,00"
                />
              </div>
              {errors.valor_orcamento && (
                <span className="text-red-500 text-sm">{errors.valor_orcamento.message}</span>
              )}
            </div>
          </div>
        </Card>

        {/* Botões de Ação */}
        <div className="flex gap-4 justify-end">
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
          )}
          
          <Button type="submit" loading={loading} className="gap-2">
            <Save className="w-4 h-4" />
            Criar Ordem de Serviço
          </Button>
        </div>
      </form>
    </div>
  )
}
