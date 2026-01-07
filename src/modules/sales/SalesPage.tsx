import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Printer, FileText, AlertCircle } from 'lucide-react'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { useAuth } from '../auth'
import { useCaixa } from '../../hooks/useCaixa'
import { usePrintReceipt } from '../../hooks/usePrintReceipt'
import { useEmpresaSettings } from '../../hooks/useEmpresaSettings'
import { useCart, useSaleCalculation, useKeyboardShortcuts } from '../../hooks/useSales'
import { ProductSearch } from './components/ProductSearch'
import { SaleResumo } from './components/SaleResumo'
import { PagamentoForm } from './components/PagamentoForm'
import { ClienteSelector } from '../../components/ui/ClienteSelectorSimples'
import { CashRegisterModal } from './components/CashRegisterModal'
import { ProductFormModal } from '../../components/product/ProductFormModal'
import { QuickSaleModal } from './components/QuickSaleModal'
import PrintConfirmationModal from '../../components/PrintConfirmationModal'
import { salesService } from '../../services/sales'
import type { Product, Customer } from '../../types/sales'
import type { Cliente } from '../../types/cliente'
import { formatCurrency } from '../../utils/format'

export function SalesPage() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { caixaAtual, loading: loadingCaixa, abrirCaixa } = useCaixa()
  const { printReceipt } = usePrintReceipt()
  const { settings: empresaSettings } = useEmpresaSettings()
  const [customer, setCustomer] = useState<Customer | null>(null)
  const [clienteSelecionado, setClienteSelecionado] = useState<Cliente | null>(null)
  const [loading, setLoading] = useState(false)
  const [cashReceived, setCashReceived] = useState<number>(0)
  const [showCashModal, setShowCashModal] = useState(false)
  const [showProductFormModal, setShowProductFormModal] = useState(false)
  const [showQuickSaleModal, setShowQuickSaleModal] = useState(false)
  const [showPrintModal, setShowPrintModal] = useState(false)
  const [pendingSaleData, setPendingSaleData] = useState<any>(null)
  const [initialCheckDone, setInitialCheckDone] = useState(false)

  // Sincronizar cliente selecionado com customer para impressão
  useEffect(() => {
    if (clienteSelecionado) {
      const customerData = {
        id: clienteSelecionado.id,
        name: clienteSelecionado.nome,
        email: clienteSelecionado.email || undefined,
        phone: clienteSelecionado.telefone || undefined,
        document: clienteSelecionado.cpf_cnpj || undefined,
        active: clienteSelecionado.ativo,
        created_at: clienteSelecionado.criado_em,
        updated_at: clienteSelecionado.atualizado_em
      }
      console.log('👤 Cliente sincronizado para impressão:', customerData)
      setCustomer(customerData)
    } else {
      console.log('👤 Nenhum cliente selecionado')
      setCustomer(null)
    }
  }, [clienteSelecionado])

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

  // Verificar caixa aberto ao carregar - APENAS UMA VEZ
  useEffect(() => {
    // ✅ Verificar apenas uma vez após carregamento inicial
    if (!loadingCaixa && !initialCheckDone) {
      console.log('🎯 [SalesPage] Verificação inicial de caixa (UMA VEZ)');
      if (!caixaAtual || caixaAtual.status !== 'aberto') {
        setShowCashModal(true);
      }
      setInitialCheckDone(true);
    }
  }, [caixaAtual, loadingCaixa, initialCheckDone]) // Deps necessárias para verificação inicial

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

  // Função para navegar para página de criar produto
  const handleCreateProduct = () => {
    navigate('/produtos', { state: { openForm: true } })
    toast.success('Abrindo formulário de cadastro de produtos...')
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
    console.log('🎯 handleProductSelect chamado:', { 
      productId: product.id, 
      productName: product.name, 
      receivedQuantity: quantity,
      productPrice: product.price
    })
    
    // Permite adicionar ao carrinho independentemente do estoque
    // O sistema agora trabalha com estoque negativo
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
      // Determinar método de pagamento correto
      let paymentMethod: 'cash' | 'card' | 'pix' | 'mixed' = 'cash'
      
      if (payments.length === 0) {
        // Sem pagamentos no array = pagamento em dinheiro direto
        paymentMethod = 'cash'
      } else if (payments.length === 1) {
        // Um único método de pagamento
        const method = payments[0].method
        if (method === 'cash') paymentMethod = 'cash'
        else if (method === 'pix') paymentMethod = 'pix'
        else if (method === 'credit' || method === 'debit') paymentMethod = 'card'
        else paymentMethod = 'cash'
      } else {
        // Múltiplos métodos = misto
        paymentMethod = 'mixed'
      }

      console.log('💳 [SALES] Método de pagamento detectado:', paymentMethod, {
        paymentsCount: payments.length,
        payments: payments.map(p => ({ method: p.method, amount: p.amount })),
        cashReceived
      })

      // Preparar dados da venda - produtos de venda rápida ficam apenas na memória
      const saleData = {
        customer_id: customer?.id,
        cash_register_id: caixaAtual.id,
        user_id: user.id,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        payment_method: paymentMethod,
        payment_details: {
          payments_count: payments.length,
          cash_received: cashReceived,
          change_amount: changeAmount
        } as Record<string, string | number | boolean>,
        status: 'completed' as const,
        notes: '',
        sale_items: items.map(item => ({
          product_id: item.product.id.startsWith('quick-') ? null : item.product.id,
          product_name: item.product.name,
          quantity: item.quantity,
          unit_price: item.unit_price,
          total_price: item.total_price
        }))
      }

      // Criar venda
      const sale = await salesService.create(saleData)

      // Salvar dados para impressão ANTES de limpar
      const dadosParaImpressao = {
        sale,
        saleData,
        customerData: customer // Salva o customer antes de limpar
      }

      // Limpar formulário COMPLETO
      clearCart()
      setCustomer(null)
      setClienteSelecionado(null) // Remove o cliente selecionado
      setCashReceived(0)
      resetCalculation()

      toast.success('Venda finalizada com sucesso!')

      // Mostrar modal de confirmação de impressão
      setPendingSaleData(dadosParaImpressao)
      setShowPrintModal(true)

    } catch (error) {
      console.error('Erro ao finalizar venda:', error)
      toast.error('Erro ao finalizar venda. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

    // Imprimir comprovante
  const handlePrintReceipt = (saleId: string, saleData: any, customerData?: Customer | null) => {
    try {
      // Usa o customerData passado ou o customer do estado (para preview)
      const clienteParaImprimir = customerData !== undefined ? customerData : customer;
      
      console.log('📄 Dados para impressão:', {
        customer: clienteParaImprimir,
        empresaSettings
      });

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
        customer: clienteParaImprimir ? {
          id: clienteParaImprimir.id,
          name: clienteParaImprimir.name,
          email: clienteParaImprimir.email,
          phone: clienteParaImprimir.phone,
          document: clienteParaImprimir.document
        } : null,
        storeName: empresaSettings.nome || "RaVal pdv",
        storeInfo: {
          logo: empresaSettings.logo,
          razao_social: empresaSettings.razao_social,
          cnpj: empresaSettings.cnpj,
          phone: empresaSettings.telefone,
          email: empresaSettings.email,
          // Endereço completo separado
          logradouro: empresaSettings.logradouro,
          numero: empresaSettings.numero,
          complemento: empresaSettings.complemento,
          bairro: empresaSettings.bairro,
          cidade: empresaSettings.cidade,
          estado: empresaSettings.estado,
          cep: empresaSettings.cep,
          // Fallback para endereço antigo (se ainda não foi migrado)
          address: !empresaSettings.logradouro ? "Configure o endereço em Configurações → Empresa" : undefined
        },
        cashReceived,
        changeAmount,
        // Buscar configurações de impressão do localStorage
        printConfig: (() => {
          try {
            const configStr = localStorage.getItem('print_config');
            if (!configStr) return undefined;
            
            const config = JSON.parse(configStr);
            console.log('📋 Configurações de impressão carregadas:', config);
            return config;
          } catch (error) {
            console.error('Erro ao carregar configurações de impressão:', error);
            return undefined;
          }
        })()
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
    <div className="bg-gradient-to-br from-secondary-50 via-white to-primary-50 pb-8">
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
      
      {/* Background Pattern - z-index negativo para não bloquear header */}
      <div className="absolute inset-0 opacity-5 pointer-events-none" style={{ zIndex: -1 }}>
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
          <div className="space-y-6">
            {/* Layout Principal - 3 Colunas em Desktop */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
              {/* Coluna Esquerda - Busca e Cliente (Compacta) */}
              <div className="space-y-4 lg:col-span-3">
                {/* Card de Busca de Produtos */}
                <div className="scale-90 origin-top">
                  <ProductSearch 
                    onProductSelect={handleProductSelect}
                    onBarcodeSearch={(barcode) => console.log('Barcode:', barcode)}
                    onCreateProduct={handleCreateProduct}
                  />
                </div>

                {/* Card de Cliente */}
                <div className="scale-90 origin-top">
                  <ClienteSelector 
                    clienteSelecionado={clienteSelecionado}
                    onClienteSelect={setClienteSelecionado}
                    titulo="Cliente da Venda"
                    showCard={false}
                  />
                </div>

                {/* Seção de Venda Avulsa */}
                <Card className="p-4 bg-gradient-to-r from-orange-50 to-amber-50 border-2 border-orange-200">
                  <div className="space-y-3">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-amber-500 rounded-lg flex items-center justify-center shadow-lg">
                        <FileText className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <h3 className="text-base font-bold text-gray-900">Venda Avulsa</h3>
                        <p className="text-xs text-gray-600">Sem cadastro no estoque</p>
                      </div>
                    </div>
                    <Button
                      onClick={() => setShowQuickSaleModal(true)}
                      size="sm"
                      className="w-full bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 text-white font-semibold shadow-lg"
                    >
                      <FileText className="w-4 h-4 mr-2" />
                      Iniciar Venda Avulsa
                    </Button>
                  </div>
                </Card>
              </div>

              {/* Coluna do Meio - Carrinho */}
              <div className="lg:col-span-5">
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

              {/* Coluna Direita - Pagamento */}
              <div className="space-y-4 lg:col-span-4">
                {/* Formulário de Pagamento */}
                <PagamentoForm
                  totalAmount={totalAmount}
                  payments={payments}
                  onAddPayment={addPayment}
                  onRemovePayment={removePayment}
                  cashReceived={cashReceived}
                  onCashReceivedChange={setCashReceived}
                  changeAmount={changeAmount}
                  hasItems={items.length > 0}
                />

                {/* Botões de Ação */}
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
            handlePrintReceipt(
              pendingSaleData.sale.id, 
              pendingSaleData.saleData,
              pendingSaleData.customerData // Passa o customer salvo
            )
          }
        }}
        saleTotal={totalAmount}
        customerName={pendingSaleData?.customerData?.name || customer?.name || clienteSelecionado?.nome}
      />

      {/* Modal de Venda Rápida */}
      {showQuickSaleModal && (
        <QuickSaleModal
          isOpen={showQuickSaleModal}
          onClose={() => setShowQuickSaleModal(false)}
          onSubmit={(data) => {
            try {
              // Criar produto temporário apenas para o carrinho (não salva no banco)
              const productId = `quick-${Date.now()}`
              
              const quickProduct: Product = {
                id: productId,
                name: data.productName,
                price: data.productPrice,
                cost: data.productPrice * 0.7,
                stock_quantity: 999999,
                min_stock: 0,
                unit: 'un',
                active: true,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
              }
              addItem(quickProduct, data.quantity)
              
              // Se cliente rápido foi informado, selecionar
              if (data.customerName) {
                const quickCustomer: Customer = {
                  id: `quick-customer-${Date.now()}`,
                  name: data.customerName,
                  email: '',
                  phone: '',
                  active: true,
                  created_at: new Date().toISOString(),
                  updated_at: new Date().toISOString()
                }
                setCustomer(quickCustomer)
              }
              
              setShowQuickSaleModal(false)
              toast.success('Item adicionado à venda!')
              
            } catch (error) {
              console.error('Erro na venda rápida:', error)
              toast.error('Erro ao processar venda rápida. Tente novamente.')
            }
          }}
        />
      )}
    </div>
  )
}
