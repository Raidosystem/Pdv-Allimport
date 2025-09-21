import React, { useState, useEffect } from 'react';
import { 
  Database,
  Download,
  Upload,
  Clock,
  HardDrive,
  AlertTriangle,
  CheckCircle,
  RefreshCw,
  Settings,
  Play,
  Pause,
  Trash2,
  Archive,
  History
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';

interface BackupInfo {
  id: string;
  nome: string;
  tipo: 'automatico' | 'manual';
  status: 'em_andamento' | 'concluido' | 'erro';
  tamanho_mb: number;
  created_at: string;
  url_download?: string;
  erro_detalhes?: string;
}

interface BackupConfig {
  automatico_ativo: boolean;
  frequencia: 'diario' | 'semanal' | 'mensal';
  horario: string;
  manter_por_dias: number;
  incluir_arquivos: boolean;
  incluir_logs: boolean;
}

const AdminBackupsPage: React.FC = () => {
  const { can, isAdmin } = usePermissions();
  const [backups, setBackups] = useState<BackupInfo[]>([]);
  const [config, setConfig] = useState<BackupConfig>({
    automatico_ativo: true,
    frequencia: 'diario',
    horario: '02:00',
    manter_por_dias: 30,
    incluir_arquivos: true,
    incluir_logs: false
  });
  const [loading, setLoading] = useState(true);
  const [backupInProgress, setBackupInProgress] = useState(false);
  const [showConfigModal, setShowConfigModal] = useState(false);
  const [storageInfo, setStorageInfo] = useState({
    usado_mb: 0,
    total_mb: 1000,
    backups_count: 0
  });

  useEffect(() => {
    if (can('administracao.backups', 'read')) {
      loadData();
    }
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadBackups(),
        loadConfig(),
        loadStorageInfo()
      ]);
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadBackups = async () => {
    // Simulação de dados de backup - em produção viria do Supabase
    const mockBackups: BackupInfo[] = [
      {
        id: '1',
        nome: 'Backup Automático - 2024-12-08',
        tipo: 'automatico',
        status: 'concluido',
        tamanho_mb: 45.2,
        created_at: '2024-12-08T02:00:00Z',
        url_download: 'https://exemplo.com/backup1.sql'
      },
      {
        id: '2',
        nome: 'Backup Manual - 2024-12-07',
        tipo: 'manual',
        status: 'concluido',
        tamanho_mb: 42.8,
        created_at: '2024-12-07T14:30:00Z',
        url_download: 'https://exemplo.com/backup2.sql'
      },
      {
        id: '3',
        nome: 'Backup Automático - 2024-12-07',
        tipo: 'automatico',
        status: 'erro',
        tamanho_mb: 0,
        created_at: '2024-12-07T02:00:00Z',
        erro_detalhes: 'Erro de conexão com o banco de dados'
      }
    ];

    setBackups(mockBackups);
  };

  const loadConfig = async () => {
    // Simulação - em produção viria das configurações da empresa
    const mockConfig: BackupConfig = {
      automatico_ativo: true,
      frequencia: 'diario',
      horario: '02:00',
      manter_por_dias: 30,
      incluir_arquivos: true,
      incluir_logs: false
    };

    setConfig(mockConfig);
  };

  const loadStorageInfo = async () => {
    // Simulação - em produção calcularia o uso real
    const totalBackups = backups.length;
    const usedSpace = backups.reduce((total, backup) => total + backup.tamanho_mb, 0);

    setStorageInfo({
      usado_mb: usedSpace,
      total_mb: 1000,
      backups_count: totalBackups
    });
  };

  const handleCreateBackup = async () => {
    if (!can('administracao.backups', 'create')) return;

    setBackupInProgress(true);
    try {
      // Simular criação de backup
      const newBackup: BackupInfo = {
        id: Date.now().toString(),
        nome: `Backup Manual - ${new Date().toLocaleDateString('pt-BR')}`,
        tipo: 'manual',
        status: 'em_andamento',
        tamanho_mb: 0,
        created_at: new Date().toISOString()
      };

      setBackups([newBackup, ...backups]);

      // Simular progresso do backup
      setTimeout(async () => {
        const completedBackup = {
          ...newBackup,
          status: 'concluido' as const,
          tamanho_mb: Math.random() * 50 + 30,
          url_download: `https://exemplo.com/backup${Date.now()}.sql`
        };

        setBackups(prev => prev.map(b => b.id === newBackup.id ? completedBackup : b));
        setBackupInProgress(false);

        // Log de auditoria
        await supabase.from('audit_logs').insert({
          recurso: 'administracao.backups',
          acao: 'create',
          entidade_tipo: 'backup',
          entidade_id: newBackup.id
        });
      }, 5000);

    } catch (error) {
      console.error('Erro ao criar backup:', error);
      setBackupInProgress(false);
      alert('Erro ao criar backup. Tente novamente.');
    }
  };

  const handleDownloadBackup = async (backup: BackupInfo) => {
    if (!can('administracao.backups', 'read') || !backup.url_download) return;

    try {
      // Simular download
      const link = document.createElement('a');
      link.href = backup.url_download;
      link.download = `${backup.nome}.sql`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.backups',
        acao: 'export',
        entidade_tipo: 'backup',
        entidade_id: backup.id
      });

    } catch (error) {
      console.error('Erro ao baixar backup:', error);
      alert('Erro ao baixar backup. Tente novamente.');
    }
  };

  const handleDeleteBackup = async (backupId: string) => {
    if (!can('administracao.backups', 'delete')) return;

    if (confirm('Tem certeza que deseja excluir este backup? Esta ação não pode ser desfeita.')) {
      try {
        setBackups(prev => prev.filter(b => b.id !== backupId));

        // Log de auditoria
        await supabase.from('audit_logs').insert({
          recurso: 'administracao.backups',
          acao: 'delete',
          entidade_tipo: 'backup',
          entidade_id: backupId
        });

      } catch (error) {
        console.error('Erro ao excluir backup:', error);
        alert('Erro ao excluir backup. Tente novamente.');
      }
    }
  };

  const handleRestoreBackup = async (backup: BackupInfo) => {
    if (!can('administracao.backups', 'update')) return;

    const confirmed = confirm(
      `Tem certeza que deseja restaurar o backup "${backup.nome}"? ` +
      'Esta ação substituirá todos os dados atuais e não pode ser desfeita.'
    );

    if (confirmed) {
      try {
        // Simular processo de restore
        alert('Processo de restauração iniciado. O sistema ficará indisponível por alguns minutos.');
        
        // Log de auditoria
        await supabase.from('audit_logs').insert({
          recurso: 'administracao.backups',
          acao: 'restore',
          entidade_tipo: 'backup',
          entidade_id: backup.id
        });

      } catch (error) {
        console.error('Erro ao restaurar backup:', error);
        alert('Erro ao restaurar backup. Tente novamente.');
      }
    }
  };

  const handleUpdateConfig = async (newConfig: BackupConfig) => {
    if (!can('administracao.backups', 'update')) return;

    try {
      setConfig(newConfig);
      setShowConfigModal(false);

      // Salvar configuração (simulado)
      console.log('Configuração salva:', newConfig);

      // Log de auditoria
      await supabase.from('audit_logs').insert({
        recurso: 'administracao.backups',
        acao: 'update',
        entidade_tipo: 'config',
        detalhes: newConfig
      });

    } catch (error) {
      console.error('Erro ao salvar configuração:', error);
      alert('Erro ao salvar configuração. Tente novamente.');
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'concluido': return <CheckCircle className="w-4 h-4 text-green-600" />;
      case 'em_andamento': return <RefreshCw className="w-4 h-4 text-blue-600 animate-spin" />;
      case 'erro': return <AlertTriangle className="w-4 h-4 text-red-600" />;
      default: return <Clock className="w-4 h-4 text-gray-600" />;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'concluido': return 'Concluído';
      case 'em_andamento': return 'Em andamento';
      case 'erro': return 'Erro';
      default: return status;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'concluido': return 'bg-green-100 text-green-800';
      case 'em_andamento': return 'bg-blue-100 text-blue-800';
      case 'erro': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatFileSize = (mb: number) => {
    if (mb >= 1024) {
      return `${(mb / 1024).toFixed(1)} GB`;
    }
    return `${mb.toFixed(1)} MB`;
  };

  const getUsagePercentage = () => {
    return (storageInfo.usado_mb / storageInfo.total_mb) * 100;
  };

  // REGRA: Todo usuário logado é admin da sua empresa
  if (!isAdmin) {
    console.log('⚠️ Usuário não reconhecido como admin na página de backup, mas permitindo acesso...');
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Gerenciar Backups</h1>
          <p className="text-gray-600">
            Controle os backups automáticos e manuais do sistema
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          {can('administracao.backups', 'update') && (
            <button
              onClick={() => setShowConfigModal(true)}
              className="flex items-center gap-2 px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
            >
              <Settings className="w-4 h-4" />
              Configurações
            </button>
          )}
          
          {can('administracao.backups', 'create') && (
            <button
              onClick={handleCreateBackup}
              disabled={backupInProgress}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {backupInProgress ? (
                <RefreshCw className="w-4 h-4 animate-spin" />
              ) : (
                <Download className="w-4 h-4" />
              )}
              {backupInProgress ? 'Criando...' : 'Novo Backup'}
            </button>
          )}
        </div>
      </div>

      {/* Status Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Último Backup */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Último Backup</p>
              <p className="text-lg font-bold text-gray-900">
                {backups.length > 0 
                  ? new Date(backups[0].created_at).toLocaleDateString('pt-BR')
                  : 'Nenhum'
                }
              </p>
            </div>
            <History className="w-8 h-8 text-blue-500" />
          </div>
          <div className="mt-4">
            {backups.length > 0 && (
              <div className="flex items-center gap-2">
                {getStatusIcon(backups[0].status)}
                <span className="text-sm text-gray-600">
                  {getStatusText(backups[0].status)}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Backup Automático */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Backup Automático</p>
              <p className="text-lg font-bold text-gray-900">
                {config.automatico_ativo ? 'Ativo' : 'Inativo'}
              </p>
            </div>
            {config.automatico_ativo ? (
              <Play className="w-8 h-8 text-green-500" />
            ) : (
              <Pause className="w-8 h-8 text-gray-400" />
            )}
          </div>
          <div className="mt-4">
            <span className="text-sm text-gray-600">
              {config.automatico_ativo 
                ? `${config.frequencia} às ${config.horario}`
                : 'Configurar backup automático'
              }
            </span>
          </div>
        </div>

        {/* Armazenamento */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Armazenamento</p>
              <p className="text-lg font-bold text-gray-900">
                {formatFileSize(storageInfo.usado_mb)}
              </p>
            </div>
            <HardDrive className="w-8 h-8 text-purple-500" />
          </div>
          <div className="mt-4">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-purple-600 h-2 rounded-full" 
                style={{ width: `${Math.min(getUsagePercentage(), 100)}%` }}
              ></div>
            </div>
            <span className="text-sm text-gray-600 mt-1">
              {formatFileSize(storageInfo.total_mb)} total
            </span>
          </div>
        </div>
      </div>

      {/* Lista de Backups */}
      <div className="bg-white rounded-lg border border-gray-200">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">Histórico de Backups</h2>
            <button
              onClick={loadData}
              className="flex items-center gap-2 px-3 py-2 text-gray-600 hover:text-gray-800 transition-colors"
            >
              <RefreshCw className="w-4 h-4" />
              Atualizar
            </button>
          </div>
        </div>

        {loading ? (
          <div className="p-8">
            <div className="animate-pulse space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="flex items-center space-x-4">
                  <div className="w-12 h-12 bg-gray-200 rounded-lg"></div>
                  <div className="flex-1 space-y-2">
                    <div className="h-4 bg-gray-200 rounded w-1/3"></div>
                    <div className="h-3 bg-gray-200 rounded w-1/4"></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Backup
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tipo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tamanho
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Data
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {backups.map((backup) => (
                  <tr key={backup.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                          <Database className="w-5 h-5 text-blue-600" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {backup.nome}
                          </div>
                          {backup.erro_detalhes && (
                            <div className="text-xs text-red-600 mt-1">
                              {backup.erro_detalhes}
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                        backup.tipo === 'automatico' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-blue-100 text-blue-800'
                      }`}>
                        {backup.tipo === 'automatico' ? 'Automático' : 'Manual'}
                      </span>
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(backup.status)}
                        <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(backup.status)}`}>
                          {getStatusText(backup.status)}
                        </span>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {backup.status === 'concluido' ? formatFileSize(backup.tamanho_mb) : '-'}
                    </td>
                    
                    <td className="px-6 py-4 text-sm text-gray-500">
                      {new Date(backup.created_at).toLocaleString('pt-BR')}
                    </td>
                    
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {backup.status === 'concluido' && backup.url_download && can('administracao.backups', 'read') && (
                          <button
                            onClick={() => handleDownloadBackup(backup)}
                            className="p-1 text-blue-600 hover:text-blue-800 transition-colors"
                            title="Baixar backup"
                          >
                            <Download className="w-4 h-4" />
                          </button>
                        )}
                        
                        {backup.status === 'concluido' && can('administracao.backups', 'update') && (
                          <button
                            onClick={() => handleRestoreBackup(backup)}
                            className="p-1 text-green-600 hover:text-green-800 transition-colors"
                            title="Restaurar backup"
                          >
                            <Upload className="w-4 h-4" />
                          </button>
                        )}
                        
                        {can('administracao.backups', 'delete') && (
                          <button
                            onClick={() => handleDeleteBackup(backup.id)}
                            className="p-1 text-red-600 hover:text-red-800 transition-colors"
                            title="Excluir backup"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            
            {backups.length === 0 && (
              <div className="text-center py-12">
                <Archive className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">
                  Nenhum backup encontrado
                </h3>
                <p className="text-gray-500">
                  Crie o primeiro backup do sistema
                </p>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Modal de Configurações */}
      {showConfigModal && (
        <BackupConfigModal
          config={config}
          onSave={handleUpdateConfig}
          onClose={() => setShowConfigModal(false)}
        />
      )}
    </div>
  );
};

// Modal de Configurações de Backup
interface BackupConfigModalProps {
  config: BackupConfig;
  onSave: (config: BackupConfig) => Promise<void>;
  onClose: () => void;
}

const BackupConfigModal: React.FC<BackupConfigModalProps> = ({ config, onSave, onClose }) => {
  const [newConfig, setNewConfig] = useState<BackupConfig>(config);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    setLoading(true);
    try {
      await onSave(newConfig);
    } catch (error) {
      // Erro já tratado no componente pai
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-md">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Configurações de Backup
        </h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={newConfig.automatico_ativo}
                onChange={(e) => setNewConfig({
                  ...newConfig,
                  automatico_ativo: e.target.checked
                })}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm font-medium text-gray-700">
                Ativar backup automático
              </span>
            </label>
          </div>

          {newConfig.automatico_ativo && (
            <>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Frequência
                </label>
                <select
                  value={newConfig.frequencia}
                  onChange={(e) => setNewConfig({
                    ...newConfig,
                    frequencia: e.target.value as any
                  })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="diario">Diário</option>
                  <option value="semanal">Semanal</option>
                  <option value="mensal">Mensal</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Horário
                </label>
                <input
                  type="time"
                  value={newConfig.horario}
                  onChange={(e) => setNewConfig({
                    ...newConfig,
                    horario: e.target.value
                  })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Manter backups por (dias)
            </label>
            <input
              type="number"
              min="1"
              max="365"
              value={newConfig.manter_por_dias}
              onChange={(e) => setNewConfig({
                ...newConfig,
                manter_por_dias: parseInt(e.target.value)
              })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <div className="space-y-2">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={newConfig.incluir_arquivos}
                onChange={(e) => setNewConfig({
                  ...newConfig,
                  incluir_arquivos: e.target.checked
                })}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">
                Incluir arquivos anexos
              </span>
            </label>

            <label className="flex items-center">
              <input
                type="checkbox"
                checked={newConfig.incluir_logs}
                onChange={(e) => setNewConfig({
                  ...newConfig,
                  incluir_logs: e.target.checked
                })}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">
                Incluir logs de auditoria
              </span>
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <RefreshCw className="w-4 h-4 animate-spin" />
              ) : (
                <CheckCircle className="w-4 h-4" />
              )}
              Salvar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AdminBackupsPage;