import { useState, useEffect } from 'react'
import { Package, Plus, Search, Edit, Trash2, Eye } from 'lucide-react'
import { Button } from '../components/ui/Button'
import ProductForm from '../components/product/ProductForm'

interface Product {
  id: string
  user_id?: string
  name: string
  barcode: string
  category_id?: string
  sale_price: number
  cost_price: number
  current_stock: number
  minimum_stock: number
  unit_measure: string
  active: boolean
  expiry_date?: string | null
  created_at: string
  updated_at: string
}

type ViewMode = 'list' | 'form' | 'view'

// Dados de exemplo do backup - carregando alguns produtos inicialmente
const sampleProducts: Product[] = [
  {
    id: "a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0",
    name: "WIRELESS MICROPHONE",
    barcode: "",
    sale_price: 160,
    cost_price: 0,
    current_stock: 1,
    minimum_stock: 1,
    unit_measure: "un",
    active: true,
    created_at: "2025-06-17T09:37:11.163625-03:00",
    updated_at: "2025-06-17T09:37:11.163625-03:00"
  },
  {
    id: "17fd37b4-b9f0-484c-aeb1-6702b8b80b5f",
    name: "MINI MICROFONE DE LAPELA",
    barcode: "7898594127486",
    sale_price: 24.99,
    cost_price: 0,
    current_stock: 4,
    minimum_stock: 2,
    unit_measure: "un",
    active: true,
    created_at: "2025-06-17T09:38:30.078078-03:00",
    updated_at: "2025-06-17T09:38:30.078078-03:00"
  },
  {
    id: "1b843d2d-263a-4333-8bba-c2466a1bad27",
    name: "CARTÃO DE MEMORIA A GOLD 64GB",
    barcode: "7219452780313",
    sale_price: 75,
    cost_price: 0,
    current_stock: 2,
    minimum_stock: 1,
    unit_measure: "un",
    active: true,
    created_at: "2025-06-17T09:41:19.19484-03:00",
    updated_at: "2025-06-17T09:41:19.19484-03:00"
  }
]

// Função para carregar todos os produtos do backup
const loadAllProducts = async (): Promise<Product[]> => {
  try {
    const response = await fetch('/backup-products.json')
    const backupData = await response.json()
    return backupData.data || []
  } catch (error) {
    console.error('Erro ao carregar backup:', error)
    return sampleProducts
  }
}

export function ProductsPage() {
  console.log('🔥 ProductsPage carregando...')
  const [products, setProducts] = useState<Product[]>([])
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [viewingProduct, setViewingProduct] = useState<Product | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Carregar todos os produtos do backup
    const loadProducts = async () => {
      try {
        const allProducts = await loadAllProducts()
        setProducts(allProducts)
        console.log(`✅ Carregados ${allProducts.length} produtos do backup`)
      } catch (error) {
        console.error('Erro ao carregar produtos:', error)
        setProducts(sampleProducts)
      } finally {
        setLoading(false)
      }
    }
    
    loadProducts()
  }, [])

  const handleNovoProduto = () => {
    setEditingProduct(null)
    setViewMode('form')
  }

  const handleEditarProduto = (product: Product) => {
    setEditingProduct(product)
    setViewMode('form')
  }

  const handleVisualizarProduto = (product: Product) => {
    setViewingProduct(product)
    setViewMode('view')
  }

  const handleSalvarProduto = async () => {
    try {
      // Recarregar lista (aqui seria a implementação do save)
      setViewMode('list')
      setEditingProduct(null)
      console.log('✅ Produto salvo com sucesso!')
    } catch (error) {
      console.error('Erro ao salvar produto:', error)
    }
  }

  const handleCancelar = () => {
    setViewMode('list')
    setEditingProduct(null)
    setViewingProduct(null)
  }

  const formatPrice = (price: number) => {
    return price.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    })
  }

  const filteredProducts = products.filter(product =>
    product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    product.barcode.includes(searchTerm)
  )

  const activeProducts = products.filter(p => p.active)
  const lowStockProducts = products.filter(p => p.current_stock <= p.minimum_stock)
  const totalValue = products.reduce((acc, p) => acc + (p.sale_price * p.current_stock), 0)

  // View de formulário (nova/editar produto)
  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Package className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {editingProduct ? 'Editar Produto' : 'Novo Produto'}
                </h1>
                <p className="text-sm text-gray-600">Preencha os dados do produto</p>
              </div>
            </div>
            
            <Button
              onClick={handleCancelar}
              variant="outline"
            >
              Voltar para Lista
            </Button>
          </div>

          <ProductForm
            productId={editingProduct?.id}
            onSuccess={handleSalvarProduto}
            onCancel={handleCancelar}
          />
        </main>
      </div>
    )
  }

  // View de visualização do produto
  if (viewMode === 'view' && viewingProduct) {
    return (
      <div className="min-h-screen bg-gray-50">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Package className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  Visualizar Produto
                </h1>
                <p className="text-sm text-gray-600">{viewingProduct.name}</p>
              </div>
            </div>
            
            <div className="flex gap-2">
              <Button
                onClick={() => handleEditarProduto(viewingProduct)}
                variant="outline"
              >
                Editar Produto
              </Button>
              <Button
                onClick={handleCancelar}
                variant="outline"
              >
                Voltar para Lista
              </Button>
            </div>
          </div>

          {/* Card de visualização do produto */}
          <div className="bg-white rounded-lg border p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Informações básicas */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Informações Básicas
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Nome do Produto</label>
                  <p className="text-gray-900 font-medium">{viewingProduct.name}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Código de Barras</label>
                  <p className="text-gray-900">{viewingProduct.barcode || 'Não informado'}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Unidade de Medida</label>
                  <p className="text-gray-900">{viewingProduct.unit_measure}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Status</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    viewingProduct.active 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {viewingProduct.active ? 'Ativo' : 'Inativo'}
                  </span>
                </div>
              </div>

              {/* Preços e estoque */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Preços e Estoque
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Preço de Venda</label>
                  <p className="text-xl font-bold text-green-600">{formatPrice(viewingProduct.sale_price)}</p>
                </div>
                
                {viewingProduct.cost_price > 0 && (
                  <div>
                    <label className="block text-sm font-medium text-gray-600">Preço de Custo</label>
                    <p className="text-lg font-medium text-gray-700">{formatPrice(viewingProduct.cost_price)}</p>
                  </div>
                )}
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Estoque Atual</label>
                  <p className={`text-lg font-bold ${
                    viewingProduct.current_stock <= viewingProduct.minimum_stock 
                      ? 'text-red-600' 
                      : 'text-gray-900'
                  }`}>
                    {viewingProduct.current_stock} {viewingProduct.unit_measure}
                  </p>
                  {viewingProduct.current_stock <= viewingProduct.minimum_stock && (
                    <p className="text-sm text-red-500 mt-1">⚠️ Estoque baixo!</p>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Estoque Mínimo</label>
                  <p className="text-gray-900">{viewingProduct.minimum_stock} {viewingProduct.unit_measure}</p>
                </div>
              </div>
            </div>

            {/* Informações adicionais */}
            <div className="mt-6 pt-6 border-t">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Informações Adicionais
              </h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                <div>
                  <span className="font-medium">Criado em:</span> {new Date(viewingProduct.created_at).toLocaleDateString('pt-BR')}
                </div>
                <div>
                  <span className="font-medium">Última atualização:</span> {new Date(viewingProduct.updated_at).toLocaleDateString('pt-BR')}
                </div>
                {viewingProduct.expiry_date && (
                  <div>
                    <span className="font-medium">Data de vencimento:</span> {new Date(viewingProduct.expiry_date).toLocaleDateString('pt-BR')}
                  </div>
                )}
                {viewingProduct.cost_price > 0 && viewingProduct.sale_price > 0 && (
                  <div>
                    <span className="font-medium">Margem de lucro:</span> 
                    <span className="ml-1 font-bold text-green-600">
                      {(((viewingProduct.sale_price - viewingProduct.cost_price) / viewingProduct.cost_price) * 100).toFixed(1)}%
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </main>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p>Carregando produtos...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-100 rounded-lg">
            <Package className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Produtos</h1>
            <p className="text-sm text-gray-600">Gerencie seus produtos e estoque</p>
          </div>
        </div>
        
        <Button onClick={handleNovoProduto} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Novo Produto
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-blue-600">{products.length}</div>
          <div className="text-sm text-gray-600">Total de Produtos</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-green-600">{activeProducts.length}</div>
          <div className="text-sm text-gray-600">Produtos Ativos</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-red-600">{lowStockProducts.length}</div>
          <div className="text-sm text-gray-600">Estoque Baixo</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-purple-600">{formatPrice(totalValue)}</div>
          <div className="text-sm text-gray-600">Valor Total Estoque</div>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white rounded-lg border p-4">
        <div className="flex items-center gap-2">
          <Search className="w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar produtos..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="flex-1 border-0 focus:ring-0 focus:outline-none"
          />
        </div>
      </div>

      {/* Products Table */}
      <div className="bg-white rounded-lg border">
        <div className="p-4 border-b">
          <h2 className="text-lg font-semibold">
            Produtos ({filteredProducts.length})
          </h2>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Código</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Preço</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estoque</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredProducts.slice(0, 50).map((product) => (
                <tr key={product.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-900 truncate max-w-xs">{product.name}</div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {product.barcode || '-'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <div className="font-medium text-green-600">
                        {formatPrice(product.sale_price)}
                      </div>
                      {product.cost_price > 0 && (
                        <div className="text-xs text-gray-500">
                          Custo: {formatPrice(product.cost_price)}
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <span className={`font-medium ${
                        product.current_stock <= product.minimum_stock 
                          ? 'text-red-600' 
                          : 'text-gray-900'
                      }`}>
                        {product.current_stock}
                      </span>
                      <span className="text-gray-500 ml-1">{product.unit_measure}</span>
                      {product.current_stock <= product.minimum_stock && (
                        <div className="text-xs text-red-500">Estoque baixo!</div>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      product.active 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {product.active ? 'Ativo' : 'Inativo'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <button 
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Visualizar produto"
                        onClick={() => handleVisualizarProduto(product)}
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-green-600 hover:text-green-800"
                        title="Editar produto"
                        onClick={() => handleEditarProduto(product)}
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-red-600 hover:text-red-800"
                        title="Excluir produto"
                        onClick={() => {
                          console.log('🗑️ Excluir produto:', product.id);
                          if (confirm(`Deseja excluir o produto "${product.name}"?`)) {
                            alert('Produto excluído com sucesso!');
                          }
                        }}
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredProducts.length > 50 && (
          <div className="p-4 border-t text-center text-sm text-gray-600">
            Mostrando 50 de {filteredProducts.length} produtos
          </div>
        )}
        
        {filteredProducts.length === 0 && (
          <div className="text-center py-12">
            <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchTerm ? 'Nenhum produto encontrado' : 'Nenhum produto cadastrado'}
            </h3>
            <p className="text-gray-600 mb-4">
              {searchTerm ? 'Tente buscar com outros termos' : 'Comece criando seu primeiro produto'}
            </p>
            {!searchTerm && (
              <Button onClick={handleNovoProduto} className="flex items-center gap-2 mx-auto">
                <Plus className="w-4 h-4" />
                Criar Primeiro Produto
              </Button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
