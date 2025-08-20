import React, { useEffect, useState } from 'react';
import { Download, Upload, Database, RefreshCw, Calendar, AlertTriangle, CheckCircle } from 'lucide-react';
import { useBackup } from '../hooks/useBackup';
import { BackupTransformer } from '../utils/backupTransformer';
import BackupDebugger from './BackupDebugger';

export default function BackupManager() {
  const [transformReport, setTransformReport] = useState<string>('');
  const [showReport, setShowReport] = useState(false);
  
  const {
    backups,
    loading,
    exporting,
    importing,
    loadBackups,
    createManualBackup,
    exportToJSON,
    importFromJSON,
    restoreFromDatabase,
    formatSize,
    formatDate,
  } = useBackup();

  // Função para lidar com upload de arquivo UNIVERSAL
  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      setShowReport(false);
      setTransformReport('');
      
      // Ler arquivo
      const fileContent = await file.text();
      let jsonData;
      
      try {
        jsonData = JSON.parse(fileContent);
      } catch (error) {
        alert('❌ Arquivo JSON inválido. Verifique o formato do arquivo.');
        return;
      }
      
      // Verificar se é um backup válido
      if (!BackupTransformer.isValidBackup(jsonData)) {
        alert('❌ O arquivo não contém dados de backup válidos.');
        return;
      }
      
      // Detectar sistema e confirmar transformação
      const systemType = BackupTransformer.detectBackupSystem(jsonData);
      const arrays = BackupTransformer.findDataArrays(jsonData);
      const totalItems = Object.values(arrays).reduce((sum: number, arr: any[]) => sum + arr.length, 0);
      
      const confirmMessage = `
🔍 BACKUP DETECTADO:

📱 Sistema: ${systemType}
📊 Total de itens: ${totalItems}
📁 Arrays encontrados: ${Object.keys(arrays).join(', ')}

🔄 Este backup será automaticamente transformado para o formato PDV Allimport.

Deseja continuar com a importação?`;
      
      if (!confirm(confirmMessage)) {
        return;
      }
      
      // Transformar backup
      const transformedBackup = await BackupTransformer.transformBackup(jsonData, 'usuario@sistema.com');
      
      // Gerar relatório
      const report = BackupTransformer.generateTransformReport(jsonData, transformedBackup);
      setTransformReport(report);
      setShowReport(true);
      
      // Converter para arquivo e importar
      const transformedJson = JSON.stringify(transformedBackup, null, 2);
      const blob = new Blob([transformedJson], { type: 'application/json' });
      const transformedFile = new File([blob], `backup-transformado-${Date.now()}.json`, {
        type: 'application/json'
      });
      
      // Importar usando o sistema existente
      await importFromJSON(transformedFile);
      
    } catch (error) {
      console.error('Erro ao processar backup:', error);
      alert('❌ Erro ao processar o arquivo de backup. Verifique o console para mais detalhes.');
    }
  };

  // Confirmar restauração
  const handleRestore = async (backupId: string) => {
    if (!confirm('Tem certeza que deseja restaurar este backup? Esta ação irá substituir seus dados atuais.')) {
      return;
    }
    await restoreFromDatabase(backupId);
  };

  // Handler para exportar JSON
  const handleExportJSON = () => {
    exportToJSON();
  };

  useEffect(() => {
    loadBackups();
  }, [loadBackups]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Backup e Restauração</h2>
          <p className="text-gray-600">Gerencie backups dos seus dados do PDV</p>
        </div>
        <button
          onClick={loadBackups}
          disabled={loading}
          className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 disabled:opacity-50"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
          Atualizar
        </button>
      </div>

      {/* Ações Principais */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Backup Manual */}
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <div className="flex items-center gap-3 mb-4">
            <Database className="h-6 w-6 text-blue-600" />
            <h3 className="text-lg font-semibold">Backup Manual</h3>
          </div>
          <p className="text-gray-600 mb-4">Criar backup dos seus dados no banco de dados</p>
          <button
            onClick={createManualBackup}
            disabled={loading}
            className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            <Database className="h-4 w-4" />
            {loading ? 'Criando...' : 'Criar Backup'}
          </button>
        </div>

        {/* Exportar JSON */}
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <div className="flex items-center gap-3 mb-4">
            <Download className="h-6 w-6 text-green-600" />
            <h3 className="text-lg font-semibold">Exportar JSON</h3>
          </div>
          <p className="text-gray-600 mb-4">Baixar seus dados em formato JSON</p>
          <button
            onClick={handleExportJSON}
            disabled={exporting}
            className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            <Download className="h-4 w-4" />
            {exporting ? 'Exportando...' : 'Exportar JSON'}
          </button>
        </div>

        {/* Importar JSON UNIVERSAL */}
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <div className="flex items-center gap-3 mb-4">
            <Upload className="h-6 w-6 text-purple-600" />
            <h3 className="text-lg font-semibold">Importar Qualquer Backup</h3>
          </div>
          <p className="text-gray-600 mb-4">
            🔄 Sistema inteligente que aceita <strong>qualquer backup JSON</strong> e transforma automaticamente
          </p>
          <div className="bg-purple-50 rounded-lg p-3 mb-4">
            <div className="text-sm text-purple-700">
              <strong>✨ Suporte a:</strong>
              <br />• AllImport, POS, PDV e outros sistemas
              <br />• Detecção automática de estrutura
              <br />• Mapeamento inteligente de campos
              <br />• Conversão automática de dados
            </div>
          </div>
          <label className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 cursor-pointer">
            <Upload className="h-4 w-4" />
            {importing ? 'Processando...' : 'Selecionar Backup JSON'}
            <input
              type="file"
              accept=".json,application/json"
              onChange={handleFileUpload}
              disabled={importing}
              className="hidden"
            />
          </label>
        </div>
      </div>

      {/* Relatório de Transformação */}
      {showReport && transformReport && (
        <div className="bg-white rounded-lg border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <div className="flex items-center gap-3">
              <CheckCircle className="h-6 w-6 text-green-600" />
              <h3 className="text-lg font-semibold text-green-800">Transformação Realizada com Sucesso!</h3>
            </div>
          </div>
          <div className="p-6">
            <pre className="bg-gray-50 p-4 rounded-lg text-sm overflow-x-auto whitespace-pre-wrap">
              {transformReport}
            </pre>
            <div className="flex justify-end mt-4">
              <button
                onClick={() => setShowReport(false)}
                className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600"
              >
                Fechar Relatório
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Aviso */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <div className="flex items-start gap-3">
          <AlertTriangle className="h-5 w-5 text-yellow-600 mt-0.5" />
          <div>
            <h4 className="font-semibold text-yellow-800">Importante</h4>
            <p className="text-yellow-700 text-sm">
              Ao restaurar um backup, todos os dados atuais serão substituídos. 
              Certifique-se de fazer um backup antes de restaurar.
            </p>
          </div>
        </div>
      </div>

      {/* Lista de Backups */}
      <div className="bg-white rounded-lg border border-gray-200">
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold">Backups Disponíveis</h3>
          <p className="text-gray-600">Backups automáticos e manuais salvos no banco de dados</p>
        </div>
        
        <div className="p-6">
          {loading ? (
            <div className="text-center py-8">
              <RefreshCw className="h-8 w-8 animate-spin mx-auto text-gray-400" />
              <p className="text-gray-500 mt-2">Carregando backups...</p>
            </div>
          ) : backups.length === 0 ? (
            <div className="text-center py-8">
              <Database className="h-12 w-12 mx-auto text-gray-300" />
              <p className="text-gray-500 mt-2">Nenhum backup encontrado</p>
            </div>
          ) : (
            <div className="space-y-3">
              {backups.map((backup) => (
                <div key={backup.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                  <div className="flex items-center gap-4">
                    <div className="flex-shrink-0">
                      <Calendar className="h-5 w-5 text-gray-400" />
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">
                        Backup {formatDate(backup.backup_date)}
                      </div>
                      <div className="text-sm text-gray-500">
                        Criado em {formatDate(backup.created_at)} • {formatSize(backup.size)}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleRestore(backup.id)}
                      disabled={loading}
                      className="flex items-center gap-2 px-3 py-1.5 text-sm bg-blue-100 text-blue-700 rounded-md hover:bg-blue-200 disabled:opacity-50"
                    >
                      <Upload className="h-3 w-3" />
                      Restaurar
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Debug do Sistema */}
      <BackupDebugger />
    </div>
  );
}
