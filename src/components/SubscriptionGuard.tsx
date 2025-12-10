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

  // 🚨 CRÍTICO: Super admin NUNCA pode ser bloqueado!
  const SUPER_ADMIN_EMAIL = 'novaradiosystem@outlook.com'
  const isSuperAdmin = user?.email?.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase()
  
  if (isSuperAdmin) {
    console.log('✅ [SubscriptionGuard] SUPER ADMIN detectado - acesso TOTAL garantido')
    return <>{children}</>
  }

  // Admins sempre têm acesso
  if (isAdmin()) {
    console.log('✅ [SubscriptionGuard] Admin detectado - acesso garantido')
    return <>{children}</>
  }

  // Só mostrar tela de pagamento se:
  // 1. Está em período de teste E expirou
  // 2. OU não tem acesso E não tem assinatura ativa
  const shouldShowPayment = (isInTrial && isExpired) || (!hasAccess && !isActive)
  
  // 🔍 DEBUG: Logar decisão de mostrar pagamento
  const decisao = {
    user: user?.email,
    isAdmin: isAdmin(),
    hasAccess,
    isInTrial,
    isExpired,
    isActive,
    needsPayment,
    shouldShowPayment,
    decisao: shouldShowPayment || needsPayment ? '❌ MOSTRAR PAGAMENTO' : '✅ PERMITIR ACESSO'
  }
  console.log('🔍 [SubscriptionGuard] Decisão de acesso:', decisao)
  console.log('📊 [SubscriptionGuard] Decisão JSON:', JSON.stringify(decisao, null, 2))
  
  if (shouldShowPayment || needsPayment) {
    return <PaymentPage onPaymentSuccess={() => window.location.reload()} />
  }

  // Usuário tem acesso, mostrar conteúdo
  return <>{children}</>
}
