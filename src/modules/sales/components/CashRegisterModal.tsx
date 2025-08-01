import { useState } from 'react'
import { DollarSign, AlertCircle } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { Input } from '../../../components/ui/Input'
import { formatCurrency } from '../../../utils/format'

interface CashRegisterModalProps {
  isOpen: boolean
  onClose: () => void
  onOpenRegister: (openingAmount: number) => Promise<void>
}

export function CashRegisterModal({ 
  isOpen, 
  onClose, 
  onOpenRegister
}: CashRegisterModalProps) {
  const [openingAmount, setOpeningAmount] = useState<string>('0')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  if (!isOpen) return null

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    const amount = parseFloat(openingAmount.replace(',', '.'))
    
    if (amount <= 0 || isNaN(amount)) {
      setError('O valor deve ser maior que zero')
      return
    }

    setIsLoading(true)
    setError('')

    try {
      console.log('Tentando abrir caixa com valor:', amount)
      await onOpenRegister(amount)
      console.log('Caixa aberto com sucesso')
    } catch (error) {
      console.error('Erro detalhado ao abrir caixa:', error)
      setError('Erro ao abrir caixa. Tente novamente.')
    } finally {
      setIsLoading(false)
    }
  }

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose()
    }
  }

  return (
    <div 
      className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
      onClick={handleBackdropClick}
    >
      <Card className="w-full max-w-md bg-white border-0 shadow-2xl">
        <div className="p-6 space-y-6">
          {/* Cabeçalho */}
          <div className="text-center">
            <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <DollarSign className="w-8 h-8 text-white" />
            </div>
            <h2 className="text-2xl font-bold text-secondary-900">Abrir Caixa</h2>
            <p className="text-secondary-600 mt-2">
              Para realizar vendas, é necessário abrir um caixa primeiro
            </p>
          </div>

          {/* Alerta */}
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div className="flex items-start space-x-3">
              <AlertCircle className="w-5 h-5 text-yellow-600 mt-0.5 flex-shrink-0" />
              <div className="text-sm text-yellow-800">
                <p className="font-medium mb-1">Importante:</p>
                <p>
                  Informe o valor inicial do caixa. Este valor será usado como referência 
                  para o controle de entrada e saída de dinheiro.
                </p>
              </div>
            </div>
          </div>

          {/* Formulário */}
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Valor Inicial do Caixa"
              type="number"
              value={openingAmount}
              onChange={(e) => setOpeningAmount(e.target.value)}
              placeholder="0,00"
              step="0.01"
              min="0"
              required
              icon={<DollarSign className="w-5 h-5" />}
            />

            {/* Exibir erro se houver */}
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-3">
                <div className="flex items-center space-x-2">
                  <AlertCircle className="w-4 h-4 text-red-600" />
                  <p className="text-sm text-red-800">{error}</p>
                </div>
              </div>
            )}

            {/* Preview do valor */}
            <div className="bg-secondary-50 rounded-lg p-4">
              <div className="flex justify-between items-center">
                <span className="text-secondary-600">Valor inicial:</span>
                <span className="text-xl font-bold text-green-600">
                  {formatCurrency(parseFloat(openingAmount) || 0)}
                </span>
              </div>
            </div>

            {/* Botões */}
            <div className="flex space-x-3">
              <Button
                type="button"
                variant="outline"
                onClick={onClose}
                disabled={isLoading}
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button
                type="submit"
                disabled={isLoading}
                className="flex-1 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700"
              >
                {isLoading ? 'Abrindo...' : 'Abrir Caixa'}
              </Button>
            </div>
          </form>
        </div>
      </Card>
    </div>
  )
}
