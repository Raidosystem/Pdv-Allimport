import { Link } from 'react-router-dom'
import { ShoppingCart, Mail, ExternalLink, Copy } from 'lucide-react'
import { useState } from 'react'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'

export function EmailInstructionsPage() {
  const [copied, setCopied] = useState(false)

  const correctUrl = 'https://pdv.gruporaval.com.br/confirm-email'

  const copyToClipboard = () => {
    navigator.clipboard.writeText(correctUrl)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-2xl">
        {/* Logo Card */}
        <Card className="mb-6 bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="text-center py-6">
            <Link to="/" className="inline-flex items-center space-x-3">
              <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
                <p className="text-primary-600 font-medium">Instruções de Email</p>
              </div>
            </Link>
          </div>
        </Card>

        {/* Instructions Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <Mail className="w-10 h-10 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                Link do Email Abre Localhost?
              </h2>
              <p className="text-secondary-600 text-lg">
                Siga estas instruções para acessar corretamente
              </p>
            </div>

            <div className="space-y-6">
              {/* Problema */}
              <div className="bg-red-50 border border-red-200 rounded-xl p-6">
                <h3 className="text-xl font-bold text-red-800 mb-3">🚨 Problema Comum</h3>
                <p className="text-red-700">
                  O link do email às vezes abre <code className="bg-red-100 px-2 py-1 rounded">localhost:5173</code> ao invés do site de produção.
                </p>
              </div>

              {/* Soluções */}
              <div className="bg-green-50 border border-green-200 rounded-xl p-6">
                <h3 className="text-xl font-bold text-green-800 mb-4">✅ Soluções</h3>
                
                <div className="space-y-4">
                  <div className="bg-white p-4 rounded-lg border border-green-200">
                    <h4 className="font-semibold text-green-800 mb-2">1. Substituir a URL manualmente</h4>
                    <p className="text-green-700 text-sm mb-3">
                      Quando o link abrir, substitua <code className="bg-green-100 px-1 rounded">localhost:5173</code> por <code className="bg-green-100 px-1 rounded">pdv.gruporaval.com.br</code>
                    </p>
                    <div className="bg-green-100 p-3 rounded border border-green-300">
                      <p className="text-sm text-green-800 mb-2">URL correta para colar na barra de endereços:</p>
                      <div className="flex items-center gap-2">
                        <code className="bg-white px-3 py-2 rounded flex-1 text-sm">{correctUrl}</code>
                        <Button
                          size="sm"
                          onClick={copyToClipboard}
                          className="flex items-center gap-2"
                        >
                          {copied ? <span>Copiado!</span> : <><Copy className="w-4 h-4" /> Copiar</>}
                        </Button>
                      </div>
                    </div>
                  </div>

                  <div className="bg-white p-4 rounded-lg border border-green-200">
                    <h4 className="font-semibold text-green-800 mb-2">2. Usar o botão abaixo</h4>
                    <p className="text-green-700 text-sm mb-3">
                      Clique no botão para ir diretamente para a página de confirmação
                    </p>
                    <a href={correctUrl} target="_blank" rel="noopener noreferrer">
                      <Button className="flex items-center gap-2 bg-green-600 hover:bg-green-700">
                        <ExternalLink className="w-4 h-4" />
                        Abrir Página de Confirmação
                      </Button>
                    </a>
                  </div>

                  <div className="bg-white p-4 rounded-lg border border-green-200">
                    <h4 className="font-semibold text-green-800 mb-2">3. Testar login direto</h4>
                    <p className="text-green-700 text-sm mb-3">
                      Teste se sua conta já funciona mesmo sem confirmação
                    </p>
                    <Link to="/test-login">
                      <Button variant="outline" className="border-green-600 text-green-600 hover:bg-green-50">
                        Testar Login Agora
                      </Button>
                    </Link>
                  </div>
                </div>
              </div>

              {/* Explicação Técnica */}
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
                <h3 className="text-xl font-bold text-blue-800 mb-3">🔧 Por que isso acontece?</h3>
                <p className="text-blue-700 text-sm">
                  Durante o desenvolvimento, o sistema às vezes gera links com localhost. 
                  Estamos corrigindo isso, mas por enquanto você pode usar as soluções acima.
                </p>
              </div>
            </div>

            <div className="mt-8 flex flex-col sm:flex-row gap-4 justify-center">
              <Link to="/resend-confirmation">
                <Button variant="outline" className="w-full sm:w-auto">
                  Reenviar Email
                </Button>
              </Link>
              <Link to="/login">
                <Button className="w-full sm:w-auto">
                  Voltar ao Login
                </Button>
              </Link>
            </div>
          </div>
        </Card>
      </div>
    </div>
  )
}
