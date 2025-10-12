import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { CheckCircle, XCircle, Loader2 } from 'lucide-react'
import { supabase } from '../../lib/supabase'

export function ConfirmEmailPage() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('')

  useEffect(() => {
    const confirmEmail = async () => {
      try {
        // Pegar tokens da URL
        const token = searchParams.get('token')
        const type = searchParams.get('type')

        if (!token || type !== 'signup') {
          setStatus('error')
          setMessage('Link inválido ou expirado')
          return
        }

        // Verificar email com Supabase
        const { data, error } = await supabase.auth.verifyOtp({
          token_hash: token,
          type: 'signup'
        })

        if (error) {
          throw error
        }

        if (data) {
          setStatus('success')
          setMessage('Email confirmado com sucesso!')
          
          // Redirecionar para login após 3 segundos
          setTimeout(() => {
            navigate('/login')
          }, 3000)
        }
      } catch (error: any) {
        console.error('Erro ao confirmar email:', error)
        setStatus('error')
        setMessage(error.message || 'Erro ao confirmar email. O link pode ter expirado.')
      }
    }

    confirmEmail()
  }, [searchParams, navigate])

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <div className="text-center">
          {status === 'loading' && (
            <>
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Loader2 className="w-10 h-10 text-blue-600 animate-spin" />
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">
                Confirmando email...
              </h2>
              <p className="text-gray-600 text-sm">
                Aguarde enquanto verificamos sua conta
              </p>
            </>
          )}

          {status === 'success' && (
            <>
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-10 h-10 text-green-600" />
              </div>
              <h2 className="text-2xl font-bold text-green-900 mb-2">
                Email Confirmado! ??
              </h2>
              <p className="text-gray-600 text-sm mb-4">
                {message}
              </p>
              <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-4">
                <p className="text-sm text-green-800">
                  Redirecionando para o login...
                </p>
              </div>
              <Button onClick={() => navigate('/login')} className="w-full">
                Ir para Login
              </Button>
            </>
          )}

          {status === 'error' && (
            <>
              <div className="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <XCircle className="w-10 h-10 text-red-600" />
              </div>
              <h2 className="text-2xl font-bold text-red-900 mb-2">
                Erro na Confirmação
              </h2>
              <p className="text-gray-600 text-sm mb-4">
                {message}
              </p>
              <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
                <p className="text-sm text-red-800">
                  O link pode ter expirado. Tente fazer um novo cadastro ou entre em contato com o suporte.
                </p>
              </div>
              <div className="space-y-2">
                <Button onClick={() => navigate('/signup')} className="w-full">
                  Fazer Novo Cadastro
                </Button>
                <Button 
                  onClick={() => navigate('/login')} 
                  variant="outline"
                  className="w-full"
                >
                  Ir para Login
                </Button>
              </div>
            </>
          )}
        </div>
      </Card>
    </div>
  )
}
