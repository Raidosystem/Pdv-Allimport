import { useState } from 'react'
import { Users, Plus, ArrowLeft } from 'lucide-react'
import { Link } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { ClienteFormulario } from '../../components/cliente/ClienteFormulario'
import { ClienteTable } from '../../components/cliente/ClienteTable'
import { ClienteModal } from '../../components/cliente/ClienteModal'
import { useClientes } from '../../hooks/useClientes'
import type { Cliente, ClienteFilters } from '../../types/cliente'

type ViewMode = 'list' | 'form' | 'view'

export function ClientesPage() {
  const {
    clientes,
    loading,
    carregarClientes,
    criarCliente,
    atualizarCliente,
    deletarCliente,
    alternarStatus
  } = useClientes()

  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [clienteEditando, setClienteEditando] = useState<Cliente | null>(null)
  const [clienteVisualizando, setClienteVisualizando] = useState<Cliente | null>(null)

  // Estatísticas
  const totalClientes = clientes.length
  const clientesAtivos = clientes.filter(c => c.ativo).length
  const clientesInativos = clientes.filter(c => !c.ativo).length
  const pessoasFisicas = clientes.filter(c => c.tipo === 'Física').length
  const pessoasJuridicas = clientes.filter(c => c.tipo === 'Jurídica').length

  const handleNovoCliente = () => {
    setClienteEditando(null)
    setViewMode('form')
  }

  const handleEditarCliente = (cliente: Cliente) => {
    setClienteEditando(cliente)
    setViewMode('form')
    setClienteVisualizando(null)
  }

  const handleVisualizarCliente = (cliente: Cliente) => {
    setClienteVisualizando(cliente)
  }

  const handleCancelarForm = () => {
    setClienteEditando(null)
    setViewMode('list')
  }

  const handleSubmitForm = async (data: any) => {
    if (clienteEditando) {
      await atualizarCliente(clienteEditando.id, data)
    } else {
      await criarCliente(data)
    }
    setClienteEditando(null)
    setViewMode('list')
  }

  const handleFiltersChange = (filtros: ClienteFilters) => {
    carregarClientes(filtros)
  }

  const handleToggleStatus = async (id: string, ativo: boolean) => {
    await alternarStatus(id, ativo)
  }

  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              <div className="flex items-center space-x-4">
                <Link 
                  to="/dashboard" 
                  className="flex items-center space-x-2 text-gray-600 hover:text-orange-600 transition-colors"
                >
                  <ArrowLeft className="w-4 h-4" />
                  <span>Dashboard</span>
                </Link>
                <div className="h-8 border-l border-gray-300"></div>
                <button
                  onClick={() => setViewMode('list')}
                  className="flex items-center space-x-2 text-gray-600 hover:text-orange-600 transition-colors"
                >
                  <ArrowLeft className="w-4 h-4" />
                  <span>Voltar para Clientes</span>
                </button>
              </div>
            </div>
          </div>
        </header>

        {/* Conteúdo */}
        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <ClienteFormulario
            cliente={clienteEditando || undefined}
            onSuccess={handleSubmitForm}
            onCancel={handleCancelarForm}
          />
        </main>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link 
                to="/dashboard" 
                className="flex items-center space-x-2 text-gray-600 hover:text-orange-600 transition-colors"
              >
                <ArrowLeft className="w-4 h-4" />
                <span>Dashboard</span>
              </Link>
              <div className="h-8 border-l border-gray-300"></div>
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center">
                  <Users className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Clientes</h1>
                  <p className="text-sm text-gray-600">Gerenciar cadastro de clientes</p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Button
                onClick={handleNovoCliente}
                className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700"
              >
                <Plus className="w-4 h-4 mr-2" />
                Novo Cliente
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total</p>
                <p className="text-2xl font-bold text-gray-900">{totalClientes}</p>
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
              <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-red-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Inativos</p>
                <p className="text-2xl font-bold text-gray-900">{clientesInativos}</p>
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
              <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                <Users className="w-5 h-5 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">P. Jurídica</p>
                <p className="text-2xl font-bold text-gray-900">{pessoasJuridicas}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Tabela de Clientes */}
        <ClienteTable
          clientes={clientes}
          loading={loading}
          onEdit={handleEditarCliente}
          onDelete={deletarCliente}
          onView={handleVisualizarCliente}
          onToggleStatus={handleToggleStatus}
          onFiltersChange={handleFiltersChange}
        />
      </main>

      {/* Modal de Visualização */}
      {clienteVisualizando && (
        <ClienteModal
          cliente={clienteVisualizando}
          onClose={() => setClienteVisualizando(null)}
          onEdit={() => handleEditarCliente(clienteVisualizando)}
        />
      )}
    </div>
  )
}
