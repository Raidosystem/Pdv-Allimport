import { useState } from 'react';
import { supabase } from '../../lib/supabase';
import { CheckCircle, XCircle, AlertCircle, Mail, Settings, ExternalLink } from 'lucide-react';

interface EmailConfigCheck {
  setting_name: string;
  current_value: string;
  recommended_value: string;
  status: string;
}

export default function EmailConfigTest() {
  const [testEmail, setTestEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<string>('');
  const [configChecks, setConfigChecks] = useState<EmailConfigCheck[]>([]);
  const [checkingConfig, setCheckingConfig] = useState(false);

  const testPasswordRecovery = async () => {
    if (!testEmail.trim()) {
      setResult('❌ Por favor, insira um email válido');
      return;
    }

    setLoading(true);
    setResult('');

    try {
      console.log('🔄 Iniciando teste de recuperação de senha...');
      
      const { data, error } = await supabase.auth.resetPasswordForEmail(testEmail, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      console.log('📧 Resposta do Supabase:', { data, error });

      if (error) {
        console.error('❌ Erro ao enviar email:', error);
        setResult(`❌ Erro: ${error.message}`);
      } else {
        console.log('✅ Email de recuperação enviado com sucesso');
        setResult('✅ Email de recuperação enviado! Verifique sua caixa de entrada (incluindo spam).');
      }
    } catch (err) {
      console.error('❌ Erro inesperado:', err);
      setResult(`❌ Erro inesperado: ${err instanceof Error ? err.message : 'Erro desconhecido'}`);
    } finally {
      setLoading(false);
    }
  };

  const checkEmailConfig = async () => {
    setCheckingConfig(true);
    try {
      const { data, error } = await supabase.rpc('check_email_config');
      
      if (error) {
        console.error('Erro ao verificar configuração:', error);
        setResult('❌ Erro ao verificar configuração de email');
      } else {
        setConfigChecks(data || []);
      }
    } catch (err) {
      console.error('Erro inesperado:', err);
    } finally {
      setCheckingConfig(false);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'OK':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'ERROR':
        return <XCircle className="h-4 w-4 text-red-500" />;
      default:
        return <AlertCircle className="h-4 w-4 text-yellow-500" />;
    }
  };

  const getStatusBadge = (status: string) => {
    const baseClasses = "px-2 py-1 rounded-full text-xs font-medium";
    switch (status) {
      case 'OK':
        return <span className={`${baseClasses} bg-green-100 text-green-800`}>OK</span>;
      case 'ERROR':
        return <span className={`${baseClasses} bg-red-100 text-red-800`}>Erro</span>;
      default:
        return <span className={`${baseClasses} bg-yellow-100 text-yellow-800`}>Verificar</span>;
    }
  };

  const openSupabaseDashboard = () => {
    window.open('https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings', '_blank');
  };

  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <div className="space-y-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900">Teste de Configuração de Email</h1>
          <p className="text-gray-600 mt-2">
            Teste e configure o sistema de recuperação de senha por email
          </p>
        </div>

        {/* Teste de Envio */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <Mail className="h-5 w-5" />
              Teste de Envio de Email
            </h2>
            <p className="text-gray-600 mt-1">
              Teste o envio de email de recuperação de senha
            </p>
          </div>
          <div className="p-6 space-y-4">
            <div className="space-y-2">
              <label htmlFor="test-email" className="block text-sm font-medium text-gray-700">
                Email para teste
              </label>
              <input
                id="test-email"
                type="email"
                placeholder="seu@email.com"
                value={testEmail}
                onChange={(e) => setTestEmail(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <button 
              onClick={testPasswordRecovery} 
              disabled={loading}
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? 'Enviando...' : 'Testar Recuperação de Senha'}
            </button>

            {result && (
              <div className="p-4 bg-blue-50 border border-blue-200 rounded-md">
                <p className="text-blue-800">{result}</p>
              </div>
            )}
          </div>
        </div>

        {/* Verificação de Configuração */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <Settings className="h-5 w-5" />
              Verificação de Configuração
            </h2>
            <p className="text-gray-600 mt-1">
              Verifique as configurações de email no Supabase
            </p>
          </div>
          <div className="p-6 space-y-4">
            <button 
              onClick={checkEmailConfig} 
              disabled={checkingConfig}
              className="w-full bg-gray-600 text-white py-2 px-4 rounded-md hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {checkingConfig ? 'Verificando...' : 'Verificar Configuração'}
            </button>

            {configChecks.length > 0 && (
              <div className="space-y-3">
                {configChecks.map((check, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                    <div className="flex items-center gap-3">
                      {getStatusIcon(check.status)}
                      <div>
                        <div className="font-medium text-gray-900">{check.setting_name}</div>
                        <div className="text-sm text-gray-600">
                          Recomendado: {check.recommended_value}
                        </div>
                      </div>
                    </div>
                    {getStatusBadge(check.status)}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Configuração Manual */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <ExternalLink className="h-5 w-5" />
              Configuração Manual no Supabase
            </h2>
            <p className="text-gray-600 mt-1">
              Configure manualmente no painel do Supabase
            </p>
          </div>
          <div className="p-6 space-y-4">
            <div className="space-y-3">
              <div className="p-4 bg-gray-50 rounded-lg">
                <h4 className="font-medium mb-2">📧 Configurações de Email necessárias:</h4>
                <ul className="space-y-2 text-sm text-gray-700">
                  <li>• <strong>SMTP Provider:</strong> Configure um provedor de email (Gmail, SendGrid, etc.)</li>
                  <li>• <strong>Email Templates:</strong> Configure templates customizados</li>
                  <li>• <strong>Redirect URLs:</strong> Configure URLs de redirecionamento</li>
                  <li>• <strong>Email Confirmations:</strong> Habilite confirmações por email</li>
                </ul>
              </div>

              <button 
                onClick={openSupabaseDashboard}
                className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
              >
                <ExternalLink className="h-4 w-4" />
                Abrir Painel do Supabase
              </button>
            </div>
          </div>
        </div>

        {/* URLs de Configuração */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold">URLs de Redirecionamento</h2>
            <p className="text-gray-600 mt-1">
              Configure estas URLs no painel do Supabase
            </p>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              <div className="p-3 bg-gray-50 rounded-lg">
                <div className="font-medium mb-2 text-gray-900">Site URL:</div>
                <div className="font-mono text-sm text-gray-700">https://pdv-allimport.vercel.app</div>
              </div>
              
              <div className="p-3 bg-gray-50 rounded-lg">
                <div className="font-medium mb-2 text-gray-900">Redirect URLs:</div>
                <div className="space-y-1 font-mono text-sm text-gray-700">
                  <div>https://pdv-allimport.vercel.app/reset-password</div>
                  <div>https://pdv-allimport.vercel.app/auth/callback</div>
                  <div>http://localhost:5174/reset-password</div>
                  <div>http://localhost:5174/auth/callback</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
