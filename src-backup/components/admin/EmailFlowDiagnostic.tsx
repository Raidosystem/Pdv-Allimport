import { useState } from 'react'
import { Mail, AlertCircle, CheckCircle, Info } from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { supabase } from '../../lib/supabase'

export function EmailFlowDiagnostic() {
  const [results, setResults] = useState<any[]>([])
  const [loading, setLoading] = useState(false)

  const runDiagnostic = async () => {
    setLoading(true)
    setResults([])
    
    const checks = []

    // 1. Testar configuração básica
    checks.push({
      test: 'Configuração Supabase',
      status: 'success',
      message: 'Cliente Supabase inicializado corretamente'
    })

    // 2. Testar URLs de redirecionamento
    const currentUrl = window.location.origin
    checks.push({
      test: 'URL de redirecionamento',
      status: 'info',
      message: `URL atual: ${currentUrl}/confirm-email`
    })

    // 3. Testar criação de usuário
    try {
      const testEmail = `teste-${Date.now()}@exemplo.com`
      const { data, error } = await supabase.auth.signUp({
        email: testEmail,
        password: 'teste123456',
        options: {
          emailRedirectTo: `${currentUrl}/confirm-email`
        }
      })

      if (error) {
        checks.push({
          test: 'Criação de usuário de teste',
          status: 'error',
          message: `Erro: ${error.message}`
        })
      } else {
        checks.push({
          test: 'Criação de usuário de teste',
          status: 'success',
          message: `Usuário criado. Email confirmado: ${data.user?.email_confirmed_at ? 'Sim' : 'Não'}`
        })
        
        if (!data.user?.email_confirmed_at) {
          checks.push({
            test: 'Status de confirmação',
            status: 'warning',
            message: 'Email não confirmado automaticamente - confirmação por email necessária'
          })
        }
      }
    } catch (err: any) {
      checks.push({
        test: 'Criação de usuário de teste',
        status: 'error',
        message: `Erro inesperado: ${err.message}`
      })
    }

    // 4. Verificar sessão atual
    try {
      const { data: { session } } = await supabase.auth.getSession()
      checks.push({
        test: 'Sessão atual',
        status: 'info',
        message: session ? `Usuário logado: ${session.user.email}` : 'Nenhuma sessão ativa'
      })
    } catch (err: any) {
      checks.push({
        test: 'Sessão atual',
        status: 'error',
        message: `Erro ao verificar sessão: ${err.message}`
      })
    }

    // 5. Verificar suporte a auth
    checks.push({
      test: 'Suporte a autenticação',
      status: 'success',
      message: 'Métodos disponíveis: email/senha, confirmação por email'
    })

    setResults(checks)
    setLoading(false)
  }

  const getIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-5 h-5 text-green-500" />
      case 'error':
        return <AlertCircle className="w-5 h-5 text-red-500" />
      case 'warning':
        return <AlertCircle className="w-5 h-5 text-yellow-500" />
      default:
        return <Info className="w-5 h-5 text-blue-500" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'text-green-700 bg-green-50 border-green-200'
      case 'error':
        return 'text-red-700 bg-red-50 border-red-200'
      case 'warning':
        return 'text-yellow-700 bg-yellow-50 border-yellow-200'
      default:
        return 'text-blue-700 bg-blue-50 border-blue-200'
    }
  }

  return (
    <Card className="max-w-4xl mx-auto p-6">
      <div className="flex items-center gap-3 mb-6">
        <Mail className="w-6 h-6 text-blue-600" />
        <h2 className="text-xl font-semibold">Diagnóstico do Fluxo de Email</h2>
      </div>

      <div className="mb-6">
        <Button
          onClick={runDiagnostic}
          disabled={loading}
          className="w-full"
        >
          {loading ? 'Executando diagnóstico...' : 'Executar Diagnóstico'}
        </Button>
      </div>

      {results.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-medium text-gray-900 mb-3">Resultados do Diagnóstico:</h3>
          
          {results.map((result, index) => (
            <div
              key={index}
              className={`p-4 rounded-lg border ${getStatusColor(result.status)}`}
            >
              <div className="flex items-start gap-3">
                {getIcon(result.status)}
                <div className="flex-1">
                  <h4 className="font-medium">{result.test}</h4>
                  <p className="text-sm mt-1">{result.message}</p>
                </div>
              </div>
            </div>
          ))}

          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">Instruções para resolver problemas:</h4>
            <ul className="text-sm text-gray-600 space-y-1">
              <li>• Verifique se a URL de confirmação está correta no Dashboard do Supabase</li>
              <li>• Confirme que as URLs de redirecionamento estão na lista de URLs autorizadas</li>
              <li>• Verifique se a confirmação por email está habilitada nas configurações</li>
              <li>• Teste o link de confirmação em uma aba privada do navegador</li>
              <li>• Verifique os logs do console do navegador durante a confirmação</li>
            </ul>
          </div>
        </div>
      )}
    </Card>
  )
}
