import { useState, useRef, useEffect } from 'react'
import { Search, Plus, Package } from 'lucide-react'
import { Input } from '../../../components/ui/Input'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { useDebounce } from '../../../hooks/useSales'
import { productService } from '../../../services/sales'
import type { Product } from '../../../types/sales'
import { formatCurrency } from '../../../utils/format'

interface ProductSearchProps {
  onProductSelect: (product: Product, quantity?: number) => void
  onBarcodeSearch?: (barcode: string) => void
  onCreateProduct?: () => void
}

export function ProductSearch({ onProductSelect, onBarcodeSearch, onCreateProduct }: ProductSearchProps) {
  const [searchTerm, setSearchTerm] = useState('')
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [showResults, setShowResults] = useState(false)
  const [selectedIndex, setSelectedIndex] = useState(-1)
  const [productJustAdded, setProductJustAdded] = useState(false)
  
  const searchInputRef = useRef<HTMLInputElement>(null)
  const debouncedSearchTerm = useDebounce(searchTerm, 300)

  // Escutar evento de produto adicionado para limpar cache
  useEffect(() => {
    const handleProductAdded = () => {
      // Força nova busca se houver termo de busca ativo
      if (searchTerm.trim()) {
        setProducts([])
        setLoading(true)
      }
      
      // Mostrar feedback visual
      setProductJustAdded(true)
      setTimeout(() => setProductJustAdded(false), 3000)
    }

    window.addEventListener('productAdded', handleProductAdded)
    return () => window.removeEventListener('productAdded', handleProductAdded)
  }, [searchTerm])

  // Buscar produtos quando termo de busca mudar
  useEffect(() => {
    const searchProducts = async () => {
      if (!debouncedSearchTerm.trim()) {
        setProducts([])
        setShowResults(false)
        return
      }

      console.log('🔍 Buscando produtos para:', debouncedSearchTerm);
      console.log('🔍 Usando productService.search...');
      setLoading(true)
      try {
        // Se o termo é só números, busca por código de barras
        // Senão, busca por nome/descrição
        const isBarcode = /^\d+$/.test(debouncedSearchTerm.trim())
        
        const data = await productService.search({
          search: isBarcode ? '' : debouncedSearchTerm,
          barcode: isBarcode ? debouncedSearchTerm : ''
        })
        console.log('📦 Produtos encontrados:', data.length, data);
        console.log('📦 Primeiro produto (se houver):', data[0]);
        console.log('📦 Tipo de data:', typeof data, Array.isArray(data));
        
        setProducts(data)
        setShowResults(true)
        setSelectedIndex(-1)
        
        console.log('✅ Estado atualizado - showResults:', true, 'products.length:', data.length);
        
        // Se encontrou apenas 1 produto e o termo parece ser código de barras (só números), seleciona automaticamente
        if (data.length === 1 && /^\d+$/.test(debouncedSearchTerm.trim())) {
          console.log('🔍 Auto-selecionando produto por código de barras');
          onProductSelect(data[0])
          setSearchTerm('')
          setShowResults(false)
          onBarcodeSearch?.(debouncedSearchTerm)
          // Foca no campo para facilitar adicionar mais produtos
          setTimeout(() => searchInputRef.current?.focus(), 100)
        }
      } catch (error) {
        console.error('❌ Erro ao buscar produtos:', error)
        setProducts([])
      } finally {
        setLoading(false)
        console.log('🏁 Busca finalizada - loading:', false);
      }
    }

    searchProducts()
  }, [debouncedSearchTerm])

  // Navegação com teclado
  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (!showResults || products.length === 0) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        setSelectedIndex(prev => 
          prev < products.length - 1 ? prev + 1 : prev
        )
        break
      case 'ArrowUp':
        event.preventDefault()
        setSelectedIndex(prev => prev > 0 ? prev - 1 : -1)
        break
      case 'Enter':
        event.preventDefault()
        if (selectedIndex >= 0 && selectedIndex < products.length) {
          onProductSelect(products[selectedIndex])
          setSearchTerm('')
          setShowResults(false)
          setSelectedIndex(-1)
        }
        break
      case 'Escape':
        setShowResults(false)
        setSelectedIndex(-1)
        break
    }
  }

  // Selecionar produto
  const handleProductSelect = (product: Product) => {
    onProductSelect(product)
    setSearchTerm('')
    setShowResults(false)
    setSelectedIndex(-1)
    // Foca no campo de busca para facilitar adicionar mais produtos
    setTimeout(() => searchInputRef.current?.focus(), 100)
  }

  return (
    <Card className="p-6 bg-white border-0 shadow-lg">
      <div className="space-y-4">
        {/* Cabeçalho Simplificado */}
        <div className="flex items-center space-x-3 pb-4 border-b border-gray-200">
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
            <Search className="w-5 h-5 text-white" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900">Buscar Produto</h3>
        </div>

        {/* Feedback de produto adicionado */}
        {productJustAdded && (
          <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-green-500 rounded-full flex items-center justify-center">
                <span className="text-white text-xs">✓</span>
              </div>
              <span className="text-green-700 text-sm font-medium">
                Produto cadastrado com sucesso!
              </span>
            </div>
          </div>
        )}

        {/* Campo de Busca Simplificado */}
        <div>
          <div className="relative">
            <Input
              ref={searchInputRef}
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Digite código de barras, nome ou SKU..."
              data-search="unified"
              onKeyDown={handleKeyDown}
              className="h-11 text-base pl-11 pr-11 border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20"
            />
            <Search className="absolute left-3.5 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            {loading && (
              <div className="absolute right-3.5 top-1/2 transform -translate-y-1/2">
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-blue-500 border-t-transparent"></div>
              </div>
            )}
          </div>
          
          {/* Dica de busca e Botão lado a lado */}
          <div className="flex items-center justify-between mt-2">
            <p className="text-xs text-gray-500 ml-1">
              Busque por código de barras, nome ou SKU
            </p>
            
            {/* Botão Criar Produto */}
            {onCreateProduct && (
              <Button
                type="button"
                onClick={onCreateProduct}
                className="flex items-center gap-2 whitespace-nowrap"
              >
                <Plus className="w-4 h-4" />
                Criar Produto
              </Button>
            )}
          </div>
        </div>

        {/* Resultados da busca - Simplificado */}
        {showResults && (
          <div className="border border-gray-200 rounded-lg overflow-hidden bg-white">
            {(() => {
              console.log('🎯 Renderizando resultados - showResults:', showResults, 'loading:', loading, 'products.length:', products.length);
              return null;
            })()}
            {loading ? (
              <div className="p-6 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-500 border-t-transparent mx-auto mb-3"></div>
                <p className="text-gray-600 text-sm">Buscando...</p>
              </div>
            ) : products.length > 0 ? (
              <div className="max-h-80 overflow-y-auto">
                <div className="p-3 bg-blue-50 border-b border-blue-100">
                  <p className="text-sm font-medium text-blue-900">
                    {products.length} produto{products.length !== 1 ? 's' : ''} encontrado{products.length !== 1 ? 's' : ''}
                  </p>
                </div>
                <div className="divide-y divide-gray-200">
                  {products.map((product, index) => {
                    console.log(`🔍 Renderizando produto ${index}:`, product.name, product);
                    return (
                    <div
                      key={product.id}
                      onClick={() => handleProductSelect(product)}
                      className={`p-4 cursor-pointer transition-all duration-150 ${
                        index === selectedIndex
                          ? 'bg-blue-50 border-l-4 border-blue-500 shadow-sm'
                          : 'hover:bg-gray-50 hover:shadow-sm'
                      }`}
                    >
                      <div className="flex items-start justify-between gap-4">
                        {/* Informações do Produto */}
                        <div className="flex-1 min-w-0 space-y-2">
                          {/* Nome do Produto */}
                          <div className="flex items-start gap-2">
                            <Package className="w-5 h-5 text-blue-500 flex-shrink-0 mt-0.5" />
                            <div className="flex-1">
                              <h4 className="font-semibold text-gray-900 text-base leading-tight mb-1">
                                {product.name}
                              </h4>
                              {/* Badges de Informação */}
                              <div className="flex items-center gap-2 flex-wrap">
                                <span className="inline-flex items-center bg-blue-100 text-blue-800 px-2.5 py-1 rounded-md text-xs font-medium">
                                  SKU: {product.sku}
                                </span>
                                <span className={`inline-flex items-center px-2.5 py-1 rounded-md text-xs font-medium ${
                                  product.stock_quantity < 0
                                    ? 'bg-red-100 text-red-800'
                                    : product.stock_quantity === 0
                                    ? 'bg-orange-100 text-orange-800'
                                    : product.stock_quantity <= (product.min_stock || 0)
                                    ? 'bg-yellow-100 text-yellow-800'
                                    : product.stock_quantity < 10
                                    ? 'bg-yellow-100 text-yellow-800'
                                    : 'bg-green-100 text-green-800'
                                }`}>
                                  {product.stock_quantity < 0 && '⚠️ '}
                                  {product.stock_quantity === 0 && '⚠️ '}
                                  {product.stock_quantity > 0 && product.stock_quantity <= (product.min_stock || 0) && '⚠️ '}
                                  Estoque: {product.stock_quantity}
                                </span>
                              </div>
                            </div>
                          </div>
                        </div>

                        {/* Preço e Ação */}
                        <div className="flex flex-col items-end gap-2 flex-shrink-0">
                          <div className="text-right">
                            <div className="text-xs text-gray-500 mb-0.5">Preço</div>
                            <div className="text-xl font-bold text-blue-600">
                              {formatCurrency(product.price)}
                            </div>
                          </div>
                          <Button
                            size="sm"
                            onClick={(e) => {
                              e.stopPropagation()
                              handleProductSelect(product)
                            }}
                            className="bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white text-sm px-4 py-2 font-medium shadow-md"
                          >
                            + Adicionar
                          </Button>
                        </div>
                      </div>
                    </div>
                    );
                  })}
                </div>
              </div>
            ) : (
              <div className="p-6 text-center">
                <div className="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                  <Package className="w-6 h-6 text-gray-400" />
                </div>
                <p className="text-sm font-medium text-gray-600 mb-1">Nenhum produto encontrado</p>
                <p className="text-xs text-gray-500">Tente buscar com outros termos</p>
              </div>
            )}
          </div>
        )}

      </div>
    </Card>
  )
}
