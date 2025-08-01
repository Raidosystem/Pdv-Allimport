import { useState, useEffect } from 'react'
import { ShoppingCart, Printer, FileText, RotateCcw, CheckCircle, AlertCircle } from 'lucide-react'
import { Link } from 'react-router-dom'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { useAuth } from '../auth'
import { useCart, useSaleCalculation, useKeyboardShortcuts } from '../../hooks/useSales'
import { ProductSearch } from './components/ProductSearch'
import { SaleResumo } from './components/SaleResumo'
import { PagamentoForm } from './components/PagamentoForm'
import { ClienteSelect } from './components/ClienteSelect'
import { CashRegisterModal } from './components/CashRegisterModal'
import { salesService, cashRegisterService } from '../../services/sales'
import type { Product, Customer, CashRegister } from '../../types/sales'
import { formatCurrency } from '../../utils/format'

export function SalesPage() {
  const { user } = useAuth()
  const [customer, setCustomer] = useState<Customer | null>(null)
  const [cashRegister, setCashRegister] = useState<CashRegister | null>(null)
  const [loading, setLoading] = useState(false)
  const [cashReceived, setCashReceived] = useState<number>(0)
  const [showCashModal, setShowCashModal] = useState(false)

  // Hooks do carrinho e cálculos
  const {
    items,
    addItem,
    updateQuantity,
    updatePrice,
    removeItem,
    clearCart,
    getSubtotal,
    getItemsCount
  } = useCart()

  const {
    discountType,
    setDiscountType,
    discountValue,
    setDiscountValue,
    payments,
    addPayment,
    removePayment,
    calculateDiscount,
    getTotalPayments,
    getChangeAmount,
    resetCalculation
  } = useSaleCalculation()

  // Cálculos da venda
  const subtotal = getSubtotal()
  const discountAmount = calculateDiscount(subtotal)
  const totalAmount = Math.max(0, subtotal - discountAmount)
  const changeAmount = getChangeAmount(totalAmount, cashReceived)
  const totalPaid = getTotalPayments() + cashReceived

  // Verificar se pode finalizar a venda
  const canFinalizeSale = items.length > 0 && totalPaid >= totalAmount && cashRegister

  // Verificar caixa aberto ao carregar
  useEffect(() => {
    const checkCashRegister = async () => {
      try {
        const openRegister = await cashRegisterService.getOpenRegister()
        setCashRegister(openRegister)
        
        if (!openRegister) {
          setShowCashModal(true)
        }
      } catch (error) {
        console.error('Erro ao verificar caixa:', error)
        toast.error('Erro ao verificar status do caixa')
      }
    }

    checkCashRegister()
  }, [])

  const handleCashOpen = async (amount: number) => {
    try {
      if (!user) {
        toast.error('Usuário não logado')
        return
      }
      
      const register = await cashRegisterService.openRegister(amount, user.id)
      setCashRegister(register)
      setShowCashModal(false)
      toast.success('Caixa aberto com sucesso!')
    } catch (error) {
      console.error('Erro ao abrir caixa:', error)
      toast.error('Erro ao abrir caixa')
    }
  }

  // Atalhos de teclado
  const handleNewSale = () => {
    clearCart()
    setCustomer(null)
    setCashReceived(0)
    resetCalculation()
    toast.success('Nova venda iniciada')
  }

  const handleAddProduct = () => {
    // Foco no campo de busca será tratado pelo componente ProductSearch
    console.log('Add product shortcut triggered')
  }

  useKeyboardShortcuts(handleNewSale, handleAddProduct)

  // Adicionar produto ao carrinho
  const handleProductSelect = (product: Product, quantity: number = 1) => {
    if (product.stock_quantity < quantity) {
      toast.error(`Estoque insuficiente. Disponível: ${product.stock_quantity}`)
      return
    }

    addItem(product, quantity)
    toast.success(`${product.name} adicionado ao carrinho`)
  }

  // Finalizar venda
  const handleFinalizeSale = async () => {
    if (!canFinalizeSale) {
      toast.error('Verifique os itens e pagamento antes de finalizar')
      return
    }

    if (!user || !cashRegister) {
      toast.error('Usuário ou caixa não identificado')
      return
    }

    setLoading(true)

    try {
      // Preparar dados da venda
      const saleData = {
        customer_id: customer?.id,
        cash_register_id: cashRegister.id,
        user_id: user.id,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        payment_method: payments.length > 0 ? 'mixed' : 'cash',
        payment_details: {
          payments,
          cash_received: cashReceived,
          change_amount: changeAmount
        },
        notes: '',
        items: items.map(item => ({
          product_id: item.product.id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          total_price: item.total_price
        }))
      }

      // Criar venda
      const sale = await salesService.create(saleData)

      // Limpar formulário
      clearCart()
      setCustomer(null)
      setCashReceived(0)
      resetCalculation()

      toast.success('Venda finalizada com sucesso!')

      // Exibir opções pós-venda
      const shouldPrint = window.confirm('Venda finalizada! Deseja imprimir o comprovante?')
      if (shouldPrint) {
        handlePrintReceipt(sale.id)
      }

    } catch (error) {
      console.error('Erro ao finalizar venda:', error)
      toast.error('Erro ao finalizar venda. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  // Imprimir comprovante
  const handlePrintReceipt = (saleId: string) => {
    // Implementar impressão
    console.log('Imprimir comprovante:', saleId)
    toast.success('Comprovante enviado para impressão')
  }

  // Emitir NFE
  const handleEmitNFE = () => {
    console.log('Emitir NFE')
    toast('Funcionalidade de NFE em desenvolvimento', { icon: 'ℹ️' })
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-50 via-white to-primary-50">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-green-400 rounded-full blur-3xl"></div>
      </div>

      {/* Header */}
      <header className="relative bg-white/90 backdrop-blur-sm shadow-lg border-b border-secondary-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            <div className="flex items-center space-x-4">
              <Link to="/dashboard" className="flex items-center space-x-3">
                <div className="w-14 h-14 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg">
                  <ShoppingCart className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
                  <p className="text-primary-600 font-medium">Sistema de Vendas</p>
                </div>
              </Link>
            </div>
            
            <div className="flex items-center space-x-4">
              {/* Status do caixa */}
              <div className={`px-4 py-2 rounded-xl ${
                cashRegister 
                  ? 'bg-green-100 text-green-700 border border-green-200'
                  : 'bg-red-100 text-red-700 border border-red-200'
              }`}>
                <div className="flex items-center space-x-2">
                  {cashRegister ? (
                    <CheckCircle className="w-5 h-5" />
                  ) : (
                    <AlertCircle className="w-5 h-5" />
                  )}
                  <span className="font-medium">
                    {cashRegister ? 'Caixa Aberto' : 'Caixa Fechado'}
                  </span>
                </div>
              </div>

              {/* Ações principais */}
              <Button
                onClick={handleNewSale}
                variant="outline"
                className="flex items-center space-x-2"
              >
                <RotateCcw className="w-5 h-5" />
                <span>Nova Venda (Ctrl+N)</span>
              </Button>
              
              <Link to="/dashboard">
                <Button variant="outline">
                  Voltar ao Dashboard
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="relative max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {!cashRegister ? (
          /* Aviso de caixa fechado */
          <Card className="p-8 text-center">
            <AlertCircle className="w-16 h-16 mx-auto mb-4 text-red-500" />
            <h2 className="text-2xl font-bold text-secondary-900 mb-2">Caixa Fechado</h2>
            <p className="text-secondary-600 mb-6">
              Para realizar vendas, é necessário abrir um caixa primeiro.
            </p>
            <Button>
              Abrir Caixa
            </Button>
          </Card>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Coluna esquerda - Busca e Cliente */}
            <div className="space-y-6">
              <ProductSearch 
                onProductSelect={handleProductSelect}
                onBarcodeSearch={(barcode) => console.log('Barcode:', barcode)}
              />
              <ClienteSelect 
                selectedCustomer={customer}
                onCustomerSelect={setCustomer}
              />
            </div>

            {/* Coluna central - Carrinho */}
            <div>
              <SaleResumo
                items={items}
                onUpdateQuantity={updateQuantity}
                onUpdatePrice={updatePrice}
                onRemoveItem={removeItem}
                onClearCart={clearCart}
                subtotal={subtotal}
                discountType={discountType}
                discountValue={discountValue}
                discountAmount={discountAmount}
                totalAmount={totalAmount}
                onDiscountTypeChange={setDiscountType}
                onDiscountValueChange={setDiscountValue}
              />
            </div>

            {/* Coluna direita - Pagamento */}
            <div className="space-y-6">
              <PagamentoForm
                totalAmount={totalAmount}
                payments={payments}
                onAddPayment={addPayment}
                onRemovePayment={removePayment}
                cashReceived={cashReceived}
                onCashReceivedChange={setCashReceived}
                changeAmount={changeAmount}
              />

              {/* Botões de ação */}
              <Card className="p-6 bg-white border-0 shadow-lg">
                <div className="space-y-4">
                  <div className="text-center">
                    <div className="text-sm text-secondary-600 mb-2">
                      {getItemsCount()} {getItemsCount() === 1 ? 'item' : 'itens'} • Total: {formatCurrency(totalAmount)}
                    </div>
                    {totalPaid >= totalAmount && items.length > 0 && (
                      <div className="text-green-600 font-medium">
                        ✓ Pronto para finalizar
                      </div>
                    )}
                  </div>

                  <Button
                    onClick={handleFinalizeSale}
                    disabled={!canFinalizeSale || loading}
                    className="w-full text-lg py-4 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700"
                  >
                    {loading ? 'Finalizando...' : 'Finalizar Venda'}
                  </Button>

                  <div className="grid grid-cols-2 gap-3">
                    <Button
                      variant="outline"
                      onClick={() => handlePrintReceipt('')}
                      disabled={items.length === 0}
                      className="flex items-center justify-center space-x-2"
                    >
                      <Printer className="w-4 h-4" />
                      <span>Imprimir</span>
                    </Button>
                    
                    <Button
                      variant="outline"
                      onClick={handleEmitNFE}
                      disabled={items.length === 0}
                      className="flex items-center justify-center space-x-2"
                    >
                      <FileText className="w-4 h-4" />
                      <span>NFE</span>
                    </Button>
                  </div>
                </div>
              </Card>
            </div>
          </div>
        )}
      </main>

      {/* Modal de Abertura de Caixa */}
      <CashRegisterModal
        isOpen={showCashModal}
        onClose={() => setShowCashModal(false)}
        onOpenRegister={handleCashOpen}
      />
    </div>
  )
}
