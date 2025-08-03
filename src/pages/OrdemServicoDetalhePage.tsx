import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { toast } from 'react-hot-toast'
import { 
  ArrowLeft, 
  Edit, 
  Printer, 
  User, 
  Phone, 
  Mail, 
  Calendar, 
  DollarSign,
  CheckCircle,
  XCircle,
  Settings,
  Shield
} from 'lucide-react'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { ModalEntregaOS } from '../components/ordem-servico/ModalEntregaOS'
import { ordemServicoService } from '../services/ordemServicoService'
import type { OrdemServico, StatusOS } from '../types/ordemServico'
import { STATUS_COLORS, TIPO_ICONS } from '../types/ordemServico'

export function OrdemServicoDetalhePage() {
  const { id } = useParams<{ id: string }>()
  const [ordem, setOrdem] = useState<OrdemServico | null>(null)
  const [loading, setLoading] = useState(true)
  const [atualizandoStatus, setAtualizandoStatus] = useState(false)
  const [modalEntregaAberto, setModalEntregaAberto] = useState(false)

  useEffect(() => {
    if (id) {
      carregarOrdem()
    }
  }, [id])

  const carregarOrdem = async () => {
    if (!id) return
    
    setLoading(true)
    try {
      const dados = await ordemServicoService.buscarPorId(id)
      setOrdem(dados)
    } catch (error: any) {
      console.error('Erro ao carregar ordem:', error)
      toast.error('Erro ao carregar ordem de serviço')
    } finally {
      setLoading(false)
    }
  }

  const atualizarStatus = async (novoStatus: StatusOS) => {
    if (!id) return
    
    setAtualizandoStatus(true)
    try {
      await ordemServicoService.atualizarStatus(id, novoStatus)
      toast.success('Status atualizado com sucesso!')
      carregarOrdem()
    } catch (error: any) {
      console.error('Erro ao atualizar status:', error)
      toast.error('Erro ao atualizar status')
    } finally {
      setAtualizandoStatus(false)
    }
  }

  const processarEntrega = async (dados: {
    garantia_meses?: number
    valor_final?: number
    data_entrega: string
    data_fim_garantia?: string
  }) => {
    if (!id) return
    
    await ordemServicoService.processarEntrega(id, dados)
    carregarOrdem()
  }

  const formatarData = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit', 
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatarDataSimples = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR')
  }

  const formatarValor = (valor?: number) => {
    if (!valor) return 'Não informado'
    return valor.toLocaleString('pt-BR', { 
      style: 'currency', 
      currency: 'BRL' 
    })
  }

  const imprimirOS = () => {
    window.print()
  }

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/3"></div>
          <div className="space-y-4">
            <div className="h-32 bg-gray-200 rounded"></div>
            <div className="h-32 bg-gray-200 rounded"></div>
            <div className="h-32 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    )
  }

  if (!ordem) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <Card className="p-8 text-center">
          <div className="text-gray-400 text-6xl mb-4">📋</div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">
            Ordem de serviço não encontrada
          </h2>
          <p className="text-gray-600 mb-4">
            A ordem de serviço solicitada não existe ou você não tem permissão para visualizá-la.
          </p>
          <Link to="/ordens-servico">
            <Button className="gap-2">
              <ArrowLeft className="w-4 h-4" />
              Voltar para lista
            </Button>
          </Link>
        </Card>
      </div>
    )
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link to="/ordens-servico" className="text-gray-600 hover:text-gray-900">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              OS #{ordem.id.slice(-6).toUpperCase()}
            </h1>
            <p className="text-gray-600">
              Criada em {formatarData(ordem.data_entrada)}
            </p>
          </div>
        </div>
        
        <div className="flex gap-3">
          <Button variant="outline" onClick={imprimirOS} className="gap-2">
            <Printer className="w-4 h-4" />
            Imprimir
          </Button>
          
          <Link to={`/ordens-servico/${ordem.id}/editar`}>
            <Button className="gap-2">
              <Edit className="w-4 h-4" />
              Editar
            </Button>
          </Link>
        </div>
      </div>

      {/* Status */}
      <Card className="p-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-gray-900 mb-2">Status da Ordem</h2>
            <span className={`inline-flex px-3 py-1 rounded-full text-sm font-medium border ${STATUS_COLORS[ordem.status]}`}>
              {ordem.status}
            </span>
          </div>
          
          {ordem.status === 'Entregue' ? (
            <div className="flex gap-3">
              <Button onClick={imprimirOS} className="gap-2">
                <Printer className="w-4 h-4" />
                Imprimir OS
              </Button>
            </div>
          ) : ordem.status === 'Pronto' ? (
            <div className="flex gap-3">
              <Button 
                onClick={() => setModalEntregaAberto(true)}
                className="gap-2 bg-green-600 hover:bg-green-700"
                disabled={atualizandoStatus}
              >
                <CheckCircle className="w-4 h-4" />
                Encerrar OS
              </Button>
            </div>
          ) : (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Alterar Status
              </label>
              <select
                value={ordem.status}
                onChange={(e) => atualizarStatus(e.target.value as StatusOS)}
                disabled={atualizandoStatus}
                className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="Em análise">Em análise</option>
                <option value="Aguardando aprovação">Aguardando aprovação</option>
                <option value="Aguardando peças">Aguardando peças</option>
                <option value="Em conserto">Em conserto</option>
                <option value="Pronto">Pronto</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
          )}
        </div>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        {/* Dados do Cliente */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <User className="w-5 h-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-gray-900">Dados do Cliente</h2>
          </div>
          
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <User className="w-4 h-4 text-gray-400" />
              <div>
                <div className="font-medium text-gray-900">{ordem.cliente?.nome}</div>
                <div className="text-sm text-gray-600">Nome completo</div>
              </div>
            </div>
            
            <div className="flex items-center gap-3">
              <Phone className="w-4 h-4 text-gray-400" />
              <div>
                <div className="font-medium text-gray-900">{ordem.cliente?.telefone}</div>
                <div className="text-sm text-gray-600">Telefone</div>
              </div>
            </div>
            
            {ordem.cliente?.email && (
              <div className="flex items-center gap-3">
                <Mail className="w-4 h-4 text-gray-400" />
                <div>
                  <div className="font-medium text-gray-900">{ordem.cliente.email}</div>
                  <div className="text-sm text-gray-600">Email</div>
                </div>
              </div>
            )}
          </div>
        </Card>

        {/* Informações do Aparelho */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <span className="text-xl">{TIPO_ICONS[ordem.tipo]}</span>
            <h2 className="text-lg font-semibold text-gray-900">Informações do Aparelho</h2>
          </div>
          
          <div className="space-y-3">
            <div>
              <div className="font-medium text-gray-900">{ordem.tipo}</div>
              <div className="text-sm text-gray-600">Tipo de equipamento</div>
            </div>
            
            <div>
              <div className="font-medium text-gray-900">{ordem.marca} {ordem.modelo}</div>
              <div className="text-sm text-gray-600">Marca e modelo</div>
            </div>
            
            {ordem.cor && (
              <div>
                <div className="font-medium text-gray-900">{ordem.cor}</div>
                <div className="text-sm text-gray-600">Cor</div>
              </div>
            )}
            
            {ordem.numero_serie && (
              <div>
                <div className="font-medium text-gray-900">{ordem.numero_serie}</div>
                <div className="text-sm text-gray-600">Número de série</div>
              </div>
            )}
          </div>
        </Card>
      </div>

      {/* Checklist Técnico */}
      <Card className="p-6">
        <div className="flex items-center gap-2 mb-4">
          <Settings className="w-5 h-5 text-purple-600" />
          <h2 className="text-lg font-semibold text-gray-900">Checklist Técnico</h2>
        </div>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { key: 'liga', label: 'Aparelho liga?' },
            { key: 'tela_quebrada', label: 'Tela quebrada?' },
            { key: 'molhado', label: 'Aparelho molhado?' },
            { key: 'com_senha', label: 'Com senha?' },
            { key: 'bateria_boa', label: 'Bateria boa?' },
            { key: 'tampa_presente', label: 'Tampa presente?' },
            { key: 'acessorios', label: 'Acessórios?' },
            { key: 'carregador', label: 'Carregador?' }
          ].map((item) => {
            const valor = ordem.checklist?.[item.key as keyof typeof ordem.checklist]
            return (
              <div key={item.key} className="flex items-center gap-2">
                {valor === true ? (
                  <CheckCircle className="w-5 h-5 text-green-600" />
                ) : valor === false ? (
                  <XCircle className="w-5 h-5 text-red-600" />
                ) : (
                  <div className="w-5 h-5 rounded-full border-2 border-gray-300" />
                )}
                <span className="text-sm text-gray-700">{item.label}</span>
              </div>
            )
          })}
        </div>
      </Card>

      {/* Detalhes do Problema */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Detalhes do Problema</h2>
        
        <div className="space-y-4">
          <div>
            <h3 className="font-medium text-gray-900 mb-2">Defeito Relatado</h3>
            <p className="text-gray-700 bg-gray-50 p-3 rounded-md">
              {ordem.defeito_relatado || 'Não informado'}
            </p>
          </div>
          
          {ordem.observacoes && (
            <div>
              <h3 className="font-medium text-gray-900 mb-2">Observações</h3>
              <p className="text-gray-700 bg-gray-50 p-3 rounded-md">
                {ordem.observacoes}
              </p>
            </div>
          )}
        </div>
      </Card>

      {/* Prazos e Valores */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Calendar className="w-5 h-5 text-orange-600" />
            <h2 className="text-lg font-semibold text-gray-900">Prazos</h2>
          </div>
          
          <div className="space-y-3">
            <div>
              <div className="font-medium text-gray-900">
                {formatarData(ordem.data_entrada)}
              </div>
              <div className="text-sm text-gray-600">Data de entrada</div>
            </div>
            
            {ordem.data_previsao && (
              <div>
                <div className="font-medium text-gray-900">
                  {formatarDataSimples(ordem.data_previsao)}
                </div>
                <div className="text-sm text-gray-600">Previsão de entrega</div>
              </div>
            )}
            
            {ordem.data_entrega && (
              <div>
                <div className="font-medium text-gray-900">
                  {formatarData(ordem.data_entrega)}
                </div>
                <div className="text-sm text-gray-600">Data de entrega</div>
              </div>
            )}
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <DollarSign className="w-5 h-5 text-green-600" />
            <h2 className="text-lg font-semibold text-gray-900">Valores</h2>
          </div>
          
          <div className="space-y-3">
            <div>
              <div className="font-medium text-gray-900">
                {formatarValor(ordem.valor_orcamento)}
              </div>
              <div className="text-sm text-gray-600">Valor do orçamento</div>
            </div>
            
            {ordem.valor_final && (
              <div>
                <div className="font-medium text-gray-900">
                  {formatarValor(ordem.valor_final)}
                </div>
                <div className="text-sm text-gray-600">Valor final</div>
              </div>
            )}
          </div>
        </Card>

        {/* Informações de Garantia */}
        {ordem.status === 'Entregue' && (
          <Card className="p-6">
            <div className="flex items-center gap-2 mb-4">
              <Shield className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold text-gray-900">Garantia</h2>
            </div>
            
            <div className="space-y-3">
              {ordem.data_entrega && (
                <div>
                  <div className="font-medium text-gray-900">
                    {formatarData(ordem.data_entrega)}
                  </div>
                  <div className="text-sm text-gray-600">Data de entrega</div>
                </div>
              )}
              
              {ordem.garantia_meses ? (
                <>
                  <div>
                    <div className="font-medium text-gray-900">
                      {ordem.garantia_meses} meses
                    </div>
                    <div className="text-sm text-gray-600">Período de garantia</div>
                  </div>
                  
                  {ordem.data_fim_garantia && (
                    <div>
                      <div className="font-medium text-gray-900">
                        {formatarDataSimples(ordem.data_fim_garantia)}
                      </div>
                      <div className="text-sm text-gray-600">Garantia válida até</div>
                    </div>
                  )}
                </>
              ) : (
                <div>
                  <div className="font-medium text-gray-900">Sem garantia</div>
                  <div className="text-sm text-gray-600">Equipamento entregue sem garantia</div>
                </div>
              )}
            </div>
          </Card>
        )}
      </div>

      {/* Modal de Entrega */}
      {ordem && (
        <ModalEntregaOS
          ordem={ordem}
          isOpen={modalEntregaAberto}
          onClose={() => setModalEntregaAberto(false)}
          onConfirmar={processarEntrega}
        />
      )}
    </div>
  )
}
