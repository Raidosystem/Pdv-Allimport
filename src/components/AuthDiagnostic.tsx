import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth/AuthContext';
import { 
  AlertTriangle, 
  CheckCircle, 
  Database, 
  Settings, 
  RefreshCw, 
  User,
  Key,
  Globe,
  Eye,
  EyeOff,
  Zap
} from 'lucide-react';
import { Button } from './ui/Button';
import { detectAuthProblems, autoFixCommonProblems, getErrorIcon, getErrorColor, type AuthError } from '../utils/authDiagnostic';

interface DiagnosticStatus {
  envConfig: boolean;
  supabaseConnection: boolean;
  authState: boolean;
  userSession: boolean;
  tableAccess: boolean;
  message: string;
  details: string[];
  errors: AuthError[];
}

export function AuthDiagnostic() {
  const { user, signIn, signOut } = useAuth();
  const [status, setStatus] = useState<DiagnosticStatus>({
    envConfig: false,
    supabaseConnection: false,
    authState: false,
    userSession: false,
    tableAccess: false,
    message: 'Iniciando diagnóstico...',
    details: [],
    errors: []
  });
  const [loading, setLoading] = useState(true);
  const [showTestLogin, setShowTestLogin] = useState(false);
  const [testCredentials, setTestCredentials] = useState({
    email: 'teste@teste.com',
    password: 'teste@@'
  });
  const [loginLoading, setLoginLoading] = useState(false);
  const [autoFixLoading, setAutoFixLoading] = useState(false);

  const runFullDiagnostic = async () => {
    setLoading(true);
    const newStatus: DiagnosticStatus = {
      envConfig: false,
      supabaseConnection: false,
      authState: false,
      userSession: false,
      tableAccess: false,
      message: '',
      details: [],
      errors: []
    };

    try {
      // Usar o detector automático de problemas
      const detectedErrors = await detectAuthProblems();
      newStatus.errors = detectedErrors;

      // 1. Verificar variáveis de ambiente
      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
      const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
      
      if (supabaseUrl && supabaseKey && supabaseUrl !== 'your_supabase_project_url') {
        newStatus.envConfig = true;
        newStatus.details.push('✅ Variáveis de ambiente configuradas');
      } else {
        newStatus.details.push('❌ Variáveis de ambiente não configuradas');
        newStatus.message = 'Configure VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY no .env';
        setStatus(newStatus);
        setLoading(false);
        return;
      }

      // 2. Testar conexão com Supabase
      try {
        const { error } = await supabase.from('_test_connection').select('*').limit(1);
        if (error && error.code !== 'PGRST116') {
          throw error;
        }
        newStatus.supabaseConnection = true;
        newStatus.details.push('✅ Conexão com Supabase estabelecida');
      } catch (error) {
        newStatus.details.push('❌ Falha na conexão com Supabase');
        console.error('Erro de conexão:', error);
      }

      // 3. Verificar estado de autenticação atual
      const { data: { user: currentUser }, error: authError } = await supabase.auth.getUser();
      if (!authError && currentUser) {
        newStatus.authState = true;
        newStatus.userSession = true;
        newStatus.details.push(`✅ Usuário autenticado: ${currentUser.email}`);
      } else {
        newStatus.details.push('❌ Nenhum usuário autenticado');
      }

      // 4. Testar acesso às tabelas
      if (currentUser) {
        try {
          const { error: categoriesError } = await supabase
            .from('categories')
            .select('id')
            .limit(1);
          
          const { error: caixaError } = await supabase
            .from('caixa')
            .select('id')
            .limit(1);

          if (!categoriesError && !caixaError) {
            newStatus.tableAccess = true;
            newStatus.details.push('✅ Acesso às tabelas funcionando');
          } else {
            newStatus.details.push('❌ Erro ao acessar tabelas do banco');
            if (categoriesError) newStatus.details.push(`  • Categorias: ${categoriesError.message}`);
            if (caixaError) newStatus.details.push(`  • Caixa: ${caixaError.message}`);
          }
        } catch {
          newStatus.details.push('❌ Erro ao testar acesso às tabelas');
        }
      }

      // Definir mensagem final
      if (newStatus.envConfig && newStatus.supabaseConnection && newStatus.authState && newStatus.tableAccess) {
        newStatus.message = '🎉 Sistema funcionando perfeitamente!';
      } else if (newStatus.envConfig && newStatus.supabaseConnection && !newStatus.authState) {
        newStatus.message = '🔐 Faça login para acessar o sistema';
      } else if (newStatus.envConfig && newStatus.supabaseConnection && newStatus.authState && !newStatus.tableAccess) {
        newStatus.message = '🗄️ Problema com acesso ao banco de dados';
      } else {
        newStatus.message = '⚠️ Sistema com problemas de configuração';
      }

    } catch (error) {
      console.error('Erro no diagnóstico:', error);
      newStatus.message = '❌ Erro durante diagnóstico';
      newStatus.details.push(`Erro: ${error instanceof Error ? error.message : 'Erro desconhecido'}`);
    }

    setStatus(newStatus);
    setLoading(false);
  };

  const handleTestLogin = async () => {
    setLoginLoading(true);
    try {
      const { error } = await signIn(testCredentials.email, testCredentials.password);
      if (error) {
        console.error('Erro no login de teste:', error);
      } else {
        // Aguardar um momento e refazer diagnóstico
        setTimeout(() => {
          runFullDiagnostic();
        }, 1000);
      }
    } catch (error) {
      console.error('Erro inesperado:', error);
    }
    setLoginLoading(false);
  };

  const handleAutoFix = async () => {
    setAutoFixLoading(true);
    try {
      const result = await autoFixCommonProblems();
      if (result.fixed) {
        setTimeout(() => {
          runFullDiagnostic();
        }, 1000);
      }
    } catch (error) {
      console.error('Erro na correção automática:', error);
    }
    setAutoFixLoading(false);
  };

  const handleLogout = async () => {
    await signOut();
    setTimeout(() => {
      runFullDiagnostic();
    }, 500);
  };

  useEffect(() => {
    runFullDiagnostic();
  }, []);

  const allGreen = status.envConfig && status.supabaseConnection && status.authState && status.tableAccess;

  return (
    <div className={`border rounded-lg p-6 ${
      allGreen 
        ? 'bg-green-50 border-green-200' 
        : 'bg-orange-50 border-orange-200'
    }`}>
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          {allGreen ? (
            <CheckCircle className="w-6 h-6 text-green-600" />
          ) : (
            <AlertTriangle className="w-6 h-6 text-orange-600" />
          )}
          <div>
            <h3 className={`text-lg font-semibold ${
              allGreen ? 'text-green-800' : 'text-orange-800'
            }`}>
              Diagnóstico de Autenticação
            </h3>
            <p className={`text-sm ${
              allGreen ? 'text-green-600' : 'text-orange-600'
            }`}>
              {status.message}
            </p>
          </div>
        </div>
        
        <Button
          onClick={runFullDiagnostic}
          size="sm"
          variant="outline"
          loading={loading}
          className="gap-2"
        >
          <RefreshCw className="w-4 h-4" />
          Verificar Novamente
        </Button>
        
        {status.errors.length > 0 && (
          <Button
            onClick={handleAutoFix}
            size="sm"
            loading={autoFixLoading}
            className="gap-2 bg-orange-500 hover:bg-orange-600"
          >
            <Zap className="w-4 h-4" />
            Correção Automática
          </Button>
        )}
      </div>

      {/* Status Detalhado */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <div className="flex items-center gap-2">
          <Settings className="w-4 h-4" />
          <span className="text-sm">Configuração:</span>
          {status.envConfig ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-red-600" />
          )}
        </div>

        <div className="flex items-center gap-2">
          <Globe className="w-4 h-4" />
          <span className="text-sm">Conexão:</span>
          {status.supabaseConnection ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-red-600" />
          )}
        </div>

        <div className="flex items-center gap-2">
          <User className="w-4 h-4" />
          <span className="text-sm">Autenticação:</span>
          {status.authState ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-yellow-600" />
          )}
        </div>

        <div className="flex items-center gap-2">
          <Database className="w-4 h-4" />
          <span className="text-sm">Banco:</span>
          {status.tableAccess ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-red-600" />
          )}
        </div>
      </div>

      {/* Detalhes */}
      <div className="mb-6">
        <h4 className="font-medium text-gray-800 mb-2">Detalhes do Diagnóstico:</h4>
        <div className="bg-white rounded border p-3 max-h-32 overflow-y-auto">
          {status.details.map((detail, index) => (
            <div key={index} className="text-sm py-1 font-mono">
              {detail}
            </div>
          ))}
        </div>
      </div>

      {/* Problemas Detectados */}
      {status.errors.length > 0 && (
        <div className="mb-6">
          <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
            <AlertTriangle className="w-5 h-5 text-orange-500" />
            Problemas Detectados ({status.errors.length})
          </h4>
          <div className="space-y-3">
            {status.errors.map((error, index) => (
              <div key={index} className={`border rounded-lg p-4 bg-${getErrorColor(error.type)}-50 border-${getErrorColor(error.type)}-200`}>
                <div className="flex items-start gap-3">
                  <span className="text-2xl">{getErrorIcon(error.type)}</span>
                  <div className="flex-1">
                    <h5 className={`font-medium text-${getErrorColor(error.type)}-800 mb-1`}>
                      {error.userMessage}
                    </h5>
                    <p className={`text-sm text-${getErrorColor(error.type)}-600 mb-2`}>
                      {error.message}
                    </p>
                    <div className="space-y-1">
                      <p className={`text-xs font-medium text-${getErrorColor(error.type)}-700`}>
                        Soluções sugeridas:
                      </p>
                      {error.solutions.map((solution, sIndex) => (
                        <p key={sIndex} className={`text-xs text-${getErrorColor(error.type)}-600 pl-3`}>
                          • {solution}
                        </p>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Ações */}
      <div className="space-y-4">
        {user ? (
          <div className="flex items-center justify-between p-3 bg-green-100 rounded border">
            <div>
              <p className="text-sm font-medium text-green-800">
                Logado como: {user.email}
              </p>
              <p className="text-xs text-green-600">
                ID: {user.id.substring(0, 8)}...
              </p>
            </div>
            <Button onClick={handleLogout} size="sm" variant="outline">
              Logout
            </Button>
          </div>
        ) : (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h4 className="font-medium text-gray-800">Teste de Login:</h4>
              <Button
                onClick={() => setShowTestLogin(!showTestLogin)}
                size="sm"
                variant="outline"
                className="gap-2"
              >
                {showTestLogin ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                {showTestLogin ? 'Ocultar' : 'Mostrar'}
              </Button>
            </div>

            {showTestLogin && (
              <div className="p-4 bg-white rounded border space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Email:
                  </label>
                  <input
                    type="email"
                    value={testCredentials.email}
                    onChange={(e) => setTestCredentials(prev => ({ ...prev, email: e.target.value }))}
                    className="w-full px-3 py-2 border rounded-md text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Senha:
                  </label>
                  <input
                    type="password"
                    value={testCredentials.password}
                    onChange={(e) => setTestCredentials(prev => ({ ...prev, password: e.target.value }))}
                    className="w-full px-3 py-2 border rounded-md text-sm"
                  />
                </div>
                <Button
                  onClick={handleTestLogin}
                  loading={loginLoading}
                  className="w-full gap-2"
                >
                  <Key className="w-4 h-4" />
                  Testar Login
                </Button>
              </div>
            )}
          </div>
        )}

        {/* Script para corrigir banco */}
        {status.envConfig && status.supabaseConnection && !status.tableAccess && (
          <div className="p-4 bg-yellow-50 border border-yellow-200 rounded">
            <h4 className="font-medium text-yellow-800 mb-2">🔧 Como corrigir o banco:</h4>
            <ol className="text-sm text-yellow-700 space-y-1 list-decimal list-inside">
              <li>Acesse o <a href="https://supabase.com/dashboard" target="_blank" className="underline">Painel do Supabase</a></li>
              <li>Vá em SQL Editor</li>
              <li>Execute o arquivo <code>script-completo-para-supabase.sql</code></li>
              <li>Verifique se todas as tabelas foram criadas</li>
            </ol>
          </div>
        )}
      </div>
    </div>
  );
}
