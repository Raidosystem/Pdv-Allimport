import { Clock, AlertTriangle, Crown } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'

interface SubscriptionStatusProps {
  className?: string
}

export function SubscriptionStatus({ className = '' }: SubscriptionStatusProps) {
  const { subscriptionStatus, daysRemaining, isInTrial, isActive, isExpired } = useSubscription()

  if (!subscriptionStatus?.has_subscription) {
    return null
  }

  const getStatusInfo = () => {
    if (isActive) {
      return {
        icon: <Crown className="w-4 h-4" />,
        text: 'Assinatura Ativa',
        bgColor: 'bg-green-100',
        textColor: 'text-green-800',
        borderColor: 'border-green-200'
      }
    }

    if (isInTrial) {
      const isLowTime = daysRemaining <= 7
      return {
        icon: <Clock className="w-4 h-4" />,
        text: `Teste: ${daysRemaining} dias restantes`,
        bgColor: isLowTime ? 'bg-orange-100' : 'bg-blue-100',
        textColor: isLowTime ? 'text-orange-800' : 'text-blue-800',
        borderColor: isLowTime ? 'border-orange-200' : 'border-blue-200'
      }
    }

    if (isExpired) {
      return {
        icon: <AlertTriangle className="w-4 h-4" />,
        text: 'Período expirado',
        bgColor: 'bg-red-100',
        textColor: 'text-red-800',
        borderColor: 'border-red-200'
      }
    }

    return {
      icon: <Clock className="w-4 h-4" />,
      text: 'Status pendente',
      bgColor: 'bg-gray-100',
      textColor: 'text-gray-800',
      borderColor: 'border-gray-200'
    }
  }

  const statusInfo = getStatusInfo()

  return (
    <div className={`
      inline-flex items-center space-x-2 px-3 py-1.5 rounded-full border text-sm font-medium
      ${statusInfo.bgColor} ${statusInfo.textColor} ${statusInfo.borderColor}
      ${className}
    `}>
      {statusInfo.icon}
      <span>{statusInfo.text}</span>
    </div>
  )
}
