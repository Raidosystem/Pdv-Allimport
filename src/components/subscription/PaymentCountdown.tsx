import { useState, useEffect } from 'react'
import { Calendar, Clock, CreditCard } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'
import { useAuth } from '../../modules/auth/AuthContext'
import { Link } from 'react-router-dom'

interface PaymentCountdownProps {
  className?: string
}

export function PaymentCountdown({ className = '' }: PaymentCountdownProps) {
  console.log('🚨 PAYMENT COUNTDOWN INICIANDO...')
  
  const { subscription, isActive, subscriptionStatus, loading, error } = useSubscription()
  const { user } = useAuth()
  const [daysUntilPayment, setDaysUntilPayment] = useState<number>(0)
  const [nextPaymentDate, setNextPaymentDate] = useState<Date | null>(null)

  console.log('💳 PaymentCountdown renderizado!')

  // Calcular próxima data de pagamento (31 dias)
  useEffect(() => {
    if (subscription?.created_at) {
      const createdDate = new Date(subscription.created_at)
      const nextPayment = new Date(createdDate)
      nextPayment.setDate(nextPayment.getDate() + 31)
      
      setNextPaymentDate(nextPayment)
      
      // Calcular dias restantes
      const today = new Date()
      const diffTime = nextPayment.getTime() - today.getTime()
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      
      setDaysUntilPayment(diffDays)
      
      // Debug log
      console.log('PaymentCountdown: Próximo pagamento em', diffDays, 'dias')
    }
  }, [subscription])

  // Atualizar contador a cada minuto
  useEffect(() => {
    const interval = setInterval(() => {
      if (nextPaymentDate) {
        const today = new Date()
        const diffTime = nextPaymentDate.getTime() - today.getTime()
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
        
        setDaysUntilPayment(diffDays)
        console.log('PaymentCountdown: Atualização - dias restantes:', diffDays)
      }
    }, 60000) // Atualizar a cada minuto

    return () => clearInterval(interval)
  }, [nextPaymentDate])

  // Debug: verificar status da assinatura
  console.log('PaymentCountdown Debug:', {
    isActive,
    subscription: subscription ? 'existe' : 'null',
    subscriptionStatus,
    loading,
    error,
    nextPaymentDate: nextPaymentDate ? nextPaymentDate.toISOString() : 'null',
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
  if (!isActive || !subscription || !nextPaymentDate) {
    console.log('PaymentCountdown não será exibido:', { isActive, hasSubscription: !!subscription, hasNextPaymentDate: !!nextPaymentDate })
    
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
    if (daysUntilPayment <= 0) {
      return {
        bgColor: 'bg-red-100',
        textColor: 'text-red-800',
        borderColor: 'border-red-300',
        icon: <CreditCard className="w-4 h-4" />
      }
    } else if (daysUntilPayment <= 3) {
      return {
        bgColor: 'bg-orange-100',
        textColor: 'text-orange-800',
        borderColor: 'border-orange-300',
        icon: <Clock className="w-4 h-4" />
      }
    } else if (daysUntilPayment <= 7) {
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
    if (daysUntilPayment <= 0) {
      return '0'
    } else {
      return `${daysUntilPayment}`
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