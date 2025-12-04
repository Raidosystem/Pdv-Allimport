import { useState } from 'react'
import { ShoppingCart, Plus, Minus, X, Edit3, Percent } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { Input } from '../../../components/ui/Input'
import type { CartItem } from '../../../types/sales'
import { formatCurrency } from '../../../utils/format'

interface SaleResumoProps {
  items: CartItem[]
  onUpdateQuantity: (productId: string, quantity: number) => void
  onUpdatePrice: (productId: string, price: number) => void
  onRemoveItem: (productId: string) => void
  onClearCart: () => void
  subtotal: number
  discountType: 'percentage' | 'fixed'
  discountValue: number
  discountAmount: number
  totalAmount: number
  onDiscountTypeChange: (type: 'percentage' | 'fixed') => void
  onDiscountValueChange: (value: number) => void
}

export function SaleResumo({
  items,
  onUpdateQuantity,
  onUpdatePrice,
  onRemoveItem,
  onClearCart,
  subtotal,
  discountType,
  discountValue,
  discountAmount,
  totalAmount,
  onDiscountTypeChange,
  onDiscountValueChange
}: SaleResumoProps) {
  const [editingPrice, setEditingPrice] = useState<string | null>(null)
  const [tempPrice, setTempPrice] = useState('')

  const handlePriceEdit = (productId: string, currentPrice: number) => {
    setEditingPrice(productId)
    setTempPrice(currentPrice.toString())
  }

  const handlePriceSave = (productId: string) => {
    const newPrice = parseFloat(tempPrice)
    if (!isNaN(newPrice) && newPrice > 0) {
      onUpdatePrice(productId, newPrice)
    }
    setEditingPrice(null)
    setTempPrice('')
  }

  const handlePriceCancel = () => {
    setEditingPrice(null)
    setTempPrice('')
  }

  const totalItems = items.reduce((count, item) => count + item.quantity, 0)
  
  // Debug: log dos items recebidos
  console.log('📊 SaleResumo - items recebidos:', items.map(item => ({
    productId: item.product.id,
    productName: item.product.name,
    quantity: item.quantity,
    unit_price: item.unit_price,
    total_price: item.total_price
  })))

  return (
    <Card className="p-6 bg-white border-0 shadow-xl h-fit">
      <div className="space-y-6">
        {/* Cabeçalho Melhorado */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="w-14 h-14 bg-gradient-to-br from-green-500 to-green-600 rounded-xl flex items-center justify-center shadow-lg">
              <ShoppingCart className="w-7 h-7 text-white" />
            </div>
            <div>
              <h3 className="text-xl font-bold text-secondary-900">Carrinho de Compras</h3>
              <div className="flex items-center space-x-4 text-sm">
                <span className="text-green-600 font-medium">
                  {totalItems} {totalItems === 1 ? 'item' : 'itens'}
                </span>
                <span className="text-gray-400">•</span>
                <span className="text-blue-600 font-medium">
                  {items.length} {items.length === 1 ? 'produto' : 'produtos'}
                </span>
              </div>
            </div>
          </div>
          
          {items.length > 0 && (
            <Button
              variant="outline"
              size="sm"
              onClick={onClearCart}
              className="text-red-600 border-red-200 hover:bg-red-50 hover:border-red-300 transition-all"
            >
              <X className="w-4 h-4 mr-2" />
              Limpar Tudo
            </Button>
          )}
        </div>

        {/* Lista de itens melhorada */}
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {items.length === 0 ? (
            <div className="text-center py-12">
              <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <ShoppingCart className="w-10 h-10 text-gray-400" />
              </div>
              <h4 className="text-lg font-medium text-gray-600 mb-2">Carrinho Vazio</h4>
              <p className="text-gray-500">Adicione produtos para começar sua venda</p>
            </div>
          ) : (
            items.map((item, index) => (
              <div
                key={item.product.id}
                className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-4 border border-gray-200 hover:shadow-lg transition-all duration-200"
              >
                {/* Cabeçalho do Item */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full font-medium">
                        #{index + 1}
                      </span>
                      <h4 className="font-semibold text-secondary-900 text-sm leading-tight">
                        {item.product.name}
                      </h4>
                    </div>
                    <div className="flex items-center space-x-4 text-xs text-gray-600">
                      <span className="bg-gray-200 px-2 py-1 rounded">{item.product.sku}</span>
                      <span className={item.product.stock_quantity < 0 ? 'text-red-600 font-bold' : ''}>
                        Estoque: {item.product.stock_quantity}
                      </span>
                      {item.product.stock_quantity <= 0 && (
                        <span className="text-red-600 font-medium">⚠️ {item.product.stock_quantity < 0 ? 'Negativo' : 'Zerado'}</span>
                      )}
                      {item.product.stock_quantity > 0 && item.product.stock_quantity <= item.product.min_stock && (
                        <span className="text-yellow-600 font-medium">⚠️ Baixo</span>
                      )}
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => onRemoveItem(item.product.id)}
                    className="text-red-500 hover:text-red-700 hover:bg-red-50 p-2 ml-2"
                  >
                    <X className="w-4 h-4" />
                  </Button>
                </div>

                {/* Controles do Item */}
                <div className="grid grid-cols-3 gap-4 items-center">
                  {/* Quantidade */}
                  <div className="space-y-2">
                    <label className="text-xs font-medium text-gray-700 uppercase tracking-wide">
                      Quantidade
                    </label>
                    <div className="flex items-center space-x-1">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => onUpdateQuantity(item.product.id, item.quantity - 1)}
                        disabled={item.quantity <= 1}
                        className="w-8 h-8 p-0 rounded-lg"
                      >
                        <Minus className="w-3 h-3" />
                      </Button>
                      
                      <div className="w-12 h-8 bg-white border border-gray-300 rounded-lg flex items-center justify-center">
                        <span className="font-bold text-secondary-900 text-sm">
                          {item.quantity}
                        </span>
                      </div>
                      
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => onUpdateQuantity(item.product.id, item.quantity + 1)}
                        className="w-8 h-8 p-0 rounded-lg"
                      >
                        <Plus className="w-3 h-3" />
                      </Button>
                    </div>
                  </div>

                  {/* Preço Unitário */}
                  <div className="space-y-2">
                    <label className="text-xs font-medium text-gray-700 uppercase tracking-wide">
                      Preço Unit.
                    </label>
                    {editingPrice === item.product.id ? (
                      <div className="flex items-center space-x-1">
                        <Input
                          value={tempPrice}
                          onChange={(e) => setTempPrice(e.target.value)}
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') {
                              handlePriceSave(item.product.id)
                            } else if (e.key === 'Escape') {
                              handlePriceCancel()
                            }
                          }}
                          className="w-20 h-8 text-xs p-2"
                          type="number"
                          step="0.01"
                          autoFocus
                        />
                        <Button
                          size="sm"
                          onClick={() => handlePriceSave(item.product.id)}
                          className="h-8 px-2 text-xs bg-green-500 hover:bg-green-600"
                        >
                          ✓
                        </Button>
                      </div>
                    ) : (
                      <div className="flex items-center space-x-1">
                        <div className="bg-white border border-gray-300 rounded-lg px-2 py-1 min-w-[4rem]">
                          <span className="text-sm font-semibold text-secondary-700">
                            {formatCurrency(item.unit_price)}
                          </span>
                        </div>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handlePriceEdit(item.product.id, item.unit_price)}
                          className="p-1 h-6 w-6 text-secondary-500 hover:text-secondary-700 hover:bg-gray-100"
                        >
                          <Edit3 className="w-3 h-3" />
                        </Button>
                      </div>
                    )}
                  </div>

                  {/* Total do Item */}
                  <div className="space-y-2">
                    <label className="text-xs font-medium text-gray-700 uppercase tracking-wide">
                      Total
                    </label>
                    <div className="bg-green-50 border border-green-200 rounded-lg px-3 py-2">
                      <div className="text-lg font-bold text-green-600 text-center">
                        {formatCurrency(item.total_price)}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Resumo dos valores melhorado */}
        {items.length > 0 && (
          <div className="border-t border-gray-200 pt-6 space-y-4">
            {/* Subtotal */}
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-700 font-medium">Subtotal:</span>
              <span className="text-lg font-semibold text-gray-900">{formatCurrency(subtotal)}</span>
            </div>

            {/* Seção de Desconto Melhorada */}
            <div className="p-4 bg-gradient-to-r from-yellow-50 to-orange-50 rounded-xl border border-yellow-200">
              <div className="space-y-3">
                <div className="flex items-center space-x-2">
                  <Percent className="w-5 h-5 text-orange-600" />
                  <label className="text-lg font-semibold text-orange-800">Aplicar Desconto:</label>
                </div>
                
                <div className="grid grid-cols-3 gap-3">
                  <select
                    value={discountType}
                    onChange={(e) => onDiscountTypeChange(e.target.value as 'percentage' | 'fixed')}
                    className="px-3 py-2 border border-orange-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  >
                    <option value="percentage">Percentual (%)</option>
                    <option value="fixed">Valor Fixo (R$)</option>
                  </select>
                  
                  <Input
                    type="number"
                    value={discountValue}
                    onChange={(e) => onDiscountValueChange(parseFloat(e.target.value) || 0)}
                    placeholder="0"
                    className="h-10 text-center font-semibold"
                    step={discountType === 'percentage' ? '0.1' : '0.01'}
                    min="0"
                    max={discountType === 'percentage' ? '100' : subtotal}
                  />
                  
                  <div className="flex items-center justify-center">
                    <span className="text-sm text-orange-700 font-medium">
                      {discountType === 'percentage' ? '%' : 'R$'}
                    </span>
                  </div>
                </div>
                
                {discountAmount > 0 && (
                  <div className="flex justify-between items-center pt-2 border-t border-orange-200">
                    <span className="text-orange-700 font-medium">Valor do desconto:</span>
                    <span className="text-lg font-bold text-red-600">-{formatCurrency(discountAmount)}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Total Final Destacado */}
            <div className="p-4 bg-gradient-to-r from-green-50 to-green-100 rounded-xl border-2 border-green-200 shadow-lg">
              <div className="flex justify-between items-center">
                <div>
                  <span className="text-green-700 text-lg font-semibold">TOTAL DA VENDA</span>
                  {discountAmount > 0 && (
                    <div className="text-sm text-green-600">
                      (Desconto de {formatCurrency(discountAmount)} aplicado)
                    </div>
                  )}
                </div>
                <div className="text-right">
                  <div className="text-3xl font-bold text-green-600">
                    {formatCurrency(totalAmount)}
                  </div>
                  {discountAmount > 0 && (
                    <div className="text-sm text-gray-500 line-through">
                      {formatCurrency(subtotal)}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </Card>
  )
}
