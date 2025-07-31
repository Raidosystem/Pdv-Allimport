import { useState, useEffect } from 'react'
import { testSupabaseConnection, checkAuth } from './services/auth'
import './App.css'

function App() {
  const [connectionStatus, setConnectionStatus] = useState<'testing' | 'connected' | 'error'>('testing')
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    const initializeApp = async () => {
      // Testar conexão com Supabase
      const isConnected = await testSupabaseConnection()
      setConnectionStatus(isConnected ? 'connected' : 'error')
      
      // Verificar autenticação
      const currentUser = await checkAuth()
      setUser(currentUser)
    }

    initializeApp()
  }, [])

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                📊 PDV Allimport
              </h1>
            </div>
            <div className="flex items-center space-x-4">
              {/* Status da conexão */}
              <div className="flex items-center space-x-2">
                <div className={`w-3 h-3 rounded-full ${
                  connectionStatus === 'connected' ? 'bg-success-500' :
                  connectionStatus === 'error' ? 'bg-danger-500' : 'bg-warning-500'
                }`}></div>
                <span className="text-sm text-gray-600">
                  {connectionStatus === 'connected' ? 'Conectado' :
                   connectionStatus === 'error' ? 'Erro de conexão' : 'Conectando...'}
                </span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          
          {/* Welcome Card */}
          <div className="card mb-8">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                🚀 Sistema PDV Configurado com Sucesso!
              </h2>
              <p className="text-lg text-gray-600 mb-6">
                Seu ambiente de desenvolvimento está pronto para criar um sistema PDV moderno e completo.
              </p>
            </div>
          </div>

          {/* Status Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            
            {/* Supabase Status */}
            <div className="card">
              <div className="flex items-center">
                <div className={`w-10 h-10 rounded-lg flex items-center justify-center mr-4 ${
                  connectionStatus === 'connected' ? 'bg-success-100' :
                  connectionStatus === 'error' ? 'bg-danger-100' : 'bg-warning-100'
                }`}>
                  {connectionStatus === 'connected' ? '✅' :
                   connectionStatus === 'error' ? '❌' : '⏳'}
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Supabase</h3>
                  <p className="text-sm text-gray-600">
                    {connectionStatus === 'connected' ? 'Conectado e funcionando' :
                     connectionStatus === 'error' ? 'Erro na conexão' : 'Testando conexão...'}
                  </p>
                </div>
              </div>
            </div>

            {/* Auth Status */}
            <div className="card">
              <div className="flex items-center">
                <div className={`w-10 h-10 rounded-lg flex items-center justify-center mr-4 ${
                  user ? 'bg-success-100' : 'bg-gray-100'
                }`}>
                  {user ? '👤' : '🔐'}
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Autenticação</h3>
                  <p className="text-sm text-gray-600">
                    {user ? `Logado: ${user.email}` : 'Não autenticado'}
                  </p>
                </div>
              </div>
            </div>

            {/* Environment */}
            <div className="card">
              <div className="flex items-center">
                <div className="w-10 h-10 rounded-lg bg-primary-100 flex items-center justify-center mr-4">
                  ⚙️
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Ambiente</h3>
                  <p className="text-sm text-gray-600">
                    Desenvolvimento
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Next Steps */}
          <div className="card">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">🎯 Próximos Passos</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-3">
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">1</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Sistema de Autenticação</h4>
                    <p className="text-sm text-gray-600">Implementar login, registro e controle de permissões</p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">2</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Cadastro de Produtos</h4>
                    <p className="text-sm text-gray-600">Criar interface para gerenciar produtos e estoque</p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">3</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Tela de Vendas</h4>
                    <p className="text-sm text-gray-600">Interface principal do PDV para realizar vendas</p>
                  </div>
                </div>
              </div>
              
              <div className="space-y-3">
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">4</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Controle de Caixa</h4>
                    <p className="text-sm text-gray-600">Abertura, fechamento e controle financeiro</p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">5</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Relatórios</h4>
                    <p className="text-sm text-gray-600">Dashboard com gráficos e relatórios financeiros</p>
                  </div>
                </div>
                
                <div className="flex items-start space-x-3">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-600 rounded-full flex items-center justify-center text-sm font-medium">6</span>
                  <div>
                    <h4 className="font-medium text-gray-900">Impressão de Recibos</h4>
                    <p className="text-sm text-gray-600">Geração de PDFs e impressão térmica</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </main>
    </div>
  )
}

export default App
