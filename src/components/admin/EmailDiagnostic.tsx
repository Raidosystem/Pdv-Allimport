import { useState } from 'react'
import { Mail, CheckCircle, AlertTriangle, RefreshCw } from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { Input } from '../ui/Input'
import { useAuth } from '../../modules/auth'
import { supabase } from '../../lib/supabase'

export function EmailDiagnostic() {
  const { user } = useAuth()
  const [testEmail, setTestEmail] = useState('')
  const [signupResult, setSignupResult] = useState('')
  const [resetResult, setResetResult] = useState('')
  const [loading, setLoading] = useState(false)

  const testSignupEmail = async () => {
    if (!testEmail) return
    
    setLoading(true)
    setSignupResult('🔄 Testando envio de email de cadastro...')
    
    try {
      const { error } = await supabase.auth.signUp({
        email: testEmail,
        password: 'teste123456',
        options: {
          emailRedirectTo: 'https://pdv.gruporaval.com.br/confirm-email'
        }
      })
      
      if (error) {
        if (error.message.includes('already')) {
          setSignupResult('⚠️ Email já cadastrado. Teste com outro email.')
        } else {
          setSignupResult(`❌ Erro: ${error.message}`)
        }
      } else {
        setSignupResult('✅ Email de confirmação enviado! Verifique sua caixa de entrada.')
      }
    } catch (err) {
      setSignupResult(`❌ Erro inesperado: ${err}`)
    } finally {
      setLoading(false)
    }
  }

  const testResetEmail = async () => {
    if (!testEmail) return
    
    setLoading(true)
    setResetResult('🔄 Testando envio de email de recuperação...')
    
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(testEmail, {
        redirectTo: 'https://pdv.gruporaval.com.br/reset-password'
      })
      
      if (error) {
        setResetResult(`❌ Erro: ${error.message}`)
      } else {
        setResetResult('✅ Email de recuperação enviado! Verifique sua caixa de entrada.')
      }
    } catch (err) {
      setResetResult(`❌ Erro inesperado: ${err}`)
    } finally {
      setLoading(false)
    }
  }

  const configuracoes = [
    {
      item: 'Site URL',
      esperado: 'https://pdv.gruporaval.com.br',
      status: 'manual'
    },
    {
      item: 'Redirect URLs',
      esperado: '/confirm-email, /reset-password configuradas',
      status: 'manual'
    },
    {
      item: 'Email Confirmations',
      esperado: 'Habilitado',
      status: 'manual'
    },
    {
      item: 'Email Templates',
      esperado: 'Personalizados configurados',
      status: 'manual'
    }
  ]

  return (
    <div className="space-y-6">
      <div className="text-center">
        <Mail className="w-16 h-16 mx-auto mb-4 text-blue-500" />
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Diagnóstico de Email
        </h1>
        <p className="text-gray-600">
          Teste se os emails de cadastro e recuperação estão funcionando
        </p>
      </div>

      {/* Configurações Necessárias */}
      <Card className="p-6">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
          <AlertTriangle className="w-5 h-5 text-orange-500" />
          Configurações Necessárias no Dashboard
        </h2>
        
        <div className="space-y-3">
          {configuracoes.map((config, index) => (
            <div key={index} className="flex items-center justify-between p-3 bg-orange-50 rounded-lg">
              <div>
                <div className="font-medium">{config.item}</div>
                <div className="text-sm text-gray-600">{config.esperado}</div>
              </div>
              <div className="flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-orange-500" />
                <span className="text-sm text-orange-600">Verificar manualmente</span>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-4 p-4 bg-blue-50 rounded-lg">
          <div className="font-semibold text-blue-800 mb-2">📋 Instruções:</div>
          <ol className="list-decimal list-inside space-y-1 text-sm text-blue-700">
            <li>Acesse: <a href="https://supabase.com/dashboard/project/your-project-ref/auth/settings" className="underline" target="_blank" rel="noopener noreferrer">Dashboard do Supabase</a></li>
            <li>Configure todas as opções conforme o arquivo CONFIGURAR_EMAIL_SUPABASE.md</li>
            <li>Volte aqui e teste os emails</li>
          </ol>
        </div>
      </Card>

      {/* Teste de Emails */}
      <Card className="p-6">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
          <RefreshCw className="w-5 h-5 text-blue-500" />
          Testar Envio de Emails
        </h2>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Email para teste:
            </label>
            <Input
              type="email"
              value={testEmail}
              onChange={(e) => setTestEmail(e.target.value)}
              placeholder="seu-email@exemplo.com"
              className="w-full"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Teste de Cadastro */}
            <div className="space-y-3">
              <Button
                onClick={testSignupEmail}
                disabled={!testEmail || loading}
                className="w-full"
                variant="primary"
              >
                Testar Email de Cadastro
              </Button>
              
              {signupResult && (
                <div className="p-3 bg-gray-50 rounded-lg">
                  <div className="text-sm">{signupResult}</div>
                </div>
              )}
            </div>

            {/* Teste de Recuperação */}
            <div className="space-y-3">
              <Button
                onClick={testResetEmail}
                disabled={!testEmail || loading}
                className="w-full"
                variant="secondary"
              >
                Testar Email de Recuperação
              </Button>
              
              {resetResult && (
                <div className="p-3 bg-gray-50 rounded-lg">
                  <div className="text-sm">{resetResult}</div>
                </div>
              )}
            </div>
          </div>
        </div>
      </Card>

      {/* Status do Usuário Atual */}
      {user && (
        <Card className="p-6">
          <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
            <CheckCircle className="w-5 h-5 text-green-500" />
            Status do Usuário Atual
          </h2>
          
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>Email:</span>
              <span className="font-mono">{user.email}</span>
            </div>
            <div className="flex justify-between">
              <span>Email confirmado:</span>
              <span className={user.email_confirmed_at ? 'text-green-600' : 'text-red-600'}>
                {user.email_confirmed_at ? '✅ Sim' : '❌ Não'}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Data de confirmação:</span>
              <span className="font-mono text-sm">
                {user.email_confirmed_at || 'Não confirmado'}
              </span>
            </div>
          </div>
        </Card>
      )}

      {/* Problemas Comuns */}
      <Card className="p-6 bg-yellow-50 border-yellow-200">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2 text-yellow-800">
          <AlertTriangle className="w-5 h-5" />
          Problemas Comuns
        </h2>
        
        <div className="space-y-3 text-sm text-yellow-700">
          <div>
            <div className="font-semibold">❌ Email não chega:</div>
            <div>• Verifique se "Enable email confirmations" está LIGADO</div>
            <div>• Verifique a pasta de SPAM/Lixo eletrônico</div>
            <div>• Aguarde até 5 minutos</div>
          </div>
          
          <div>
            <div className="font-semibold">❌ Link redireciona para localhost:</div>
            <div>• Configure as Redirect URLs no dashboard</div>
            <div>• Verifique se Site URL está correta</div>
          </div>
          
          <div>
            <div className="font-semibold">❌ Erro 404 ao clicar no link:</div>
            <div>• Verifique se as rotas /confirm-email e /reset-password existem</div>
            <div>• Verifique se o deploy está atualizado</div>
          </div>
        </div>
      </Card>
    </div>
  )
}
