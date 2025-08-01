import { useState } from 'react'
import { Toaster } from 'react-hot-toast'
import { ProductSearch } from '../modules/sales/components/ProductSearch'
import { ProductModal } from '../components/product/ProductModal'
import type { Product } from '../types/sales'

export function SalesWithProductForm() {
  const [isProductModalOpen, setIsProductModalOpen] = useState(false)
  const [selectedProducts, setSelectedProducts] = useState<Product[]>([])

  const handleProductSelect = (product: Product) => {
    // Adicionar produto à lista de vendas
    setSelectedProducts(prev => [...prev, product])
    console.log('Produto selecionado:', product)
  }

  const handleBarcodeSearch = (barcode: string) => {
    console.log('Busca por código de barras:', barcode)
  }

  const handleCreateProduct = () => {
    setIsProductModalOpen(true)
  }

  const handleProductCreated = () => {
    // Recarregar produtos ou atualizar lista
    console.log('Novo produto criado!')
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4 space-y-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Sistema PDV - Vendas
          </h1>
          <p className="text-gray-600">
            Busque produtos existentes ou cadastre novos produtos
          </p>
        </div>

        {/* Componente de Busca de Produtos */}
        <div className="max-w-4xl mx-auto">
          <ProductSearch
            onProductSelect={handleProductSelect}
            onBarcodeSearch={handleBarcodeSearch}
            onCreateProduct={handleCreateProduct}
          />
        </div>

        {/* Lista de Produtos Selecionados */}
        {selectedProducts.length > 0 && (
          <div className="max-w-4xl mx-auto">
            <div className="bg-white rounded-xl shadow-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Produtos Selecionados ({selectedProducts.length})
              </h3>
              <div className="space-y-2">
                {selectedProducts.map((product, index) => (
                  <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                    <div>
                      <span className="font-medium">{product.name}</span>
                      <span className="text-sm text-gray-500 ml-2">SKU: {product.sku || 'N/A'}</span>
                    </div>
                    <div className="text-lg font-bold text-green-600">
                      R$ {product.price.toFixed(2)}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Modal de Cadastro de Produto */}
        <ProductModal
          isOpen={isProductModalOpen}
          onClose={() => setIsProductModalOpen(false)}
          onSuccess={handleProductCreated}
        />
      </div>

      {/* Toast Notifications */}
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: '#fff',
            color: '#374151',
            border: '1px solid #d1d5db',
            borderRadius: '0.75rem',
            fontSize: '14px',
            fontWeight: '500',
          },
          success: {
            iconTheme: {
              primary: '#059669',
              secondary: '#fff',
            },
          },
          error: {
            iconTheme: {
              primary: '#dc2626',
              secondary: '#fff',
            },
          },
        }}
      />
    </div>
  )
}
