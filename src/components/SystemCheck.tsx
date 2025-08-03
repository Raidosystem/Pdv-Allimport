import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { AlertTriangle, CheckCircle, Database, Settings, RefreshCw } from 'lucide-react';

interface ConfigStatus {
  supabaseConfig: boolean;
  authentication: boolean;
  database: boolean;
  message: string;
}

export function SystemCheck() {
  const [status, setStatus] = useState<ConfigStatus>({
    supabaseConfig: false,
    authentication: false,
    database: false,
    message: 'Verificando configurações...'
  });
  const [loading, setLoading] = useState(true);

  const checkSystemStatus = async () => {
    setLoading(true);
    const newStatus: ConfigStatus = {
      supabaseConfig: false,
      authentication: false,
      database: false,
      message: ''
    };

    try {
      // 1. Verificar configuração do Supabase
      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
      const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
      
      if (supabaseUrl && supabaseKey && supabaseUrl !== 'your_supabase_project_url') {
        newStatus.supabaseConfig = true;
      } else {
        newStatus.message = 'Configure as variáveis VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY no arquivo .env';
        setStatus(newStatus);
        setLoading(false);
        return;
      }

      // 2. Verificar autenticação
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (!authError) {
        newStatus.authentication = !!user;
      }

      // 3. Verificar se as tabelas existem
      if (user) {
        try {
          const { error: dbError } = await supabase
            .from('caixa')
            .select('id')
            .limit(1);
          
          newStatus.database = !dbError;
          
          if (dbError) {
            newStatus.message = 'Tabelas do caixa não encontradas. Execute o script fix-caixa-database.sql no Supabase.';
          } else {
            newStatus.message = 'Sistema configurado corretamente!';
          }
        } catch {
          newStatus.database = false;
          newStatus.message = 'Erro ao verificar banco de dados.';
        }
      } else {
        newStatus.message = 'Faça login para verificar o banco de dados.';
      }

    } catch (error) {
      console.error('Erro na verificação:', error);
      newStatus.message = 'Erro ao verificar sistema. Verifique a configuração do Supabase.';
    }

    setStatus(newStatus);
    setLoading(false);
  };

  useEffect(() => {
    checkSystemStatus();
  }, []);

  const allConfigured = status.supabaseConfig && status.authentication && status.database;

  if (loading) {
    return (
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-center gap-2">
          <div className="animate-spin rounded-full h-4 w-4 border-2 border-blue-600 border-t-transparent"></div>
          <span className="text-blue-800 text-sm">Verificando configurações do sistema...</span>
        </div>
      </div>
    );
  }

  return (
    <div className={`border rounded-lg p-4 ${
      allConfigured 
        ? 'bg-green-50 border-green-200' 
        : 'bg-yellow-50 border-yellow-200'
    }`}>
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          {allConfigured ? (
            <CheckCircle className="w-5 h-5 text-green-600" />
          ) : (
            <AlertTriangle className="w-5 h-5 text-yellow-600" />
          )}
          <h4 className={`font-medium ${
            allConfigured ? 'text-green-800' : 'text-yellow-800'
          }`}>
            Status do Sistema
          </h4>
        </div>
        
        <button
          onClick={checkSystemStatus}
          className="flex items-center gap-1 px-2 py-1 text-xs bg-white rounded border hover:bg-gray-50 transition-colors"
        >
          <RefreshCw className="w-3 h-3" />
          Verificar
        </button>
      </div>

      <div className="space-y-2 mb-3">
        <div className="flex items-center gap-2">
          <Settings className="w-4 h-4" />
          <span className="text-sm">Configuração Supabase:</span>
          {status.supabaseConfig ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-red-600" />
          )}
        </div>

        <div className="flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />
          <span className="text-sm">Autenticação:</span>
          {status.authentication ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-yellow-600" />
          )}
        </div>

        <div className="flex items-center gap-2">
          <Database className="w-4 h-4" />
          <span className="text-sm">Banco de Dados:</span>
          {status.database ? (
            <CheckCircle className="w-4 h-4 text-green-600" />
          ) : (
            <AlertTriangle className="w-4 h-4 text-red-600" />
          )}
        </div>
      </div>

      <p className={`text-sm ${
        allConfigured ? 'text-green-700' : 'text-yellow-700'
      }`}>
        {status.message}
      </p>

      {!allConfigured && (
        <div className="mt-3 p-3 bg-white rounded border text-xs">
          <p className="font-medium mb-2">💡 Como corrigir:</p>
          <ol className="list-decimal list-inside space-y-1 text-gray-600">
            {!status.supabaseConfig && (
              <li>Configure as variáveis no arquivo .env com suas credenciais do Supabase</li>
            )}
            {!status.authentication && (
              <li>Faça login no sistema</li>
            )}
            {!status.database && (
              <li>Execute o script fix-caixa-database.sql no Supabase SQL Editor</li>
            )}
          </ol>
        </div>
      )}
    </div>
  );
}
