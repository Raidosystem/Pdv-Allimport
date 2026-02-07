import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth/AuthContext';
import toast from 'react-hot-toast';

export interface PrintSettings {
  cabecalhoPersonalizado: string;
  // Rodapé de Vendas
  rodapeLinha1: string;
  rodapeLinha2: string;
  rodapeLinha3: string;
  rodapeLinha4: string;
  // Rodapé de Ordem de Serviço (separado)
  rodapeOsLinha1: string;
  rodapeOsLinha2: string;
  rodapeOsLinha3: string;
  rodapeOsLinha4: string;
  papelTamanho: 'A4' | '80mm' | '58mm';
  fonteTamanho: 'pequena' | 'media' | 'grande';
  fonteIntensidade: 'normal' | 'medio' | 'forte';
  fonteNegrito: boolean;
  logoRecibo: boolean;
}

const DEFAULT_SETTINGS: PrintSettings = {
  cabecalhoPersonalizado: '',
  // Rodapé de Vendas (garantia fixa de 3 meses)
  rodapeLinha1: 'Garantia de produtos de 3 meses',
  rodapeLinha2: 'Agradecemos pela preferencia',
  rodapeLinha3: 'Volte sempre!!',
  rodapeLinha4: '',
  // Rodapé de Ordem de Serviço (garantia dinâmica, definida ao encerrar OS)
  rodapeOsLinha1: 'Será cobrado uma taxa de serviço de avaliação do aparelho de mínimo de 30,00',
  rodapeOsLinha2: 'A partir do quarto mês será cobrado uma multa diária de 1,00',
  rodapeOsLinha3: 'Agradecemos pela preferencia, Volte sempre',
  rodapeOsLinha4: '',
  papelTamanho: '80mm',
  fonteTamanho: 'media',
  fonteIntensidade: 'normal',
  fonteNegrito: false,
  logoRecibo: true,
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
      console.log('❌ [PRINT SETTINGS] Usuário não autenticado, usando configurações padrão');
      setSettings(DEFAULT_SETTINGS);
      setLoading(false);
      return;
    }

    console.log('🔄 [PRINT SETTINGS] Carregando configurações de impressão para usuário:', user.id);
    console.log('🔄 [PRINT SETTINGS] Timestamp:', new Date().toISOString());

    try {
      // Buscar diretamente da tabela (mais confiável que RPC)
      const { data, error } = await supabase
        .from('configuracoes_impressao')
        .select('*')
        .eq('user_id', user.id)
        .single();

      console.log('📊 [PRINT SETTINGS] Resultado da busca:', { data, error });

      if (error) {
        // Se erro é "not found", é porque não tem configuração ainda
        if (error.code === 'PGRST116') {
          console.log('📝 [PRINT SETTINGS] Nenhuma configuração encontrada no banco, usando configurações padrão');
          setSettings(DEFAULT_SETTINGS);
          return;
        }
        
        console.error('❌ [PRINT SETTINGS] Erro ao carregar configurações:', error);
        setSettings(DEFAULT_SETTINGS);
        return;
      }

      if (data) {
        console.log('✅ [PRINT SETTINGS] Configurações carregadas do banco:', {
          cabecalho: data.cabecalho?.substring(0, 50) + '...',
          cabecalho_personalizado: data.cabecalho_personalizado?.substring(0, 50) + '...',
          rodape1: data.rodape_linha1?.substring(0, 30) + '...',
          atualizado_em: data.atualizado_em
        });
        
        const loadedSettings: PrintSettings = {
          cabecalhoPersonalizado: data.cabecalho_personalizado || data.cabecalho || '',
          // Rodapé de Vendas
          rodapeLinha1: data.rodape_linha1 || '',
          rodapeLinha2: data.rodape_linha2 || '',
          rodapeLinha3: data.rodape_linha3 || '',
          rodapeLinha4: data.rodape_linha4 || '',
          // Rodapé de Ordem de Serviço (com fallback para rodapé de vendas se ainda não configurado)
          rodapeOsLinha1: data.rodape_os_linha1 ?? data.rodape_linha1 ?? '',
          rodapeOsLinha2: data.rodape_os_linha2 ?? data.rodape_linha2 ?? '',
          rodapeOsLinha3: data.rodape_os_linha3 ?? data.rodape_linha3 ?? '',
          rodapeOsLinha4: data.rodape_os_linha4 ?? data.rodape_linha4 ?? '',
          papelTamanho: data.papel_tamanho || DEFAULT_SETTINGS.papelTamanho,
          fonteTamanho: data.fonte_tamanho || DEFAULT_SETTINGS.fonteTamanho,
          fonteIntensidade: data.fonte_intensidade || DEFAULT_SETTINGS.fonteIntensidade,
          fonteNegrito: data.fonte_negrito ?? DEFAULT_SETTINGS.fonteNegrito,
          logoRecibo: data.logo_recibo ?? DEFAULT_SETTINGS.logoRecibo,
        };
        
        console.log('📦 [PRINT SETTINGS] Settings que serão aplicados:', loadedSettings);
        setSettings(loadedSettings);
      } else {
        console.log('📝 [PRINT SETTINGS] Data null, usando configurações padrão');
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
            ...DEFAULT_SETTINGS,
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

      // Usar UPSERT direto na tabela em vez de RPC
      const { data, error } = await supabase
        .from('configuracoes_impressao')
        .upsert({
          user_id: user.id,
          cabecalho: updatedSettings.cabecalhoPersonalizado,
          cabecalho_personalizado: updatedSettings.cabecalhoPersonalizado,
          rodape_linha1: updatedSettings.rodapeLinha1,
          rodape_linha2: updatedSettings.rodapeLinha2,
          rodape_linha3: updatedSettings.rodapeLinha3,
          rodape_linha4: updatedSettings.rodapeLinha4,
          // Rodapé de Ordem de Serviço (separado)
          rodape_os_linha1: updatedSettings.rodapeOsLinha1,
          rodape_os_linha2: updatedSettings.rodapeOsLinha2,
          rodape_os_linha3: updatedSettings.rodapeOsLinha3,
          rodape_os_linha4: updatedSettings.rodapeOsLinha4,
          papel_tamanho: updatedSettings.papelTamanho,
          fonte_tamanho: updatedSettings.fonteTamanho,
          fonte_intensidade: updatedSettings.fonteIntensidade,
          fonte_negrito: updatedSettings.fonteNegrito,
          logo_recibo: updatedSettings.logoRecibo,
          atualizado_em: new Date().toISOString()
        }, {
          onConflict: 'user_id' // Atualiza se já existe, insere se não
        })
        .select()
        .single();

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
    console.log('💾 [SAVE CABECALHO] Iniciando salvamento');
    console.log('💾 [SAVE CABECALHO] Cabeçalho recebido:', cabecalho.substring(0, 100));
    console.log('💾 [SAVE CABECALHO] User ID:', user?.id);
    
    if (!user?.id) {
      console.error('❌ [SAVE CABECALHO] Usuário não autenticado');
      toast.error('Usuário não autenticado');
      return false;
    }
    
    // Salvar APENAS no banco de dados (sem localStorage)
    const result = await saveSettings({ cabecalhoPersonalizado: cabecalho });
    console.log('✅ [SAVE CABECALHO] Resultado do saveSettings:', result);
    
    if (!result) {
      toast.error('Erro ao salvar no banco de dados');
      return false;
    }
    
    console.log('✅ [SAVE CABECALHO] Cabeçalho salvo com sucesso!');
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

  // Salvar apenas o rodapé de Ordem de Serviço
  const saveRodapeOs = async (rodape: {
    linha1?: string;
    linha2?: string;
    linha3?: string;
    linha4?: string;
  }) => {
    console.log('💾 Salvando rodapé OS no BANCO DE DADOS:', rodape);
    
    if (!user?.id) {
      console.error('❌ Usuário não autenticado');
      toast.error('Usuário não autenticado');
      return false;
    }
    
    const newSettings = {
      rodapeOsLinha1: rodape.linha1 ?? settings.rodapeOsLinha1,
      rodapeOsLinha2: rodape.linha2 ?? settings.rodapeOsLinha2,
      rodapeOsLinha3: rodape.linha3 ?? settings.rodapeOsLinha3,
      rodapeOsLinha4: rodape.linha4 ?? settings.rodapeOsLinha4
    };
    
    const result = await saveSettings(newSettings);
    
    if (!result) {
      toast.error('Erro ao salvar rodapé de OS no banco de dados');
      return false;
    }
    
    toast.success('Rodapé de Ordem de Serviço salvo!');
    return true;
  };

  // Resetar para configurações padrão
  const resetSettings = async () => {
    return await saveSettings(DEFAULT_SETTINGS);
  };

  // Carregar configurações quando o usuário mudar
  useEffect(() => {
    console.log('🔄 [PRINT SETTINGS] useEffect disparado - user.id:', user?.id);
    console.log('🔄 [PRINT SETTINGS] Timestamp:', new Date().toISOString());
    loadSettings();
  }, [user?.id]);

  return {
    settings,
    loading,
    saving,
    saveSettings,
    saveCabecalho,
    saveRodape,
    saveRodapeOs,
    resetSettings,
    reloadSettings: loadSettings
  };
}