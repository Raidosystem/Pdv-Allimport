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
  const { hasAccess, loading: subscriptionLoading, needsPayment, isInTrial, isActive, isExpired } = useSubscription()
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

  // Emails administrativos sempre têm acesso (bypass especial)
  const adminEmails = [
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiamribeiro@outlook.com'
  ]
  
  if (user.email && adminEmails.includes(user.email.toLowerCase())) {
    console.log('🔓 Acesso admin liberado para:', user.email)
    return <>{children}</>
  }

  // Verificação de admin genérica
  if (isAdmin && isAdmin()) {
    console.log('🔓 Acesso admin (função) liberado')
    return <>{children}</>
  }

  // BYPASS TEMPORÁRIO: Se há erro no subscription service, liberar acesso
  // Isso evita que o sistema trave completamente
  if (subscriptionLoading === false && !hasAccess && !needsPayment && !isInTrial) {
    console.log('⚠️ Bypass ativado - possível erro no serviço de assinatura')
    return <>{children}</>
  }

  // Só mostrar tela de pagamento se:
  // 1. Está em período de teste E expirou
  // 2. OU não tem acesso E não tem assinatura ativa
  const shouldShowPayment = (isInTrial && isExpired) || (!hasAccess && !isActive)
  
  if (shouldShowPayment || needsPayment) {
    console.log('💳 Redirecionando para pagamento:', { shouldShowPayment, needsPayment })
    return <PaymentPage onPaymentSuccess={() => window.location.reload()} />
  }

  // Usuário tem acesso, mostrar conteúdo
  console.log('✅ Acesso liberado')
  return <>{children}</>
}
