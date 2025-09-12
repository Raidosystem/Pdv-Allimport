import { Calendar, Clock, CreditCard } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'
import { useAuth } from '../../modules/auth/AuthContext'
import { Link } from 'react-router-dom'

interface PaymentCountdownProps {
  className?: string
}

export function PaymentCountdown({ className = '' }: PaymentCountdownProps) {
  console.log('🚨 PAYMENT COUNTDOWN INICIANDO...')
  
  const { subscription, isActive, subscriptionStatus, loading, error, daysRemaining } = useSubscription()
  const { user } = useAuth()

  console.log('💳 PaymentCountdown renderizado!')

  // Debug: verificar status da assinatura
  console.log('PaymentCountdown Debug:', {
    isActive,
    subscription: subscription ? 'existe' : 'null',
    subscriptionStatus,
    loading,
    error,
    daysRemaining,
    user: user ? user.email : 'null'
  })

  // Mostrar loading se ainda carregando
  if (loading) {
    return (
      <div className={`flex items-center gap-2 px-3 py-2 bg-gray-100 text-gray-700 rounded-lg border ${className}`}>
        <Clock className="w-4 h-4 animate-spin" />
        <span className="text-sm font-medium">Carregando assinatura...</span>
      </div>
    )
  }

  // Mostrar erro se houver
  if (error) {
    return (
      <div className={`flex items-center gap-2 px-3 py-2 bg-red-100 text-red-700 rounded-lg border border-red-300 ${className}`}>
        <CreditCard className="w-4 h-4" />
        <span className="text-sm font-medium">Erro: {error}</span>
      </div>
    )
  }

  // Mostrar informações mesmo sem assinatura ativa (para debug)
  if (!isActive || !subscription) {
    console.log('PaymentCountdown não será exibido:', { isActive, hasSubscription: !!subscription })
    
    // Mostrar informações de debug no desenvolvimento
    if (process.env.NODE_ENV === 'development') {
      return (
        <div className={`flex flex-col gap-2 px-3 py-2 bg-yellow-100 text-yellow-800 rounded-lg border border-yellow-300 ${className}`}>
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4" />
            <span className="text-sm font-medium">Debug: Assinatura</span>
          </div>
          <div className="text-xs">
            <div>isActive: {isActive ? 'true' : 'false'}</div>
            <div>subscription: {subscription ? 'existe' : 'null'}</div>
            <div>status: {subscriptionStatus?.status || 'null'}</div>
            <div>has_subscription: {subscriptionStatus?.has_subscription ? 'true' : 'false'}</div>
            <div>daysRemaining: {daysRemaining}</div>
            {user && (
              <div className="mt-2">
                <Link 
                  to="/assinatura" 
                  className="inline-flex items-center gap-1 text-yellow-700 hover:text-yellow-900 underline"
                >
                  <CreditCard className="w-3 h-3" />
                  Configurar Assinatura
                </Link>
              </div>
            )}
          </div>
        </div>
      )
    }
    
    return null
  }

  // Determinar cor baseada nos dias restantes
  const getColorInfo = () => {
    if (daysRemaining <= 0) {
      return {
        bgColor: 'bg-red-100',
        textColor: 'text-red-800',
        borderColor: 'border-red-300',
        icon: <CreditCard className="w-4 h-4" />
      }
    } else if (daysRemaining <= 3) {
      return {
        bgColor: 'bg-orange-100',
        textColor: 'text-orange-800',
        borderColor: 'border-orange-300',
        icon: <Clock className="w-4 h-4" />
      }
    } else if (daysRemaining <= 7) {
      return {
        bgColor: 'bg-yellow-100',
        textColor: 'text-yellow-800',
        borderColor: 'border-yellow-300',
        icon: <Clock className="w-4 h-4" />
      }
    } else {
      return {
        bgColor: 'bg-green-100',
        textColor: 'text-green-800',
        borderColor: 'border-green-300',
        icon: <Calendar className="w-4 h-4" />
      }
    }
  }

  const colorInfo = getColorInfo()

  // Texto baseado nos dias restantes - versão simplificada para header
  const getCountdownText = () => {
    if (daysRemaining <= 0) {
      return '0'
    } else {
      return `${daysRemaining}`
    }
  }

  return (
    <Link 
      to="/assinatura" 
      className={`
        inline-flex items-center space-x-2 px-3 py-1 rounded-lg border text-sm font-medium transition-colors
        ${colorInfo.bgColor} ${colorInfo.textColor} ${colorInfo.borderColor}
        hover:opacity-80
      `}
    >
      {colorInfo.icon}
      <span>{getCountdownText()}</span>
    </Link>
  )
}