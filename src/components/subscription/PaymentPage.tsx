import { useState, useEffect } from 'react'
import { CreditCard, QrCode, CheckCircle, Clock, AlertCircle, Zap } from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { useAuth } from '../../modules/auth/AuthContext'
import { useSubscription } from '../../hooks/useSubscription'
import { mercadoPagoApiService as mercadoPagoService } from '../../services/mercadoPagoApiService'
import { PAYMENT_PLANS } from '../../types/subscription'
import toast from 'react-hot-toast'

interface PaymentPageProps {
  onPaymentSuccess?: () => void
}

export function PaymentPage({ onPaymentSuccess }: PaymentPageProps) {
  const { user } = useAuth()
  const { subscription, daysRemaining, refresh } = useSubscription()
  const [paymentMethod, setPaymentMethod] = useState<'pix' | 'card'>('pix')
  const [loading, setLoading] = useState(false)
  const [pixData, setPixData] = useState<{
    qr_code: string
    qr_code_base64: string
    payment_id: string
  } | null>(null)
  const [checkingPayment, setCheckingPayment] = useState(false)
  const [paymentStatus, setPaymentStatus] = useState<'waiting' | 'checking' | 'success' | 'failed'>('waiting')
  const [isDemoMode, setIsDemoMode] = useState(false)

  const plan = PAYMENT_PLANS[0] // Plano mensal

  // Verificar status do pagamento PIX periodicamente
  useEffect(() => {
    if (pixData && paymentStatus === 'waiting' && !pixData.payment_id.startsWith('mock-')) {
      const interval = setInterval(async () => {
        try {
          setCheckingPayment(true)
          const status = await mercadoPagoService.checkPaymentStatus(pixData.payment_id)
          
          if (status.approved) {
            setPaymentStatus('success')
            toast.success('🎉 Pagamento confirmado! Ativando sua assinatura...')
            
            // Ativar assinatura
            await refresh()
            onPaymentSuccess?.()
            
            clearInterval(interval)
          }
        } catch (error) {
          console.error('Erro ao verificar status do pagamento:', error)
        } finally {
          setCheckingPayment(false)
        }
      }, 5000) // Verificar a cada 5 segundos

      return () => clearInterval(interval)
    }
  }, [pixData, paymentStatus, refresh, onPaymentSuccess])

  const generatePixPayment = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    try {
      setLoading(true)
      const userName = user.user_metadata?.name || user.email.split('@')[0]
      
      const pix = await mercadoPagoService.createPixPayment({
        userEmail: user.email,
        userName: userName,
        amount: plan.price,
        description: plan.description
      })

      if (pix.success) {
        setPixData({
          qr_code: pix.qrCode || '',
          qr_code_base64: pix.qrCodeBase64 || '',
          payment_id: pix.paymentId || ''
        })
        setPaymentStatus('waiting')
        
        // Verificar se é modo demo
        if (pix.paymentId?.startsWith('demo_')) {
          setIsDemoMode(true)
          toast.success('🧪 Modo demonstração: QR Code gerado para teste')
        } else {
          toast.success('QR Code PIX gerado! Escaneie para pagar.')
        }
      } else {
        toast.error('Erro ao gerar PIX. Tente novamente.')
      }
    } catch (error) {
      console.error('Erro ao gerar PIX:', error)
      toast.error('Erro ao gerar PIX. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  const generateCardPayment = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    try {
      setLoading(true)
      const userName = user.user_metadata?.name || user.email.split('@')[0]
      
      const preference = await mercadoPagoService.createPaymentPreference({
        userEmail: user.email,
        userName: userName,
        amount: plan.price,
        description: plan.name
      })

      if (preference.success) {
        // Verificar se é modo demo
        if (preference.paymentId?.startsWith('demo_')) {
          setIsDemoMode(true)
          toast.success('🧪 Modo demonstração: Checkout simulado')
          // Em modo demo, simular sucesso após 3 segundos
          setTimeout(() => {
            setPaymentStatus('success')
            toast.success('🎉 Pagamento simulado com sucesso!')
            setTimeout(() => {
              onPaymentSuccess?.()
            }, 2000)
          }, 3000)
        } else {
          // Redirecionar para checkout do Mercado Pago
          if (preference.checkoutUrl) {
            window.open(preference.checkoutUrl, '_blank')
            toast.success('Redirecionando para o checkout...')
          }
        }
      } else {
        toast.error('Erro ao gerar checkout. Tente novamente.')
      }
    } catch (error) {
      console.error('Erro ao gerar checkout:', error)
      toast.error('Erro ao gerar checkout. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  const handlePayment = async () => {
    if (paymentMethod === 'pix') {
      await generatePixPayment()
    } else {
      await generateCardPayment()
    }
  }

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(price)
  }

  const isTrialExpired = subscription?.status === 'expired' || daysRemaining === 0

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        {/* Demo Mode Banner */}
        {isDemoMode && (
          <div className="mb-6 bg-yellow-100 border border-yellow-400 text-yellow-800 px-4 py-3 rounded-lg">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium">Modo Demonstração</h3>
                <p className="text-sm">Este é um ambiente de teste. Nenhum pagamento real será processado.</p>
              </div>
            </div>
          </div>
        )}

        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            {isTrialExpired ? (
              <AlertCircle className="w-8 h-8 text-white" />
            ) : (
              <Clock className="w-8 h-8 text-white" />
            )}
          </div>
          <h1 className="text-3xl font-bold text-secondary-900 mb-2">
            {isTrialExpired ? 'Período de teste expirado' : 'Continue usando o PDV'}
          </h1>
          <p className="text-secondary-600 text-lg">
            {isTrialExpired 
              ? 'Para continuar usando o sistema, escolha um plano de pagamento'
              : `Faltam ${daysRemaining} dias do seu período de teste`
            }
          </p>
        </div>

        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            {/* Plano */}
            <div className="text-center mb-8">
              <h2 className="text-2xl font-bold text-secondary-900 mb-2">{plan.name}</h2>
              <div className="text-4xl font-bold text-primary-600 mb-2">
                {formatPrice(plan.price)}
                <span className="text-lg font-normal text-secondary-500">/mês</span>
              </div>
              <p className="text-secondary-600">{plan.description}</p>
            </div>

            {/* Features */}
            <div className="mb-8">
              <h3 className="font-semibold text-secondary-900 mb-4">O que está incluído:</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {plan.features.map((feature, index) => (
                  <div key={index} className="flex items-center space-x-3">
                    <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0" />
                    <span className="text-secondary-700">{feature}</span>
                  </div>
                ))}
              </div>
            </div>

            {paymentStatus === 'success' ? (
              /* Pagamento realizado com sucesso */
              <div className="text-center py-8">
                <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
                <h3 className="text-2xl font-bold text-green-600 mb-2">
                  Pagamento confirmado!
                </h3>
                <p className="text-secondary-600 mb-6">
                  Sua assinatura foi ativada com sucesso. Você já pode usar o sistema.
                </p>
                <Button 
                  onClick={() => window.location.reload()}
                  className="bg-green-600 hover:bg-green-700"
                >
                  Acessar sistema
                </Button>
              </div>
            ) : pixData ? (
              /* Exibir QR Code PIX */
              <div className="text-center">
                <h3 className="font-semibold text-secondary-900 mb-4">
                  Escaneie o QR Code para pagar
                </h3>
                
                {pixData.qr_code_base64 && (
                  <div className="bg-white p-4 rounded-lg border-2 border-dashed border-secondary-300 mb-6 inline-block">
                    <img
                      src={`data:image/png;base64,${pixData.qr_code_base64}`}
                      alt="QR Code PIX"
                      className="w-48 h-48 mx-auto"
                    />
                  </div>
                )}

                <div className="bg-secondary-50 p-4 rounded-lg mb-6">
                  <p className="text-sm text-secondary-600 mb-2">Ou copie o código PIX:</p>
                  <div className="bg-white p-3 rounded border font-mono text-sm break-all">
                    {pixData.qr_code}
                  </div>
                </div>

                <div className="flex items-center justify-center space-x-2 text-secondary-600 mb-6">
                  {checkingPayment ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-primary-600"></div>
                      <span>Verificando pagamento...</span>
                    </>
                  ) : (
                    <>
                      <Clock className="w-4 h-4" />
                      <span>Aguardando pagamento</span>
                    </>
                  )}
                </div>

                <div className="flex flex-col space-y-3">
                  <Button
                    onClick={() => setPixData(null)}
                    variant="outline"
                  >
                    Gerar novo QR Code
                  </Button>
                  <Button
                    onClick={() => setPaymentMethod('card')}
                    variant="outline"
                  >
                    Pagar com cartão
                  </Button>
                  {isDemoMode && (
                    <Button
                      onClick={() => {
                        setPaymentStatus('success')
                        toast.success('🎉 Pagamento PIX simulado com sucesso!')
                        setTimeout(() => onPaymentSuccess?.(), 2000)
                      }}
                      className="bg-green-600 hover:bg-green-700 text-white"
                    >
                      🧪 Simular Pagamento PIX
                    </Button>
                  )}
                </div>
              </div>
            ) : (
              /* Seleção de método de pagamento */
              <div className="space-y-6">
                <h3 className="font-semibold text-secondary-900 text-center mb-6">
                  Escolha a forma de pagamento:
                </h3>

                {/* Opções de pagamento */}
                <div className="space-y-4">
                  <div
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-colors ${
                      paymentMethod === 'pix'
                        ? 'border-primary-500 bg-primary-50'
                        : 'border-secondary-200 hover:border-secondary-300'
                    }`}
                    onClick={() => setPaymentMethod('pix')}
                  >
                    <div className="flex items-center space-x-3">
                      <div className={`w-5 h-5 rounded-full border-2 ${
                        paymentMethod === 'pix'
                          ? 'border-primary-500 bg-primary-500'
                          : 'border-secondary-300'
                      }`}>
                        {paymentMethod === 'pix' && (
                          <div className="w-full h-full rounded-full bg-white scale-50"></div>
                        )}
                      </div>
                      <Zap className="w-6 h-6 text-primary-600" />
                      <div>
                        <p className="font-semibold text-secondary-900">PIX</p>
                        <p className="text-sm text-secondary-600">Pagamento instantâneo</p>
                      </div>
                    </div>
                  </div>

                  <div
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-colors ${
                      paymentMethod === 'card'
                        ? 'border-primary-500 bg-primary-50'
                        : 'border-secondary-200 hover:border-secondary-300'
                    }`}
                    onClick={() => setPaymentMethod('card')}
                  >
                    <div className="flex items-center space-x-3">
                      <div className={`w-5 h-5 rounded-full border-2 ${
                        paymentMethod === 'card'
                          ? 'border-primary-500 bg-primary-500'
                          : 'border-secondary-300'
                      }`}>
                        {paymentMethod === 'card' && (
                          <div className="w-full h-full rounded-full bg-white scale-50"></div>
                        )}
                      </div>
                      <CreditCard className="w-6 h-6 text-primary-600" />
                      <div>
                        <p className="font-semibold text-secondary-900">Cartão de Crédito/Débito</p>
                        <p className="text-sm text-secondary-600">Parcelamento disponível</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Botão de pagamento */}
                <Button
                  onClick={handlePayment}
                  loading={loading}
                  className="w-full text-lg py-4"
                >
                  {paymentMethod === 'pix' ? (
                    <>
                      <QrCode className="w-5 h-5 mr-2" />
                      Gerar PIX de {formatPrice(plan.price)}
                    </>
                  ) : (
                    <>
                      <CreditCard className="w-5 h-5 mr-2" />
                      Pagar {formatPrice(plan.price)} com cartão
                    </>
                  )}
                </Button>
              </div>
            )}
          </div>
        </Card>

        {/* Informações adicionais */}
        <div className="text-center mt-6 text-secondary-600 text-sm">
          <p>Pagamento seguro processado pelo Mercado Pago</p>
          <p>Em caso de dúvidas, entre em contato pelo suporte</p>
        </div>
      </div>
    </div>
  )
}
