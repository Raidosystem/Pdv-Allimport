import { useState, useEffect } from 'react'
import { Package, Plus, Search } from 'lucide-react'
import { Button } from '../components/ui/Button'
import { useProducts } from '../hooks/useProducts'

export function ProductsPageFixed() {
  const [searchTerm, setSearchTerm] = useState('')
  
  // Usando o hook correto que filtra por user_id
  const { products, loading, loadProducts } = useProducts()

  useEffect(() => {
    loadProducts()
  }, [])

  // Filtrar produtos localmente
  const filteredProducts = products.filter(product =>
    product.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (product.codigo && product.codigo.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (product.codigo_barras && product.codigo_barras.includes(searchTerm))
  )

  const formatPrice = (price: number | null | undefined) => {
    if (!price && price !== 0) return 'R$ 0,00'
    return Number(price).toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    })
  }

  if (loading) {
    return (
      <div className="p-6">
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Carregando produtos...</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="p-6">
      {/* Cabeçalho */}
      <div className="mb-6">
        <div className="flex justify-between items-center mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
              <Package className="h-6 w-6" />
              Produtos
            </h1>
            <p className="text-gray-600 mt-1">
              {products.length} produtos cadastrados (isolados por usuário)
            </p>
          </div>
          <Button variant="primary" className="flex items-center gap-2">
            <Plus className="h-4 w-4" />
            Novo Produto
          </Button>
        </div>

        {/* Barra de pesquisa */}
        <div className="flex gap-4 mb-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <input
              type="text"
              placeholder="Buscar produtos..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white p-4 rounded-lg border">
            <div className="text-sm font-medium text-gray-500">Total de Produtos</div>
            <div className="text-2xl font-bold text-gray-900">{products.length}</div>
          </div>
          <div className="bg-white p-4 rounded-lg border">
            <div className="text-sm font-medium text-gray-500">Produtos Ativos</div>
            <div className="text-2xl font-bold text-green-600">
              {products.filter(p => p.ativo).length}
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg border">
            <div className="text-sm font-medium text-gray-500">Estoque Baixo</div>
            <div className="text-2xl font-bold text-yellow-600">
              {products.filter(p => p.estoque <= 5).length}
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg border">
            <div className="text-sm font-medium text-gray-500">Valor Total</div>
            <div className="text-2xl font-bold text-blue-600">
              {formatPrice(products.reduce((acc, p) => acc + (p.preco * p.estoque), 0))}
            </div>
          </div>
        </div>
      </div>

      {/* Lista de produtos */}
      <div className="bg-white rounded-lg border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Produto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  SKU / Código
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Preço
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estoque
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredProducts.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-gray-500">
                    {searchTerm ? 'Nenhum produto encontrado' : 'Nenhum produto cadastrado'}
                  </td>
                </tr>
              ) : (
                filteredProducts.map((product) => (
                  <tr key={product.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="font-medium text-gray-900">{product.nome}</div>
                      {product.descricao && (
                        <div className="text-sm text-gray-500">{product.descricao}</div>
                      )}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div>{product.codigo || '-'}</div>
                      {product.codigo_barras && (
                        <div className="text-gray-500">{product.codigo_barras}</div>
                      )}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      {formatPrice(product.preco)}
                    </td>
                    <td className="px-6 py-4 text-sm">
                      <div className={`font-medium ${
                        product.estoque <= 5 
                          ? 'text-red-600' 
                          : 'text-gray-900'
                      }`}>
                        {product.estoque} {product.unidade}
                      </div>
                      {product.estoque <= 5 && (
                        <div className="text-xs text-red-500">Estoque baixo!</div>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        product.ativo
                          ? 'bg-green-100 text-green-800'
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {product.ativo ? 'Ativo' : 'Inativo'}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Informação sobre isolamento */}
      <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-center">
          <Package className="h-5 w-5 text-blue-600 mr-2" />
          <div className="text-sm">
            <span className="font-medium text-blue-800">Isolamento Ativo:</span>
            <span className="text-blue-600 ml-1">
              Produtos visíveis apenas para seu usuário (filtrado por user_id)
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
