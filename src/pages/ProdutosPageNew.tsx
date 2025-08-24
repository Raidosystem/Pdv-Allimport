import React, { useState } from 'react'
import { Plus, Search, Filter, Edit, Trash2, Package, ShoppingCart, TrendingUp, AlertTriangle, CheckCircle } from 'lucide-react'
import type { Product } from '../types/product'
import { UNIDADES_MEDIDA } from '../types/product'

type ViewMode = 'list' | 'form'

export function ProdutosPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchTerm, setSearchTerm] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState<'ativo' | 'inativo' | ''>('')
  const [produtoEditando, setProdutoEditando] = useState<Product | null>(null)
  const [produtos, setProdutos] = useState<Product[]>([
    {
      id: '1',
      nome: 'Smartphone Samsung Galaxy A54',
      codigo: 'SAMS-A54-128',
      codigo_barras: '7891234567890',
      categoria: 'Smartphones',
      preco_venda: 1299.90,
      preco_custo: 899.90,
      estoque: 15,
      unidade: 'UN',
      descricao: 'Smartphone Samsung Galaxy A54 128GB, 6GB RAM, Tela 6.4", Câmera 50MP',
      fornecedor: 'Samsung Brasil',
      ativo: true,
      criado_em: '2024-01-15T08:00:00',
      atualizado_em: '2024-01-15T08:00:00'
    },
    {
      id: '2',
      nome: 'Fone Bluetooth JBL Tune 510BT',
      codigo: 'JBL-T510-BT',
      codigo_barras: '7891234567891',
      categoria: 'Áudio',
      preco_venda: 199.90,
      preco_custo: 129.90,
      estoque: 25,
      unidade: 'UN',
      descricao: 'Fone de ouvido Bluetooth JBL Tune 510BT com até 40h de bateria',
      fornecedor: 'JBL',
      ativo: true,
      criado_em: '2024-01-16T09:30:00',
      atualizado_em: '2024-01-16T09:30:00'
    },
    {
      id: '3',
      nome: 'Carregador USB-C 20W',
      codigo: 'CARR-USBC-20W',
      codigo_barras: '7891234567892',
      categoria: 'Acessórios',
      preco_venda: 29.90,
      preco_custo: 15.90,
      estoque: 50,
      unidade: 'UN',
      descricao: 'Carregador rápido USB-C 20W compatível com diversos dispositivos',
      fornecedor: 'Genérico',
      ativo: true,
      criado_em: '2024-01-17T10:15:00',
      atualizado_em: '2024-01-17T10:15:00'
    },
    {
      id: '4',
      nome: 'Capinha Silicone iPhone 14',
      codigo: 'CAPA-IP14-SIL',
      codigo_barras: '7891234567893',
      categoria: 'Capinhas',
      preco_venda: 39.90,
      preco_custo: 19.90,
      estoque: 8,
      unidade: 'UN',
      descricao: 'Capinha de silicone para iPhone 14 - Cores variadas',
      fornecedor: 'Acessórios Tech',
      ativo: true,
      criado_em: '2024-01-18T11:45:00',
      atualizado_em: '2024-01-18T11:45:00'
    },
    {
      id: '5',
      nome: 'Película Vidro Temperado',
      codigo: 'PEL-VIDRO-TEMP',
      codigo_barras: '7891234567894',
      categoria: 'Acessórios',
      preco_venda: 24.90,
      preco_custo: 12.90,
      estoque: 0,
      unidade: 'UN',
      descricao: 'Película de vidro temperado 9H - Universal',
      fornecedor: 'ProTech',
      ativo: false,
      criado_em: '2024-01-19T14:20:00',
      atualizado_em: '2024-01-19T14:20:00'
    }
  ])
  const [loading, setLoading] = useState(false)

  // Categorias disponíveis
  const categorias = ['Smartphones', 'Áudio', 'Acessórios', 'Capinhas', 'Carregadores', 'Tablets', 'Smartwatch']

  // Filtrar produtos
  const produtosFiltrados = produtos.filter((produto) => {
    const matchesSearch = produto.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         produto.codigo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (produto.codigo_barras && produto.codigo_barras.includes(searchTerm))
    
    const matchesCategory = !categoryFilter || produto.categoria === categoryFilter
    const matchesStatus = !statusFilter || (statusFilter === 'ativo' ? produto.ativo : !produto.ativo)
    
    return matchesSearch && matchesCategory && matchesStatus
  })

  // Estatísticas
  const stats = {
    total: produtos.length,
    ativos: produtos.filter(p => p.ativo).length,
    inativos: produtos.filter(p => !p.ativo).length,
    estoqueZero: produtos.filter(p => p.estoque === 0).length,
    estoqueTotal: produtos.reduce((acc, p) => acc + p.estoque, 0),
    valorEstoque: produtos.reduce((acc, p) => acc + (p.preco_custo || 0) * p.estoque, 0)
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const handleSubmitProduto = async (data: any) => {
    try {
      setLoading(true)
      
      if (produtoEditando) {
        // Atualizar produto existente
        const produtoAtualizado = {
          ...produtoEditando,
          ...data,
          atualizado_em: new Date().toISOString()
        }
        setProdutos(prev => prev.map(p => p.id === produtoEditando.id ? produtoAtualizado : p))
        setProdutoEditando(null)
      } else {
        // Criar novo produto
        const novoProduto: Product = {
          id: Date.now().toString(),
          ...data,
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString()
        }
        setProdutos(prev => [novoProduto, ...prev])
      }
      
      setViewMode('list')
    } catch (error) {
      console.error('Erro ao salvar produto:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleEdit = (produto: Product) => {
    setProdutoEditando(produto)
    setViewMode('form')
  }

  const handleDelete = async (id: string) => {
    if (confirm('Tem certeza que deseja excluir este produto?')) {
      try {
        setProdutos(prev => prev.filter(p => p.id !== id))
      } catch (error) {
        console.error('Erro ao deletar produto:', error)
      }
    }
  }

  const handleNewProduct = () => {
    setProdutoEditando(null)
    setViewMode('form')
  }

  const toggleStatus = (produto: Product) => {
    const produtoAtualizado = {
      ...produto,
      ativo: !produto.ativo,
      atualizado_em: new Date().toISOString()
    }
    setProdutos(prev => prev.map(p => p.id === produto.id ? produtoAtualizado : p))
  }

  // Card de Estatística
  const StatCard = ({ title, value, icon: Icon, color, subtitle }: {
    title: string
    value: string | number
    icon: React.ComponentType<any>
    color: string
    subtitle?: string
  }) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <Icon className="h-6 w-6 text-gray-600" />
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">
              {title}
            </dt>
            <dd className="text-lg font-medium text-gray-900">
              {typeof value === 'number' && title.includes('Valor') ? formatCurrency(value) : value}
            </dd>
            {subtitle && (
              <dd className="text-xs text-gray-500">{subtitle}</dd>
            )}
          </dl>
        </div>
      </div>
    </div>
  )

  // Formulário de Produto
  const ProductForm = () => {
    const [formData, setFormData] = useState({
      nome: produtoEditando?.nome || '',
      codigo: produtoEditando?.codigo || '',
      codigo_barras: produtoEditando?.codigo_barras || '',
      categoria: produtoEditando?.categoria || '',
      preco_venda: produtoEditando?.preco_venda || 0,
      preco_custo: produtoEditando?.preco_custo || 0,
      estoque: produtoEditando?.estoque || 0,
      unidade: produtoEditando?.unidade || 'UN',
      descricao: produtoEditando?.descricao || '',
      fornecedor: produtoEditando?.fornecedor || '',
      ativo: produtoEditando?.ativo ?? true
    })

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault()
      handleSubmitProduto(formData)
    }

    return (
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">
            {produtoEditando ? 'Editar Produto' : 'Novo Produto'}
          </h2>
          <button
            onClick={() => setViewMode('list')}
            className="text-gray-500 hover:text-gray-700"
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome do Produto *
              </label>
              <input
                type="text"
                required
                value={formData.nome}
                onChange={(e) => setFormData(prev => ({ ...prev, nome: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Nome do produto"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Código *
              </label>
              <input
                type="text"
                required
                value={formData.codigo}
                onChange={(e) => setFormData(prev => ({ ...prev, codigo: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Código interno"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Código de Barras
              </label>
              <input
                type="text"
                value={formData.codigo_barras}
                onChange={(e) => setFormData(prev => ({ ...prev, codigo_barras: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="EAN/UPC"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Categoria *
              </label>
              <select
                required
                value={formData.categoria}
                onChange={(e) => setFormData(prev => ({ ...prev, categoria: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Selecione uma categoria</option>
                {categorias.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Unidade *
              </label>
              <select
                required
                value={formData.unidade}
                onChange={(e) => setFormData(prev => ({ ...prev, unidade: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                {UNIDADES_MEDIDA.map(unidade => (
                  <option key={unidade.value} value={unidade.value}>
                    {unidade.label} ({unidade.value})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Preço de Custo
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                value={formData.preco_custo}
                onChange={(e) => setFormData(prev => ({ ...prev, preco_custo: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="0,00"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Preço de Venda *
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                required
                value={formData.preco_venda}
                onChange={(e) => setFormData(prev => ({ ...prev, preco_venda: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="0,00"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Estoque Inicial
              </label>
              <input
                type="number"
                min="0"
                value={formData.estoque}
                onChange={(e) => setFormData(prev => ({ ...prev, estoque: parseInt(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Fornecedor
              </label>
              <input
                type="text"
                value={formData.fornecedor}
                onChange={(e) => setFormData(prev => ({ ...prev, fornecedor: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Nome do fornecedor"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Descrição
              </label>
              <textarea
                rows={3}
                value={formData.descricao}
                onChange={(e) => setFormData(prev => ({ ...prev, descricao: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Descrição detalhada do produto"
              />
            </div>

            <div className="md:col-span-2">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.ativo}
                  onChange={(e) => setFormData(prev => ({ ...prev, ativo: e.target.checked }))}
                  className="mr-2"
                />
                <span className="text-sm font-medium text-gray-700">Produto ativo</span>
              </label>
            </div>
          </div>

          <div className="flex gap-3">
            <button
              type="submit"
              disabled={loading}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
            >
              {loading ? (
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
              ) : (
                <Plus className="h-4 w-4" />
              )}
              {produtoEditando ? 'Atualizar' : 'Cadastrar'} Produto
            </button>
            <button
              type="button"
              onClick={() => setViewMode('list')}
              className="bg-gray-200 text-gray-800 px-6 py-2 rounded-lg hover:bg-gray-300"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    )
  }

  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-4xl mx-auto">
          <ProductForm />
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Gestão de Produtos</h1>
            <p className="text-gray-600 mt-1">
              Gerencie seu catálogo de produtos e controle de estoque
            </p>
          </div>
          
          <button
            onClick={handleNewProduct}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2 self-start sm:self-auto"
          >
            <Plus className="h-5 w-5" />
            Novo Produto
          </button>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          <StatCard 
            title="Total de Produtos" 
            value={stats.total} 
            icon={Package} 
            color="border-blue-500" 
          />
          <StatCard 
            title="Produtos Ativos" 
            value={stats.ativos} 
            icon={CheckCircle} 
            color="border-green-500" 
          />
          <StatCard 
            title="Produtos Inativos" 
            value={stats.inativos} 
            icon={AlertTriangle} 
            color="border-red-500" 
          />
          <StatCard 
            title="Sem Estoque" 
            value={stats.estoqueZero} 
            icon={AlertTriangle} 
            color="border-orange-500" 
          />
          <StatCard 
            title="Estoque Total" 
            value={stats.estoqueTotal} 
            icon={TrendingUp} 
            color="border-purple-500"
            subtitle="unidades"
          />
          <StatCard 
            title="Valor do Estoque" 
            value={stats.valorEstoque} 
            icon={ShoppingCart} 
            color="border-indigo-500" 
          />
        </div>

        {/* Filtros */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por nome, código ou código de barras..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div className="relative">
              <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <select
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
                className="pl-10 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
              >
                <option value="">Todas as categorias</option>
                {categorias.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            <div className="relative">
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as 'ativo' | 'inativo' | '')}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
              >
                <option value="">Todos os status</option>
                <option value="ativo">Ativos</option>
                <option value="inativo">Inativos</option>
              </select>
            </div>
          </div>
        </div>

        {/* Tabela de Produtos */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
              <p className="text-gray-600">Carregando produtos...</p>
            </div>
          ) : produtosFiltrados.length === 0 ? (
            <div className="p-8 text-center">
              <Package className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600 text-lg">
                {searchTerm || categoryFilter || statusFilter
                  ? 'Nenhum produto encontrado com os filtros aplicados'
                  : 'Nenhum produto cadastrado'
                }
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Produto</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Categoria</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Preços</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Estoque</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                    <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {produtosFiltrados.map((produto) => (
                    <tr key={produto.id} className="hover:bg-gray-50">
                      <td className="py-3 px-4">
                        <div>
                          <div className="font-medium text-gray-900">
                            {produto.nome}
                          </div>
                          <div className="text-sm text-gray-500">
                            Código: {produto.codigo}
                            {produto.codigo_barras && ` | EAN: ${produto.codigo_barras}`}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                          {produto.categoria}
                        </span>
                      </td>
                      <td className="py-3 px-4">
                        <div className="text-sm">
                          <div className="text-gray-900 font-medium">
                            Venda: {formatCurrency(produto.preco_venda)}
                          </div>
                          {produto.preco_custo && (
                            <div className="text-gray-500">
                              Custo: {formatCurrency(produto.preco_custo)}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-1">
                          <span className={`font-medium ${
                            produto.estoque === 0 ? 'text-red-600' : 
                            produto.estoque < 10 ? 'text-orange-600' : 'text-green-600'
                          }`}>
                            {produto.estoque}
                          </span>
                          <span className="text-sm text-gray-500">{produto.unidade}</span>
                        </div>
                        {produto.estoque === 0 && (
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded-full text-xs bg-red-100 text-red-800 mt-1">
                            Sem estoque
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4">
                        <button
                          onClick={() => toggleStatus(produto)}
                          className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${
                            produto.ativo
                              ? 'bg-green-100 text-green-800 border-green-200 hover:bg-green-200'
                              : 'bg-red-100 text-red-800 border-red-200 hover:bg-red-200'
                          }`}
                        >
                          {produto.ativo ? (
                            <>
                              <CheckCircle className="h-3 w-3 mr-1" />
                              Ativo
                            </>
                          ) : (
                            <>
                              <AlertTriangle className="h-3 w-3 mr-1" />
                              Inativo
                            </>
                          )}
                        </button>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleEdit(produto)}
                            className="p-1 text-blue-600 hover:text-blue-800"
                            title="Editar"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(produto.id!)}
                            className="p-1 text-red-600 hover:text-red-800"
                            title="Excluir"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
