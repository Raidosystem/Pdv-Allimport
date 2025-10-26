import { useState } from 'react'
import { 
  Search, 
  Filter, 
  Edit2, 
  Trash2, 
  Eye, 
  Phone, 
  Mail, 
  User,
  Building2,
  UserCheck,
  UserX
} from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { formatarCpfCnpj } from '../../utils/formatacao'
import { onlyDigits } from '../../lib/cpf'
import { usePermissions } from '../../hooks/usePermissions'
import type { Cliente, ClienteFilters } from '../../types/cliente'

interface ClienteTableProps {
  clientes: Cliente[]
  loading: boolean
  onEdit: (cliente: Cliente) => void
  onDelete: (id: string) => void
  onView: (cliente: Cliente) => void
  onToggleStatus: (id: string, ativo: boolean) => void
  onFiltersChange: (filters: ClienteFilters) => void
}

export function ClienteTable({
  clientes,
  loading,
  onEdit,
  onDelete,
  onView,
  onToggleStatus,
  onFiltersChange
}: ClienteTableProps) {
  const { can } = usePermissions()
  
  const [filtros, setFiltros] = useState<ClienteFilters>({
    search: '',
    searchType: 'geral',
    ativo: true, // Mostrar apenas clientes ativos por padrão
    tipo: null
  })
  const [showFilters, setShowFilters] = useState(false)

  const handleSearchTypeChange = (newSearchType: NonNullable<ClienteFilters['searchType']>) => {
    console.log('🎯 [CLIENTE TABLE] Mudando tipo de busca para:', newSearchType)
    const novosFiltros = { ...filtros, searchType: newSearchType }
    setFiltros(novosFiltros)
    
    // Se há busca ativa, reprocessar com o novo tipo
    if (filtros.search && filtros.search.trim() !== '') {
      onFiltersChange(novosFiltros)
    }
  }

  const handleSearchChange = (value: string) => {
    console.log('🔍 [CLIENTE TABLE] handleSearchChange chamado com valor:', `"${value}"`)
    console.log('🎯 [CLIENTE TABLE] Tipo de busca selecionado:', filtros.searchType)
    
    // Aplicar formatação automática apenas se for busca geral (que inclui CPF/CNPJ)
    let formattedValue = value
    if (filtros.searchType === 'geral') {
      const digits = onlyDigits(value)
      // Se tem apenas dígitos ou formatação de CPF/CNPJ, aplicar formatação automática
      if (digits.length > 0 && /^[\d\.\-\/\s]*$/.test(value)) {
        formattedValue = formatarCpfCnpj(value)
        console.log('🎭 [CLIENTE TABLE] Aplicando formatação automática:', `"${value}" → "${formattedValue}"`)
      }
    }
    
    if (formattedValue.trim() === '') {
      // Se o campo está vazio, manter search vazio mas não remover da estrutura
      console.log('🧹 [CLIENTE TABLE] Campo vazio - definindo busca como vazia')
      const novosFiltros = { ...filtros, search: '' }
      console.log('📋 [CLIENTE TABLE] Novos filtros (busca vazia):', novosFiltros)
      setFiltros(novosFiltros)
      
      // Para o callback, remover search se estiver vazio para voltar ao modo limitado
      const { search, ...filtrosSemBusca } = novosFiltros
      onFiltersChange(filtrosSemBusca)
    } else {
      // Campo tem conteúdo, aplicar filtro normalmente
      const novosFiltros = { ...filtros, search: formattedValue }
      console.log('📋 [CLIENTE TABLE] Novos filtros (com busca):', novosFiltros)
      setFiltros(novosFiltros)
      onFiltersChange(novosFiltros)
    }
  }

  const handleFilterChange = (key: keyof ClienteFilters, value: string | boolean | null) => {
    const novosFiltros = { ...filtros, [key]: value }
    setFiltros(novosFiltros)
    onFiltersChange(novosFiltros)
  }

  const confirmarExclusao = (id: string, nome: string) => {
    if (window.confirm(`Tem certeza que deseja excluir o cliente "${nome}"?`)) {
      onDelete(id)
    }
  }

  const formatarTelefone = (telefone: string) => {
    if (!telefone) return ''
    const nums = telefone.replace(/\D/g, '')
    if (nums.length === 11) {
      return `(${nums.slice(0, 2)}) ${nums.slice(2, 7)}-${nums.slice(7)}`
    }
    return telefone
  }

  return (
    <div className="space-y-6">
      {/* Cabeçalho e Filtros */}
      <Card className="p-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Busca */}
          <div className="flex-1">
            {/* Seletor de Tipo de Busca */}
            <div className="flex flex-wrap gap-2 mb-3">
              <button
                onClick={() => handleSearchTypeChange('geral')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'geral'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Geral (Nome e CPF/CNPJ)
              </button>
              <button
                onClick={() => handleSearchTypeChange('telefone')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'telefone'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Telefone
              </button>
            </div>
            
            {/* Campo de Busca */}
            <div className="relative">
              <Input
                placeholder={
                  filtros.searchType === 'telefone' ? "Buscar por telefone..." :
                  "Buscar por nome ou CPF/CNPJ..."
                }
                value={filtros.search}
                onChange={(e) => handleSearchChange(e.target.value)}
                className="pl-10"
              />
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            </div>
          </div>

          {/* Botão de Filtros */}
          <Button
            variant="outline"
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center space-x-2"
          >
            <Filter className="w-4 h-4" />
            <span>Filtros</span>
          </Button>
        </div>

        {/* Filtros Expandidos */}
        {showFilters && (
          <div className="mt-4 pt-4 border-t border-gray-200">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Status
                </label>
                <select
                  value={filtros.ativo === null || filtros.ativo === undefined ? '' : filtros.ativo.toString()}
                  onChange={(e) => handleFilterChange('ativo', e.target.value === '' ? null : e.target.value === 'true')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                >
                  <option value="">Todos</option>
                  <option value="true">Ativos</option>
                  <option value="false">Inativos</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo
                </label>
                <select
                  value={filtros.tipo || ''}
                  onChange={(e) => handleFilterChange('tipo', e.target.value || null)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                >
                  <option value="">Todos</option>
                  <option value="Física">Pessoa Física</option>
                  <option value="Jurídica">Pessoa Jurídica</option>
                </select>
              </div>
            </div>
          </div>
        )}
      </Card>

      {/* Tabela */}
      <Card className="overflow-hidden">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-500 mx-auto"></div>
            <p className="mt-2 text-gray-600">Carregando clientes...</p>
          </div>
        ) : clientes.length === 0 ? (
          <div className="p-8 text-center">
            <User className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Nenhum cliente encontrado</h3>
            <p className="text-gray-600">
              {filtros.search || filtros.ativo !== null || filtros.tipo
                ? 'Tente ajustar os filtros de busca'
                : 'Comece cadastrando seu primeiro cliente'
              }
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contato
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Documento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {clientes.map((cliente) => (
                  <tr key={cliente.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className={`flex-shrink-0 flex items-center justify-center w-12 h-12 rounded-full ${
                          cliente.tipo === 'fisica' 
                            ? 'bg-blue-100 text-blue-600' 
                            : 'bg-purple-100 text-purple-600'
                        }`}>
                          {cliente.tipo === 'fisica' ? (
                            <User className="w-5 h-5" />
                          ) : (
                            <Building2 className="w-5 h-5" />
                          )}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {cliente.nome}
                          </div>
                          <div className="text-sm text-gray-500">
                            {cliente.tipo === 'fisica' ? 'Pessoa Física' : 'Pessoa Jurídica'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="space-y-1">
                        <div className="flex items-center text-sm">
                          <Phone className="w-4 h-4 mr-2 text-gray-400" />
                          <span className={cliente.telefone ? 'text-gray-900' : 'text-gray-400 italic'}>
                            {formatarTelefone(cliente.telefone) || 'Não informado'}
                          </span>
                        </div>
                        {cliente.email && (
                          <div className="flex items-center text-sm text-gray-500">
                            <Mail className="w-4 h-4 mr-2 text-gray-400" />
                            {cliente.email}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className={`text-sm ${cliente.cpf_cnpj ? 'text-gray-900' : 'text-gray-400 italic'}`}>
                        {cliente.cpf_cnpj || 'Não informado'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <button
                        onClick={() => onToggleStatus(cliente.id, !cliente.ativo)}
                        className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          cliente.ativo
                            ? 'bg-green-100 text-green-800 hover:bg-green-200'
                            : 'bg-red-100 text-red-800 hover:bg-red-200'
                        }`}
                      >
                        {cliente.ativo ? (
                          <>
                            <UserCheck className="w-3 h-3 mr-1" />
                            Ativo
                          </>
                        ) : (
                          <>
                            <UserX className="w-3 h-3 mr-1" />
                            Inativo
                          </>
                        )}
                      </button>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex items-center space-x-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => onView(cliente)}
                          className="text-gray-600 hover:text-gray-800"
                        >
                          <Eye className="w-4 h-4" />
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => onEdit(cliente)}
                          className="text-orange-600 hover:text-orange-800"
                        >
                          <Edit2 className="w-4 h-4" />
                        </Button>
                        {can('clientes', 'delete') && (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => confirmarExclusao(cliente.id, cliente.nome)}
                            className="text-red-600 hover:text-red-800"
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  )
}
