import { useState, useEffect } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { ShoppingCart, Eye, EyeOff, Check } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'

export function ResetPasswordPage() {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState('')
  const [recoveryTokens, setRecoveryTokens] = useState<{ access: string; refresh: string } | null>(null)
  const navigate = useNavigate()

  useEffect(() => {
    // 🔒 SEGURANÇA CRÍTICA: Fazer logout de qualquer sessão existente ANTES de processar tokens
    // Isso previne que sessões antigas interfiram com o fluxo de recuperação
    const initResetPassword = async () => {
      // 1. Limpar qualquer sessão existente
      await supabase.auth.signOut({ scope: 'local' })
      console.log('🧹 Sessão anterior limpa')
      
      // 2. Extrair tokens do hash
      const hashParams = new URLSearchParams(window.location.hash.substring(1))
      const accessToken = hashParams.get('access_token')
      const refreshToken = hashParams.get('refresh_token')
      
      console.log('🔍 URL:', window.location.href)
      console.log('🔑 Tokens presentes:', { 
        hasAccess: !!accessToken, 
        hasRefresh: !!refreshToken 
      })
      
      if (!accessToken || !refreshToken) {
        console.log('⚠️ Tokens não encontrados')
        setError('Link inválido ou expirado. Solicite um novo link.')
        return
      }

      // 3. Armazenar tokens - NÃO criar sessão ainda
      console.log('✅ Tokens armazenados - aguardando redefinição de senha')
      setRecoveryTokens({ access: accessToken, refresh: refreshToken })
    }
    
    initResetPassword()
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    if (password !== confirmPassword) {
      setError('As senhas não coincidem.')
      setLoading(false)
      return
    }

    if (password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres.')
      setLoading(false)
      return
    }

    if (!recoveryTokens) {
      setError('Tokens de recuperação não encontrados. Solicite um novo link.')
      setLoading(false)
      return
    }

    try {
      console.log('🔄 Redefinindo senha...')
      
      // 🔒 SEGURANÇA: Criar sessão TEMPORÁRIA apenas para alterar senha
      const { error: sessionError } = await supabase.auth.setSession({
        access_token: recoveryTokens.access,
        refresh_token: recoveryTokens.refresh,
      })

      if (sessionError) {
        throw new Error('Erro ao validar tokens: ' + sessionError.message)
      }

      // Atualizar senha
      const { error: updateError } = await supabase.auth.updateUser({
        password: password
      })

      if (updateError) {
        throw updateError
      }

      console.log('✅ Senha atualizada com sucesso')

      // 🔒 CRÍTICO: Fazer logout IMEDIATAMENTE após alterar senha
      await supabase.auth.signOut({ scope: 'global' })
      console.log('🔓 Logout realizado - usuário deve fazer login com nova senha')

      setSuccess(true)
      
      // Redirecionar para login após 3 segundos
      setTimeout(() => {
        navigate('/login')
      }, 3000)
    } catch (err: any) {
      console.error('❌ Erro ao redefinir senha:', err)
      setError('Erro ao redefinir senha: ' + (err.message || 'Tente novamente.'))
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
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
                Senha Redefinida!
              </h2>
              
              <p className="text-secondary-600 mb-6 leading-relaxed">
                Sua senha foi alterada com sucesso. 
                Redirecionando para a página de login...
              </p>

              <div className="animate-spin w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full mx-auto"></div>
            </div>
          </Card>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-md">
        <Card className="mb-6 bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="text-center py-6">
            <div className="inline-flex items-center space-x-3">
              <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-secondary-900">RaVal pdv</h1>
                <p className="text-primary-600 font-medium">Sistema de Ponto de Venda</p>
              </div>
            </div>
          </div>
        </Card>

        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <ShoppingCart className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Nova Senha
              </h2>
              <p className="text-secondary-600 text-lg">
                Digite sua nova senha
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <div className="p-4 rounded-xl bg-red-50 border border-red-200 shadow-sm">
                  <p className="text-red-600 font-medium text-center">{error}</p>
                  <p className="text-red-500 text-sm text-center mt-2">
                    Links de recuperação são válidos por 1 hora e só podem ser usados 1 vez.
                  </p>
                  <p className="text-red-400 text-xs text-center mt-2">
                    💡 Horário atual: {new Date().toLocaleTimeString('pt-BR')}
                  </p>
                  <p className="text-red-400 text-xs text-center mt-1">
                    Certifique-se de usar o email MAIS RECENTE que você recebeu.
                  </p>
                </div>
              )}

              <div className="relative">
                <Input
                  label="Nova Senha"
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

              <div className="relative">
                <Input
                  label="Confirmar Nova Senha"
                  type={showConfirmPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
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

              <div className="p-4 rounded-xl bg-blue-50 border border-blue-200">
                <h3 className="text-blue-800 font-semibold mb-2">🔒 Requisitos da Senha</h3>
                <ul className="text-blue-700 text-sm space-y-1">
                  <li className={password.length >= 6 ? 'text-green-600' : ''}>
                    • Mínimo de 6 caracteres
                  </li>
                  <li className={password === confirmPassword && password ? 'text-green-600' : ''}>
                    • Senhas devem coincidir
                  </li>
                </ul>
              </div>

              <Button
                type="submit"
                className="w-full text-lg py-4 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 shadow-lg transform hover:scale-[1.02] transition-all"
                loading={loading}
                disabled={!password || !confirmPassword || password !== confirmPassword}
              >
                Redefinir Senha
              </Button>

              {error && (
                <div className="text-center">
                  <Link 
                    to="/forgot-password" 
                    className="text-primary-600 hover:text-primary-700 font-medium"
                  >
                    Solicitar novo link de recuperação
                  </Link>
                </div>
              )}
            </form>
          </div>
        </Card>
      </div>
    </div>
  )
}
