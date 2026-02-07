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
      setLoading(true);
      const { data, error } = await supabase
        .from('empresas')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(1);

      if (error) {
        console.error('Erro ao buscar empresa:', error);
        return;
      }

      // Extrair primeiro item do array
      setEmpresa(data && data.length > 0 ? data[0] : null);
    } catch (error) {
      console.error('Erro ao buscar empresa:', error);
    } finally {
      setLoading(false);
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
          .select();

        if (error) throw error;
        setEmpresa(data && data.length > 0 ? data[0] : null);
      } else {
        // Criar nova empresa
        const { data, error } = await supabase
          .from('empresas')
          .insert({
            ...dadosEmpresa,
            user_id: user.id
          })
          .select();

        if (error) throw error;
        setEmpresa(data && data.length > 0 ? data[0] : null);
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

  // Criar funcionário com permissões padronizadas
  const createFuncionario = async (funcionarioData: Partial<Funcionario>, loginData: { usuario: string; senha: string }) => {
    if (!empresa) return { success: false, error: 'Empresa não encontrada' };

    try {
      console.log('✅ Criando funcionário com permissões iniciais...');
      
      // Garantir que permissões estejam definidas
      const permissoesIniciais = funcionarioData.permissoes || {
        vendas: true,
        produtos: true,
        clientes: true,
        caixa: false,
        ordens_servico: true,
        funcionarios: false,
        relatorios: false,
        configuracoes: false,
        backup: false,
        pode_criar_vendas: true,
        pode_editar_vendas: false,
        pode_cancelar_vendas: false,
        pode_aplicar_desconto: false,
        pode_criar_produtos: false,
        pode_editar_produtos: false,
        pode_deletar_produtos: false,
        pode_gerenciar_estoque: false,
        pode_criar_clientes: true,
        pode_editar_clientes: true,
        pode_deletar_clientes: false,
        pode_abrir_caixa: false,
        pode_fechar_caixa: false,
        pode_gerenciar_movimentacoes: false,
        pode_criar_os: true,
        pode_editar_os: true,
        pode_finalizar_os: false,
        pode_ver_todos_relatorios: false,
        pode_exportar_dados: false,
        pode_alterar_configuracoes: false,
        pode_gerenciar_funcionarios: false,
        pode_fazer_backup: false,
      };

      // Criar usuário no Supabase Auth
      const { data, error } = await supabase.auth.signUp({
        email: funcionarioData.email!,
        password: loginData.senha,
        options: {
          data: {
            full_name: funcionarioData.nome,
            company_name: empresa.nome,
            role: 'employee',
            parent_user_id: user?.id
          }
        }
      });

      if (error) {
        throw new Error(error.message);
      }

      // Criar registro na tabela funcionarios com permissões JSON
      const { error: funcionarioError } = await supabase
        .from('funcionarios')
        .insert({
          nome: funcionarioData.nome,
          email: funcionarioData.email,
          telefone: funcionarioData.telefone,
          cargo: funcionarioData.cargo,
          empresa_id: empresa.id,
          user_id: data.user?.id,
          ativo: true,
          permissoes: permissoesIniciais // ✅ Salvar permissões como JSON
        });

      if (funcionarioError) {
        console.error('❌ Erro ao criar registro de funcionário:', funcionarioError);
        throw new Error(funcionarioError.message);
      }

      console.log('✅ Funcionário criado com sucesso!');
      await fetchFuncionarios();
      return { success: true };
    } catch (error: any) {
      console.error('❌ Erro ao criar funcionário:', error);
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
      // Buscar funcionário atual para verificar status
      const { data: funcionarioAtual, error: fetchError } = await supabase
        .from('funcionarios')
        .select('status')
        .eq('id', funcionarioId)
        .single();

      if (fetchError) throw fetchError;

      // Determinar novo status baseado no parâmetro ativo
      const novoStatus = ativo ? 'ativo' : 'pausado';

      // Atualizar funcionário
      const { error } = await supabase
        .from('funcionarios')
        .update({ status: novoStatus })
        .eq('id', funcionarioId);

      if (error) throw error;

      // Atualizar também o login_funcionarios
      const { error: loginError } = await supabase
        .from('login_funcionarios')
        .update({ ativo })
        .eq('funcionario_id', funcionarioId);

      if (loginError) {
        console.error('Aviso: Erro ao atualizar login_funcionarios:', loginError);
      }

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
    } else {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    if (empresa) {
      fetchFuncionarios();
    }
  }, [empresa]);

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
