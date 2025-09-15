import { useState } from 'react';
import { Bug, FileText, CheckCircle, XCircle } from 'lucide-react';
import { useBackup } from '../../../hooks/useBackup';

export default function BackupDebugger() {
  const [debugLog, setDebugLog] = useState<string[]>([]);
  const [testResult, setTestResult] = useState<{ success: boolean; message: string } | null>(null);
  
  const { importFromJSON } = useBackup();

  const addLog = (message: string) => {
    setDebugLog(prev => [...prev, `${new Date().toLocaleTimeString()} - ${message}`]);
  };

  // Criar um backup de teste
  const createTestBackup = () => {
    const testBackup = {
      backup_info: {
        user_id: "test-user",
        user_email: "teste@pdv.com",
        backup_date: new Date().toISOString(),
        backup_version: "2.0",
        system: "PDV Allimport (Teste Debug)"
      },
      data: {
        clientes: [
          {
            id: "client-1",
            name: "Cliente Teste",
            email: "cliente@teste.com",
            telefone: "(11) 99999-9999"
          }
        ],
        categorias: [
          {
            id: "cat-1", 
            name: "Categoria Teste",
            cor: "#FF6B6B",
            ativo: true
          }
        ],
        produtos: [
          {
            id: "prod-1",
            name: "Produto Teste",
            preco: 99.99,
            codigo: "TEST001",
            categoria: "cat-1",
            ativo: true
          }
        ],
        vendas: [],
        itens_venda: [],
        caixa: [],
        movimentacoes_caixa: [],
        configuracoes: []
      }
    };

    // Criar arquivo para download
    const dataStr = JSON.stringify(testBackup, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = 'backup-teste-debug.json';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    URL.revokeObjectURL(url);
    addLog('✅ Backup de teste criado e baixado');
  };

  // Testar importação
  const testImport = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    addLog(`🔄 Iniciando teste de importação: ${file.name}`);
    setTestResult(null);

    try {
      const result = await importFromJSON(file);
      if (result) {
        setTestResult({ success: true, message: 'Importação realizada com sucesso!' });
        addLog('✅ Teste de importação concluído com sucesso');
      } else {
        setTestResult({ success: false, message: 'Falha na importação' });
        addLog('❌ Teste de importação falhou');
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      setTestResult({ success: false, message: errorMessage });
      addLog(`❌ Erro no teste: ${errorMessage}`);
    }
  };

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-6">
      <div className="flex items-center gap-3 mb-6">
        <Bug className="h-6 w-6 text-orange-600" />
        <h3 className="text-lg font-semibold">Debug do Sistema de Backup</h3>
      </div>

      {/* Ações de Teste */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <button
          onClick={createTestBackup}
          className="flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <FileText className="h-4 w-4" />
          Criar Backup de Teste
        </button>
        
        <label className="flex items-center justify-center gap-2 px-4 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 cursor-pointer">
          <Bug className="h-4 w-4" />
          Testar Importação
          <input
            type="file"
            accept=".json"
            onChange={testImport}
            className="hidden"
          />
        </label>
      </div>

      {/* Resultado do Teste */}
      {testResult && (
        <div className={`p-4 rounded-lg mb-6 ${
          testResult.success 
            ? 'bg-green-50 border border-green-200' 
            : 'bg-red-50 border border-red-200'
        }`}>
          <div className="flex items-center gap-2">
            {testResult.success ? (
              <CheckCircle className="h-5 w-5 text-green-600" />
            ) : (
              <XCircle className="h-5 w-5 text-red-600" />
            )}
            <span className={`font-medium ${
              testResult.success ? 'text-green-800' : 'text-red-800'
            }`}>
              {testResult.message}
            </span>
          </div>
        </div>
      )}

      {/* Log de Debug */}
      <div>
        <h4 className="font-medium mb-3">Log de Debug:</h4>
        <div className="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
          {debugLog.length === 0 ? (
            <p className="text-gray-500 text-sm">Nenhum evento registrado ainda...</p>
          ) : (
            <div className="space-y-1">
              {debugLog.map((log, index) => (
                <div key={index} className="text-sm font-mono text-gray-700">
                  {log}
                </div>
              ))}
            </div>
          )}
        </div>
        
        {debugLog.length > 0 && (
          <button
            onClick={() => setDebugLog([])}
            className="mt-3 px-3 py-1 text-sm bg-gray-200 text-gray-700 rounded hover:bg-gray-300"
          >
            Limpar Log
          </button>
        )}
      </div>

      {/* Instruções */}
      <div className="mt-6 p-4 bg-blue-50 rounded-lg">
        <h5 className="font-medium text-blue-800 mb-2">Como usar:</h5>
        <ol className="text-sm text-blue-700 space-y-1">
          <li>1. Clique em "Criar Backup de Teste" para gerar um arquivo JSON válido</li>
          <li>2. Clique em "Testar Importação" e selecione o arquivo baixado</li>
          <li>3. Observe o log para ver detalhes do processo</li>
          <li>4. Verifique se a importação foi bem-sucedida</li>
        </ol>
      </div>
    </div>
  );
}
