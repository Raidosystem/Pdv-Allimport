import { useState } from 'react'
import { Link } from 'react-router-dom'
import { ShoppingCart, ArrowLeft, Mail, Check } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { SupportContact } from '../../components/auth/SupportContact'

export function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      console.log('🔄 Tentando enviar email de recuperação para:', email)
      
      const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      })

      console.log('📧 Resposta do Supabase:', { data, error })

      if (error) {
        console.error('❌ Erro do Supabase:', error)
        
        // Tratar diferentes tipos de erro
        if (error.message.includes('Email not confirmed')) {
          setError('Este email ainda não foi confirmado. Verifique sua caixa de entrada para confirmar o email primeiro.')
        } else if (error.message.includes('User not found')) {
          setError('Nenhuma conta encontrada com este email. Verifique se o email está correto ou crie uma nova conta.')
        } else if (error.message.includes('Email rate limit exceeded')) {
          setError('Muitas tentativas de recuperação. Aguarde alguns minutos antes de tentar novamente.')
        } else {
          setError(`Erro: ${error.message}`)
        }
        return
      }

      console.log('✅ Email de recuperação enviado com sucesso')
      setSent(true)
    } catch (error: unknown) {
      console.error('💥 Erro inesperado:', error)
      setError('Erro inesperado ao enviar email de recuperação. Tente novamente em alguns minutos.')
    } finally {
      setLoading(false)
    }
  }

  if (sent) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
          <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
        </div>

        <div className="relative w-full max-w-md">
          <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
            <div className="p-8 text-center">
              <div className="w-20 h-20 bg-gradient-to-br from-green-500 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg">
                <Check className="w-10 h-10 text-white" />
              </div>
              
              <h2 className="text-2xl font-bold text-secondary-900 mb-4">
                Email Enviado!
              </h2>
              
              <p className="text-secondary-600 mb-6 leading-relaxed">
                Enviamos um link para recuperação de senha para <strong>{email}</strong>. 
                Verifique sua caixa de entrada e spam.
              </p>

              <div className="mb-6 p-4 rounded-xl bg-blue-50 border border-blue-200">
                <h3 className="text-blue-800 font-semibold mb-2">🕐 Validade do Link</h3>
                <p className="text-blue-700 text-sm mb-2">
                  O link de recuperação é válido por <strong>1 hora</strong>. 
                  Use-o assim que receber o email para evitar expiração.
                </p>
                <p className="text-blue-600 text-xs">
                  💡 Se o link expirar, você pode solicitar um novo link nesta mesma página.
                </p>
              </div>

              <div className="mb-6 p-4 rounded-xl bg-amber-50 border border-amber-200">
                <h3 className="text-amber-800 font-semibold mb-2">⚠️ Importante</h3>
                <p className="text-amber-700 text-sm">
                  Se você não receber o email em 10-15 minutos, pode ser que o serviço de email 
                  esteja em configuração. Neste caso, entre em contato com o suporte ou tente 
                  fazer login com sua senha atual.
                </p>
              </div>

              <div className="space-y-4">
                <Link to="/login">
                  <Button className="w-full bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700">
                    Voltar ao Login
                  </Button>
                </Link>
                
                <Button
                  variant="outline"
                  onClick={() => {
                    setSent(false)
                    setEmail('')
                  }}
                  className="w-full"
                >
                  Enviar para outro email
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </div>
    )
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
                <h1 className="text-3xl font-bold text-secondary-900">RaVal pdv</h1>
                <p className="text-primary-600 font-medium">Sistema de Ponto de Venda</p>
              </div>
            </Link>
          </div>
        </Card>

        {/* Forgot Password Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-gradient-to-br from-orange-500 to-orange-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <Mail className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Esqueceu sua senha?
              </h2>
              <p className="text-secondary-600 text-lg">
                Digite seu email para receber um link de recuperação
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="p-4 rounded-xl bg-red-50 border border-red-200 shadow-sm">
                  <p className="text-red-600 font-medium text-center">{error}</p>
                </div>
              )}

              <Input
                label="Email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="seu@email.com"
                required
                className="text-lg p-4"
              />

              <Button
                type="submit"
                className="w-full text-lg py-4 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 shadow-lg transform hover:scale-[1.02] transition-all"
                loading={loading}
                disabled={!email}
              >
                Enviar Link de Recuperação
              </Button>
            </form>

            <div className="mt-8">
              <Link 
                to="/login" 
                className="inline-flex items-center text-secondary-500 hover:text-primary-600 transition-colors font-medium"
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                Voltar ao Login
              </Link>
            </div>

            <div className="mt-6 p-4 rounded-xl bg-blue-50 border border-blue-200">
              <h3 className="text-blue-800 font-semibold mb-2">💡 Dica</h3>
              <p className="text-blue-700 text-sm">
                Se você não receber o email em alguns minutos, verifique sua pasta de spam 
                ou lixo eletrônico.
              </p>
            </div>

            <div className="mt-6">
              <SupportContact userEmail={email} />
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
