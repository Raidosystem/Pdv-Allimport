import { useState, useRef } from 'react'
import { Search, Barcode } from 'lucide-react'
import { Input } from '../../../components/ui/Input'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { productService } from '../../../services/salesNew'
import type { Product } from '../../../types/sales'

interface ProductSearchProps {
  onProductSelect: (product: Product, quantity?: number) => void
  onBarcodeSearch?: (barcode: string) => void
}

export function ProductSearch({ onProductSelect, onBarcodeSearch }: ProductSearchProps) {
  const [barcode, setBarcode] = useState('')
  const [loading, setLoading] = useState(false)
  
  const barcodeInputRef = useRef<HTMLInputElement>(null)

  // Buscar por código de barras
  const handleBarcodeSearch = async () => {
    if (!barcode.trim()) return

    setLoading(true)
    try {
      const data = await productService.search({ barcode })
      if (data.length > 0) {
        onProductSelect(data[0])
        setBarcode('')
        barcodeInputRef.current?.focus()
      } else {
        alert('Produto não encontrado!')
      }
      onBarcodeSearch?.(barcode)
    } catch (error) {
      console.error('Erro ao buscar por código de barras:', error)
      alert('Erro ao buscar produto!')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="p-6 bg-white border-0 shadow-xl">
      <div className="space-y-6">
        {/* Cabeçalho Melhorado */}
        <div className="flex items-center space-x-4">
          <div className="w-14 h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl flex items-center justify-center shadow-lg">
            <Search className="w-7 h-7 text-white" />
          </div>
          <div className="flex-1">
            <h3 className="text-xl font-bold text-secondary-900">Busque Produtos</h3>
          </div>
          <div className="text-right">
            <div className="text-2xl font-bold text-primary-600">0</div>
            <div className="text-sm text-gray-500">produtos encontrados</div>
          </div>
        </div>

        {/* Busca por código de barras melhorada */}
        <div className="p-5 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border-2 border-blue-200 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
              <Barcode className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="text-lg font-semibold text-blue-800">Código de Barras</span>
              <p className="text-sm text-blue-600">Escaneie ou digite o código</p>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
            <div className="md:col-span-3">
              <Input
                ref={barcodeInputRef}
                type="text"
                value={barcode}
                onChange={(e) => setBarcode(e.target.value)}
                placeholder="Escaneie ou digite o código de barras..."
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
      </div>
    </Card>
  )
}
