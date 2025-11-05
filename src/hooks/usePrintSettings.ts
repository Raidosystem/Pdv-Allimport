import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth/AuthContext';
import toast from 'react-hot-toast';

export interface PrintSettings {
  cabecalhoPersonalizado: string;
  rodapeLinha1: string;
  rodapeLinha2: string;
  rodapeLinha3: string;
  rodapeLinha4: string;
}

const DEFAULT_SETTINGS: PrintSettings = {
  cabecalhoPersonalizado: '',
  rodapeLinha1: '',
  rodapeLinha2: '',
  rodapeLinha3: '',
  rodapeLinha4: ''
};

export function usePrintSettings() {
  const { user } = useAuth();
  const [settings, setSettings] = useState<PrintSettings>(DEFAULT_SETTINGS);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  console.log('👤 Hook usePrintSettings - Usuário atual:', user?.id || 'não autenticado');
  console.log('👤 Objeto user completo:', user);

  // Carregar configurações do banco de dados
  const loadSettings = async () => {
    if (!user?.id) {
      console.log('❌ Usuário não autenticado, usando configurações padrão');
      setSettings(DEFAULT_SETTINGS);
      setLoading(false);
      return;
    }

    console.log('🔄 Carregando configurações de impressão para usuário:', user.id);

    try {
      // Primeiro tenta buscar do banco
      const { data, error } = await supabase
        .rpc('buscar_configuracoes_impressao_usuario', {
          p_user_id: user.id
        });

      if (error) {
        console.error('❌ Erro ao carregar configurações:', error);
        // Tenta migrar do localStorage se houver erro
        await migrateFromLocalStorage();
        return;
      }

      if (data && data.length > 0) {
        const config = data[0];
        console.log('✅ Configurações carregadas do banco:', config);
        setSettings({
          cabecalhoPersonalizado: config.cabecalho_personalizado || '',
          rodapeLinha1: config.rodape_linha1 || '',
          rodapeLinha2: config.rodape_linha2 || '',
          rodapeLinha3: config.rodape_linha3 || '',
          rodapeLinha4: config.rodape_linha4 || ''
        });
      } else {
        console.log('📝 Nenhuma configuração encontrada no banco, usando configurações padrão');
        // Se não tem dados no banco, usar configurações padrão
        setSettings(DEFAULT_SETTINGS);
      }
    } catch (error) {
      console.error('❌ Erro ao carregar configurações:', error);
      setSettings(DEFAULT_SETTINGS);
    } finally {
      setLoading(false);
    }
  };

  // Migrar dados do localStorage para o banco (se existirem)
  const migrateFromLocalStorage = async () => {
    if (!user?.id) return;

    try {
      // Buscar dados antigos do localStorage
      const oldCabecalho = localStorage.getItem('cabecalhoPersonalizado') || '';
      const oldRodape1 = localStorage.getItem('rodapeLinha1') || '';
      const oldRodape2 = localStorage.getItem('rodapeLinha2') || '';
      const oldRodape3 = localStorage.getItem('rodapeLinha3') || '';
      const oldRodape4 = localStorage.getItem('rodapeLinha4') || '';

      // Se tem dados no localStorage, migrar para o banco
      if (oldCabecalho || oldRodape1 || oldRodape2 || oldRodape3 || oldRodape4) {
        console.log('Migrando configurações do localStorage para o banco...');
        
        const { data, error } = await supabase
          .rpc('migrar_configuracoes_impressao_usuario', {
            p_user_id: user.id,
            p_cabecalho_personalizado: oldCabecalho,
            p_rodape_linha1: oldRodape1,
            p_rodape_linha2: oldRodape2,
            p_rodape_linha3: oldRodape3,
            p_rodape_linha4: oldRodape4
          });

        if (!error && data) {
          // Atualizar state com os dados migrados
          setSettings({
            cabecalhoPersonalizado: oldCabecalho,
            rodapeLinha1: oldRodape1,
            rodapeLinha2: oldRodape2,
            rodapeLinha3: oldRodape3,
            rodapeLinha4: oldRodape4
          });

          // Limpar localStorage após migração bem-sucedida
          localStorage.removeItem('cabecalhoPersonalizado');
          localStorage.removeItem('rodapeLinha1');
          localStorage.removeItem('rodapeLinha2');
          localStorage.removeItem('rodapeLinha3');
          localStorage.removeItem('rodapeLinha4');
          
          console.log('Migração concluída com sucesso!');
        }
      } else {
        // Se não tem dados no localStorage, usar padrão
        setSettings(DEFAULT_SETTINGS);
      }
    } catch (error) {
      console.error('Erro na migração do localStorage:', error);
      setSettings(DEFAULT_SETTINGS);
    }
  };

  // Salvar configurações no banco de dados
  const saveSettings = async (newSettings: Partial<PrintSettings>) => {
    if (!user?.id) {
      console.log('❌ Usuário não autenticado');
      toast.error('Usuário não autenticado');
      return false;
    }

    setSaving(true);
    console.log('💾 Salvando configurações no banco:', newSettings);
    console.log('👤 ID do usuário:', user.id);

    try {
      const updatedSettings = { ...settings, ...newSettings };
      console.log('📋 Configurações completas para salvar:', updatedSettings);

      const { data, error } = await supabase
        .rpc('migrar_configuracoes_impressao_usuario', {
          p_user_id: user.id,
          p_cabecalho_personalizado: updatedSettings.cabecalhoPersonalizado,
          p_rodape_linha1: updatedSettings.rodapeLinha1,
          p_rodape_linha2: updatedSettings.rodapeLinha2,
          p_rodape_linha3: updatedSettings.rodapeLinha3,
          p_rodape_linha4: updatedSettings.rodapeLinha4
        });

      if (error) {
        console.error('❌ Erro ao salvar configurações:', error);
        console.error('❌ Detalhes do erro:', JSON.stringify(error, null, 2));
        toast.error(`Erro ao salvar: ${error.message}`);
        return false;
      }

      if (data) {
        console.log('✅ Configurações salvas com sucesso!', data);
        // Recarregar as configurações para garantir sincronização
        await loadSettings();
        toast.success('Configurações salvas no banco de dados!');
        return true;
      }

      console.log('⚠️ Nenhum data retornado da função RPC');
      return false;
    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
      toast.error('Erro ao salvar configurações de impressão');
      return false;
    } finally {
      setSaving(false);
    }
  };

  // Salvar apenas o cabeçalho
  const saveCabecalho = async (cabecalho: string) => {
    console.log('💾 Salvando cabeçalho no BANCO DE DADOS:', cabecalho);
    
    if (!user?.id) {
      console.error('❌ Usuário não autenticado');
      toast.error('Usuário não autenticado');
      return false;
    }
    
    // Salvar APENAS no banco de dados (sem localStorage)
    const result = await saveSettings({ cabecalhoPersonalizado: cabecalho });
    console.log('✅ Resultado salvamento cabeçalho no banco:', result);
    
    if (!result) {
      toast.error('Erro ao salvar no banco de dados');
      return false;
    }
    
    toast.success('Cabeçalho salvo no banco de dados!');
    return true;
  };

  // Salvar apenas o rodapé
  const saveRodape = async (rodape: {
    linha1?: string;
    linha2?: string;
    linha3?: string;
    linha4?: string;
  }) => {
    console.log('💾 Salvando rodapé no BANCO DE DADOS:', rodape);
    
    if (!user?.id) {
      console.error('❌ Usuário não autenticado');
      toast.error('Usuário não autenticado');
      return false;
    }
    
    const newSettings = {
      rodapeLinha1: rodape.linha1 ?? settings.rodapeLinha1,
      rodapeLinha2: rodape.linha2 ?? settings.rodapeLinha2,
      rodapeLinha3: rodape.linha3 ?? settings.rodapeLinha3,
      rodapeLinha4: rodape.linha4 ?? settings.rodapeLinha4
    };
    
    // Salvar APENAS no banco de dados (sem localStorage)
    const result = await saveSettings(newSettings);
    
    if (!result) {
      toast.error('Erro ao salvar rodapé no banco de dados');
      return false;
    }
    
    toast.success('Rodapé salvo no banco de dados!');
    return true;
  };

  // Resetar para configurações padrão
  const resetSettings = async () => {
    return await saveSettings(DEFAULT_SETTINGS);
  };

  // Carregar configurações quando o usuário mudar
  useEffect(() => {
    console.log('🔄 useEffect disparado - user.id:', user?.id);
    loadSettings();
  }, [user?.id]);

  return {
    settings,
    loading,
    saving,
    saveSettings,
    saveCabecalho,
    saveRodape,
    resetSettings,
    reloadSettings: loadSettings
  };
}