import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { ImportadorPrivado } from '../utils/importador-privado';

export default function ImportacaoAutomaticaPage() {
  const [loading, setLoading] = useState(false);
  const [resultado, setResultado] = useState<any>(null);
  const [erro, setErro] = useState<string>('');

  const executarImportacaoAutomatica = async () => {
    setLoading(true);
    setErro('');
    setResultado(null);

    try {
      console.log('🚀 Iniciando importação automática...');

      // 1. FAZER LOGIN AUTOMÁTICO
      const email = 'assistenciaallimport10@gmail.com';
      const senha = prompt('Digite a senha para assistenciaallimport10@gmail.com:');
      
      if (!senha) {
        setErro('Senha é obrigatória');
        setLoading(false);
        return;
      }

      console.log(`🔐 Fazendo login com: ${email}`);
      
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: email,
        password: senha
      });

      if (authError || !authData.user) {
        throw new Error(`Erro no login: ${authError?.message || 'Login falhou'}`);
      }

      console.log('✅ Login realizado com sucesso!');
      console.log('👤 User ID:', authData.user.id);

      // 2. CARREGAR BACKUP DO LOCALHOST
      console.log('📦 Carregando backup do localhost...');
      
      const response = await fetch('/backup-allimport.json');
      console.log('📡 Response status:', response.status, response.statusText);
      
      if (!response.ok) {
        throw new Error(`Erro ao carregar backup: ${response.status} - ${response.statusText}`);
      }

      const backupData = await response.json();
      console.log('✅ Backup carregado com sucesso!');
      console.log('📊 Estrutura do backup:', {
        hasData: !!backupData.data,
        clients: backupData.data?.clients?.length || 0,
        products: backupData.data?.products?.length || 0,
        categories: backupData.data?.categories?.length || 0,
        service_orders: backupData.data?.service_orders?.length || 0,
        service_parts: backupData.data?.service_parts?.length || 0
      });

      // Validar estrutura do backup
      if (!backupData || !backupData.data) {
        throw new Error('Estrutura do backup inválida - campo "data" não encontrado');
      }

      // 3. EXECUTAR IMPORTAÇÃO PRIVADA
      console.log('🔄 Iniciando importação privada...');
      
      const importador = new ImportadorPrivado(authData.user.id);
      const resultadoImport = await importador.importarBackup(backupData);

      console.log('📋 Resultado detalhado da importação:', resultadoImport);
      setResultado(resultadoImport);

    } catch (error: any) {
      console.error('💥 Erro completo:', error);
      console.error('🔍 Stack trace:', error.stack);
      console.error('🔍 Error details:', {
        message: error.message,
        name: error.name,
        cause: error.cause
      });
      setErro(error.message || 'Erro desconhecido na importação');
    } finally {
      setLoading(false);
    }
  };

  const irParaAnterior = () => {
    window.history.back();
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-lg p-8 max-w-2xl w-full">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            🚀 Importação Automática
          </h1>
          <p className="text-gray-600">
            Importa backup automaticamente para assistenciaallimport10@gmail.com
          </p>
        </div>

        {!loading && !resultado && !erro && (
          <div className="text-center">
            <button
              onClick={executarImportacaoAutomatica}
              className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-8 rounded-lg transition-colors"
            >
              🔄 Iniciar Importação Automática
            </button>
            
            <div className="mt-6 text-sm text-gray-500">
              <p>• Fará login automaticamente</p>
              <p>• Carregará backup do localhost</p>
              <p>• Importará dados com isolamento por usuário</p>
            </div>
          </div>
        )}

        {loading && (
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-lg font-medium text-gray-700">
              Processando importação...
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Isso pode levar alguns minutos
            </p>
          </div>
        )}

        {erro && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <div className="flex">
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">
                  ❌ Erro na Importação
                </h3>
                <div className="mt-2 text-sm text-red-700">
                  {erro}
                </div>
              </div>
            </div>
            
            <div className="mt-4">
              <button
                onClick={() => setErro('')}
                className="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded text-sm"
              >
                Tentar Novamente
              </button>
            </div>
          </div>
        )}

        {resultado && (
          <div className="space-y-6">
            <div className={`p-4 rounded-lg ${
              resultado.sucesso ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'
            }`}>
              <h3 className={`font-medium ${
                resultado.sucesso ? 'text-green-800' : 'text-red-800'
              }`}>
                {resultado.sucesso ? '✅ Importação Concluída com Sucesso!' : '❌ Importação com Problemas'}
              </h3>
              
              <div className="mt-4 grid grid-cols-2 gap-4 text-sm">
                <div>
                  <strong>Total de Registros:</strong><br />
                  <span className="text-2xl font-bold text-blue-600">{resultado.total}</span>
                </div>
                <div>
                  <strong>Tempo de Execução:</strong><br />
                  <span className="text-lg">{resultado.tempoExecucao}</span>
                </div>
              </div>
            </div>

            {Object.keys(resultado.detalhes).length > 0 && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h4 className="font-medium text-blue-800 mb-3">📊 Detalhes por Tabela:</h4>
                <div className="grid grid-cols-2 gap-2 text-sm">
                  {Object.entries(resultado.detalhes).map(([tabela, count]) => (
                    <div key={tabela} className="flex justify-between">
                      <span className="capitalize">{tabela}:</span>
                      <strong>{count as number} registros</strong>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {resultado.avisos && resultado.avisos.length > 0 && (
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <h4 className="font-medium text-yellow-800 mb-2">⚠️ Avisos:</h4>
                <ul className="text-sm text-yellow-700 space-y-1">
                  {resultado.avisos.map((aviso: string, index: number) => (
                    <li key={index}>• {aviso}</li>
                  ))}
                </ul>
              </div>
            )}

            {resultado.erros.length > 0 && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <h4 className="font-medium text-red-800 mb-2">❌ Erros:</h4>
                <ul className="text-sm text-red-700 space-y-1">
                  {resultado.erros.map((erro: string, index: number) => (
                    <li key={index}>• {erro}</li>
                  ))}
                </ul>
              </div>
            )}

            <div className="text-center pt-4">
              <button
                onClick={irParaAnterior}
                className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-8 rounded-lg transition-colors"
              >
                Voltar
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
