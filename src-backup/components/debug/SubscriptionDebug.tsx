import { useSubscription } from '../../hooks/useSubscription'

export function SubscriptionDebug() {
  const subscriptionData = useSubscription()

  return (
    <div className="fixed top-4 right-4 bg-gray-900 text-white p-4 rounded-lg text-xs max-w-md z-50">
      <h3 className="text-yellow-400 font-bold mb-2">🐛 DEBUG - Dados da Assinatura</h3>
      <pre className="whitespace-pre-wrap overflow-auto max-h-96">
        {JSON.stringify(subscriptionData, null, 2)}
      </pre>
      <div className="mt-2 p-2 bg-red-900 rounded">
        <p className="text-red-200 text-xs">
          <strong>Problema:</strong> days_remaining = {subscriptionData.daysRemaining || 'undefined'}
        </p>
        <p className="text-red-200 text-xs mt-1">
          <strong>Status:</strong> {subscriptionData.subscriptionStatus?.status || 'undefined'}
        </p>
        <p className="text-red-200 text-xs mt-1">
          <strong>isActive:</strong> {subscriptionData.isActive ? 'true' : 'false'}
        </p>
      </div>
    </div>
  )
}
