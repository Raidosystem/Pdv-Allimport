import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Printer, FileText, AlertCircle, Clock, DollarSign } from 'lucide-react'
import { toast } from 'react-hot-toast'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { useAuth } from '../auth'
import { useCaixa } from '../../hooks/useCaixa'
import { usePrintReceipt } from '../../hooks/usePrintReceipt'
import { usePrintSettings } from '../../hooks/usePrintSettings'
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
import { supabase } from '../../lib/supabase'
import type { Product, Customer, Sale } from '../../types/sales'
import type { Cliente } from '../../types/cliente'
import { formatCurrency } from '../../utils/format'

export function SalesPage() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const { caixaAtual, loading: loadingCaixa, abrirCaixa } = useCaixa()
  const { printReceipt } = usePrintReceipt()
  const { settings: printSettings, loading: loadingPrintSettings } = usePrintSettings()
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
  const [recentSales, setRecentSales] = useState<any[]>([])
  const [loadingRecentSales, setLoadingRecentSales] = useState(false)
  const [showReprintModal, setShowReprintModal] = useState(false)
  const [saleToReprint, setSaleToReprint] = useState<any>(null)

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

  // Carregar últimas vendas
  const loadRecentSales = async () => {
    if (!user) {
      console.log('⚠️ [RECENT SALES] User não disponível')
      return
    }
    
    try {
      console.log('🔄 [RECENT SALES] Carregando vendas recentes...')
      setLoadingRecentSales(true)
      const { data, error } = await supabase
        .from('vendas')
        .select(`
          *,
          clientes (
            nome,
            cpf_cnpj
          ),
          vendas_itens (
            *,
            produtos (
              id,
              nome,
              codigo_barras
            )
          )
        `)
        .order('criado_em', { ascending: false })
        .limit(10)
      
      if (error) {
        console.error('❌ [RECENT SALES] Erro ao carregar:', error)
        throw error
      }
      
      console.log('✅ [RECENT SALES] Vendas carregadas:', data?.length || 0)
      setRecentSales(data || [])
    } catch (error) {
      console.error('❌ [RECENT SALES] Erro ao carregar vendas recentes:', error)
    } finally {
      setLoadingRecentSales(false)
    }
  }

  // Carregar vendas ao iniciar e quando caixa estiver aberto
  useEffect(() => {
    if (caixaAtual?.status === 'aberto' && user) {
      console.log('🎯 [RECENT SALES] useEffect disparado - carregando vendas')
      loadRecentSales()
    }
  }, [caixaAtual?.status, user?.id]) // Dependências mais específicas

  // Função para reimprimir venda
  const handleReprintSale = (sale: any) => {
    console.log('🖨️ Preparando reimpressão de venda:', sale.id)
    setSaleToReprint(sale)
    setShowReprintModal(true)
  }

  const confirmReprintSale = () => {
    if (!saleToReprint) return

    try {
      const customerData = saleToReprint.clientes ? {
        id: saleToReprint.customer_id || '',
        name: saleToReprint.clientes.nome,
        document: saleToReprint.clientes.cpf_cnpj,
      } : {
        id: 'quick-customer',
        name: saleToReprint.detalhes_pagamento?.quick_customer_name || 'Cliente Rápido'
      }

      // Formatar itens com dados dos produtos
      const formattedItems = (saleToReprint.vendas_itens || []).map((item: any) => ({
        product_id: item.product_id || item.produto_id,
        quantity: item.quantidade || item.quantity,
        unit_price: item.preco_unitario || item.unit_price,
        total_price: item.preco_total || item.total_price,
        product: {
          name: item.produtos?.nome || item.product?.name || 'Produto',
          sku: item.produtos?.codigo_barras || item.product?.sku
        }
      }))

      console.log('🖨️ [REPRINT] Dados completos para impressão:', {
        customer: customerData,
        items: formattedItems,
        empresaSettings,
        printSettings
      })

      printReceipt({
        sale: {
          id: saleToReprint.id,
          total_amount: saleToReprint.total,
          discount_amount: saleToReprint.desconto || 0,
          payment_method: saleToReprint.metodo_pagamento,
          payment_details: saleToReprint.detalhes_pagamento,
          created_at: saleToReprint.criado_em,
          items: formattedItems
        },
        customer: customerData,
        storeName: empresaSettings.nome || "RaVal pdv",
        storeInfo: {
          logo: empresaSettings.logo,
          razao_social: empresaSettings.razao_social,
          cnpj: empresaSettings.cnpj,
          phone: empresaSettings.telefone,
          email: empresaSettings.email,
          logradouro: empresaSettings.logradouro,
          numero: empresaSettings.numero,
          complemento: empresaSettings.complemento,
          bairro: empresaSettings.bairro,
          cidade: empresaSettings.cidade,
          estado: empresaSettings.estado,
          cep: empresaSettings.cep,
          address: !empresaSettings.logradouro ? "Configure o endereço em Configurações → Empresa" : undefined
        },
        printConfig: {
          cabecalho_personalizado: printSettings.cabecalhoPersonalizado,
          rodape_linha1: printSettings.rodapeLinha1,
          rodape_linha2: printSettings.rodapeLinha2,
          rodape_linha3: printSettings.rodapeLinha3,
          rodape_linha4: printSettings.rodapeLinha4
        }
      })

      toast.success('Comprovante reimpresso!')
      setShowReprintModal(false)
      setSaleToReprint(null)
    } catch (error) {
      console.error('Erro ao reimprimir:', error)
      toast.error('Erro ao reimprimir comprovante')
    }
  }

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
        // ✅ Só enviar customer_id se for UUID válido (não quick-customer)
        customer_id: (customer?.id && !customer.id.startsWith('quick-')) ? customer.id : undefined,
        cash_register_id: caixaAtual.id,
        user_id: user.id,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        payment_method: paymentMethod,
        payment_details: {
          payments_count: payments.length,
          cash_received: cashReceived,
          change_amount: changeAmount,
          // Salvar nome do cliente rápido para impressão
          quick_customer_name: customer?.id.startsWith('quick-') ? customer.name : undefined
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

      // Recarregar vendas recentes
      loadRecentSales()

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
      
      console.log('📄 [VENDA] Dados para impressão:', {
        customer: clienteParaImprimir,
        empresaSettings,
        printSettings: {
          cabecalho: printSettings.cabecalhoPersonalizado?.substring(0, 50),
          rodape1: printSettings.rodapeLinha1?.substring(0, 30),
          timestamp: new Date().toISOString()
        }
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
        // Buscar configurações de impressão do banco de dados
        printConfig: {
          cabecalho_personalizado: printSettings.cabecalhoPersonalizado,
          rodape_linha1: printSettings.rodapeLinha1,
          rodape_linha2: printSettings.rodapeLinha2,
          rodape_linha3: printSettings.rodapeLinha3,
          rodape_linha4: printSettings.rodapeLinha4
        }
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

              {/* Coluna do Meio - Carrinho e Últimas Vendas */}
              <div className="lg:col-span-5 space-y-4">
                {/* Carrinho */}
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

                {/* Últimas Vendas */}
                <Card className="p-4 bg-white border-0 shadow-lg">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                        <Clock className="w-4 h-4 text-white" />
                      </div>
                      <div>
                        <h3 className="text-sm font-bold text-gray-900">Últimas Vendas</h3>
                        <p className="text-xs text-gray-600">10 mais recentes</p>
                      </div>
                    </div>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={loadRecentSales}
                      disabled={loadingRecentSales}
                      className="text-xs"
                    >
                      {loadingRecentSales ? 'Carregando...' : 'Atualizar'}
                    </Button>
                  </div>

                  {loadingRecentSales ? (
                    <div className="text-center py-6">
                      <div className="w-6 h-6 mx-auto border-4 border-gray-300 border-t-blue-600 rounded-full animate-spin mb-2" />
                      <p className="text-xs text-gray-600">Carregando vendas...</p>
                    </div>
                  ) : recentSales.length === 0 ? (
                    <div className="text-center py-6">
                      <FileText className="w-8 h-8 mx-auto text-gray-400 mb-2" />
                      <p className="text-xs text-gray-600">Nenhuma venda realizada ainda</p>
                    </div>
                  ) : (
                    <div className="overflow-x-auto">
                      <table className="w-full text-xs">
                        <thead>
                          <tr className="border-b border-gray-200">
                            <th className="text-left py-2 px-2 font-semibold text-gray-700">Data/Hora</th>
                            <th className="text-left py-2 px-2 font-semibold text-gray-700">Cliente</th>
                            <th className="text-left py-2 px-2 font-semibold text-gray-700">Pgto</th>
                            <th className="text-right py-2 px-2 font-semibold text-gray-700">Total</th>
                            <th className="text-center py-2 px-2 font-semibold text-gray-700">Ações</th>
                          </tr>
                        </thead>
                        <tbody>
                          {recentSales.map((sale, index) => (
                            <tr 
                              key={sale.id} 
                              className={`border-b border-gray-100 hover:bg-gray-50 transition-colors ${index === 0 ? 'bg-blue-50' : ''}`}
                            >
                              <td className="py-2 px-2 text-gray-700">
                                {new Date(sale.criado_em).toLocaleString('pt-BR', {
                                  day: '2-digit',
                                  month: '2-digit',
                                  hour: '2-digit',
                                  minute: '2-digit'
                                })}
                              </td>
                              <td className="py-2 px-2 text-gray-700 truncate max-w-[120px]">
                                {sale.clientes?.nome || sale.detalhes_pagamento?.quick_customer_name || 'Cliente Rápido'}
                              </td>
                              <td className="py-2 px-2">
                                <span className={`px-1.5 py-0.5 rounded-full font-medium ${
                                  sale.metodo_pagamento === 'cash' ? 'bg-green-100 text-green-700' :
                                  sale.metodo_pagamento === 'credit' ? 'bg-blue-100 text-blue-700' :
                                  sale.metodo_pagamento === 'debit' ? 'bg-purple-100 text-purple-700' :
                                  sale.metodo_pagamento === 'pix' ? 'bg-teal-100 text-teal-700' :
                                  'bg-gray-100 text-gray-700'
                                }`}>
                                  {sale.metodo_pagamento === 'cash' ? '💵' :
                                   sale.metodo_pagamento === 'credit' ? '💳' :
                                   sale.metodo_pagamento === 'debit' ? '💳' :
                                   sale.metodo_pagamento === 'pix' ? '📱' :
                                   sale.metodo_pagamento}
                                </span>
                              </td>
                              <td className="py-2 px-2 font-semibold text-right text-gray-900">
                                {formatCurrency(sale.total)}
                              </td>
                              <td className="py-2 px-2 text-center">
                                <Button
                                  onClick={() => handleReprintSale(sale)}
                                  size="sm"
                                  variant="ghost"
                                  className="px-2 py-1 h-auto text-xs hover:bg-blue-50"
                                  title="Reimprimir Venda"
                                >
                                  <Printer className="w-3.5 h-3.5" />
                                </Button>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </Card>
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
      {/* Modal de Confirmação de Reimpressão */}
      {showReprintModal && saleToReprint && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-[110]">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Reimprimir Venda</h3>
              <button
                onClick={() => {
                  setShowReprintModal(false)
                  setSaleToReprint(null)
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                ✕
              </button>
            </div>

            <div className="space-y-3 mb-6">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Cliente:</span>
                <span className="font-medium text-gray-900">
                  {saleToReprint.clientes?.nome || saleToReprint.detalhes_pagamento?.quick_customer_name || 'Cliente Rápido'}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Total:</span>
                <span className="font-semibold text-lg text-green-600">
                  {formatCurrency(saleToReprint.total)}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Data:</span>
                <span className="font-medium text-gray-900">
                  {new Date(saleToReprint.criado_em).toLocaleString('pt-BR')}
                </span>
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                onClick={() => {
                  setShowReprintModal(false)
                  setSaleToReprint(null)
                }}
                variant="outline"
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button
                onClick={confirmReprintSale}
                className="flex-1 bg-blue-600 hover:bg-blue-700"
              >
                <Printer className="w-4 h-4 mr-2" />
                Imprimir
              </Button>
            </div>
          </div>
        </div>
      )}
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
