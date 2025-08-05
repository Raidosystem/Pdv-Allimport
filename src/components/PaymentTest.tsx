import { useState } from 'react'
import { mercadoPagoApiService } from '../services/mercadoPagoApiService'

export function PaymentTest() {
  const [result, setResult] = useState<any>(null)
  const [loading, setLoading] = useState(false)

  const testPix = async () => {
    setLoading(true)
    try {
      const response = await mercadoPagoApiService.createPixPayment({
        userEmail: 'teste@exemplo.com',
        userName: 'Teste Usuario',
        amount: 59.90,
        description: 'Teste PIX'
      })
      setResult(response)
      console.log('PIX Result:', response)
    } catch (error) {
      console.error('PIX Error:', error)
      setResult({ error: error instanceof Error ? error.message : 'Erro desconhecido' })
    } finally {
      setLoading(false)
    }
  }

  const testCard = async () => {
    setLoading(true)
    try {
      const response = await mercadoPagoApiService.createPaymentPreference({
        userEmail: 'teste@exemplo.com',
        userName: 'Teste Usuario',
        amount: 59.90,
        description: 'Teste Cartão'
      })
      setResult(response)
      console.log('Card Result:', response)
    } catch (error) {
      console.error('Card Error:', error)
      setResult({ error: error instanceof Error ? error.message : 'Erro desconhecido' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Teste de Pagamento</h1>
      
      <div className="space-y-4">
        <button 
          onClick={testPix}
          disabled={loading}
          className="bg-blue-500 text-white px-4 py-2 rounded mr-4"
        >
          {loading ? 'Carregando...' : 'Testar PIX'}
        </button>
        
        <button 
          onClick={testCard}
          disabled={loading}
          className="bg-green-500 text-white px-4 py-2 rounded"
        >
          {loading ? 'Carregando...' : 'Testar Cartão'}
        </button>
      </div>

      {result && (
        <div className="mt-6">
          <h2 className="text-lg font-semibold">Resultado:</h2>
          <pre className="bg-gray-100 p-4 rounded mt-2 overflow-auto">
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  )
}
