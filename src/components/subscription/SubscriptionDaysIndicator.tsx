import { Clock, Crown, AlertTriangle } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'

export function SubscriptionDaysIndicator() {
  const { subscription, daysRemaining, isActive, isInTrial } = useSubscription()

  if (!subscription || !isActive) {
    return null
  }

  // Definir a cor baseada nos dias restantes
  const getIndicatorStyle = () => {
    if (daysRemaining > 25) {
      return {
        bgColor: 'bg-green-100',
        textColor: 'text-green-800',
        borderColor: 'border-green-300',
        icon: Clock,
        iconColor: 'text-green-600'
      }
    } else if (daysRemaining >= 3) {
      return {
        bgColor: 'bg-yellow-100',
        textColor: 'text-yellow-800',
        borderColor: 'border-yellow-300',
        icon: AlertTriangle,
        iconColor: 'text-yellow-600'
      }
    } else {
      return {
        bgColor: 'bg-red-100',
        textColor: 'text-red-800',
        borderColor: 'border-red-300',
        icon: AlertTriangle,
        iconColor: 'text-red-600'
      }
    }
  }

  const style = getIndicatorStyle()
  const IconComponent = style.icon

  return (
    <div className={`
      inline-flex items-center gap-2 px-4 py-2 rounded-full border-2 
      ${style.bgColor} ${style.borderColor} ${style.textColor}
      shadow-sm transition-all duration-200 hover:shadow-md
    `}>
      {isInTrial ? (
        <Crown className={`w-4 h-4 ${style.iconColor}`} />
      ) : (
        <IconComponent className={`w-4 h-4 ${style.iconColor}`} />
      )}
      
      <div className="flex flex-col items-center">
        <span className="text-sm font-semibold">
          {daysRemaining} {daysRemaining === 1 ? 'dia' : 'dias'}
        </span>
        <span className="text-xs opacity-75">
          {isInTrial ? 'período trial' : 'restantes'}
        </span>
      </div>
      
      {/* Barra de progresso visual */}
      <div className="ml-2">
        <div className="w-16 h-2 bg-white/50 rounded-full overflow-hidden">
          <div 
            className={`h-full transition-all duration-300 ${
              daysRemaining > 25 ? 'bg-green-500' :
              daysRemaining >= 3 ? 'bg-yellow-500' : 'bg-red-500'
            }`}
            style={{ 
              width: `${Math.max(5, Math.min(100, (daysRemaining / 31) * 100))}%` 
            }}
          />
        </div>
      </div>
    </div>
  )
}