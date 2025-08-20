import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { Empresa, Funcionario } from '../types/empresa';
import { useAuth } from '../modules/auth';

export function useEmpresa() {
  const { user } = useAuth();
  const [empresa, setEmpresa] = useState<Empresa | null>(null);
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([]);
  const [loading, setLoading] = useState(true);

  // Buscar dados da empresa
  const fetchEmpresa = async () => {
    if (!user) return;

    try {
      const { data, error } = await supabase
        .from('empresas')
        .select('*')
        .eq('user_id', user.id)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Erro ao buscar empresa:', error);
        return;
      }

      setEmpresa(data);
    } catch (error) {
      console.error('Erro ao buscar empresa:', error);
    }
  };

  // Buscar funcionários
  const fetchFuncionarios = async () => {
    if (!empresa) return;

    try {
      const { data, error } = await supabase
        .from('funcionarios')
        .select(`
          *,
          login_funcionarios (
            usuario,
            ativo,
            ultimo_acesso
          )
        `)
        .eq('empresa_id', empresa.id);

      if (error) {
        console.error('Erro ao buscar funcionários:', error);
        return;
      }

      setFuncionarios(data || []);
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error);
    }
  };

  // Criar ou atualizar empresa
  const saveEmpresa = async (dadosEmpresa: Partial<Empresa>) => {
    if (!user) return { success: false, error: 'Usuário não autenticado' };

    try {
      if (empresa) {
        // Atualizar empresa existente
        const { data, error } = await supabase
          .from('empresas')
          .update({
            ...dadosEmpresa,
            updated_at: new Date().toISOString()
          })
          .eq('id', empresa.id)
          .select()
          .single();

        if (error) throw error;
        setEmpresa(data);
      } else {
        // Criar nova empresa
        const { data, error } = await supabase
          .from('empresas')
          .insert({
            ...dadosEmpresa,
            user_id: user.id
          })
          .select()
          .single();

        if (error) throw error;
        setEmpresa(data);
      }

      return { success: true };
    } catch (error: any) {
      console.error('Erro ao salvar empresa:', error);
      return { success: false, error: error.message };
    }
  };

  // Upload da logo
  const uploadLogo = async (file: File) => {
    if (!user) return { success: false, error: 'Usuário não autenticado' };

    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `${user.id}/logo.${fileExt}`;

      // Fazer upload do arquivo diretamente (sem verificar bucket)
      const { error: uploadError } = await supabase.storage
        .from('empresas')
        .upload(fileName, file, { upsert: true });

      if (uploadError) {
        console.error('Erro no upload:', uploadError);
        // Se for erro de bucket não encontrado, dar instruções específicas
        if (uploadError.message.includes('bucket') || uploadError.message.includes('Bucket')) {
          return { 
            success: false, 
            error: 'Bucket de storage não configurado. Execute o script CONFIGURAR_STORAGE_EMPRESAS.sql no Supabase.' 
          };
        }
        throw new Error(`Erro no upload: ${uploadError.message}`);
      }

      // Obter URL pública
      const { data } = supabase.storage
        .from('empresas')
        .getPublicUrl(fileName);

      return { success: true, url: data.publicUrl };
    } catch (error: any) {
      console.error('Erro ao fazer upload da logo:', error);
      
      // Verificar se é erro relacionado ao storage
      if (error.message && (error.message.includes('bucket') || error.message.includes('Bucket'))) {
        return { 
          success: false, 
          error: 'Storage não configurado. Execute o script CONFIGURAR_STORAGE_EMPRESAS.sql no Supabase.' 
        };
      }
      
      return { 
        success: false, 
        error: error.message || 'Erro desconhecido ao fazer upload da logo' 
      };
    }
  };

  // Criar funcionário
  const createFuncionario = async (funcionarioData: Partial<Funcionario>, loginData: { usuario: string; senha: string }) => {
    if (!empresa) return { success: false, error: 'Empresa não encontrada' };

    try {
      // Criar funcionário
      const { data: funcionario, error: funcionarioError } = await supabase
        .from('funcionarios')
        .insert({
          ...funcionarioData,
          empresa_id: empresa.id
        })
        .select()
        .single();

      if (funcionarioError) throw funcionarioError;

      // Criar login do funcionário
      const { error: loginError } = await supabase
        .from('login_funcionarios')
        .insert({
          funcionario_id: funcionario.id,
          usuario: loginData.usuario,
          senha: loginData.senha // Em produção, fazer hash da senha
        });

      if (loginError) throw loginError;

      await fetchFuncionarios();
      return { success: true };
    } catch (error: any) {
      console.error('Erro ao criar funcionário:', error);
      return { success: false, error: error.message };
    }
  };

  // Atualizar funcionário
  const updateFuncionario = async (funcionarioId: string, dados: Partial<Funcionario>) => {
    try {
      const { error } = await supabase
        .from('funcionarios')
        .update({
          ...dados,
          updated_at: new Date().toISOString()
        })
        .eq('id', funcionarioId);

      if (error) throw error;

      await fetchFuncionarios();
      return { success: true };
    } catch (error: any) {
      console.error('Erro ao atualizar funcionário:', error);
      return { success: false, error: error.message };
    }
  };

  // Ativar/desativar funcionário
  const toggleFuncionario = async (funcionarioId: string, ativo: boolean) => {
    try {
      const { error } = await supabase
        .from('funcionarios')
        .update({ ativo })
        .eq('id', funcionarioId);

      if (error) throw error;

      await fetchFuncionarios();
      return { success: true };
    } catch (error: any) {
      console.error('Erro ao alterar status do funcionário:', error);
      return { success: false, error: error.message };
    }
  };

  useEffect(() => {
    if (user) {
      fetchEmpresa();
    }
  }, [user]);

  useEffect(() => {
    if (empresa) {
      fetchFuncionarios();
    }
  }, [empresa]);

  useEffect(() => {
    if (user) {
      setLoading(false);
    }
  }, [user]);

  return {
    empresa,
    funcionarios,
    loading,
    saveEmpresa,
    uploadLogo,
    createFuncionario,
    updateFuncionario,
    toggleFuncionario,
    refetch: fetchEmpresa
  };
}
