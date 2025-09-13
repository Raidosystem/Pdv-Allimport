import { useState } from 'react'
import { Wrench, Plus } from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { OrdemServicoForm } from '../../components/ordem-servico/OrdemServicoForm'
// import { StatusCardsOS } from '../../components/ordem-servico/StatusCardsOS'
import { useOrdemServico } from '../../hooks/useOrdemServico'
import type { OrdemServico } from '../../types/ordemServico'

type ViewMode = 'list' | 'form'

export function OrdensServicoPage() {
  const {
    ordensServico,
    loading,
    carregarOS,
    // criarOS,
    // atualizarOS,
    // deletarOS
  } = useOrdemServico()

  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [osEditando, setOsEditando] = useState<OrdemServico | null>(null)

  // Estatísticas das OS
  const osAbertas = ordensServico.filter(os => os.status === 'Em análise').length
  const osAndamento = ordensServico.filter(os => os.status === 'Em conserto').length
  const osFinalizadas = ordensServico.filter(os => os.status === 'Pronto').length
  const osEntregues = ordensServico.filter(os => os.status === 'Entregue').length

  const handleNovaOS = () => {
    setOsEditando(null)
    setViewMode('form')
  }

  const handleEditarOS = (os: OrdemServico) => {
    setOsEditando(os)
    setViewMode('form')
  }

  const handleSalvarOS = async () => {
    try {
      await carregarOS() // Recarregar lista
      setViewMode('list')
      setOsEditando(null)
    } catch (error) {
      console.error('Erro ao salvar OS:', error)
    }
  }

  const handleCancelar = () => {
    setViewMode('list')
    setOsEditando(null)
  }

  if (loading && ordensServico.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 border-4 border-gray-300 border-t-blue-600 rounded-full animate-spin" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Carregando ordens de serviço...</h2>
          <p className="text-gray-600">Aguarde enquanto buscamos os dados.</p>
        </div>
      </div>
    )
  }

  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Conteúdo do formulário */}
        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Wrench className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {osEditando ? 'Editar OS' : 'Nova Ordem de Serviço'}
                </h1>
                <p className="text-sm text-gray-600">Preencha os dados da ordem de serviço</p>
              </div>
            </div>
            
            <Button
              onClick={handleCancelar}
              variant="outline"
            >
              Voltar para Lista
            </Button>
          </div>

          <OrdemServicoForm
            // ordemServico={osEditando || undefined}
            onSuccess={handleSalvarOS}
            onCancel={handleCancelar}
          />
        </main>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        {/* Barra de ações */}
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
              <Wrench className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-900">Ordens de Serviço</h1>
              <p className="text-sm text-gray-600">Gerenciar assistência técnica</p>
            </div>
          </div>
          
          <Button
            onClick={handleNovaOS}
            className="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            Nova OS
          </Button>
        </div>
        
        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
                <Wrench className="w-5 h-5 text-yellow-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Abertas</p>
                <p className="text-2xl font-bold text-gray-900">{osAbertas}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <Wrench className="w-5 h-5 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Em Andamento</p>
                <p className="text-2xl font-bold text-gray-900">{osAndamento}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Wrench className="w-5 h-5 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Finalizadas</p>
                <p className="text-2xl font-bold text-gray-900">{osFinalizadas}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                <Wrench className="w-5 h-5 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Entregues</p>
                <p className="text-2xl font-bold text-gray-900">{osEntregues}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Cards de Status */}
        {/* <StatusCardsOS ordensServico={ordensServico} loading={loading} /> */}

        {/* Lista simplificada por enquanto */}
        <div className="mt-8 bg-white rounded-lg shadow-sm border">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Ordens de Serviço Recentes</h3>
            
            {ordensServico.length === 0 ? (
              <div className="text-center py-12">
                <Wrench className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Nenhuma OS encontrada</h3>
                <p className="text-gray-600 mb-4">Começe criando uma nova ordem de serviço.</p>
                <Button onClick={handleNovaOS} className="bg-blue-600 hover:bg-blue-700">
                  <Plus className="w-4 h-4 mr-2" />
                  Criar primeira OS
                </Button>
              </div>
            ) : (
              <div className="space-y-4">
                {ordensServico.slice(0, 5).map((os) => (
                  <div 
                    key={os.id}
                    className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
                  >
                    <div className="flex items-center space-x-4">
                      <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                        <Wrench className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">OS #{os.id.slice(0, 8)}</p>
                        <p className="text-sm text-gray-600">{os.cliente_id} - {os.defeito_relatado || 'Sem descrição'}</p>
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-3">
                      <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                        os.status === 'Em análise' ? 'bg-yellow-100 text-yellow-800' :
                        os.status === 'Em conserto' ? 'bg-blue-100 text-blue-800' :
                        os.status === 'Pronto' ? 'bg-green-100 text-green-800' :
                        'bg-purple-100 text-purple-800'
                      }`}>
                        {os.status}
                      </span>
                      
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleEditarOS(os)}
                      >
                        Ver/Editar
                      </Button>
                    </div>
                  </div>
                ))}
                
                {ordensServico.length > 5 && (
                  <div className="text-center pt-4">
                    <p className="text-gray-600">
                      E mais {ordensServico.length - 5} ordens de serviço...
                    </p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  )
}
