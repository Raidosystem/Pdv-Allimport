import { X } from 'lucide-react'
import { Button } from '../ui/Button'
import ProductForm from './ProductForm'

interface ProductModalProps {
  isOpen: boolean
  onClose: () => void
  productId?: string
  onSuccess?: () => void
}

export function ProductModal({ isOpen, onClose, productId, onSuccess }: ProductModalProps) {
  console.log('🆕 ProductModal NOVO renderizado - isOpen:', isOpen, 'productId:', productId, 'timestamp:', new Date().toISOString())
  
  if (!isOpen) return null

  const handleSuccess = () => {
    if (onSuccess) {
      onSuccess()
    }
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">
            {productId ? 'Editar Produto' : 'Novo Produto'}
          </h2>
          <Button
            variant="ghost"
            size="sm"
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="h-5 w-5" />
          </Button>
        </div>

        {/* Content */}
        <div className="overflow-y-auto max-h-[calc(90vh-120px)]">
          <ProductForm
            productId={productId}
            onSuccess={handleSuccess}
            onCancel={onClose}
          />
        </div>
      </div>
    </div>
  )
}
