import { useState } from 'react'
import { Users, Plus } from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { ClienteFormulario } from '../../components/cliente/ClienteFormulario'
import { ClienteTable } from '../../components/cliente/ClienteTable'
import { useClientes } from '../../hooks/useClientes'
import type { Cliente } from '../../types/cliente'

type ViewMode = 'list' | 'form' | 'view'

export function ClientesPage() {
  const {
    clientes,
    loading,
    carregarClientes,
    deletarCliente,
    alternarStatus
  } = useClientes()

  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [clienteEditando, setClienteEditando] = useState<Cliente | null>(null)
  const [clienteVisualizando, setClienteVisualizando] = useState<Cliente | null>(null)

  // Estatísticas dos clientes
  const clientesAtivos = clientes.filter(c => c.ativo).length
  const pessoasFisicas = clientes.filter(c => c.tipo === 'Física').length
  const pessoasJuridicas = clientes.filter(c => c.tipo === 'Jurídica').length

  const handleNovoCliente = () => {
    setClienteEditando(null)
    setViewMode('form')
  }

  const handleEditarCliente = (cliente: Cliente) => {
    setClienteEditando(cliente)
    setViewMode('form')
  }

  const handleVisualizarCliente = (cliente: Cliente) => {
    setClienteVisualizando(cliente)
    setViewMode('view')
  }

  const handleSalvarCliente = async (_clienteResult: Cliente) => {
    try {
      await carregarClientes() // Recarregar lista
      setViewMode('list')
      setClienteEditando(null)
    } catch (error) {
      console.error('Erro ao salvar cliente:', error)
    }
  }

  const handleCancelar = () => {
    setViewMode('list')
    setClienteEditando(null)
    setClienteVisualizando(null)
  }

  const handleDeleteCliente = async (id: string) => {
    const cliente = clientes.find(c => c.id === id)
    if (!cliente) return
    
    if (window.confirm(`Deseja realmente excluir o cliente "${cliente.nome}"?`)) {
      try {
        await deletarCliente(id)
      } catch (error) {
        console.error('Erro ao excluir cliente:', error)
      }
    }
  }

  const handleToggleStatus = async (id: string, ativo: boolean) => {
    try {
      await alternarStatus(id, ativo)
    } catch (error) {
      console.error('Erro ao alterar status:', error)
    }
  }

  if (loading && clientes.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 border-4 border-gray-300 border-t-blue-600 rounded-full animate-spin" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Carregando clientes...</h2>
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
              <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {clienteEditando ? 'Editar Cliente' : 'Novo Cliente'}
                </h1>
                <p className="text-sm text-gray-600">Preencha os dados do cliente</p>
              </div>
            </div>
            
            <Button
              onClick={handleCancelar}
              variant="outline"
            >
              Voltar para Lista
            </Button>
          </div>

          <ClienteFormulario
            cliente={clienteEditando || undefined}
            onSuccess={handleSalvarCliente}
            onCancel={handleCancelar}
          />
        </main>
      </div>
    )
  }

  if (viewMode === 'view' && clienteVisualizando) {
    // Por enquanto, vamos editar ao invés de visualizar
    setViewMode('form')
    setClienteEditando(clienteVisualizando)
    setClienteVisualizando(null)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        {/* Barra de ações */}
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center">
              <Users className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-900">Clientes</h1>
              <p className="text-sm text-gray-600">Gerenciar cadastro de clientes</p>
            </div>
          </div>
          
          <Button
            onClick={handleNovoCliente}
            className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            Novo Cliente
          </Button>
        </div>
        
        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total</p>
                <p className="text-2xl font-bold text-gray-900">{clientes.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Ativos</p>
                <p className="text-2xl font-bold text-gray-900">{clientesAtivos}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">P. Física</p>
                <p className="text-2xl font-bold text-gray-900">{pessoasFisicas}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-yellow-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">P. Jurídica</p>
                <p className="text-2xl font-bold text-gray-900">{pessoasJuridicas}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Tabela de clientes */}
        <ClienteTable
          clientes={clientes}
          loading={loading}
          onEdit={handleEditarCliente}
          onView={handleVisualizarCliente}
          onDelete={handleDeleteCliente}
          onToggleStatus={handleToggleStatus}
          onFiltersChange={() => {}}
        />
      </main>
    </div>
  )
}
