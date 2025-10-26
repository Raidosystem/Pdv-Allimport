import { useState, useEffect } from 'react'
import { X, ShoppingBag } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Input } from '../../../components/ui/Input'

interface QuickSaleData {
  customerName: string
  productName: string
  productPrice: number
  quantity: number
}

interface QuickSaleModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (data: QuickSaleData) => void
}

export function QuickSaleModal({ isOpen, onClose, onSubmit }: QuickSaleModalProps) {
  const [customerName, setCustomerName] = useState('')
  const [productName, setProductName] = useState('')
  const [productPrice, setProductPrice] = useState('')
  const [quantity, setQuantity] = useState(1)

  // Scroll para o topo quando o modal abrir
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
      window.scrollTo({ top: 0, behavior: 'smooth' })
    } else {
      document.body.style.overflow = 'unset'
    }
    
    return () => {
      document.body.style.overflow = 'unset'
    }
  }, [isOpen])

  if (!isOpen) return null

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!productName.trim()) {
      alert('Nome do produto é obrigatório')
      return
    }
    
    if (!productPrice || Number(productPrice) <= 0) {
      alert('Preço do produto deve ser maior que zero')
      return
    }

    onSubmit({
      customerName: customerName.trim(),
      productName: productName.trim(),
      productPrice: Number(productPrice),
      quantity
    })

    // Limpar formulário
    setCustomerName('')
    setProductName('')
    setProductPrice('')
    setQuantity(1)
  }

  const handleClose = () => {
    setCustomerName('')
    setProductName('')
    setProductPrice('')
    setQuantity(1)
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
      <div className="bg-white rounded-lg p-6 w-full max-w-md my-8 shadow-2xl">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <ShoppingBag className="w-5 h-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-gray-900">Venda Avulsa</h2>
          </div>
          <Button variant="secondary" size="sm" onClick={handleClose}>
            <X className="w-4 h-4" />
          </Button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cliente (opcional)
            </label>
            <Input
              type="text"
              value={customerName}
              onChange={(e) => setCustomerName(e.target.value)}
              placeholder="Nome do cliente (opcional)"
              className="w-full"
            />
            <p className="text-xs text-gray-500 mt-1">
              Apenas o nome, sem CPF necessário
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Produto *
            </label>
            <Input
              type="text"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              placeholder="Nome do produto"
              className="w-full"
              required
            />
            <p className="text-xs text-gray-500 mt-1">
              Produto não precisa estar cadastrado
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Preço *
            </label>
            <Input
              type="number"
              step="0.01"
              min="0.01"
              value={productPrice}
              onChange={(e) => setProductPrice(e.target.value)}
              placeholder="0,00"
              className="w-full"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Quantidade
            </label>
            <Input
              type="number"
              min="1"
              value={quantity}
              onChange={(e) => setQuantity(Number(e.target.value))}
              className="w-full"
            />
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              variant="secondary"
              onClick={handleClose}
              className="flex-1"
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              className="flex-1 bg-blue-600 hover:bg-blue-700"
            >
              Adicionar à Venda
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}