import { Crown, AlertTriangle } from 'lucide-react'
import { useSubscription } from '../../hooks/useSubscription'

export function SubscriptionDaysIndicator() {
  const { daysRemaining, isInTrial, hasAccess } = useSubscription()

  // Mostrar se tiver acesso (ativo ou em trial)
  if (!hasAccess || daysRemaining <= 0) {
    return null
  }

  // Definir a cor baseada nos dias restantes
  const getIndicatorStyle = () => {
    if (daysRemaining >= 30) {
      return {
        bgColor: 'bg-green-100',
        textColor: 'text-green-800',
        borderColor: 'border-green-300',
        icon: Crown,
        iconColor: 'text-green-600'
      }
    } else if (daysRemaining >= 7) {
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
      inline-flex items-center gap-1.5 sm:gap-2 px-2 py-1 sm:px-4 sm:py-2 rounded-full border-2 
      ${style.bgColor} ${style.borderColor} ${style.textColor}
      shadow-sm transition-all duration-200 hover:shadow-md
      ${isInTrial ? 'animate-pulse-slow' : ''}
    `}>
      {isInTrial ? (
        <Crown className={`w-3 h-3 sm:w-4 sm:h-4 ${style.iconColor} animate-bounce-slow`} />
      ) : (
        <IconComponent className={`w-3 h-3 sm:w-4 sm:h-4 ${style.iconColor}`} />
      )}
      
      <div className="flex flex-col items-center">
        <span className="text-xs sm:text-sm font-semibold">
          {daysRemaining} {daysRemaining === 1 ? 'dia' : 'dias'}
        </span>
        <span className="text-[10px] sm:text-xs opacity-75 font-medium">
          {isInTrial ? '🎁 Teste' : '✨ Premium'}
        </span>
      </div>
      
      {/* Barra de progresso visual - oculta em mobile */}
      <div className="ml-1 sm:ml-2 hidden sm:block">
        <div className="w-16 h-2 bg-white/50 rounded-full overflow-hidden">
          <div 
            className={`h-full transition-all duration-300 ${
              isInTrial 
                ? (daysRemaining >= 7 ? 'bg-blue-500' : 'bg-orange-500')
                : (daysRemaining > 30 ? 'bg-green-500' :
                   daysRemaining >= 7 ? 'bg-yellow-500' : 'bg-red-500')
            }`}
            style={{ 
              width: `${Math.max(5, Math.min(100, isInTrial ? (daysRemaining / 15) * 100 : (daysRemaining / 365) * 100))}%` 
            }}
          />
        </div>
      </div>
    </div>
  )
}