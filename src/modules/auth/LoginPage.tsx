import { useState } from 'react'
import { Link, Navigate } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'

export function LoginPage() {
  const { signIn, user } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Redirecionar se já estiver logado
  if (user) {
    return <Navigate to="/dashboard" replace />
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { error } = await signIn(email, password)
    
    if (error) {
      setError('Email ou senha incorretos')
    }
    
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-primary-50 to-primary-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center space-x-3">
            <div className="w-12 h-12 bg-primary-500 rounded-xl flex items-center justify-center shadow-lg">
              <ShoppingCart className="w-7 h-7 text-white" />
            </div>
            <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
          </Link>
        </div>

        <Card>
          <div className="text-center mb-6">
            <h2 className="text-2xl font-bold text-secondary-900 mb-2">
              Bem-vindo de volta
            </h2>
            <p className="text-secondary-600">
              Entre com sua conta para acessar o sistema
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <div className="p-3 rounded-lg bg-danger-50 border border-danger-200">
                <p className="text-sm text-danger-600">{error}</p>
              </div>
            )}

            <Input
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="seu@email.com"
              required
            />

            <div className="relative">
              <Input
                label="Senha"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-8 text-secondary-400 hover:text-secondary-600"
              >
                {showPassword ? (
                  <EyeOff className="w-5 h-5" />
                ) : (
                  <Eye className="w-5 h-5" />
                )}
              </button>
            </div>

            <Button
              type="submit"
              className="w-full"
              loading={loading}
              disabled={!email || !password}
            >
              Entrar
            </Button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-secondary-600">
              Não tem uma conta?{' '}
              <Link to="/signup" className="text-primary-500 hover:text-primary-600 font-medium">
                Cadastre-se grátis
              </Link>
            </p>
          </div>

          <div className="mt-4 text-center">
            <Link 
              to="/" 
              className="text-sm text-secondary-500 hover:text-secondary-700"
            >
              ← Voltar para o início
            </Link>
          </div>
        </Card>
      </div>
    </div>
  )
}
