import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { supabase } from '../../lib/supabase'

export function LoginPage() {
  const { signIn, user } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [hasAttemptedLogin, setHasAttemptedLogin] = useState(false)

  // 🔒 SEGURANÇA: Não redirecionar automaticamente na página de login
  // Apenas redirecionar APÓS o usuário fazer login manualmente
  useEffect(() => {
    if (user && hasAttemptedLogin) {
      checkFuncionariosERedirect()
    }
  }, [user, hasAttemptedLogin, navigate])

  // Verifica se há funcionários cadastrados e redireciona
  const checkFuncionariosERedirect = async () => {
    try {
      console.log('🔍 Verificando se há funcionários cadastrados...')
      
      // Buscar funcionários ativos da empresa
      const { data: funcionarios, error } = await supabase
        .from('funcionarios')
        .select('id')
        .eq('empresa_id', user?.id)
        .eq('status', 'ativo')
        .limit(1)

      if (error) {
        console.error('❌ Erro ao verificar funcionários:', error)
        navigate('/dashboard', { replace: true })
        return
      }

      if (funcionarios && funcionarios.length > 0) {
        // Tem funcionários - redirecionar para seleção
        console.log('👥 Funcionários encontrados - redirecionando para /login-local')
        navigate('/login-local', { replace: true })
      } else {
        // Não tem funcionários - ir direto pro dashboard
        console.log('📊 Nenhum funcionário - redirecionando para /dashboard')
        navigate('/dashboard', { replace: true })
      }
    } catch (error) {
      console.error('❌ Erro ao verificar funcionários:', error)
      navigate('/dashboard', { replace: true })
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { error } = await signIn(email, password)
    
    if (error) {
      if (error.message === 'Email not confirmed') {
        setError('Por favor, confirme seu email antes de fazer login. Verifique sua caixa de entrada.')
      } else if (error.message === 'Invalid login credentials') {
        setError('Email ou senha incorretos')
      } else {
        setError('Erro ao fazer login. Tente novamente.')
      }
      setLoading(false)
    } else {
      // 🔒 Marcar que o usuário fez login manualmente
      setHasAttemptedLogin(true)
      console.log('✅ Login bem-sucedido!')
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
                <h1 className="text-3xl font-bold text-secondary-900">RaVal pdv</h1>
                <p className="text-primary-600 font-medium">Sistema de Ponto de Venda</p>
              </div>
            </Link>
          </div>
        </Card>

        {/* Login Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <ShoppingCart className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Bem-vindo de volta
              </h2>
              <p className="text-secondary-600 text-lg">
                Acesse seu sistema
              </p>
            </div>

            {error && (
              <div className="mb-6 p-4 rounded-xl bg-red-50 border border-red-200 shadow-sm">
                <p className="text-red-700 text-sm font-medium">
                  {error}
                </p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-4">
                <Input
                  label="Email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="seu@email.com"
                  required
                  className="text-lg p-4"
                />

                <div className="relative">
                  <Input
                    label="Senha"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
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
              </div>

              <Button
                type="submit"
                className="w-full text-lg py-4 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 shadow-lg transform hover:scale-[1.02] transition-all"
                loading={loading}
                disabled={!email || !password}
              >
                Entrar no Sistema
              </Button>

              {/* Link Esqueci a Senha */}
              <div className="text-center">
                <Link 
                  to="/forgot-password" 
                  className="text-primary-600 hover:text-primary-700 font-medium transition-colors"
                >
                  Esqueci minha senha
                </Link>
              </div>
            </form>

            <div className="mt-8 space-y-4">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-secondary-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white text-secondary-500">Não tem conta?</span>
                </div>
              </div>
              
              <Link to="/signup" className="block">
                <Button 
                  variant="outline" 
                  className="w-full text-lg py-4 border-primary-200 text-primary-600 hover:bg-primary-50 hover:border-primary-300"
                >
                  Criar conta grátis
                </Button>
              </Link>
            </div>

            <div className="mt-6 text-center space-y-3">
              {/* Botão de acesso para funcionários - só aparece se empresa tiver funcionários */}
              {/* A lógica decide automaticamente após o login */}
              
              <Link 
                to="/resend-confirmation" 
                className="block text-primary-600 hover:text-primary-700 font-medium transition-colors"
              >
                Não recebeu o email de confirmação?
              </Link>
              
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
