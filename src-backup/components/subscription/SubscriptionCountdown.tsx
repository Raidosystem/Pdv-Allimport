import { Calendar, Clock } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'

interface SubscriptionCountdownProps {
  className?: string
}

export function SubscriptionCountdown({ className = '' }: SubscriptionCountdownProps) {
  const { subscription, daysRemaining, isActive } = useSubscription()

  // Só mostrar se tem assinatura ativa
  if (!isActive || !subscription) {
    return null
  }

  // Usar os dias restantes do hook
  const subscriptionDaysRemaining = daysRemaining || 0

  // Determinar cor baseada nos dias restantes
  const getColorInfo = () => {
    if (subscriptionDaysRemaining <= 5) {
      return {
        bgColor: 'bg-red-100',
        textColor: 'text-red-800',
        borderColor: 'border-red-200',
        icon: <Clock className="w-4 h-4" />
      }
    } else {
      return {
        bgColor: 'bg-green-100',
        textColor: 'text-green-800',
        borderColor: 'border-green-200',
        icon: <Calendar className="w-4 h-4" />
      }
    }
  }

  const colorInfo = getColorInfo()

  return (
    <div className={`
      inline-flex items-center space-x-2 px-3 py-1.5 rounded-full border text-sm font-medium
      ${colorInfo.bgColor} ${colorInfo.textColor} ${colorInfo.borderColor}
      ${className}
    `}>
      {colorInfo.icon}
      <span>
        {subscriptionDaysRemaining === 1 
          ? '1 dia restante' 
          : `${subscriptionDaysRemaining} dias restantes`
        }
      </span>
    </div>
  )
}
