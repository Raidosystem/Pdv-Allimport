import { useState } from 'react'
import { Clock, AlertTriangle, CreditCard, X } from 'lucide-react'
import { Button } from '../ui/Button'
import { useSubscription } from '../../hooks/useSubscription'
import { useAuth } from '../../modules/auth/AuthContext'
import { PaymentPage } from './PaymentPage'

export function SubscriptionBanner() {
  const { isInTrial, isExpired, daysRemaining, subscriptionStatus } = useSubscription()
  const { isAdmin } = useAuth()
  const [showPayment, setShowPayment] = useState(false)
  const [dismissed, setDismissed] = useState(false)

  // Não mostrar para admins ou se foi dispensado
  if (isAdmin() || dismissed || !subscriptionStatus?.has_subscription) {
    return null
  }

  // Mostrar modal de pagamento se solicitado
  if (showPayment) {
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
          <div className="p-4 border-b flex items-center justify-between">
            <h2 className="text-xl font-bold">Assinar RaVal pdv</h2>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowPayment(false)}
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
          <PaymentPage onPaymentSuccess={() => {
            setShowPayment(false)
            window.location.reload()
          }} />
        </div>
      </div>
    )
  }

  // Verificar se deve mostrar banner
  const shouldShow = isExpired || (isInTrial && daysRemaining <= 7)
  
  if (!shouldShow) {
    return null
  }

  const getBannerConfig = () => {
    if (isExpired) {
      return {
        icon: <AlertTriangle className="w-5 h-5" />,
        title: 'Período de teste expirado',
        message: 'Assine agora para continuar usando o RaVal pdv',
        bgColor: 'bg-red-500',
        textColor: 'text-white',
        urgent: true
      }
    }
    
    if (daysRemaining <= 3) {
      return {
        icon: <AlertTriangle className="w-5 h-5" />,
        title: `Apenas ${daysRemaining} dias restantes`,
        message: 'Seu período de teste está acabando. Assine para não perder o acesso',
        bgColor: 'bg-orange-500',
        textColor: 'text-white',
        urgent: true
      }
    }
    
    return {
      icon: <Clock className="w-5 h-5" />,
      title: `${daysRemaining} dias restantes do teste`,
      message: 'Assine o RaVal pdv e continue aproveitando todas as funcionalidades',
      bgColor: 'bg-blue-500',
      textColor: 'text-white',
      urgent: false
    }
  }

  const config = getBannerConfig()

  return (
    <div className={`${config.bgColor} ${config.textColor} shadow-lg relative`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            {config.icon}
            <div>
              <p className="font-semibold">{config.title}</p>
              <p className="text-sm opacity-90">{config.message}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-3">
            <Button
              onClick={() => setShowPayment(true)}
              className="bg-white text-gray-900 hover:bg-gray-100 font-medium"
              size="sm"
            >
              <CreditCard className="w-4 h-4 mr-2" />
              Assinar Agora
            </Button>
            
            {!config.urgent && (
              <Button
                onClick={() => setDismissed(true)}
                variant="outline"
                size="sm"
                className="border-white/20 text-white hover:bg-white/10"
              >
                <X className="w-4 h-4" />
              </Button>
            )}
          </div>
        </div>
      </div>
      
      {/* Animação de urgência para casos críticos */}
      {config.urgent && (
        <div className="absolute inset-0 animate-pulse opacity-20 bg-white pointer-events-none"></div>
      )}
    </div>
  )
}
