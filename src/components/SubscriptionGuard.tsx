import { useEffect, useState } from 'react'
import { useAuth } from '../modules/auth/AuthContext'
import { useSubscription } from '../hooks/useSubscription'
import { PaymentPage } from '../components/subscription/PaymentPage'
import { Loader2 } from 'lucide-react'

interface SubscriptionGuardProps {
  children: React.ReactNode
}

export function SubscriptionGuard({ children }: SubscriptionGuardProps) {
  const { user, loading: authLoading, isAdmin } = useAuth()
  const { hasAccess, loading: subscriptionLoading, needsPayment } = useSubscription()
  const [checking, setChecking] = useState(true)

  useEffect(() => {
    // Esperar até que ambos os loadings terminem
    if (!authLoading && !subscriptionLoading) {
      setChecking(false)
    }
  }, [authLoading, subscriptionLoading])

  // Mostrar loading enquanto verifica
  if (checking || authLoading || subscriptionLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
        <div className="text-center">
          <Loader2 className="w-8 h-8 animate-spin text-primary-600 mx-auto mb-4" />
          <p className="text-secondary-600">Verificando acesso...</p>
        </div>
      </div>
    )
  }

  // Se não tem usuário logado, deixar o AuthContext lidar com isso
  if (!user) {
    return <>{children}</>
  }

  // Admins sempre têm acesso
  if (isAdmin()) {
    return <>{children}</>
  }

  // Se não tem acesso ou precisa de pagamento, mostrar tela de pagamento
  if (!hasAccess || needsPayment) {
    return <PaymentPage onPaymentSuccess={() => window.location.reload()} />
  }

  // Usuário tem acesso, mostrar conteúdo
  return <>{children}</>
}
