import { useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { toast } from 'react-hot-toast';

export interface BackupInfo {
  id: string;
  backup_date: string;
  created_at: string;
  updated_at: string;
  size: number;
}

export interface BackupData {
  backup_info: {
    user_id: string;
    user_email: string;
    backup_date: string;
    backup_version: string;
    system: string;
  };
  data: {
    clientes: any[];
    categorias: any[];
    produtos: any[];
    vendas: any[];
    itens_venda: any[];
    caixa: any[];
    movimentacoes_caixa: any[];
    configuracoes: any[];
  };
}

export const useBackup = () => {
  const [backups, setBackups] = useState<BackupInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [exporting, setExporting] = useState(false);
  const [importing, setImporting] = useState(false);

  // Carregar lista de backups
  const loadBackups = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase.rpc('list_user_backups');
      
      if (error) throw error;
      
      setBackups(data || []);
      return data || [];
    } catch (error) {
      console.error('Erro ao carregar backups:', error);
      toast.error('Erro ao carregar lista de backups');
      return [];
    } finally {
      setLoading(false);
    }
  }, []);

  // Criar backup manual no banco
  const createManualBackup = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase.rpc('save_backup_to_database');
      
      if (error) throw error;
      
      if (data) {
        toast.success('Backup criado com sucesso!');
        await loadBackups(); // Recarregar lista
        return true;
      } else {
        toast.error('Erro ao criar backup');
        return false;
      }
    } catch (error) {
      console.error('Erro ao criar backup:', error);
      toast.error('Erro ao criar backup manual');
      return false;
    } finally {
      setLoading(false);
    }
  }, [loadBackups]);

  // Exportar dados para JSON
  const exportToJSON = useCallback(async (filename?: string) => {
    try {
      setExporting(true);
      const { data, error } = await supabase.rpc('export_user_data_json');
      
      if (error) throw error;
      
      // Criar arquivo JSON para download
      const dataStr = JSON.stringify(data, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      
      // Criar link de download
      const link = document.createElement('a');
      link.href = url;
      link.download = filename || `pdv-backup-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      
      URL.revokeObjectURL(url);
      toast.success('Dados exportados com sucesso!');
      return true;
    } catch (error) {
      console.error('Erro ao exportar dados:', error);
      toast.error('Erro ao exportar dados');
      return false;
    } finally {
      setExporting(false);
    }
  }, []);

  // Importar dados de JSON
  const importFromJSON = useCallback(async (file: File, clearExisting: boolean = true) => {
    try {
      setImporting(true);
      
      // Validar tipo de arquivo
      if (file.type !== 'application/json' && !file.name.endsWith('.json')) {
        toast.error('Por favor, selecione um arquivo JSON válido');
        return false;
      }
      
      // Ler arquivo JSON
      const text = await file.text();
      const backupData: BackupData = JSON.parse(text);
      
      // Validar estrutura do backup
      if (!backupData.backup_info || !backupData.data) {
        toast.error('Arquivo de backup inválido - estrutura incorreta');
        return false;
      }
      
      // Importar dados
      const { data, error } = await supabase.rpc('import_user_data_json', {
        backup_json: backupData,
        clear_existing: clearExisting
      });
      
      if (error) throw error;
      
      if (data.success) {
        toast.success('Dados importados com sucesso!');
        await loadBackups(); // Recarregar lista
        return true;
      } else {
        toast.error(data.message || 'Erro ao importar dados');
        return false;
      }
    } catch (error) {
      console.error('Erro ao importar dados:', error);
      if (error instanceof SyntaxError) {
        toast.error('Arquivo JSON inválido ou corrompido');
      } else {
        toast.error('Erro ao importar arquivo JSON');
      }
      return false;
    } finally {
      setImporting(false);
    }
  }, [loadBackups]);

  // Restaurar de backup do banco
  const restoreFromDatabase = useCallback(async (backupId: string, clearExisting: boolean = true) => {
    try {
      setLoading(true);
      const { data, error } = await supabase.rpc('restore_from_database_backup', {
        backup_id: backupId,
        clear_existing: clearExisting
      });
      
      if (error) throw error;
      
      if (data.success) {
        toast.success('Dados restaurados com sucesso!');
        return true;
      } else {
        toast.error(data.message || 'Erro ao restaurar dados');
        return false;
      }
    } catch (error) {
      console.error('Erro ao restaurar backup:', error);
      toast.error('Erro ao restaurar backup');
      return false;
    } finally {
      setLoading(false);
    }
  }, []);

  // Obter dados de backup (sem salvar no banco)
  const getBackupData = useCallback(async (): Promise<BackupData | null> => {
    try {
      const { data, error } = await supabase.rpc('export_user_data_json');
      
      if (error) throw error;
      
      return data as BackupData;
    } catch (error) {
      console.error('Erro ao obter dados de backup:', error);
      return null;
    }
  }, []);

  // Utilitários
  const formatSize = useCallback((bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }, []);

  const formatDate = useCallback((dateString: string) => {
    return new Date(dateString).toLocaleString('pt-BR');
  }, []);

  return {
    // Estado
    backups,
    loading,
    exporting,
    importing,
    
    // Funções principais
    loadBackups,
    createManualBackup,
    exportToJSON,
    importFromJSON,
    restoreFromDatabase,
    getBackupData,
    
    // Utilitários
    formatSize,
    formatDate,
  };
};
