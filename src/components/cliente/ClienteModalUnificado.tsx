import { X } from 'lucide-react'
import { ClienteFormUnificado } from './ClienteFormUnificado'

interface ClienteModalProps {
  isOpen: boolean
  onClose: () => void
  onSuccess?: (cliente: any) => void
  empresaId?: string
  titulo?: string
}

export function ClienteModalUnificado({ 
  isOpen, 
  onClose, 
  onSuccess, 
  empresaId,
  titulo = "Novo Cliente" 
}: ClienteModalProps) {
  if (!isOpen) return null

  const handleSuccess = (cliente: any) => {
    if (onSuccess) {
      onSuccess(cliente)
    }
    onClose()
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-gray-900">{titulo}</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
        
        <div className="p-6">
          <ClienteFormUnificado
            empresaId={empresaId}
            titulo={titulo}
            onSuccess={handleSuccess}
            onCancel={onClose}
            showHeader={false}
            isModal={true}
          />
        </div>
      </div>
    </div>
  )
}