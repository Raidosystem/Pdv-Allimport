import { useState } from 'react'
import { Link, Navigate } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff, CheckCircle } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'

export function SignupPage() {
  const { signUp, user } = useAuth()
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    fullName: '',
    companyName: ''
  })
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)

  // Redirecionar se já estiver logado
  if (user) {
    return <Navigate to="/dashboard" replace />
  }

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    setError('')
  }

  const validateForm = () => {
    if (formData.password !== formData.confirmPassword) {
      setError('As senhas não coincidem')
      return false
    }
    
    if (formData.password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres')
      return false
    }

    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return
    
    setLoading(true)
    setError('')

    const { error } = await signUp(formData.email, formData.password, {
      full_name: formData.fullName,
      company_name: formData.companyName
    })
    
    if (error) {
      setError(error.message === 'User already registered' 
        ? 'Este email já está cadastrado' 
        : 'Erro ao criar conta. Tente novamente.')
    } else {
      setSuccess(true)
    }
    
    setLoading(false)
  }

  if (success) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white via-primary-50 to-primary-100 flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          <Card>
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-8 h-8 text-green-500" />
              </div>
              <h2 className="text-2xl font-bold text-secondary-900 mb-2">
                Conta criada com sucesso!
              </h2>
              <p className="text-secondary-600 mb-6">
                Verifique seu email para confirmar sua conta e fazer login.
              </p>
              <Link to="/login">
                <Button>
                  Ir para Login
                </Button>
              </Link>
            </div>
          </Card>
        </div>
      </div>
    )
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
              Crie sua conta
            </h2>
            <p className="text-secondary-600">
              Comece a usar o melhor sistema PDV do mercado
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <div className="p-3 rounded-lg bg-danger-50 border border-danger-200">
                <p className="text-sm text-danger-600">{error}</p>
              </div>
            )}

            <Input
              label="Nome completo"
              type="text"
              value={formData.fullName}
              onChange={(e) => handleChange('fullName', e.target.value)}
              placeholder="Seu nome completo"
              required
            />

            <Input
              label="Nome da empresa"
              type="text"
              value={formData.companyName}
              onChange={(e) => handleChange('companyName', e.target.value)}
              placeholder="Nome da sua empresa"
              required
            />

            <Input
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => handleChange('email', e.target.value)}
              placeholder="seu@email.com"
              required
            />

            <div className="relative">
              <Input
                label="Senha"
                type={showPassword ? 'text' : 'password'}
                value={formData.password}
                onChange={(e) => handleChange('password', e.target.value)}
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

            <div className="relative">
              <Input
                label="Confirmar senha"
                type={showConfirmPassword ? 'text' : 'password'}
                value={formData.confirmPassword}
                onChange={(e) => handleChange('confirmPassword', e.target.value)}
                placeholder="••••••••"
                required
              />
              <button
                type="button"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                className="absolute right-3 top-8 text-secondary-400 hover:text-secondary-600"
              >
                {showConfirmPassword ? (
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
              disabled={!formData.email || !formData.password || !formData.fullName}
            >
              Criar conta
            </Button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-secondary-600">
              Já tem uma conta?{' '}
              <Link to="/login" className="text-primary-500 hover:text-primary-600 font-medium">
                Faça login
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
