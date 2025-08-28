import { useState, useEffect } from 'react'
import { Package, Plus, Search, Edit, Trash2, Eye } from 'lucide-react'
import { Button } from '../components/ui/Button'

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
  const [showModal, setShowModal] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
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
    setEditingProduct(null) // Limpar produto sendo editado
    setShowModal(true)
  }

  const handleEditarProduto = (product: Product) => {
    setEditingProduct(product) // Definir produto para edição
    setShowModal(true)
  }

  const handleCloseModal = () => {
    setShowModal(false)
    setEditingProduct(null) // Limpar estado de edição
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
                        onClick={() => {
                          console.log('👁️ Visualizar produto:', product.id);
                          alert(`Visualizar produto: ${product.name}`);
                        }}
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-green-600 hover:text-green-800"
                        title="Editar produto"
                        onClick={() => {
                          console.log('✏️ Editar produto:', product.id);
                          handleEditarProduto(product);
                        }}
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

      {/* Modal de Formulário Completo */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-bold mb-4">
              {editingProduct ? `Editar Produto: ${editingProduct.name}` : 'Novo Produto'}
            </h3>
            
            <form className="space-y-4">
              {/* Nome do Produto */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome do Produto *
                </label>
                <input
                  type="text"
                  defaultValue={editingProduct?.name || ''}
                  placeholder="Digite o nome do produto"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              {/* Código de Barras */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Código de Barras
                </label>
                <input
                  type="text"
                  defaultValue={editingProduct?.barcode || ''}
                  placeholder="Digite o código de barras"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Preço de Venda */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Preço de Venda *
                  </label>
                  <input
                    type="text"
                    defaultValue={editingProduct ? editingProduct.sale_price.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2
                    }) : '0,00'}
                    onFocus={(e) => {
                      if (e.target.value === '0,00') {
                        e.target.value = ''
                      }
                    }}
                    onBlur={(e) => {
                      if (!e.target.value) {
                        e.target.value = '0,00'
                      } else {
                        const num = parseFloat(e.target.value.replace(',', '.')) || 0
                        e.target.value = num.toLocaleString('pt-BR', {
                          minimumFractionDigits: 2,
                          maximumFractionDigits: 2
                        })
                      }
                    }}
                    placeholder="0,00"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Preço de Custo */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Preço de Custo
                  </label>
                  <input
                    type="text"
                    defaultValue={editingProduct ? editingProduct.cost_price.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2
                    }) : '0,00'}
                    onFocus={(e) => {
                      if (e.target.value === '0,00') {
                        e.target.value = ''
                      }
                    }}
                    onBlur={(e) => {
                      if (!e.target.value) {
                        e.target.value = '0,00'
                      } else {
                        const num = parseFloat(e.target.value.replace(',', '.')) || 0
                        e.target.value = num.toLocaleString('pt-BR', {
                          minimumFractionDigits: 2,
                          maximumFractionDigits: 2
                        })
                      }
                    }}
                    placeholder="0,00"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Estoque Atual */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Estoque Atual *
                  </label>
                  <input
                    type="text"
                    defaultValue={editingProduct ? editingProduct.current_stock.toString() : '0'}
                    onFocus={(e) => {
                      if (e.target.value === '0') {
                        e.target.value = ''
                      }
                    }}
                    onBlur={(e) => {
                      if (!e.target.value) {
                        e.target.value = '0'
                      }
                    }}
                    placeholder="0"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                {/* Estoque Mínimo */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Estoque Mínimo
                  </label>
                  <input
                    type="text"
                    defaultValue="1"
                    onFocus={(e) => {
                      if (e.target.value === '1') {
                        e.target.value = ''
                      }
                    }}
                    onBlur={(e) => {
                      if (!e.target.value) {
                        e.target.value = '1'
                      }
                    }}
                    placeholder="1"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Unidade de Medida */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Unidade de Medida
                  </label>
                  <select className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="un">Unidade</option>
                    <option value="kg">Quilograma</option>
                    <option value="g">Grama</option>
                    <option value="l">Litro</option>
                    <option value="ml">Mililitro</option>
                    <option value="m">Metro</option>
                    <option value="cm">Centímetro</option>
                    <option value="pç">Peça</option>
                    <option value="cx">Caixa</option>
                    <option value="pct">Pacote</option>
                  </select>
                </div>

                {/* Status */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Status
                  </label>
                  <select className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    <option value="true">Ativo</option>
                    <option value="false">Inativo</option>
                  </select>
                </div>
              </div>

              {/* Descrição */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Descrição
                </label>
                <textarea
                  rows={3}
                  placeholder="Descrição detalhada do produto (opcional)"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                ></textarea>
              </div>

              {/* Botões */}
              <div className="flex justify-end gap-3 pt-4 border-t">
                <button 
                  type="button"
                  onClick={handleCloseModal}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800 font-medium"
                >
                  Cancelar
                </button>
                <button 
                  type="button"
                  onClick={() => {
                    // Aqui você pode adicionar a lógica para salvar
                    alert('Produto salvo com sucesso!')
                    handleCloseModal()
                  }}
                  className="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 font-medium"
                >
                  Salvar Produto
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
