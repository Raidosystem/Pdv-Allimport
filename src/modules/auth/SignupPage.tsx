import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'

export function SignupPage() {
  const { signUp, user } = useAuth()
  const navigate = useNavigate()
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

  console.log('SignupPage render - success:', success, 'loading:', loading)

  // Monitorar mudanças no success
  useEffect(() => {
    console.log('useEffect - success mudou para:', success)
  }, [success])

  // Redirecionar se já estiver logado (mas não durante o processo de cadastro)
  useEffect(() => {
    if (user && !loading) {
      console.log('User detectado, redirecionando para dashboard:', user)
      navigate('/dashboard', { replace: true })
    }
  }, [user, loading, navigate])

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

    const { data, error } = await signUp(formData.email, formData.password, {
      full_name: formData.fullName,
      company_name: formData.companyName
    })
    
    console.log('=== DEBUG SIGNUP ===')
    console.log('Data:', data)
    console.log('Error:', error)
    console.log('Error message:', error?.message)
    console.log('===================')
    
    if (error) {
      console.log('Signup error:', error) // Para debug
      if (error.message === 'User already registered') {
        setError('Este email já está cadastrado')
      } else if (error.message === 'APPROVAL_SYSTEM_NOT_CONFIGURED') {
        setError('Sistema de aprovação não configurado. Contate o administrador.')
      } else if (error.message === 'PENDING_APPROVAL' || error.name === 'PENDING_APPROVAL') {
        // Usuário cadastrado com sucesso, mas está pendente de aprovação
        console.log('DETECTOU PENDING_APPROVAL - mostrando tela de sucesso')
        console.log('Definindo success = true')
        setLoading(false)
        setSuccess(true)
        console.log('Success definido, retornando...')
        return // Não mostrar erro, mostrar página de sucesso
      } else if (error.message.includes('email')) {
        setError('Problema com o email. Verifique se está correto.')
      } else {
        setError(`Erro ao criar conta: ${error.message}`)
      }
    } else {
      console.log('Signup success:', data) // Para debug
      // Mostrar mensagem de sucesso informando sobre aprovação
      setSuccess(true)
    }
    
    setLoading(false)
  }

  // Se o cadastro foi bem-sucedido, mostrar página de sucesso com informação sobre aprovação
  if (success) {
    console.log('Renderizando página de sucesso!')
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
              <div className="w-20 h-20 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg">
                <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-4">
                Conta criada com sucesso!
              </h2>
              <div className="text-secondary-600 text-lg mb-8 space-y-3">
                <p className="text-sm bg-yellow-50 p-4 rounded-lg border border-yellow-200">
                  <strong>⏳ Aguardando Aprovação</strong><br/>
                  Sua conta foi criada, mas precisa ser aprovada por um administrador antes que você possa acessar todas as funcionalidades do sistema.
                </p>
                <p className="text-sm text-secondary-500">
                  Você receberá uma confirmação quando sua conta for aprovada.
                </p>
              </div>
              <div className="space-y-3">
                <Link to="/login">
                  <Button className="text-lg py-4 px-8 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg w-full">
                    Fazer Login
                  </Button>
                </Link>
                <Link to="/">
                  <Button variant="ghost" className="text-secondary-600 w-full">
                    ← Voltar ao início
                  </Button>
                </Link>
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

      <div className="relative w-full max-w-lg">
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

        {/* Signup Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <ShoppingCart className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Crie sua conta
              </h2>
              <p className="text-secondary-600 text-lg">
                Comece a usar o melhor sistema
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="p-4 rounded-xl bg-red-50 border border-red-200 shadow-sm">
                  <p className="text-red-600 font-medium text-center">{error}</p>
                </div>
              )}

              <div className="grid grid-cols-1 gap-4">
                <Input
                  label="Nome completo"
                  type="text"
                  value={formData.fullName}
                  onChange={(e) => handleChange('fullName', e.target.value)}
                  placeholder="Seu nome completo"
                  required
                  className="text-lg p-4"
                />

                <Input
                  label="Nome da empresa"
                  type="text"
                  value={formData.companyName}
                  onChange={(e) => handleChange('companyName', e.target.value)}
                  placeholder="Nome da sua empresa"
                  required
                  className="text-lg p-4"
                />

                <Input
                  label="Email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleChange('email', e.target.value)}
                  placeholder="seu@email.com"
                  required
                  className="text-lg p-4"
                />

                <div className="relative">
                  <Input
                    label="Senha"
                    type={showPassword ? 'text' : 'password'}
                    value={formData.password}
                    onChange={(e) => handleChange('password', e.target.value)}
                    placeholder="••••••••"
                    required
                    className="text-lg p-4 pr-12"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-12 text-secondary-400 hover:text-secondary-600 transition-colors"
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
                    className="text-lg p-4 pr-12"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-4 top-12 text-secondary-400 hover:text-secondary-600 transition-colors"
                  >
                    {showConfirmPassword ? (
                      <EyeOff className="w-5 h-5" />
                    ) : (
                      <Eye className="w-5 h-5" />
                    )}
                  </button>
                </div>
              </div>

              <Button
                type="submit"
                className="w-full text-lg py-4 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg transform hover:scale-[1.02] transition-all"
                loading={loading}
                disabled={!formData.email || !formData.password || !formData.fullName}
              >
                Criar conta
              </Button>
            </form>

            <div className="mt-8 space-y-4">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-secondary-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white text-secondary-500">Já tem conta?</span>
                </div>
              </div>
              
              <Link to="/login" className="block">
                <Button 
                  variant="outline" 
                  className="w-full text-lg py-4 border-primary-200 text-primary-600 hover:bg-primary-50 hover:border-primary-300"
                >
                  Fazer login
                </Button>
              </Link>
            </div>

            <div className="mt-6 text-center">
              <Link 
                to="/" 
                className="inline-flex items-center text-secondary-500 hover:text-primary-600 transition-colors"
              >
                ← Voltar para o início
              </Link>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
