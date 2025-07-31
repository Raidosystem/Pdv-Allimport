import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { ShoppingCart, CheckCircle, XCircle, Mail } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'

export function EmailConfirmationPage() {
  const [searchParams] = useSearchParams()
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('')

  useEffect(() => {
    const confirmEmail = async () => {
      const token = searchParams.get('token')
      const tokenHash = searchParams.get('token_hash')
      const type = searchParams.get('type')
      const accessToken = searchParams.get('access_token')
      const refreshToken = searchParams.get('refresh_token')

      console.log('URL params:', { token, tokenHash, type, accessToken, refreshToken })

      // Método 1: Se temos access_token e refresh_token (link direto)
      if (accessToken && refreshToken) {
        try {
          const { error } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken
          })
          
          if (error) {
            setStatus('error')
            setMessage('Erro ao confirmar email com tokens.')
          } else {
            setStatus('success')
            setMessage('Email confirmado com sucesso!')
          }
        } catch (error) {
          setStatus('error')
          setMessage('Erro inesperado ao confirmar email.')
        }
        return
      }

      // Método 2: Se temos token_hash
      if (tokenHash && type === 'email') {
        try {
          const { error } = await supabase.auth.verifyOtp({
            token_hash: tokenHash,
            type: 'email'
          })

          if (error) {
            setStatus('error')
            setMessage('Erro ao confirmar email. O link pode ter expirado.')
          } else {
            setStatus('success')
            setMessage('Email confirmado com sucesso!')
          }
        } catch (error) {
          setStatus('error')
          setMessage('Erro inesperado ao confirmar email.')
        }
        return
      }

      // Método 3: Token simples (fallback)
      if (token && type === 'email') {
        try {
          const { error } = await supabase.auth.verifyOtp({
            token_hash: token,
            type: 'email'
          })

          if (error) {
            setStatus('error')
            setMessage('Erro ao confirmar email. O link pode ter expirado.')
          } else {
            setStatus('success')
            setMessage('Email confirmado com sucesso!')
          }
        } catch (error) {
          setStatus('error')
          setMessage('Erro inesperado ao confirmar email.')
        }
        return
      }

      // Nenhum parâmetro válido encontrado
      setStatus('error')
      setMessage('Link de confirmação inválido ou expirado.')
    }

    confirmEmail()
  }, [searchParams])

  const getIcon = () => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-16 h-16 text-green-500" />
      case 'error':
        return <XCircle className="w-16 h-16 text-red-500" />
      default:
        return <Mail className="w-16 h-16 text-primary-500 animate-pulse" />
    }
  }

  const getTitle = () => {
    switch (status) {
      case 'success':
        return 'Email Confirmado!'
      case 'error':
        return 'Erro na Confirmação'
      default:
        return 'Confirmando Email...'
    }
  }

  const getBackgroundColor = () => {
    switch (status) {
      case 'success':
        return 'from-green-500 to-green-600'
      case 'error':
        return 'from-red-500 to-red-600'
      default:
        return 'from-primary-500 to-primary-600'
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-md">
        {/* Logo Card */}
        <Card className="mb-6 bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="text-center py-6">
            <Link to="/" className="inline-flex items-center space-x-3">
              <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
                <p className="text-primary-600 font-medium">Sistema de Vendas</p>
              </div>
            </Link>
          </div>
        </Card>

        {/* Confirmation Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8 text-center">
            <div className={`w-20 h-20 bg-gradient-to-br ${getBackgroundColor()} rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg`}>
              {getIcon()}
            </div>
            <h2 className="text-3xl font-bold text-secondary-900 mb-4">
              {getTitle()}
            </h2>
            <p className="text-secondary-600 text-lg mb-8">
              {message}
            </p>
            
            {status === 'success' && (
              <Link to="/login">
                <Button className="text-lg py-4 px-8 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 shadow-lg">
                  Fazer Login
                </Button>
              </Link>
            )}
            
            {status === 'error' && (
              <div className="space-y-4">
                <Link to="/signup">
                  <Button className="text-lg py-4 px-8 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg w-full">
                    Criar Nova Conta
                  </Button>
                </Link>
                <Link to="/login">
                  <Button variant="outline" className="text-lg py-4 px-8 w-full">
                    Ir para Login
                  </Button>
                </Link>
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  )
}
