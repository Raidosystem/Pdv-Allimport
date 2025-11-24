import { useState, useEffect } from 'react';
import { 
  Settings, 
  Database, 
  Upload, 
  Download, 
  Clock, 
  Shield, 
  FileText, 
  CheckCircle,
  RefreshCw,
  Zap
} from 'lucide-react';
import BackupManager from '../components/BackupManager';

interface BackupConfig {
  autoBackup: boolean;
  backupFrequency: 'daily' | 'weekly' | 'monthly';
  backupTime: string;
  retentionDays: number;
  includeImages: boolean;
  compressBackups: boolean;
  encryptBackups: boolean;
}

export default function ConfiguracoesBackup() {
  const [activeTab, setActiveTab] = useState<'backup' | 'config' | 'history'>('backup');
  const [config, setConfig] = useState<BackupConfig>({
    autoBackup: true,
    backupFrequency: 'daily',
    backupTime: '02:00',
    retentionDays: 30,
    includeImages: false,
    compressBackups: true,
    encryptBackups: true
  });
  
  const [isSaving, setIsSaving] = useState(false);
  const [lastSaved, setLastSaved] = useState<Date | null>(null);

  // Carregar configurações ao inicializar
  useEffect(() => {
    loadBackupConfig();
  }, []);

  const loadBackupConfig = async () => {
    try {
      // Aqui você carregaria as configurações do Supabase
      // const { data } = await supabase.from('configuracoes').select('*').single();
      // if (data?.backup_config) {
      //   setConfig(data.backup_config);
      // }
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
    }
  };

  const saveBackupConfig = async () => {
    try {
      setIsSaving(true);
      
      // Salvar no Supabase
      // await supabase.from('configuracoes').upsert({
      //   backup_config: config,
      //   updated_at: new Date().toISOString()
      // });
      
      setLastSaved(new Date());
      
      // Simular delay
      await new Promise(resolve => setTimeout(resolve, 500));
    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleConfigChange = (key: keyof BackupConfig, value: any) => {
    setConfig(prev => ({
      ...prev,
      [key]: value
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <Settings className="h-8 w-8 text-blue-600" />
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Configurações de Backup</h1>
                <p className="text-gray-600">Gerencie backups e importação de dados</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm mb-8">
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 px-6">
              <button
                onClick={() => setActiveTab('backup')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'backup'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Database className="h-4 w-4" />
                  Backup e Importação
                </div>
              </button>
              <button
                onClick={() => setActiveTab('config')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'config'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Settings className="h-4 w-4" />
                  Configurações Avançadas
                </div>
              </button>
              <button
                onClick={() => setActiveTab('history')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'history'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Clock className="h-4 w-4" />
                  Histórico e Logs
                </div>
              </button>
            </nav>
          </div>

          <div className="p-6">
            {/* Tab: Backup e Importação */}
            {activeTab === 'backup' && (
              <div>
                {/* Destaque do Sistema Universal */}
                <div className="bg-gradient-to-r from-purple-50 to-blue-50 rounded-xl p-6 mb-8 border border-purple-200">
                  <div className="flex items-start gap-4">
                    <div className="flex-shrink-0">
                      <Zap className="h-8 w-8 text-purple-600" />
                    </div>
                    <div className="flex-grow">
                      <h3 className="text-xl font-bold text-purple-900 mb-2">
                        🚀 Sistema Universal de Backup
                      </h3>
                      <p className="text-purple-700 mb-4">
                        Nosso sistema aceita <strong>qualquer backup JSON</strong> de outros sistemas e transforma automaticamente para funcionar no RaVal pdv.
                      </p>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                        <div className="space-y-2">
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Detecção automática de estrutura</span>
                          </div>
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Mapeamento inteligente de campos</span>
                          </div>
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Suporte a AllImport, POS, PDV</span>
                          </div>
                        </div>
                        <div className="space-y-2">
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Conversão automática de produtos</span>
                          </div>
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Importação de clientes e categorias</span>
                          </div>
                          <div className="flex items-center gap-2 text-green-700">
                            <CheckCircle className="h-4 w-4" />
                            <span>Relatório completo de transformação</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Componente de Backup */}
                <BackupManager />
              </div>
            )}

            {/* Tab: Configurações Avançadas */}
            {activeTab === 'config' && (
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-semibold">Configurações de Backup Automático</h3>
                  <button
                    onClick={saveBackupConfig}
                    disabled={isSaving}
                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  >
                    {isSaving ? (
                      <RefreshCw className="h-4 w-4 animate-spin" />
                    ) : (
                      <CheckCircle className="h-4 w-4" />
                    )}
                    {isSaving ? 'Salvando...' : 'Salvar Configurações'}
                  </button>
                </div>

                {lastSaved && (
                  <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                    <div className="flex items-center gap-2 text-green-700">
                      <CheckCircle className="h-4 w-4" />
                      <span className="text-sm">
                        Configurações salvas em {lastSaved.toLocaleString('pt-BR')}
                      </span>
                    </div>
                  </div>
                )}

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Backup Automático */}
                  <div className="bg-gray-50 rounded-lg p-6">
                    <h4 className="font-semibold mb-4 flex items-center gap-2">
                      <Clock className="h-5 w-5 text-blue-600" />
                      Backup Automático
                    </h4>
                    
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">Ativar backup automático</span>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={config.autoBackup}
                            onChange={(e) => handleConfigChange('autoBackup', e.target.checked)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                      </div>

                      {config.autoBackup && (
                        <>
                          <div>
                            <label className="block text-sm font-medium mb-1">Frequência</label>
                            <select
                              value={config.backupFrequency}
                              onChange={(e) => handleConfigChange('backupFrequency', e.target.value)}
                              className="w-full p-2 border border-gray-300 rounded-lg"
                            >
                              <option value="daily">Diário</option>
                              <option value="weekly">Semanal</option>
                              <option value="monthly">Mensal</option>
                            </select>
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">Horário</label>
                            <input
                              type="time"
                              value={config.backupTime}
                              onChange={(e) => handleConfigChange('backupTime', e.target.value)}
                              className="w-full p-2 border border-gray-300 rounded-lg"
                            />
                          </div>

                          <div>
                            <label className="block text-sm font-medium mb-1">Retenção (dias)</label>
                            <input
                              type="number"
                              min="7"
                              max="365"
                              value={config.retentionDays}
                              onChange={(e) => handleConfigChange('retentionDays', parseInt(e.target.value))}
                              className="w-full p-2 border border-gray-300 rounded-lg"
                            />
                          </div>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Opções de Backup */}
                  <div className="bg-gray-50 rounded-lg p-6">
                    <h4 className="font-semibold mb-4 flex items-center gap-2">
                      <Shield className="h-5 w-5 text-green-600" />
                      Opções Avançadas
                    </h4>
                    
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <span className="text-sm font-medium">Incluir imagens</span>
                          <p className="text-xs text-gray-500">Incluir arquivos de imagem no backup</p>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={config.includeImages}
                            onChange={(e) => handleConfigChange('includeImages', e.target.checked)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <span className="text-sm font-medium">Comprimir backups</span>
                          <p className="text-xs text-gray-500">Reduzir tamanho dos arquivos</p>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={config.compressBackups}
                            onChange={(e) => handleConfigChange('compressBackups', e.target.checked)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <span className="text-sm font-medium">Criptografar backups</span>
                          <p className="text-xs text-gray-500">Proteger dados sensíveis</p>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={config.encryptBackups}
                            onChange={(e) => handleConfigChange('encryptBackups', e.target.checked)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Tab: Histórico e Logs */}
            {activeTab === 'history' && (
              <div className="space-y-6">
                <h3 className="text-lg font-semibold">Histórico de Atividades</h3>
                
                {/* Estatísticas */}
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
                    <div className="flex items-center gap-3">
                      <Database className="h-8 w-8 text-blue-600" />
                      <div>
                        <p className="text-2xl font-bold text-blue-900">12</p>
                        <p className="text-sm text-blue-700">Backups Criados</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-green-50 rounded-lg p-4 border border-green-200">
                    <div className="flex items-center gap-3">
                      <Upload className="h-8 w-8 text-green-600" />
                      <div>
                        <p className="text-2xl font-bold text-green-900">3</p>
                        <p className="text-sm text-green-700">Importações</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-orange-50 rounded-lg p-4 border border-orange-200">
                    <div className="flex items-center gap-3">
                      <Download className="h-8 w-8 text-orange-600" />
                      <div>
                        <p className="text-2xl font-bold text-orange-900">8</p>
                        <p className="text-sm text-orange-700">Exports JSON</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
                    <div className="flex items-center gap-3">
                      <FileText className="h-8 w-8 text-purple-600" />
                      <div>
                        <p className="text-2xl font-bold text-purple-900">1.2GB</p>
                        <p className="text-sm text-purple-700">Dados Processados</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Log de Atividades */}
                <div className="bg-white rounded-lg border">
                  <div className="p-4 border-b">
                    <h4 className="font-semibold">Log de Atividades Recentes</h4>
                  </div>
                  <div className="divide-y">
                    {[
                      {
                        type: 'backup',
                        action: 'Backup automático criado',
                        timestamp: '2025-08-19 02:00:00',
                        status: 'success',
                        details: 'Backup diário executado com sucesso'
                      },
                      {
                        type: 'import',
                        action: 'Importação de backup AllImport',
                        timestamp: '2025-08-18 14:30:00',
                        status: 'success',
                        details: '813 produtos, 160 OS, 141 clientes importados'
                      },
                      {
                        type: 'export',
                        action: 'Export JSON manual',
                        timestamp: '2025-08-18 10:15:00',
                        status: 'success',
                        details: 'Dados exportados para backup-manual.json'
                      },
                      {
                        type: 'error',
                        action: 'Falha na importação',
                        timestamp: '2025-08-17 16:45:00',
                        status: 'error',
                        details: 'Arquivo JSON com formato inválido'
                      }
                    ].map((log, index) => (
                      <div key={index} className="p-4 hover:bg-gray-50">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <div className={`w-2 h-2 rounded-full ${
                              log.status === 'success' ? 'bg-green-500' : 'bg-red-500'
                            }`}></div>
                            <div>
                              <p className="font-medium">{log.action}</p>
                              <p className="text-sm text-gray-500">{log.details}</p>
                            </div>
                          </div>
                          <div className="text-sm text-gray-400">
                            {log.timestamp}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
