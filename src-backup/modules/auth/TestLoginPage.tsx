import { useState } from 'react'
import { Link } from 'react-router-dom'
import { ShoppingCart, AlertTriangle, CheckCircle, Mail } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'

export function TestLoginPage() {
  const { signIn } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<{
    type: 'success' | 'error' | 'info'
    message: string
  } | null>(null)

  const handleTest = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setResult(null)

    const { error } = await signIn(email, password)
    
    if (error) {
      if (error.message === 'Email not confirmed') {
        setResult({
          type: 'info',
          message: 'Email não confirmado. Isso confirma que a conta foi criada mas precisa ser verificada.'
        })
      } else if (error.message === 'Invalid login credentials') {
        setResult({
          type: 'error',
          message: 'Credenciais inválidas. Verifique email e senha.'
        })
      } else {
        setResult({
          type: 'error',
          message: `Erro: ${error.message}`
        })
      }
    } else {
      setResult({
        type: 'success',
        message: 'Login realizado com sucesso! A confirmação de email não é obrigatória.'
      })
    }
    
    setLoading(false)
  }

  const getIcon = () => {
    if (!result) return <Mail className="w-10 h-10 text-white" />
    
    switch (result.type) {
      case 'success':
        return <CheckCircle className="w-10 h-10 text-white" />
      case 'error':
        return <AlertTriangle className="w-10 h-10 text-white" />
      case 'info':
        return <Mail className="w-10 h-10 text-white" />
    }
  }

  const getBackgroundColor = () => {
    if (!result) return 'from-primary-500 to-primary-600'
    
    switch (result.type) {
      case 'success':
        return 'from-green-500 to-green-600'
      case 'error':
        return 'from-red-500 to-red-600'
      case 'info':
        return 'from-blue-500 to-blue-600'
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
                <p className="text-primary-600 font-medium">Teste de Login</p>
              </div>
            </Link>
          </div>
        </Card>

        {/* Test Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className={`w-20 h-20 bg-gradient-to-br ${getBackgroundColor()} rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg`}>
                {getIcon()}
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Teste de Login
              </h2>
              <p className="text-secondary-600 text-lg">
                Teste se sua conta funciona mesmo sem confirmação de email
              </p>
            </div>

            <form onSubmit={handleTest} className="space-y-6">
              {result && (
                <div className={`p-4 rounded-xl border shadow-sm ${
                  result.type === 'success' ? 'bg-green-50 border-green-200' :
                  result.type === 'error' ? 'bg-red-50 border-red-200' :
                  'bg-blue-50 border-blue-200'
                }`}>
                  <p className={`font-medium text-center ${
                    result.type === 'success' ? 'text-green-600' :
                    result.type === 'error' ? 'text-red-600' :
                    'text-blue-600'
                  }`}>
                    {result.message}
                  </p>
                </div>
              )}

              <div>
                <label htmlFor="email" className="block text-sm font-semibold text-secondary-700 mb-3">
                  Email
                </label>
                <Input
                  id="email"
                  type="email"
                  placeholder="seu@email.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="text-lg py-4 px-4 border-2 border-secondary-200 focus:border-primary-400 focus:ring-primary-400/30"
                />
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-semibold text-secondary-700 mb-3">
                  Senha
                </label>
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="text-lg py-4 px-4 border-2 border-secondary-200 focus:border-primary-400 focus:ring-primary-400/30"
                />
              </div>

              <Button
                type="submit"
                disabled={loading}
                className="w-full text-lg py-4 px-6 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 disabled:from-secondary-300 disabled:to-secondary-400 shadow-lg transition-all duration-200"
              >
                {loading ? 'Testando...' : 'Testar Login'}
              </Button>
            </form>

            <div className="mt-8 text-center space-y-3">
              <Link 
                to="/login" 
                className="block text-primary-600 hover:text-primary-700 font-medium transition-colors"
              >
                Voltar ao Login Normal
              </Link>
              <Link 
                to="/resend-confirmation" 
                className="block text-secondary-500 hover:text-primary-600 transition-colors"
              >
                Reenviar Email de Confirmação
              </Link>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
