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
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-indigo-900 to-purple-900 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Background Pattern - Mais vibrante */}
      <div className="absolute inset-0 opacity-20">
        <div className="absolute inset-0 bg-gradient-to-r from-primary-500/30 to-purple-500/30"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 w-64 h-64 bg-primary-500/15 rounded-full blur-2xl animate-pulse delay-500"></div>
      </div>

      <div className="relative w-full max-w-md">
        {/* Logo Card - Mais destacado */}
        <Card className="mb-8 bg-white shadow-[0_20px_60px_rgba(0,0,0,0.4)] border-0 overflow-hidden transform hover:scale-[1.02] transition-all duration-300">
          <div className="bg-gradient-to-r from-primary-500 to-purple-600 p-1">
            <div className="bg-white text-center py-8">
              <Link to="/" className="inline-flex flex-col items-center space-y-4 group">
                <div className="w-20 h-20 bg-gradient-to-br from-primary-500 via-blue-600 to-purple-600 rounded-3xl flex items-center justify-center shadow-[0_10px_30px_rgba(59,130,246,0.5)] transform group-hover:scale-110 group-hover:rotate-3 transition-all duration-300">
                  <ShoppingCart className="w-10 h-10 text-white" />
                </div>
                <div>
                  <h1 className="text-4xl font-bold bg-gradient-to-r from-primary-600 via-blue-600 to-purple-600 bg-clip-text text-transparent">
                    RaVal PDV
                  </h1>
                  <p className="text-primary-600 font-semibold text-lg mt-1">Sistema de Ponto de Venda</p>
                </div>
              </Link>
            </div>
          </div>
        </Card>

        {/* Login Card - Design melhorado */}
        <Card className="bg-white shadow-[0_20px_60px_rgba(0,0,0,0.4)] border-0 overflow-hidden">
          <div className="bg-gradient-to-r from-primary-500 to-purple-600 p-1">
            <div className="bg-white p-8 md:p-10">
              <div className="text-center mb-8">
                <div className="inline-block p-2 bg-gradient-to-br from-primary-50 to-purple-50 rounded-3xl mb-4 shadow-lg">
                  <div className="w-16 h-16 bg-gradient-to-br from-primary-500 via-blue-600 to-purple-600 rounded-2xl flex items-center justify-center shadow-lg">
                    <ShoppingCart className="w-8 h-8 text-white" />
                  </div>
                </div>
                <h2 className="text-3xl font-bold bg-gradient-to-r from-secondary-900 to-secondary-700 bg-clip-text text-transparent mb-2">
                  Bem-vindo de volta!
                </h2>
                <p className="text-secondary-600 text-base">
                  Entre com suas credenciais para acessar
                </p>
              </div>

            {error && (
              <div className="mb-6 p-4 rounded-xl bg-gradient-to-r from-red-50 to-red-100 border-2 border-red-300 shadow-lg">
                <p className="text-red-700 text-sm font-semibold text-center">
                  {error}
                </p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-5">
                <div className="group">
                  <Input
                    label="Email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="seu@email.com"
                    required
                    className="text-lg p-4 border-2 focus:border-primary-500 focus:ring-4 focus:ring-primary-100 transition-all rounded-xl shadow-sm hover:shadow-md"
                  />
                </div>

                <div className="relative group">
                  <Input
                    label="Senha"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="text-lg p-4 pr-12 border-2 focus:border-primary-500 focus:ring-4 focus:ring-primary-100 transition-all rounded-xl shadow-sm hover:shadow-md"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-[52px] text-secondary-400 hover:text-primary-600 transition-colors p-1 hover:bg-primary-50 rounded-lg"
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
                className="w-full text-lg py-5 bg-gradient-to-r from-primary-500 via-blue-600 to-purple-600 hover:from-primary-600 hover:via-blue-700 hover:to-purple-700 shadow-[0_10px_30px_rgba(59,130,246,0.4)] hover:shadow-[0_15px_40px_rgba(59,130,246,0.6)] transform hover:scale-[1.02] transition-all duration-300 font-bold rounded-xl"
                loading={loading}
                disabled={!email || !password}
              >
                🚀 Entrar no Sistema
              </Button>

              {/* Link Esqueci a Senha */}
              <div className="text-center">
                <Link 
                  to="/forgot-password" 
                  className="group inline-flex items-center gap-2 text-primary-600 hover:text-primary-700 font-semibold transition-all duration-200 hover:scale-105 px-4 py-2 rounded-lg hover:bg-primary-50"
                >
                  <span className="text-xl">🔑</span>
                  <span>Esqueci minha senha</span>
                  <span className="opacity-0 group-hover:opacity-100 transition-opacity">→</span>
                </Link>
              </div>
            </form>

            <div className="mt-8 space-y-4">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t-2 border-secondary-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white text-secondary-600 font-semibold">Não tem conta?</span>
                </div>
              </div>
              
              <Link to="/signup" className="block">
                <Button 
                  variant="outline" 
                  className="w-full text-lg py-5 border-2 border-primary-300 text-primary-600 hover:bg-gradient-to-r hover:from-primary-50 hover:to-purple-50 hover:border-primary-400 shadow-md hover:shadow-lg transform hover:scale-[1.02] transition-all duration-300 font-bold rounded-xl"
                >
                  ✨ Criar conta grátis
                </Button>
              </Link>
            </div>

            <div className="mt-8 pt-6 border-t-2 border-secondary-100 text-center space-y-4">
              {/* Botão de acesso para funcionários - só aparece se empresa tiver funcionários */}
              {/* A lógica decide automaticamente após o login */}
              
              <Link 
                to="/resend-confirmation" 
                className="inline-block text-primary-600 hover:text-primary-700 font-semibold transition-colors hover:scale-105 transform duration-200"
              >
                📧 Não recebeu o email de confirmação?
              </Link>
              
              <Link 
                to="/" 
                className="inline-flex items-center text-secondary-500 hover:text-primary-600 transition-colors font-medium hover:scale-105 transform duration-200"
              >
                ← Voltar para o início
              </Link>
            </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
