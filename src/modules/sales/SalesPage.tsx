import { useState, useEffect } from 'react'
import { Printer, FileText, AlertCircle } from 'lucide-react'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { useAuth } from '../auth'
import { useCaixa } from '../../hooks/useCaixa'
import { usePrintReceipt } from '../../hooks/usePrintReceipt'
import { useCart, useSaleCalculation, useKeyboardShortcuts } from '../../hooks/useSales'
import { ProductSearch } from './components/ProductSearch'
import { SaleResumo } from './components/SaleResumo'
import { PagamentoForm } from './components/PagamentoForm'
import { ClienteSelector } from '../../components/ui/ClienteSelectorSimples'
import { CashRegisterModal } from './components/CashRegisterModal'
import { ProductFormModal } from '../../components/product/ProductFormModal'
import PrintConfirmationModal from '../../components/PrintConfirmationModal'
import { salesService } from '../../services/salesNew'
import type { Product, Customer } from '../../types/sales'
import type { Cliente } from '../../types/cliente'
import { formatCurrency } from '../../utils/format'

export function SalesPage() {
  const { user } = useAuth()
  const { caixaAtual, loading: loadingCaixa, abrirCaixa } = useCaixa()
  const { printReceipt } = usePrintReceipt()
  const [customer, setCustomer] = useState<Customer | null>(null)
  const [clienteSelecionado, setClienteSelecionado] = useState<Cliente | null>(null)
  const [loading, setLoading] = useState(false)
  const [cashReceived, setCashReceived] = useState<number>(0)
  const [showCashModal, setShowCashModal] = useState(false)
  const [showProductFormModal, setShowProductFormModal] = useState(false)
  const [showPrintModal, setShowPrintModal] = useState(false)
  const [pendingSaleData, setPendingSaleData] = useState<any>(null)
  const [initialCheckDone, setInitialCheckDone] = useState(false)

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
  const canFinalizeSale = items.length > 0 && totalPaid >= totalAmount && caixaAtual?.status === 'aberto'

  // Verificar caixa aberto ao carregar (simplificado)
  useEffect(() => {
    // Verificar apenas uma vez quando os dados do caixa estão prontos
    if (!loadingCaixa && !initialCheckDone) {
      if (!caixaAtual || caixaAtual.status !== 'aberto') {
        setShowCashModal(true)
      }
      setInitialCheckDone(true)
    }
  }, [caixaAtual, loadingCaixa, initialCheckDone])

    const handleOpenCashRegister = async (amount: number) => {
    if (!user) return
    
    try {
      setLoading(true)
      const sucesso = await abrirCaixa({ valor_inicial: amount })
      if (sucesso) {
        setShowCashModal(false)
        toast.success('Caixa aberto com sucesso!')
      }
    } catch (error) {
      console.error('Erro ao abrir caixa:', error)
      toast.error('Erro ao abrir caixa')
    } finally {
      setLoading(false)
    }
  }

  // Função para abrir modal de cadastro de produtos
  const handleCreateProduct = () => {
    setShowProductFormModal(true)
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

    if (!user || !caixaAtual || caixaAtual.status !== 'aberto') {
      toast.error('Caixa não está aberto para vendas')
      return
    }

    setLoading(true)

    try {
      // Preparar dados da venda
      const saleData = {
        customer_id: customer?.id,
        cash_register_id: caixaAtual.id,
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

      // Mostrar modal de confirmação de impressão
      setPendingSaleData({ sale, saleData })
      setShowPrintModal(true)

    } catch (error) {
      console.error('Erro ao finalizar venda:', error)
      toast.error('Erro ao finalizar venda. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

    // Imprimir comprovante
  const handlePrintReceipt = (saleId: string, saleData: any) => {
    try {
      const receiptData = {
        sale: {
          id: saleId,
          total_amount: saleData.total_amount || totalAmount,
          discount_amount: saleData.discount_amount || discountAmount,
          payment_method: saleData.payment_method || 'cash',
          payment_details: saleData.payment_details,
          created_at: new Date().toISOString(),
          items: items.map(item => ({
            product_id: item.product.id,
            quantity: item.quantity,
            unit_price: item.unit_price,
            total_price: item.total_price,
            product: {
              name: item.product.name,
              sku: item.product.sku
            }
          }))
        },
        customer: customer ? {
          id: customer.id,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          document: customer.document
        } : null,
        storeName: "PDV Allimport",
        storeInfo: {
          address: "Rua Exemplo, 123 - Centro",
          phone: "(11) 99999-9999",
          cnpj: "00.000.000/0001-00"
        },
        cashReceived,
        changeAmount
      };

      printReceipt(receiptData);
    } catch (error) {
      console.error('Erro ao preparar impressão:', error);
      toast.error('Erro ao preparar impressão do recibo');
    }
  }

  // Emitir NFE
  const handleEmitNFE = () => {
    console.log('Emitir NFE')
    toast('Funcionalidade de NFE em desenvolvimento', { icon: 'ℹ️' })
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-50 via-white to-primary-50">
      {/* CSS customizado para melhor experiência mobile */}
      <style>
        {`
          @media (max-width: 640px) {
            .mobile-padding {
              padding-left: 12px !important;
              padding-right: 12px !important;
              padding-top: 16px !important;
            }
            .mobile-card {
              padding: 16px !important;
            }
            .mobile-grid {
              grid-template-columns: 1fr !important;
              gap: 16px !important;
            }
            .mobile-header {
              font-size: 20px !important;
            }
            .mobile-subheader {
              font-size: 14px !important;
            }
            .mobile-button {
              width: 100% !important;
              min-height: 44px !important;
              padding: 12px 16px !important;
              font-size: 14px !important;
            }
          }
          @media (max-width: 480px) {
            .mobile-padding {
              padding-left: 8px !important;
              padding-right: 8px !important;
              padding-top: 12px !important;
            }
            .mobile-card {
              padding: 12px !important;
            }
            .mobile-header {
              font-size: 18px !important;
            }
            .mobile-subheader {
              font-size: 12px !important;
            }
          }
        `}
      </style>
      
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-green-400 rounded-full blur-3xl"></div>
      </div>

      {/* Main Content - Responsivo */}
      <main className="relative max-w-7xl mx-auto mobile-padding py-4 px-4 sm:px-6 lg:px-8">
        {/* Status do caixa - apenas se fechado - Mobile responsivo */}
        {!loadingCaixa && caixaAtual?.status !== 'aberto' && (
          <div className="mb-4 mobile-card p-4 bg-red-50 border border-red-200 rounded-lg text-center">
            <div className="flex flex-col sm:flex-row items-center justify-center gap-2 text-red-700">
              <AlertCircle className="w-5 h-5" />
              <span className="font-medium">Caixa Fechado</span>
            </div>
            <Button 
              onClick={() => setShowCashModal(true)}
              className="mobile-button mt-3 bg-primary-600 hover:bg-primary-700"
            >
              Abrir Caixa
            </Button>
          </div>
        )}
        
        {loadingCaixa ? (
          /* Loading state - Mobile responsivo */
          <Card className="mobile-card p-6 sm:p-8 text-center">
            <div className="w-12 h-12 sm:w-16 sm:h-16 mx-auto mb-4 border-4 border-gray-300 border-t-blue-600 rounded-full animate-spin" />
            <h2 className="mobile-header text-xl sm:text-2xl font-bold text-secondary-900 mb-2">Verificando Caixa...</h2>
            <p className="mobile-subheader text-sm sm:text-base text-secondary-600">
              Aguarde enquanto verificamos o status do caixa.
            </p>
          </Card>
        ) : (!caixaAtual || caixaAtual.status !== 'aberto') ? (
          /* Aviso de caixa fechado - Mobile responsivo */
          <Card className="mobile-card p-6 sm:p-8 text-center">
            <AlertCircle className="w-12 h-12 sm:w-16 sm:h-16 mx-auto mb-4 text-red-500" />
            <h2 className="mobile-header text-xl sm:text-2xl font-bold text-secondary-900 mb-2">Caixa Fechado</h2>
            <p className="mobile-subheader text-sm sm:text-base text-secondary-600 mb-4 sm:mb-6">
              Para realizar vendas, é necessário abrir um caixa primeiro.
            </p>
            <Button className="mobile-button">
              Abrir Caixa
            </Button>
          </Card>
        ) : (
          <div className="mobile-grid grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
            {/* Coluna esquerda - Busca e Cliente */}
            <div className="space-y-6">
              <ProductSearch 
                onProductSelect={handleProductSelect}
                onBarcodeSearch={(barcode) => console.log('Barcode:', barcode)}
                onCreateProduct={handleCreateProduct}
              />
              <ClienteSelector 
                clienteSelecionado={clienteSelecionado}
                onClienteSelect={setClienteSelecionado}
                titulo="Cliente da Venda"
                showCard={false}
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
                      onClick={() => {
                        if (items.length > 0) {
                          const mockSaleData = {
                            total_amount: totalAmount,
                            discount_amount: discountAmount,
                            payment_method: 'cash',
                            payment_details: null
                          };
                          handlePrintReceipt('preview_' + Date.now(), mockSaleData);
                        }
                      }}
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
        onOpenRegister={handleOpenCashRegister}
      />

      {/* Modal de Cadastro de Produto */}
      <ProductFormModal
        isOpen={showProductFormModal}
        onClose={() => setShowProductFormModal(false)}
        onSuccess={() => {
          toast.success('Produto cadastrado com sucesso!')
          // Força atualização da busca de produtos
          window.dispatchEvent(new CustomEvent('productAdded'))
        }}
      />

      {/* Modal de Confirmação de Impressão */}
      <PrintConfirmationModal
        isOpen={showPrintModal}
        onClose={() => setShowPrintModal(false)}
        onConfirm={() => {
          if (pendingSaleData) {
            handlePrintReceipt(pendingSaleData.sale.id, pendingSaleData.saleData)
          }
        }}
        saleTotal={totalAmount}
        customerName={customer?.name || clienteSelecionado?.nome}
      />
    </div>
  )
}
