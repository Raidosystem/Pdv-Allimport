import { useState } from 'react';
import { Link } from 'react-router-dom';
import { 
  AlertTriangle, 
  CheckCircle, 
  ShoppingCart, 
  Wrench,
  ArrowLeft,
  RefreshCw
} from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { AuthDiagnostic } from '../components/admin/AuthDiagnostic';
import { SystemCheck } from '../components/admin/SystemCheck';

export function DiagnosticPage() {
  const [activeTab, setActiveTab] = useState<'auth' | 'system'>('auth');

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-white to-red-50">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-orange-500 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-red-400 rounded-full blur-3xl"></div>
      </div>

      {/* Header */}
      <header className="relative bg-white/90 backdrop-blur-sm shadow-lg border-b border-orange-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            <div className="flex items-center space-x-4">
              <Link to="/" className="flex items-center space-x-3">
                <div className="w-14 h-14 bg-gradient-to-br from-orange-500 to-red-600 rounded-2xl flex items-center justify-center shadow-lg">
                  <Wrench className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h1 className="text-3xl font-bold text-gray-900">
                    Diagnóstico do Sistema
                  </h1>
                  <p className="text-orange-600 font-medium">Resolução de Problemas</p>
                </div>
              </Link>
            </div>
            
            <div className="flex items-center space-x-4">
              <Button 
                onClick={() => window.history.back()}
                variant="outline" 
                className="flex items-center space-x-2 border-blue-200 text-blue-600 hover:bg-blue-50"
              >
                <ArrowLeft className="w-5 h-5" />
                <span>Voltar</span>
              </Button>
              
              <Link to="/login">
                <Button className="bg-gradient-to-r from-orange-500 to-red-600 hover:from-orange-600 hover:to-red-700">
                  Fazer Login
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="relative max-w-6xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        {/* Título e Introdução */}
        <div className="text-center mb-12">
          <div className="w-20 h-20 bg-gradient-to-br from-orange-500 to-red-600 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-xl">
            <AlertTriangle className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Diagnóstico Completo do Sistema
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Use esta ferramenta para identificar e resolver problemas de autenticação e configuração do sistema PDV Import.
          </p>
        </div>

        {/* Tabs */}
        <div className="flex justify-center mb-8">
          <div className="bg-white rounded-lg p-1 shadow-lg border">
            <button
              onClick={() => setActiveTab('auth')}
              className={`px-6 py-3 rounded-md font-medium transition-all ${
                activeTab === 'auth'
                  ? 'bg-orange-500 text-white shadow-md'
                  : 'text-gray-600 hover:text-orange-600'
              }`}
            >
              Diagnóstico de Autenticação
            </button>
            <button
              onClick={() => setActiveTab('system')}
              className={`px-6 py-3 rounded-md font-medium transition-all ${
                activeTab === 'system'
                  ? 'bg-orange-500 text-white shadow-md'
                  : 'text-gray-600 hover:text-orange-600'
              }`}
            >
              Verificação do Sistema
            </button>
          </div>
        </div>

        {/* Conteúdo baseado na tab */}
        {activeTab === 'auth' ? (
          <div className="space-y-8">
            <AuthDiagnostic />
            
            {/* Dicas Adicionais */}
            <Card className="p-6 bg-gradient-to-r from-blue-50 to-indigo-50 border-blue-200">
              <h3 className="text-lg font-semibold text-blue-800 mb-4 flex items-center gap-2">
                <CheckCircle className="w-5 h-5" />
                Dicas para Resolver Problemas de Autenticação
              </h3>
              <div className="space-y-3 text-blue-700">
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">1</div>
                  <p><strong>Conta de Teste:</strong> Use suas credenciais de administrador para login</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">2</div>
                  <p><strong>Cache do Navegador:</strong> Limpe cache e cookies se houver problemas persistentes</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">3</div>
                  <p><strong>Configuração do Supabase:</strong> Verifique se as variáveis de ambiente estão corretas</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0 mt-0.5">4</div>
                  <p><strong>Script do Banco:</strong> Execute o script SQL completo no painel do Supabase</p>
                </div>
              </div>
            </Card>
          </div>
        ) : (
          <div className="space-y-8">
            <SystemCheck />
            
            {/* Links Úteis */}
            <Card className="p-6 bg-gradient-to-r from-green-50 to-emerald-50 border-green-200">
              <h3 className="text-lg font-semibold text-green-800 mb-4 flex items-center gap-2">
                <Wrench className="w-5 h-5" />
                Links Úteis para Configuração
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <a 
                  href="https://supabase.com/dashboard"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-3 p-3 bg-white rounded-lg border hover:border-green-300 transition-colors"
                >
                  <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                    <ShoppingCart className="w-4 h-4 text-white" />
                  </div>
                  <div>
                    <p className="font-medium text-green-800">Painel do Supabase</p>
                    <p className="text-sm text-green-600">Configurar banco de dados</p>
                  </div>
                </a>
                
                <Link 
                  to="/test-login"
                  className="flex items-center gap-3 p-3 bg-white rounded-lg border hover:border-green-300 transition-colors"
                >
                  <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                    <CheckCircle className="w-4 h-4 text-white" />
                  </div>
                  <div>
                    <p className="font-medium text-green-800">Teste de Login</p>
                    <p className="text-sm text-green-600">Página dedicada para testes</p>
                  </div>
                </Link>

                <Link 
                  to="/signup"
                  className="flex items-center gap-3 p-3 bg-white rounded-lg border hover:border-green-300 transition-colors"
                >
                  <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                    <ShoppingCart className="w-4 h-4 text-white" />
                  </div>
                  <div>
                    <p className="font-medium text-green-800">Criar Conta</p>
                    <p className="text-sm text-green-600">Registrar novo usuário</p>
                  </div>
                </Link>

                <Link 
                  to="/resend-confirmation"
                  className="flex items-center gap-3 p-3 bg-white rounded-lg border hover:border-green-300 transition-colors"
                >
                  <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                    <RefreshCw className="w-4 h-4 text-white" />
                  </div>
                  <div>
                    <p className="font-medium text-green-800">Reenviar Confirmação</p>
                    <p className="text-sm text-green-600">Email de verificação</p>
                  </div>
                </Link>
              </div>
            </Card>
          </div>
        )}

        {/* Rodapé com Ações */}
        <div className="mt-12 text-center">
          <Card className="p-6 bg-gradient-to-r from-gray-50 to-gray-100 border-gray-200">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">
              Ainda com Problemas?
            </h3>
            <p className="text-gray-600 mb-4">
              Se o diagnóstico não resolveu seu problema, tente as opções abaixo:
            </p>
            <div className="flex flex-wrap justify-center gap-4">
              <Button 
                variant="outline"
                onClick={() => window.location.reload()}
                className="gap-2"
              >
                <RefreshCw className="w-4 h-4" />
                Recarregar Página
              </Button>
              
              <Link to="/login">
                <Button className="bg-gradient-to-r from-orange-500 to-red-600 hover:from-orange-600 hover:to-red-700">
                  Tentar Login Novamente
                </Button>
              </Link>
            </div>
          </Card>
        </div>
      </main>
    </div>
  );
}
