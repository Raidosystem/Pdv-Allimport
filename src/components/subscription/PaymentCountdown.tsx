import { useState, useEffect } from 'react'
import { Calendar, Clock, CreditCard, ExternalLink } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'
import { useAuth } from '../../modules/auth/AuthContext'
import { Button } from '../ui/Button'
import { Link } from 'react-router-dom'

interface PaymentCountdownProps {
  className?: string
}

export function PaymentCountdown({ className = '' }: PaymentCountdownProps) {
  const { subscription, isActive } = useSubscription()
  const { user } = useAuth()
  const [daysUntilPayment, setDaysUntilPayment] = useState<number>(0)
  const [nextPaymentDate, setNextPaymentDate] = useState<Date | null>(null)
  const [showPaymentLink, setShowPaymentLink] = useState(false)

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
      
      // Mostrar link de pagamento se venceu ou está próximo (3 dias)
      setShowPaymentLink(diffDays <= 3)
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
        setShowPaymentLink(diffDays <= 3)
      }
    }, 60000) // Atualizar a cada minuto

    return () => clearInterval(interval)
  }, [nextPaymentDate])

  // Só mostrar se tem assinatura ativa
  if (!isActive || !subscription || !nextPaymentDate) {
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

  // Formatear data do próximo pagamento
  const formatNextPaymentDate = () => {
    return nextPaymentDate.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    })
  }

  // Texto baseado nos dias restantes
  const getCountdownText = () => {
    if (daysUntilPayment <= 0) {
      return 'Pagamento vencido!'
    } else if (daysUntilPayment === 1) {
      return 'Próximo pagamento: amanhã'
    } else {
      return `Próximo pagamento: ${daysUntilPayment} dias`
    }
  }

  return (
    <div className={`flex flex-col space-y-2 ${className}`}>
      {/* Contador principal */}
      <div className={`
        inline-flex items-center space-x-2 px-3 py-2 rounded-lg border text-sm font-medium
        ${colorInfo.bgColor} ${colorInfo.textColor} ${colorInfo.borderColor}
      `}>
        {colorInfo.icon}
        <div className="flex flex-col">
          <span className="font-semibold">{getCountdownText()}</span>
          <span className="text-xs opacity-75">
            Data: {formatNextPaymentDate()}
          </span>
        </div>
      </div>

      {/* Link de pagamento quando necessário */}
      {showPaymentLink && (
        <div className={`
          p-3 rounded-lg border-2 border-dashed
          ${daysUntilPayment <= 0 
            ? 'border-red-300 bg-red-50' 
            : 'border-orange-300 bg-orange-50'
          }
        `}>
          <div className="flex items-center justify-between">
            <div>
              <p className={`font-medium text-sm ${
                daysUntilPayment <= 0 ? 'text-red-800' : 'text-orange-800'
              }`}>
                {daysUntilPayment <= 0 
                  ? '⚠️ Pagamento em atraso' 
                  : '💳 Pagamento próximo'
                }
              </p>
              <p className={`text-xs ${
                daysUntilPayment <= 0 ? 'text-red-600' : 'text-orange-600'
              }`}>
                {daysUntilPayment <= 0 
                  ? 'Renove sua assinatura para continuar usando o sistema'
                  : 'Renove antecipadamente para evitar interrupções'
                }
              </p>
            </div>
            
            <Link to="/assinatura">
              <Button 
                size="sm"
                className={`
                  flex items-center space-x-1 text-xs
                  ${daysUntilPayment <= 0 
                    ? 'bg-red-600 hover:bg-red-700 text-white' 
                    : 'bg-orange-600 hover:bg-orange-700 text-white'
                  }
                `}
              >
                <CreditCard className="w-3 h-3" />
                <span>Renovar</span>
                <ExternalLink className="w-3 h-3" />
              </Button>
            </Link>
          </div>
        </div>
      )}
      
      {/* Informações extras para debug (remover em produção) */}
      {process.env.NODE_ENV === 'development' && (
        <div className="text-xs text-gray-500 p-2 bg-gray-100 rounded">
          <div>Debug Info:</div>
          <div>• Criado em: {new Date(subscription.created_at).toLocaleDateString('pt-BR')}</div>
          <div>• Próximo pagamento: {formatNextPaymentDate()}</div>
          <div>• Dias restantes: {daysUntilPayment}</div>
          <div>• Status: {subscription.status}</div>
          <div>• Email: {user?.email}</div>
        </div>
      )}
    </div>
  )
}