import { useState, useEffect, useRef } from 'react'
import { useSearchParams, useNavigate } from 'react-router-dom'
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

export function PaymentPage({}: PaymentPageProps) {
  const { user } = useAuth()
  const { subscription, daysRemaining, refresh, activateAfterPayment, isInTrial } = useSubscription()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const isRenewal = searchParams.get('action') === 'renew'
  const [paymentMethod, setPaymentMethod] = useState<'pix' | 'card'>('pix')
  const [loading, setLoading] = useState(false)
  const [pixData, setPixData] = useState<{
    qr_code: string
    qr_code_base64: string
    payment_id: string
  } | null>(null)
  const [paymentStatus, setPaymentStatus] = useState<'waiting' | 'checking' | 'success' | 'failed'>('waiting')
  const [isDemoMode, setIsDemoMode] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [componentMounted, setComponentMounted] = useState(false)
  
  // Ref para controlar se o componente ainda está montado
  const isMountedRef = useRef(true)

  const plan = PAYMENT_PLANS[0] // Plano mensal

  // Garantir que o componente foi montado
  useEffect(() => {
    isMountedRef.current = true
    setComponentMounted(true)
    console.log('📱 PaymentPage montada', { user: user?.email, daysRemaining });
    
    return () => {
      console.log('🧹 PaymentPage desmontada');
      isMountedRef.current = false
      setComponentMounted(false);
    }
  }, [])

  // Proteção contra renderização prematura
  if (!componentMounted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-secondary-600">Carregando página de pagamento...</p>
        </div>
      </div>
    );
  }

  // Reset error when changing payment method
  const handlePaymentMethodChange = (method: 'pix' | 'card') => {
    setError(null)
    setPaymentMethod(method)
  }

  // NOTA: Verificação automática removida - o webhook do Mercado Pago 
  // agora ativa automaticamente as assinaturas quando PIX é aprovado

  const generatePixPayment = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    try {
      setLoading(true)
      setError('') // Limpar erros anteriores
      console.log('🚀 Iniciando geração de PIX para:', user.email)
      
      const userName = user.user_metadata?.name || user.email.split('@')[0]
      
      console.log('📋 Dados do pagamento:', {
        userEmail: user.email,
        userName,
        amount: plan.price,
        description: plan.description
      })
      
      const pix = await mercadoPagoService.createPixPayment({
        userEmail: user.email,
        userName: userName,
        amount: plan.price,
        description: plan.description
      })

      console.log('✅ Resposta do serviço PIX:', pix)
      console.log('🔍 PIX Success:', pix?.success)
      console.log('🔍 PIX QR Code:', pix?.qrCode ? 'PRESENTE' : 'AUSENTE')
      console.log('🔍 PIX QR Code Base64:', pix?.qrCodeBase64 ? 'PRESENTE' : 'AUSENTE')

      if (pix && pix.success) {
        const pixInfo = {
          qr_code: pix.qrCode || '',
          qr_code_base64: pix.qrCodeBase64 || '',
          payment_id: String(pix.paymentId || '')
        };
        
        console.log('📱 Dados do PIX a serem salvos:', pixInfo);
        
        // Verificar se pelo menos um dos QR codes foi gerado
        if (!pixInfo.qr_code && !pixInfo.qr_code_base64) {
          console.warn('⚠️ Nenhum QR Code foi gerado - forçando modo demo');
          pixInfo.qr_code = 'demo_qr_code_' + Date.now();
          // Usar um QR code demo melhor
          pixInfo.qr_code_base64 = 'data:image/svg+xml;base64,' + btoa(`
            <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
              <rect width="256" height="256" fill="white"/>
              <rect x="20" y="20" width="40" height="40" fill="black"/>
              <rect x="80" y="20" width="20" height="20" fill="black"/>
              <rect x="120" y="20" width="20" height="20" fill="black"/>
              <rect x="160" y="20" width="40" height="40" fill="black"/>
              <rect x="220" y="20" width="20" height="20" fill="black"/>
              <text x="128" y="120" text-anchor="middle" font-family="monospace" font-size="14" fill="black">
                QR CODE DEMO
              </text>
              <text x="128" y="140" text-anchor="middle" font-family="monospace" font-size="10" fill="gray">
                PIX de demonstração
              </text>
              <text x="128" y="160" text-anchor="middle" font-family="monospace" font-size="10" fill="gray">
                Valor: R$ ${plan.price.toFixed(2)}
              </text>
            </svg>
          `);
          pixInfo.payment_id = 'demo_' + Date.now();
          setIsDemoMode(true);
        }
        
        setPixData(pixInfo);
        setPaymentStatus('waiting');
        
        // Verificar se é modo demo
        if (String(pix.paymentId).startsWith('demo_') || pixInfo.payment_id.startsWith('demo_')) {
          setIsDemoMode(true);
          toast.success('QR Code PIX gerado! Escaneie para pagar.');
        } else {
          setIsDemoMode(false);
          toast.success('QR Code PIX gerado! Escaneie para pagar.');
          
          // Iniciar polling automático para verificar status do pagamento
          console.log('🔄 Iniciando polling para pagamento:', pixInfo.payment_id);
          startPaymentPolling(pixInfo.payment_id);
        }
        
        console.log('✅ Estado após geração do PIX:', {
          pixData: pixInfo,
          paymentStatus: 'waiting',
          isDemoMode: String(pix.paymentId).startsWith('demo_') || pixInfo.payment_id.startsWith('demo_')
        });
      } else {
        console.error('❌ Erro na resposta do serviço:', pix);
        setError('Erro ao gerar PIX. Tente novamente.');
        toast.error(pix?.error || 'Erro ao gerar PIX. Tente novamente.');
      }
    } catch (error) {
      console.error('❌ Erro ao gerar PIX:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido ao gerar PIX';
      setError(errorMessage);
      toast.error('Erro ao gerar PIX. Tente novamente.')
    } finally {
      setLoading(false)
      console.log('🏁 Finalizando generatePixPayment - loading:', false);
    }
  }

  const generateCardPayment = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    try {
      setLoading(true)
      setError(null) // Limpar erros anteriores
      
      const userName = user.user_metadata?.name || user.email.split('@')[0]
      
      console.log('🚀 Iniciando geração de preferência para cartão:', {
        userEmail: user.email,
        userName,
        amount: plan.price,
        description: plan.name
      })
      
      const preference = await mercadoPagoService.createPaymentPreference({
        userEmail: user.email,
        userName: userName,
        amount: plan.price,
        description: plan.name
      })

      console.log('✅ Resposta da preferência:', preference)

      if (preference.success && preference.checkoutUrl) {
        // Redirecionar para checkout do Mercado Pago
        toast.success('Redirecionando para checkout do Mercado Pago...')
        window.open(preference.checkoutUrl, '_blank')
        
        toast('💡 Após o pagamento, retorne a esta página para ativar sua assinatura', {
          duration: 8000,
          icon: 'ℹ️'
        })
      } else {
        const errorMessage = preference.error || 'Erro ao processar pagamento com cartão'
        setError(errorMessage)
        toast.error(errorMessage)
      }
      
    } catch (error) {
      console.error('❌ Erro ao gerar pagamento com cartão:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido ao processar cartão'
      setError(errorMessage)
      toast.error('Erro ao processar pagamento. Tente novamente.')
    } finally {
      setLoading(false)
    }
  }

  // Sistema de polling automático para verificar status do pagamento
  const startPaymentPolling = (paymentId: string) => {
    console.log('🔄 Iniciando polling para pagamento:', paymentId);
    
    const checkPayment = async () => {
      try {
        console.log('🔍 Verificando status do pagamento:', paymentId);
        const status = await mercadoPagoService.checkPaymentStatus(paymentId);
        console.log('📊 Status do pagamento:', status);
        
        if (status.approved) {
          console.log('🎉 Pagamento aprovado! Ativando assinatura...');
          setPaymentStatus('checking');
          toast.success('✅ Pagamento PIX aprovado!');
          
          try {
            // Ativar assinatura
            const result = await activateAfterPayment(paymentId, 'pix');
            console.log('✅ Assinatura ativada:', result);
            
            setPaymentStatus('success');
            toast.success('🎉 Assinatura ativada com sucesso!');
            
            // Atualizar dados da assinatura
            await refresh();
            
            // Redirecionar para dashboard
            setTimeout(() => {
              navigate('/dashboard');
            }, 2000);
            
          } catch (error) {
            console.error('❌ Erro ao ativar assinatura:', error);
            toast.error('Pagamento confirmado, mas erro na ativação. Contate o suporte.');
            setPaymentStatus('failed');
          }
          
          return true; // Para o polling
        }
        
        return false; // Continua o polling
      } catch (error) {
        console.error('❌ Erro no polling:', error);
        return false; // Continua o polling
      }
    };
    
    // Verificar imediatamente
    checkPayment().then(shouldStop => {
      if (shouldStop) return;
      
      // Continuar verificando a cada 10 segundos por até 15 minutos
      const interval = setInterval(async () => {
        const shouldStop = await checkPayment();
        if (shouldStop) {
          clearInterval(interval);
        }
      }, 10000);
      
      // Parar após 15 minutos (15 * 60 * 1000 = 900000ms)
      setTimeout(() => {
        clearInterval(interval);
        console.log('⏰ Polling finalizado após 15 minutos');
      }, 900000);
    });
  };

  const checkManualPayment = async () => {
    if (!user?.email) {
      toast.error('Usuário não encontrado')
      return
    }

    try {
      setLoading(true)
      toast.success('🔄 Verificando status da assinatura e pagamento...')
      
      let paymentApproved = false
      
      // Se temos um PIX pendente, verificar seu status primeiro
      if (pixData && pixData.payment_id && !String(pixData.payment_id).startsWith('mock-')) {
        console.log('🔍 Verificando status específico do PIX:', pixData.payment_id);
        try {
          toast.loading(`🔍 Consultando pagamento PIX: ${pixData.payment_id}...`, { duration: 3000 });
          
          const status = await mercadoPagoService.checkPaymentStatus(String(pixData.payment_id));
          console.log('📊 Status detalhado do PIX:', status);
          
          if (status.approved) {
            toast.success('✅ Pagamento PIX encontrado e aprovado!');
            paymentApproved = true
            
            // Ativar assinatura
            try {
              console.log('🚀 Iniciando ativação da assinatura...');
              const activationResult = await activateAfterPayment(String(pixData.payment_id), 'pix');
              console.log('✅ Resultado da ativação:', activationResult);
              
              toast.success('🎉 Assinatura ativada com sucesso!');
              
              // Atualizar estado local sem reload
              await refresh();
              setPaymentStatus('success');
              
              // Redirecionar para o dashboard após 2 segundos apenas se pagamento foi aprovado
              setTimeout(() => {
                navigate('/dashboard')
              }, 2000);
              
              return;
            } catch (activationError) {
              console.error('❌ Erro ao ativar assinatura:', activationError);
              toast.error('Pagamento confirmado, mas erro na ativação. Contate o suporte.');
              return;
            }
          } else {
            toast(`⏳ PIX ainda pendente. Status: ${status.status}`, {
              icon: 'ℹ️',
              duration: 6000
            });
            console.log('⏳ Detalhes do status pendente:', status);
            // Não redirecionar se pagamento ainda está pendente
            return;
          }
        } catch (statusError) {
          console.error('❌ Erro ao verificar status do PIX:', statusError);
          toast.error('Erro ao verificar status do PIX. Tente novamente em alguns minutos.');
          return;
        }
      }
      
      // Recarregar dados da assinatura
      console.log('🔄 Atualizando dados da assinatura...');
      await refresh();
      
      // Verificar se a assinatura está vencida (0 dias ou menos)
      const isExpired = daysRemaining <= 0;
      console.log('📅 Status da assinatura:', { daysRemaining, isExpired });
      
      if (!paymentApproved && !isExpired) {
        // Se não há pagamento aprovado e assinatura não venceu, não redirecionar
        toast.success('✅ Status da assinatura atualizado');
        return;
      }
      
      // Só redirecionar se pagamento foi aprovado OU se assinatura já venceu
      toast.success('✅ Status da assinatura atualizado');
      setTimeout(() => {
        navigate('/dashboard')
      }, 1500);
      
    } catch (error) {
      console.error('Erro ao verificar pagamento manual:', error)
      toast.error('Erro ao verificar status. Tente novamente.')
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

  // Fallback em caso de erro crítico ou usuário não encontrado
  if (error || !user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 flex items-center justify-center p-4">
        <div className="w-full max-w-2xl">
          <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
            <div className="p-8 text-center">
              <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-red-600 mb-4">
                {!user ? 'Usuário não encontrado' : 'Erro no Sistema de Pagamento'}
              </h2>
              <p className="text-secondary-600 mb-6">
                {!user ? 'Faça login para acessar esta página' : error}
              </p>
              <div className="space-x-3">
                <Button 
                  onClick={() => !user ? navigate('/login') : setError(null)} 
                  className="bg-primary-600 hover:bg-primary-700"
                >
                  {!user ? 'Fazer Login' : 'Tentar Novamente'}
                </Button>
                <Button 
                  onClick={() => navigate('/dashboard')} 
                  variant="outline"
                >
                  Voltar ao Dashboard
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </div>
    )
  }

  // Renderização principal protegida
  try {
    return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
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
            {isRenewal ? 'Renovar Assinatura' : 
             isTrialExpired ? 'Período de teste expirado' : 'Continue usando o PDV'}
          </h1>
          <p className="text-secondary-600 text-lg">
            {isRenewal 
              ? `Renovar antecipadamente sua assinatura. ${isInTrial ? `Ainda restam ${daysRemaining} dias do teste.` : 'Sua assinatura atual será estendida.'}`
              : isTrialExpired 
              ? 'Para continuar usando o sistema, escolha um plano de pagamento'
              : `Faltam ${daysRemaining} dias do seu período de teste`
            }
          </p>

          {/* Aviso especial para renovação antecipada */}
          {isRenewal && (
            <div className="mt-4 p-4 bg-purple-50 border border-purple-200 rounded-lg">
              <div className="flex items-center gap-2 text-purple-800">
                <Zap className="w-5 h-5" />
                <span className="font-semibold">Renovação Antecipada</span>
              </div>
              <p className="text-sm text-purple-700 mt-1">
                💡 Ao renovar agora, o tempo restante da sua assinatura atual será preservado e adicionado ao novo período.
              </p>
            </div>
          )}
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
                  Sua assinatura foi ativada com sucesso. Redirecionando automaticamente...
                </p>
                <Button 
                  onClick={() => navigate('/dashboard')}
                  className="bg-green-600 hover:bg-green-700"
                >
                  Acessar sistema agora
                </Button>
              </div>
            ) : pixData && (pixData.qr_code_base64 || pixData.qr_code) ? (
              /* Exibir QR Code PIX */
              <div className="text-center">
                <h3 className="font-semibold text-secondary-900 mb-4">
                  Escaneie o QR Code para pagar
                </h3>
                
                {pixData.qr_code_base64 ? (
                  <div className="bg-white p-4 rounded-lg border-2 border-dashed border-secondary-300 mb-6 inline-block">
                    <img
                      src={pixData.qr_code_base64.startsWith('data:') ? pixData.qr_code_base64 : `data:image/png;base64,${pixData.qr_code_base64}`}
                      alt="QR Code PIX"
                      className="w-48 h-48 mx-auto"
                      onError={(e) => {
                        console.error('Erro ao carregar QR Code:', e);
                        console.log('QR Code Base64:', pixData.qr_code_base64);
                        // Não mostrar erro, apenas log para debug
                        console.warn('QR Code não pôde ser carregado, mas código PIX está disponível');
                      }}
                      onLoad={() => console.log('QR Code carregado com sucesso')}
                    />
                  </div>
                ) : pixData.qr_code ? (
                  <div className="bg-white p-4 rounded-lg border-2 border-dashed border-secondary-300 mb-6 inline-block">
                    <div className="w-48 h-48 mx-auto flex items-center justify-center bg-gray-100 rounded">
                      <div className="text-center">
                        <QrCode className="w-16 h-16 text-gray-400 mx-auto mb-2" />
                        <p className="text-xs text-gray-500">QR Code disponível</p>
                        <p className="text-xs text-gray-500">Use o código abaixo</p>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="bg-white p-4 rounded-lg border-2 border-dashed border-secondary-300 mb-6 inline-block">
                    <div className="w-48 h-48 mx-auto flex items-center justify-center bg-gray-100 rounded">
                      <QrCode className="w-16 h-16 text-gray-400" />
                    </div>
                    <p className="text-sm text-gray-600 mt-2">QR Code será exibido aqui</p>
                  </div>
                )}

                {pixData.qr_code && (
                  <div className="bg-secondary-50 p-4 rounded-lg mb-6">
                    <p className="text-sm text-secondary-600 mb-2">Ou copie o código PIX:</p>
                    <div className="bg-white p-3 rounded border font-mono text-sm break-all">
                      {pixData.qr_code}
                    </div>
                  </div>
                )}

                <div className="flex items-center justify-center space-x-2 text-secondary-600 mb-6">
                  {paymentStatus === 'checking' ? (
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
                        toast.success('🎉 Pagamento confirmado! Aguarde...')
                        setTimeout(() => {
                          refresh()
                        }, 2000)
                      }}
                      className="bg-green-600 hover:bg-green-700 text-white"
                    >
                      ✅ Confirmar Pagamento
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
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-colors relative ${
                      paymentMethod === 'pix'
                        ? 'border-primary-500 bg-primary-50'
                        : 'border-secondary-200 hover:border-secondary-300'
                    }`}
                    onClick={() => handlePaymentMethodChange('pix')}
                  >
                    {/* Badge recomendado */}
                    <div className="absolute -top-2 -right-2 bg-green-500 text-white text-xs px-2 py-1 rounded-full font-semibold">
                      ✅ Recomendado
                    </div>
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
                        <p className="text-sm text-secondary-600">Pagamento instantâneo • Aprovação automática</p>
                      </div>
                    </div>
                  </div>

                  <div
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-colors relative ${
                      paymentMethod === 'card'
                        ? 'border-primary-500 bg-primary-50'
                        : 'border-secondary-200 hover:border-secondary-300'
                    }`}
                    onClick={() => handlePaymentMethodChange('card')}
                  >
                    {/* Badge disponível */}
                    <div className="absolute -top-2 -right-2 bg-blue-500 text-white text-xs px-2 py-1 rounded-full font-semibold">
                      💳 Disponível
                    </div>
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
                        <p className="text-sm text-secondary-600">Parcelamento em até 12x • Checkout seguro</p>
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
          
          {/* Botão para verificar pagamento manual */}
          <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-blue-800 font-medium mb-2">
              💳 Já fez o pagamento?
            </p>
            <p className="text-blue-600 text-sm mb-3">
              <span className="font-medium">🚀 NOVIDADE:</span> O sistema agora detecta pagamentos automaticamente via webhook!
              <br />
              Se você já efetuou o pagamento, aguarde alguns minutos ou clique no botão abaixo para verificar.
              <br />
              <span className="font-medium">
                O sistema só redirecionará automaticamente após confirmar a aprovação do pagamento.
              </span>
            </p>
            <Button
              onClick={checkManualPayment}
              loading={loading}
              variant="outline"
              className="bg-blue-600 text-white hover:bg-blue-700 border-blue-600"
            >
              🔄 Verificar Status da Assinatura
            </Button>
            
            {/* Botão para voltar ao dashboard */}
            <div className="mt-3">
              <Button
                onClick={() => navigate('/dashboard')}
                variant="outline"
                className="bg-gray-100 text-gray-700 hover:bg-gray-200 border-gray-300"
              >
                ← Voltar ao Dashboard
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
  } catch (renderError) {
    console.error('❌ Erro na renderização da PaymentPage:', renderError);
    
    // Fallback de emergência
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-secondary-50 flex items-center justify-center p-4">
        <div className="w-full max-w-2xl">
          <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
            <div className="p-8 text-center">
              <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-red-600 mb-4">Erro de Renderização</h2>
              <p className="text-secondary-600 mb-6">
                Ocorreu um erro inesperado. Tente recarregar a página.
              </p>
              <div className="space-x-3">
                <Button 
                  onClick={() => window.location.reload()} 
                  className="bg-primary-600 hover:bg-primary-700"
                >
                  Recarregar Página
                </Button>
                <Button 
                  onClick={() => navigate('/dashboard')} 
                  variant="outline"
                >
                  Voltar ao Dashboard
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </div>
    );
  }
}
