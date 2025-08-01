import { useState, useRef, useEffect } from 'react'
import { Search, Barcode, Plus, Package } from 'lucide-react'
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
  const [barcode, setBarcode] = useState('')
  const [searchTerm, setSearchTerm] = useState('')
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [showResults, setShowResults] = useState(false)
  const [selectedIndex, setSelectedIndex] = useState(-1)
  
  const barcodeInputRef = useRef<HTMLInputElement>(null)
  const searchInputRef = useRef<HTMLInputElement>(null)
  const debouncedSearchTerm = useDebounce(searchTerm, 300)

  // Buscar produtos quando termo de busca mudar
  useEffect(() => {
    const searchProducts = async () => {
      if (!debouncedSearchTerm.trim()) {
        setProducts([])
        setShowResults(false)
        return
      }

      setLoading(true)
      try {
        const data = await productService.search({
          search: debouncedSearchTerm
        })
        setProducts(data)
        setShowResults(true)
        setSelectedIndex(-1)
      } catch (error) {
        console.error('Erro ao buscar produtos:', error)
        setProducts([])
      } finally {
        setLoading(false)
      }
    }

    searchProducts()
  }, [debouncedSearchTerm])

  // Buscar por código de barras ou nome
  const handleBarcodeSearch = async () => {
    if (!barcode.trim()) return

    setLoading(true)
    try {
      const data = await productService.search({ 
        barcode: barcode,
        search: barcode // Busca também por nome/SKU caso não seja código de barras
      })
      if (data.length > 0) {
        onProductSelect(data[0])
        setBarcode('')
        barcodeInputRef.current?.focus()
      } else {
        alert('Produto não encontrado!')
      }
      onBarcodeSearch?.(barcode)
    } catch (error) {
      console.error('Erro ao buscar produto:', error)
      alert('Erro ao buscar produto!')
    } finally {
      setLoading(false)
    }
  }

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
    searchInputRef.current?.focus()
  }

  return (
    <Card className="p-6 bg-white border-0 shadow-xl">
      <div className="space-y-6">
        {/* Cabeçalho Melhorado */}
        <div className="flex items-center justify-center space-x-4">
          <div className="w-14 h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl flex items-center justify-center shadow-lg">
            <Search className="w-7 h-7 text-white" />
          </div>
          <div className="text-center">
            <h3 className="text-xl font-bold text-secondary-900">Busque Produtos</h3>
          </div>
          <div className="w-14"></div>
        </div>

        {/* Busca por código de barras melhorada */}
        <div className="p-5 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border-2 border-blue-200 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
              <Barcode className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-sm text-blue-600">Codigo de barras ou Nome</p>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
            <div className="md:col-span-3">
              <Input
                ref={barcodeInputRef}
                type="text"
                value={barcode}
                onChange={(e) => setBarcode(e.target.value)}
                placeholder="Digite código de barras ou nome do produto..."
                data-search="barcode"
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault()
                    handleBarcodeSearch()
                  }
                }}
                className="h-12 text-base border-2 border-blue-200 focus:border-blue-500 focus:ring-blue-500/20"
                icon={<Barcode className="w-5 h-5" />}
              />
            </div>
            <Button
              onClick={handleBarcodeSearch}
              disabled={!barcode.trim() || loading}
              className="h-12 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 font-semibold shadow-lg transform hover:scale-105 transition-all"
            >
              {loading ? 'Buscando...' : 'Buscar'}
            </Button>
          </div>
        </div>

        {/* Busca por nome/SKU */}
        <div className="p-5 bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl border-2 border-green-200 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center">
              <Package className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-sm text-green-600">Buscar por nome ou código do produto</p>
            </div>
          </div>
          
          <div className="relative">
            <Input
              ref={searchInputRef}
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Digite o nome ou SKU do produto..."
              data-search="product"
              onKeyDown={handleKeyDown}
              className="h-12 text-base pl-12 pr-12 border-2 border-green-200 focus:border-green-500 focus:ring-green-500/20"
            />
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-green-400" />
            {loading && (
              <div className="absolute right-4 top-1/2 transform -translate-y-1/2">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-green-500"></div>
              </div>
            )}
          </div>
        </div>

        {/* Resultados da busca */}
        {showResults && (
          <div className="border-2 border-gray-200 rounded-xl shadow-xl overflow-hidden bg-white">
            {loading ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto mb-4"></div>
                <p className="text-gray-600 font-medium">Buscando produtos...</p>
              </div>
            ) : products.length > 0 ? (
              <div className="max-h-96 overflow-y-auto">
                <div className="p-4 bg-gradient-to-r from-primary-500 to-primary-600 text-white">
                  <h4 className="font-semibold text-lg">
                    {products.length} produto{products.length !== 1 ? 's' : ''} encontrado{products.length !== 1 ? 's' : ''}
                  </h4>
                </div>
                <div className="divide-y divide-gray-100">
                  {products.map((product, index) => (
                    <div
                      key={product.id}
                      onClick={() => handleProductSelect(product)}
                      className={`p-4 cursor-pointer transition-all duration-200 hover:bg-primary-50 ${
                        index === selectedIndex
                          ? 'bg-primary-100 border-l-4 border-primary-500 shadow-lg'
                          : 'hover:shadow-md'
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <div className="flex items-center space-x-3 mb-2">
                            <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-lg flex items-center justify-center shadow-md">
                              <Package className="w-5 h-5 text-white" />
                            </div>
                            <div className="flex-1">
                              <h4 className="font-semibold text-secondary-900 text-base">
                                {product.name}
                              </h4>
                              <div className="flex items-center space-x-4 mt-1">
                                <span className="text-sm bg-blue-100 text-blue-700 px-2 py-1 rounded-full font-medium">
                                  SKU: {product.sku}
                                </span>
                                <span className="text-sm text-gray-600">
                                  Estoque: {product.stock_quantity}
                                </span>
                                {product.stock_quantity <= (product.min_stock || 0) && (
                                  <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full font-medium">
                                    ⚠️ Estoque Baixo
                                  </span>
                                )}
                              </div>
                            </div>
                          </div>
                        </div>
                        <div className="text-right ml-4">
                          <div className="text-xl font-bold text-primary-600 mb-1">
                            {formatCurrency(product.price)}
                          </div>
                          <Button
                            size="sm"
                            onClick={(e) => {
                              e.stopPropagation()
                              handleProductSelect(product)
                            }}
                            className="bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-medium shadow-lg transform hover:scale-105 transition-all"
                          >
                            + Adicionar
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="p-8 text-center">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Package className="w-8 h-8 text-gray-400" />
                </div>
                <h4 className="text-lg font-medium text-gray-600 mb-2">Nenhum produto encontrado</h4>
                <p className="text-gray-500">Tente buscar com outros termos</p>
              </div>
            )}
          </div>
        )}

        {/* Botão Cadastrar Produto */}
        <div className="flex justify-center">
          <Button 
            onClick={() => {
              if (onCreateProduct) {
                onCreateProduct()
              } else {
                alert('Funcionalidade de cadastro de produto será implementada')
              }
            }}
            className="w-full max-w-sm h-12 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-semibold shadow-lg transform hover:scale-105 transition-all"
          >
            <Plus className="w-5 h-5 mr-2" />
            Cadastrar Novo Produto
          </Button>
        </div>
      </div>
    </Card>
  )
}
