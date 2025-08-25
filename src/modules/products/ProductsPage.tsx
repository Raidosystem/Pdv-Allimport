import { useState, useEffect } from 'react'
import { Package, Plus, Search } from 'lucide-react'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { Input } from '../../components/ui/Input'
import { ProductFormModal } from '../../components/product/ProductFormModal'
import type { Product } from '../../types/product'

export function ProductsPage() {
  const [showProductModal, setShowProductModal] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)

  // Debug logging
  console.log('🏪 [PRODUTOS] ProductsPage - showProductModal:', showProductModal)
  
  // TESTE FORÇADO - remover depois
  useEffect(() => {
    console.log('🧪 [PRODUTOS] Estado do modal mudou:', showProductModal)
  }, [showProductModal])

  // Dados de exemplo para teste
  const exampleProducts: Product[] = [
    {
      id: '1',
      nome: 'Produto Exemplo 1',
      codigo: 'PROD001',
      categoria: 'Eletrônicos',
      preco_venda: 299.90,
      estoque: 10,
      unidade: 'UN',
      ativo: true,
      descricao: 'Produto de exemplo para teste'
    },
    {
      id: '2',
      nome: 'Produto Exemplo 2',
      codigo: 'PROD002',
      categoria: 'Informática',
      preco_venda: 599.90,
      estoque: 5,
      unidade: 'UN',
      ativo: true,
      descricao: 'Outro produto de exemplo'
    }
  ]

  useEffect(() => {
    // Simular carregamento
    setLoading(true)
    setTimeout(() => {
      setProducts(exampleProducts)
      setLoading(false)
    }, 1000)
    
    console.log('🖥️ [PRODUTOS] useEffect - showProductModal:', showProductModal)
  }, [showProductModal])

  // Fechar modal
  const handleCloseModal = () => {
    console.log('🔄 Fechando modal de produto')
    setShowProductModal(false)
    setEditingProduct(null)
  }

  // Sucesso no modal
  const handleModalSuccess = () => {
    console.log('✅ Modal de produto - sucesso!')
    handleCloseModal()
    toast.success(editingProduct ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* TESTE DE VISIBILIDADE */}
      <div style={{backgroundColor: 'red', color: 'white', padding: '20px', fontSize: '24px', textAlign: 'center'}}>
        🚨 PÁGINA PRODUTOS CARREGOU - TESTE DE VISIBILIDADE 🚨
      </div>
      
      {/* Conteúdo Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        {/* Barra de ações */}
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-lg flex items-center justify-center">
              <Package className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-gray-900">Produtos</h1>
              <p className="text-sm text-gray-600">Controle de estoque e produtos</p>
            </div>
          </div>
          
          <Button
            onClick={() => {
              console.log('🚀 [PRODUTOS] Botão Novo Produto clicado!')
              console.log('🚀 [PRODUTOS] showProductModal ANTES:', showProductModal)
              setShowProductModal(true)
              console.log('🚀 [PRODUTOS] showProductModal DEPOIS: true')
            }}
            className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            Novo Produto
          </Button>
          
          {/* BOTÃO DE TESTE - REMOVER DEPOIS */}
          <Button
            onClick={() => {
              console.log('🧪 [TESTE] Forçando modal = true')
              setShowProductModal(true)
            }}
            className="bg-red-500 hover:bg-red-600 text-white ml-2"
          >
            TESTE Modal
          </Button>
        </div>
        
        {/* Barra de Busca */}
        <Card className="p-6 mb-8">
          <div className="relative">
            <Input
              type="text"
              placeholder="Buscar produtos por nome, código ou categoria..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
          </div>
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

        {/* Lista de Produtos Simplificada */}
        {loading ? (
          <Card className="p-12">
            <div className="flex flex-col items-center justify-center space-y-4">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500"></div>
              <p className="text-gray-600">Carregando produtos...</p>
            </div>
          </Card>
        ) : products.length === 0 ? (
          <Card className="p-12">
            <div className="text-center">
              <Package className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                Nenhum produto cadastrado
              </h3>
              <p className="text-gray-600 mb-6">
                Comece cadastrando seu primeiro produto
              </p>
              <Button
                onClick={() => setShowProductModal(true)}
                className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700"
              >
                <Plus className="w-4 h-4 mr-2" />
                Cadastrar Primeiro Produto
              </Button>
            </div>
          </Card>
        ) : (
          <Card className="overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Produto
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Código
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Categoria
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Preço
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Estoque
                    </th>
                    <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {products.map((product) => (
                    <tr key={product.id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                            <Package className="w-5 h-5 text-gray-400" />
                          </div>
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {product.nome}
                            </div>
                            {product.descricao && (
                              <div className="text-sm text-gray-500 truncate max-w-xs">
                                {product.descricao}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-mono text-gray-900">{product.codigo}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{product.categoria || '-'}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          R$ {product.preco_venda.toFixed(2)}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {product.estoque} {product.unidade}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                          product.ativo
                            ? 'bg-green-100 text-green-800'
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {product.ativo ? 'Ativo' : 'Inativo'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Card>
        )}
      </main>

      {/* Modal de Produto */}
      <ProductFormModal
        isOpen={showProductModal}
        onClose={handleCloseModal}
        onSuccess={handleModalSuccess}
        productId={editingProduct?.id}
      />
    </div>
  )
}
