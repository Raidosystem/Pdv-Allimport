import { useState, useEffect } from 'react'
import { Package, Plus, Download, Search, Filter, Grid, List } from 'lucide-react'
import { Link } from 'react-router-dom'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { Input } from '../../components/ui/Input'
import { ProductModal } from '../../components/product/ProductModal'
import { ProductList } from './components/ProductList'
import { ProductGrid } from './components/ProductGrid'
import { ProductFilters } from './components/ProductFilters'
import { useProducts } from '../../hooks/useProducts'
import { useAuth } from '../auth'
import type { Product } from '../../types/product'
import { generateProductsPDF } from '../../utils/pdfGenerator'

export function ProductsPage() {
  const { user } = useAuth()
  const { products, loading, loadProducts, deleteProduct } = useProducts()
  const [showProductModal, setShowProductModal] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid')
  const [showFilters, setShowFilters] = useState(false)
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([])
  
  // Filtros
  const [filters, setFilters] = useState({
    category: '',
    status: 'all',
    stockLevel: 'all',
    priceRange: { min: 0, max: 0 }
  })

  // Carregar produtos ao montar o componente
  useEffect(() => {
    loadProducts()
  }, [loadProducts])

  // Filtrar produtos baseado nos critérios
  useEffect(() => {
    let filtered = products

    // Filtro por termo de busca
    if (searchTerm.trim()) {
      const term = searchTerm.toLowerCase()
      filtered = filtered.filter((product: Product) => 
        product.nome.toLowerCase().includes(term) ||
        product.codigo.toLowerCase().includes(term) ||
        product.categoria?.toLowerCase().includes(term)
      )
    }

    // Filtro por categoria
    if (filters.category && filters.category !== 'all') {
      filtered = filtered.filter((product: Product) => product.categoria === filters.category)
    }

    // Filtro por status
    if (filters.status !== 'all') {
      filtered = filtered.filter((product: Product) => {
        if (filters.status === 'active') return product.ativo
        if (filters.status === 'inactive') return !product.ativo
        return true
      })
    }

    // Filtro por nível de estoque
    if (filters.stockLevel !== 'all') {
      filtered = filtered.filter((product: Product) => {
        if (filters.stockLevel === 'low') return product.estoque <= 5
        if (filters.stockLevel === 'out') return product.estoque === 0
        if (filters.stockLevel === 'normal') return product.estoque > 5
        return true
      })
    }

    // Filtro por faixa de preço
    if (filters.priceRange.min > 0 || filters.priceRange.max > 0) {
      filtered = filtered.filter((product: Product) => {
        const price = product.preco_venda
        const minOk = filters.priceRange.min === 0 || price >= filters.priceRange.min
        const maxOk = filters.priceRange.max === 0 || price <= filters.priceRange.max
        return minOk && maxOk
      })
    }

    setFilteredProducts(filtered)
  }, [products, searchTerm, filters])

  // Abrir modal para edição
  const handleEditProduct = (product: Product) => {
    setEditingProduct(product)
    setShowProductModal(true)
  }

  // Deletar produto
  const handleDeleteProduct = async (productId: string) => {
    if (!confirm('Tem certeza que deseja excluir este produto?')) return

    try {
      await deleteProduct(productId)
      toast.success('Produto excluído com sucesso!')
    } catch (error) {
      console.error('Erro ao excluir produto:', error)
      toast.error('Erro ao excluir produto')
    }
  }

  // Gerar PDF da lista de produtos
  const handleExportPDF = async () => {
    try {
      await generateProductsPDF(filteredProducts, {
        filters: {
          searchTerm,
          category: filters.category,
          status: filters.status,
          stockLevel: filters.stockLevel
        },
        generatedBy: user?.email || 'Sistema',
        generatedAt: new Date()
      })
      toast.success('PDF gerado com sucesso!')
    } catch (error) {
      console.error('Erro ao gerar PDF:', error)
      toast.error('Erro ao gerar PDF')
    }
  }

  // Fechar modal
  const handleCloseModal = () => {
    setShowProductModal(false)
    setEditingProduct(null)
  }

  // Sucesso no modal
  const handleModalSuccess = () => {
    handleCloseModal()
    loadProducts() // Recarregar produtos
    toast.success(editingProduct ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Header */}
      <header className="bg-white shadow-lg border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link 
                to="/dashboard" 
                className="flex items-center space-x-2 text-gray-600 hover:text-primary-600 transition-colors"
              >
                <span>← Dashboard</span>
              </Link>
              <div className="h-8 border-l border-gray-300"></div>
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-lg flex items-center justify-center">
                  <Package className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Produtos</h1>
                  <p className="text-sm text-gray-600">Controle de estoque e produtos</p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Button
                onClick={handleExportPDF}
                variant="outline"
                disabled={filteredProducts.length === 0}
                className="flex items-center space-x-2"
              >
                <Download className="w-4 h-4" />
                <span>Exportar PDF</span>
              </Button>
              <Button
                onClick={() => setShowProductModal(true)}
                className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700"
              >
                <Plus className="w-4 h-4 mr-2" />
                Novo Produto
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Barra de Ferramentas */}
        <Card className="p-6 mb-8">
          <div className="flex flex-col lg:flex-row gap-4">
            {/* Busca */}
            <div className="flex-1 relative">
              <Input
                type="text"
                placeholder="Buscar produtos por nome, SKU ou categoria..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            </div>

            {/* Controles */}
            <div className="flex items-center space-x-3">
              <Button
                variant={showFilters ? "primary" : "outline"}
                onClick={() => setShowFilters(!showFilters)}
                className="flex items-center space-x-2"
              >
                <Filter className="w-4 h-4" />
                <span>Filtros</span>
              </Button>

              <div className="flex border border-gray-200 rounded-lg overflow-hidden">
                <Button
                  variant={viewMode === 'grid' ? "primary" : "ghost"}
                  onClick={() => setViewMode('grid')}
                  className="rounded-none"
                  size="sm"
                >
                  <Grid className="w-4 h-4" />
                </Button>
                <Button
                  variant={viewMode === 'list' ? "primary" : "ghost"}
                  onClick={() => setViewMode('list')}
                  className="rounded-none"
                  size="sm"
                >
                  <List className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </div>

          {/* Filtros */}
          {showFilters && (
            <div className="mt-6 pt-6 border-t border-gray-200">
              <ProductFilters
                filters={filters}
                onFiltersChange={setFilters}
                products={products}
              />
            </div>
          )}
        </Card>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total de Produtos</p>
                <p className="text-2xl font-bold text-gray-900">{products.length}</p>
              </div>
              <Package className="w-8 h-8 text-primary-500" />
            </div>
          </Card>
          
          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Produtos Ativos</p>
                <p className="text-2xl font-bold text-green-600">
                  {products.filter((p: Product) => p.ativo).length}
                </p>
              </div>
              <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Estoque Baixo</p>
                <p className="text-2xl font-bold text-orange-600">
                  {products.filter((p: Product) => p.estoque <= 5).length}
                </p>
              </div>
              <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                <span className="text-orange-600 text-sm">⚠️</span>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Sem Estoque</p>
                <p className="text-2xl font-bold text-red-600">
                  {products.filter((p: Product) => p.estoque === 0).length}
                </p>
              </div>
              <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center">
                <span className="text-red-600 text-sm">❌</span>
              </div>
            </div>
          </Card>
        </div>

        {/* Lista/Grid de Produtos */}
        {loading ? (
          <Card className="p-12">
            <div className="flex flex-col items-center justify-center space-y-4">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500"></div>
              <p className="text-gray-600">Carregando produtos...</p>
            </div>
          </Card>
        ) : filteredProducts.length === 0 ? (
          <Card className="p-12">
            <div className="text-center">
              <Package className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                {products.length === 0 ? 'Nenhum produto cadastrado' : 'Nenhum produto encontrado'}
              </h3>
              <p className="text-gray-600 mb-6">
                {products.length === 0 
                  ? 'Comece cadastrando seu primeiro produto'
                  : 'Tente ajustar os filtros ou termo de busca'
                }
              </p>
              {products.length === 0 && (
                <Button
                  onClick={() => setShowProductModal(true)}
                  className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Cadastrar Primeiro Produto
                </Button>
              )}
            </div>
          </Card>
        ) : viewMode === 'grid' ? (
          <ProductGrid
            products={filteredProducts}
            onEdit={handleEditProduct}
            onDelete={handleDeleteProduct}
          />
        ) : (
          <ProductList
            products={filteredProducts}
            onEdit={handleEditProduct}
            onDelete={handleDeleteProduct}
          />
        )}
      </main>

      {/* Modal de Produto */}
      <ProductModal
        isOpen={showProductModal}
        onClose={handleCloseModal}
        onSuccess={handleModalSuccess}
        productId={editingProduct?.id}
      />
    </div>
  )
}
