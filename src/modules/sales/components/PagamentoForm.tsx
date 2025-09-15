import { useState } from 'react'
import { CreditCard, DollarSign, X, Plus, Calculator, CheckCircle, AlertCircle, Zap } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { Input } from '../../../components/ui/Input'
import type { PaymentDetails } from '../../../types/sales'
import { formatCurrency } from '../../../utils/format'

interface PagamentoFormProps {
  totalAmount: number
  payments: PaymentDetails[]
  onAddPayment: (payment: PaymentDetails) => void
  onRemovePayment: (index: number) => void
  cashReceived?: number
  changeAmount: number
  hasItems?: boolean
}

const paymentMethods = [
  { id: 'cash', name: 'Dinheiro', icon: DollarSign, color: 'bg-green-500', bgLight: 'bg-green-50', textColor: 'text-green-700', borderColor: 'border-green-200' },
  { id: 'pix', name: 'PIX', icon: Zap, color: 'bg-blue-500', bgLight: 'bg-blue-50', textColor: 'text-blue-700', borderColor: 'border-blue-200' },
  { id: 'credit', name: 'Cartão Crédito', icon: CreditCard, color: 'bg-purple-500', bgLight: 'bg-purple-50', textColor: 'text-purple-700', borderColor: 'border-purple-200' },
  { id: 'debit', name: 'Cartão Débito', icon: CreditCard, color: 'bg-orange-500', bgLight: 'bg-orange-50', textColor: 'text-orange-700', borderColor: 'border-orange-200' },
  { id: 'other', name: 'Outros', icon: CreditCard, color: 'bg-gray-500', bgLight: 'bg-gray-50', textColor: 'text-gray-700', borderColor: 'border-gray-200' }
]

export function PagamentoForm({
  totalAmount,
  payments,
  onAddPayment,
  onRemovePayment,
  cashReceived = 0,
  changeAmount,
  hasItems = false
}: PagamentoFormProps) {
  const [selectedMethod, setSelectedMethod] = useState<string>('cash')
  const [paymentAmount, setPaymentAmount] = useState<string>('')
  const [installments, setInstallments] = useState<number>(1)

  const totalPaid = payments.reduce((sum, payment) => sum + payment.amount, 0) + cashReceived
  // ✅ CORREÇÃO: Usar tolerância para precisão numérica
  const rawRemainingAmount = totalAmount - totalPaid
  const remainingAmount = Math.max(0, rawRemainingAmount)
  // ⭐ CORREÇÃO: Só mostrar como completo se há itens no carrinho E pagamento está completo
  const isPaymentComplete = hasItems && rawRemainingAmount <= 0.01 // Tolerância de 1 centavo

  const handleAddPayment = () => {
    const amount = parseFloat(paymentAmount)
    
    if (!amount || amount <= 0) {
      alert('Informe um valor válido')
      return
    }

    if (amount > remainingAmount) {
      alert(`Valor maior que o restante a pagar (${formatCurrency(remainingAmount)})`)
      return
    }

    const payment: PaymentDetails = {
      method: selectedMethod as any,
      amount,
      installments: selectedMethod === 'credit' ? installments : undefined
    }

    onAddPayment(payment)
    setPaymentAmount('')
    setInstallments(1)
  }

  const getMethodConfig = (methodId: string) => {
    return paymentMethods.find(method => method.id === methodId) || paymentMethods[0]
  }

  const getPaymentMethodName = (method: string) => {
    const config = getMethodConfig(method)
    return config.name
  }

  const selectedMethodConfig = getMethodConfig(selectedMethod)

  return (
    <Card className="p-6 bg-white border-0 shadow-xl">
      <div className="space-y-6">
        {/* Cabeçalho com Status */}
        <div className="space-y-4">
          <div className="flex items-center justify-center space-x-4">
            <div className="w-14 h-14 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center shadow-lg">
              <CreditCard className="w-7 h-7 text-white" />
            </div>
            <div className="text-center">
              <h3 className="text-xl font-bold text-secondary-900">Formas de Pagamento</h3>
              <p className="text-secondary-600 font-medium">
                Total: {formatCurrency(totalAmount)}
              </p>
            </div>
            <div className="w-14"></div>
          </div>

          {/* Indicador Visual de Progresso */}
          <div className="bg-gray-200 rounded-full h-3 overflow-hidden">
            <div 
              className="h-full bg-gradient-to-r from-green-500 to-green-600 transition-all duration-300"
              style={{ width: `${Math.min((totalPaid / totalAmount) * 100, 100)}%` }}
            />
          </div>
          
          <div className="flex justify-between text-sm">
            <span className="text-gray-600">Pago: {formatCurrency(totalPaid)}</span>
            <span className="font-medium text-gray-900">
              {remainingAmount > 0.01 ? `Falta: ${formatCurrency(remainingAmount)}` : 'Pago'}
            </span>
          </div>
        </div>

        {/* Seleção de Método de Pagamento */}
        <div className="space-y-4">
          <label className="block text-lg font-semibold text-secondary-900">
            Escolha o Método de Pagamento:
          </label>
          <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
            {paymentMethods.map((method) => {
              const Icon = method.icon
              const isSelected = selectedMethod === method.id
              return (
                <button
                  key={method.id}
                  onClick={() => setSelectedMethod(method.id)}
                  className={`
                    relative p-4 rounded-xl border-2 transition-all duration-200 transform hover:scale-105
                    ${isSelected
                      ? `${method.bgLight} ${method.borderColor} shadow-lg scale-105`
                      : 'border-gray-200 hover:border-gray-300 hover:shadow-md'
                    }
                  `}
                >
                  <div className="flex flex-col items-center space-y-2">
                    <div className={`w-10 h-10 ${method.color} rounded-lg flex items-center justify-center shadow-md`}>
                      <Icon className="w-5 h-5 text-white" />
                    </div>
                    <span className={`text-sm font-medium ${isSelected ? method.textColor : 'text-gray-700'}`}>
                      {method.name}
                    </span>
                  </div>
                  {isSelected && (
                    <div className="absolute -top-1 -right-1">
                      <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                        <CheckCircle className="w-4 h-4 text-white" />
                      </div>
                    </div>
                  )}
                </button>
              )
            })}
          </div>
        </div>

        {/* Formulário de Pagamento */}
        {remainingAmount > 0.01 && (
          <div className={`p-5 rounded-xl border-2 ${selectedMethodConfig.bgLight} ${selectedMethodConfig.borderColor}`}>
            <h4 className={`text-lg font-semibold mb-4 ${selectedMethodConfig.textColor}`}>
              Adicionar Pagamento - {selectedMethodConfig.name}
            </h4>
            
            <div className="space-y-4">
              {/* Valor Total */}
              <div className="flex justify-center">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => setPaymentAmount(remainingAmount.toFixed(2))}
                  className="px-4 py-2"
                >
                  Valor Total: {formatCurrency(remainingAmount)}
                </Button>
              </div>

              {/* Campos de Entrada */}
              <div className="grid grid-cols-2 gap-3">
                <Input
                  label="Valor"
                  type="number"
                  value={paymentAmount}
                  onChange={(e) => setPaymentAmount(e.target.value)}
                  placeholder="0,00"
                  step="0.01"
                  min="0"
                  max={remainingAmount}
                  className="h-12 text-base"
                  icon={<DollarSign className="w-5 h-5" />}
                />

                {selectedMethod === 'credit' && (
                  <Input
                    label="Parcelas"
                    type="number"
                    value={installments}
                    onChange={(e) => setInstallments(parseInt(e.target.value) || 1)}
                    min="1"
                    max="12"
                    className="h-12 text-base"
                    icon={<Calculator className="w-5 h-5" />}
                  />
                )}
              </div>

              {/* Preview do Pagamento */}
              {paymentAmount && parseFloat(paymentAmount) > 0 && (
                <div className="p-3 bg-white rounded-lg border border-gray-200">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Valor a adicionar:</span>
                    <span className="font-semibold text-green-600">
                      {formatCurrency(parseFloat(paymentAmount))}
                    </span>
                  </div>
                  {selectedMethod === 'credit' && installments > 1 && (
                    <div className="flex justify-between items-center mt-1">
                      <span className="text-xs text-gray-500">Parcelas:</span>
                      <span className="text-xs text-gray-700">
                        {installments}x de {formatCurrency(parseFloat(paymentAmount) / installments)}
                      </span>
                    </div>
                  )}
                </div>
              )}

              <Button
                onClick={handleAddPayment}
                disabled={!paymentAmount || parseFloat(paymentAmount) <= 0}
                className={`w-full h-12 text-base font-semibold ${selectedMethodConfig.color} hover:opacity-90 shadow-lg transform hover:scale-105 transition-all`}
              >
                <Plus className="w-5 h-5 mr-2" />
                Adicionar {selectedMethodConfig.name}
              </Button>
            </div>
          </div>
        )}

        {/* Lista de Pagamentos Adicionados */}
        {payments.length > 0 && (
          <div className="space-y-3">
            <h4 className="text-lg font-semibold text-secondary-900 flex items-center space-x-2">
              <CheckCircle className="w-5 h-5 text-green-500" />
              <span>Pagamentos Adicionados:</span>
            </h4>
            <div className="space-y-2">
              {payments.map((payment, index) => {
                const methodConfig = getMethodConfig(payment.method)
                const Icon = methodConfig.icon
                return (
                  <div
                    key={index}
                    className={`flex items-center justify-between p-4 rounded-xl border-2 ${methodConfig.bgLight} ${methodConfig.borderColor}`}
                  >
                    <div className="flex items-center space-x-3">
                      <div className={`w-10 h-10 ${methodConfig.color} rounded-lg flex items-center justify-center shadow-md`}>
                        <Icon className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <div className={`font-semibold ${methodConfig.textColor}`}>
                          {getPaymentMethodName(payment.method)}
                        </div>
                        {payment.installments && payment.installments > 1 && (
                          <div className="text-sm text-gray-600">
                            {payment.installments}x de {formatCurrency(payment.amount / payment.installments)}
                          </div>
                        )}
                      </div>
                    </div>
                    <div className="flex items-center space-x-3">
                      <span className="text-xl font-bold text-green-600">
                        {formatCurrency(payment.amount)}
                      </span>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onRemovePayment(index)}
                        className="text-red-500 hover:text-red-700 hover:bg-red-50 p-2"
                      >
                        <X className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* Troco */}
        {changeAmount > 0 && (
          <div className="p-4 bg-gradient-to-r from-green-50 to-green-100 rounded-xl border-2 border-green-200 shadow-lg">
            <div className="flex justify-between items-center">
              <span className="text-green-700 font-semibold text-lg">Troco a devolver:</span>
              <span className="text-2xl font-bold text-green-600">
                {formatCurrency(changeAmount)}
              </span>
            </div>
          </div>
        )}

        {/* Resumo Final */}
        <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-5 border-2 border-gray-200">
          <h4 className="text-lg font-semibold text-secondary-900 mb-4">Resumo do Pagamento:</h4>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-gray-700">Total da venda:</span>
              <span className="font-semibold text-lg">{formatCurrency(totalAmount)}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-700">Total pago:</span>
              <span className="font-semibold text-lg text-green-600">{formatCurrency(totalPaid)}</span>
            </div>
            <hr className="border-gray-300" />
            <div className="flex justify-between items-center">
              <span className="text-gray-700 font-semibold">Restante:</span>
              <span className={`font-bold text-xl ${remainingAmount > 0 ? 'text-red-600' : 'text-green-600'}`}>
                {formatCurrency(remainingAmount)}
              </span>
            </div>
          </div>
        </div>

        {/* Status Final */}
        <div className="text-center">
          {isPaymentComplete ? (
            <div className="p-4 bg-green-50 rounded-xl border-2 border-green-200">
              <div className="flex items-center justify-center space-x-2 text-green-700">
                <CheckCircle className="w-6 h-6" />
                <span className="text-lg font-semibold">
                  ✅ Pagamento Finalizado - Pronto para Finalizar!
                </span>
              </div>
            </div>
          ) : remainingAmount > 0.01 && hasItems ? (
            <div className="p-4 bg-orange-50 rounded-xl border-2 border-orange-200">
              <div className="flex items-center justify-center space-x-2 text-orange-700">
                <AlertCircle className="w-6 h-6" />
                <span className="text-lg font-semibold">
                  ⚠️ Falta pagar: {formatCurrency(remainingAmount)}
                </span>
              </div>
            </div>
          ) : hasItems && remainingAmount <= 0.01 ? (
            <div className="p-4 bg-green-50 rounded-xl border-2 border-green-200">
              <div className="flex items-center justify-center space-x-2 text-green-700">
                <CheckCircle className="w-6 h-6" />
                <span className="text-lg font-semibold">
                  ✅ Pagamento Finalizado - Pronto para Finalizar!
                </span>
              </div>
            </div>
          ) : !hasItems ? (
            <div className="p-4 bg-gray-50 rounded-xl border-2 border-gray-200">
              <div className="flex items-center justify-center space-x-2 text-gray-600">
                <Calculator className="w-6 h-6" />
                <span className="text-lg font-medium">
                  💳 Adicione produtos para iniciar o pagamento
                </span>
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </Card>
  )
}
