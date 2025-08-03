import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { ExternalLink, CheckCircle, XCircle, AlertTriangle, Settings } from 'lucide-react';

interface AuthConfigCheck {
  setting_name: string;
  current_value: string;
  recommended_value: string;
  status: string;
  instructions: string;
}

export default function AuthConfigTest() {
  const [configChecks, setConfigChecks] = useState<AuthConfigCheck[]>([]);
  const [loading, setLoading] = useState(false);
  const [testResult, setTestResult] = useState<string>('');

  const checkAuthConfig = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.rpc('check_auth_config');
      
      if (error) {
        console.error('Erro ao verificar configuração:', error);
        setTestResult('❌ Erro ao verificar configuração de autenticação');
      } else {
        setConfigChecks(data || []);
        setTestResult('✅ Configurações verificadas com sucesso');
      }
    } catch (err) {
      console.error('Erro inesperado:', err);
      setTestResult('❌ Erro inesperado ao verificar configuração');
    } finally {
      setLoading(false);
    }
  };

  const testEmailConfirmation = async () => {
    setTestResult('🔄 Testando fluxo de confirmação de email...');
    
    try {
      // Simular verificação das URLs
      const currentUrl = window.location.origin;
      const expectedUrl = 'https://pdv-allimport.vercel.app';
      
      if (currentUrl === expectedUrl) {
        setTestResult('✅ URL de produção correta detectada');
      } else {
        setTestResult(`⚠️ Executando em: ${currentUrl} (desenvolvimento)`);
      }
    } catch (error) {
      setTestResult('❌ Erro ao testar configuração');
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'OK':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'ERROR':
        return <XCircle className="h-5 w-5 text-red-500" />;
      default:
        return <AlertTriangle className="h-5 w-5 text-yellow-500" />;
    }
  };

  const openSupabaseDashboard = () => {
    window.open('https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings', '_blank');
  };

  const openAuthSettings = () => {
    window.open('https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/url-configuration', '_blank');
  };

  useEffect(() => {
    checkAuthConfig();
    testEmailConfirmation();
  }, []);

  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <div className="space-y-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900">Configuração de Autenticação</h1>
          <p className="text-gray-600 mt-2">
            Verificar e corrigir configurações de confirmação de email
          </p>
        </div>

        {/* Resultado do Teste */}
        {testResult && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <p className="text-blue-800 font-medium">{testResult}</p>
          </div>
        )}

        {/* Verificação de Configuração */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <Settings className="h-5 w-5" />
              Verificação de Configuração
            </h2>
            <p className="text-gray-600 mt-1">
              Status das configurações de autenticação
            </p>
          </div>
          <div className="p-6 space-y-4">
            <button 
              onClick={checkAuthConfig} 
              disabled={loading}
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? 'Verificando...' : 'Verificar Configuração'}
            </button>

            {configChecks.length > 0 && (
              <div className="space-y-3">
                {configChecks.map((check, index) => (
                  <div key={index} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex items-center gap-3">
                        {getStatusIcon(check.status)}
                        <div>
                          <div className="font-medium text-gray-900">{check.setting_name}</div>
                          <div className="text-sm text-gray-600">
                            Recomendado: {check.recommended_value}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="text-sm text-gray-700 bg-gray-50 p-2 rounded">
                      <strong>Instruções:</strong> {check.instructions}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Configurações Necessárias */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold">Configurações Necessárias no Supabase</h2>
            <p className="text-gray-600 mt-1">
              Configure estas URLs no painel do Supabase Dashboard
            </p>
          </div>
          <div className="p-6 space-y-6">
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <h3 className="text-red-800 font-semibold mb-2">🚨 Problema Identificado</h3>
              <p className="text-red-700 text-sm">
                Os emails de confirmação estão redirecionando para localhost:3000 porque as URLs
                não estão configuradas corretamente no painel do Supabase.
              </p>
            </div>

            <div className="space-y-4">
              <div className="p-4 bg-gray-50 rounded-lg">
                <h4 className="font-medium mb-2 text-gray-900">1. Site URL</h4>
                <div className="font-mono text-sm text-gray-700 bg-white p-2 rounded border">
                  https://pdv-allimport.vercel.app
                </div>
              </div>
              
              <div className="p-4 bg-gray-50 rounded-lg">
                <h4 className="font-medium mb-2 text-gray-900">2. Redirect URLs (adicionar todas)</h4>
                <div className="space-y-1 font-mono text-sm text-gray-700">
                  <div className="bg-white p-2 rounded border">https://pdv-allimport.vercel.app</div>
                  <div className="bg-white p-2 rounded border">https://pdv-allimport.vercel.app/confirm-email</div>
                  <div className="bg-white p-2 rounded border">https://pdv-allimport.vercel.app/auth/callback</div>
                  <div className="bg-white p-2 rounded border">https://pdv-allimport.vercel.app/reset-password</div>
                  <div className="bg-white p-2 rounded border">http://localhost:5174</div>
                  <div className="bg-white p-2 rounded border">http://localhost:5174/confirm-email</div>
                </div>
              </div>
            </div>

            <div className="space-y-3">
              <button 
                onClick={openSupabaseDashboard}
                className="w-full bg-green-600 text-white py-3 px-4 rounded-md hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
              >
                <ExternalLink className="h-4 w-4" />
                Abrir Configurações de Autenticação
              </button>
              
              <button 
                onClick={openAuthSettings}
                className="w-full bg-purple-600 text-white py-3 px-4 rounded-md hover:bg-purple-700 transition-colors flex items-center justify-center gap-2"
              >
                <ExternalLink className="h-4 w-4" />
                Abrir Configuração de URLs
              </button>
            </div>
          </div>
        </div>

        {/* Passos para Correção */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold">Como Corrigir</h2>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">1</div>
                <div>
                  <h4 className="font-medium">Acesse o Painel do Supabase</h4>
                  <p className="text-gray-600 text-sm">Clique em "Abrir Configurações de Autenticação" acima</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">2</div>
                <div>
                  <h4 className="font-medium">Configure Site URL</h4>
                  <p className="text-gray-600 text-sm">Altere de localhost para: https://pdv-allimport.vercel.app</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-blue-600 text-white rounded-full flex items-center justify-center text-sm font-bold">3</div>
                <div>
                  <h4 className="font-medium">Adicione Redirect URLs</h4>
                  <p className="text-gray-600 text-sm">Adicione todas as URLs listadas acima, uma por linha</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-green-600 text-white rounded-full flex items-center justify-center text-sm font-bold">4</div>
                <div>
                  <h4 className="font-medium">Salve as Configurações</h4>
                  <p className="text-gray-600 text-sm">Clique em "Save" e teste novamente o cadastro</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
