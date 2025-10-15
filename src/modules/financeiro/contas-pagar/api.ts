import { supabase } from '../../../lib/supabase';

// Types
export interface ContaPagar {
  id: string;
  user_id: string;
  fornecedor: string;
  descricao: string;
  valor: number;
  data_vencimento: string;
  data_pagamento?: string;
  status: 'pendente' | 'pago' | 'vencido' | 'cancelado';
  categoria: string;
  observacoes?: string;
  boleto_url?: string;
  boleto_codigo_barras?: string;
  boleto_linha_digitavel?: string;
  created_at: string;
  updated_at: string;
}

export interface ContaPagarFilters {
  fornecedor?: string;
  status?: string;
  data_inicio?: string;
  data_fim?: string;
}

export interface ContaPagarForm {
  fornecedor: string;
  descricao: string;
  valor: number;
  data_vencimento: string;
  categoria: string;
  observacoes?: string;
  boleto_url?: string;
  boleto_codigo_barras?: string;
  boleto_linha_digitavel?: string;
}

// Queries
export const getContasPagar = async (filters?: ContaPagarFilters) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    let query = supabase
      .from('contas_pagar')
      .select('*')
      .eq('user_id', user.id)
      .order('data_vencimento', { ascending: true });

    // Aplicar filtros
    if (filters?.fornecedor) {
      query = query.ilike('fornecedor', `%${filters.fornecedor}%`);
    }
    if (filters?.status) {
      query = query.eq('status', filters.status);
    }
    if (filters?.data_inicio) {
      query = query.gte('data_vencimento', filters.data_inicio);
    }
    if (filters?.data_fim) {
      query = query.lte('data_vencimento', filters.data_fim);
    }

    const { data, error } = await query;

    if (error) throw error;

    // Atualizar status de vencidos automaticamente
    const hoje = new Date().toISOString().split('T')[0];
    const contasVencidas = data?.filter(
      conta => conta.status === 'pendente' && conta.data_vencimento < hoje
    ) || [];

    if (contasVencidas.length > 0) {
      await Promise.all(
        contasVencidas.map(conta =>
          supabase
            .from('contas_pagar')
            .update({ status: 'vencido' })
            .eq('id', conta.id)
        )
      );

      // Atualizar dados localmente
      data?.forEach(conta => {
        if (conta.status === 'pendente' && conta.data_vencimento < hoje) {
          conta.status = 'vencido';
        }
      });
    }

    return data || [];
  } catch (error) {
    console.error('Erro ao buscar contas a pagar:', error);
    throw error;
  }
};

export const getContaPagarById = async (id: string) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    const { data, error } = await supabase
      .from('contas_pagar')
      .select('*')
      .eq('id', id)
      .eq('user_id', user.id)
      .single();

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('Erro ao buscar conta a pagar:', error);
    throw error;
  }
};

// Mutations
export const createContaPagar = async (contaPagar: ContaPagarForm) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    // Definir status inicial baseado na data de vencimento
    const hoje = new Date().toISOString().split('T')[0];
    const status = contaPagar.data_vencimento < hoje ? 'vencido' : 'pendente';

    const { data, error } = await supabase
      .from('contas_pagar')
      .insert({
        ...contaPagar,
        user_id: user.id,
        status,
      })
      .select()
      .single();

    if (error) throw error;

    // Log de auditoria
    await supabase.from('audit_logs').insert({
      recurso: 'financeiro.contas_pagar',
      acao: 'create',
      entidade_tipo: 'conta_pagar',
      entidade_id: data.id,
      detalhes: { fornecedor: contaPagar.fornecedor, valor: contaPagar.valor }
    });

    return data;
  } catch (error) {
    console.error('Erro ao criar conta a pagar:', error);
    throw error;
  }
};

export const updateContaPagar = async (id: string, contaPagar: Partial<ContaPagarForm>) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    const { data, error } = await supabase
      .from('contas_pagar')
      .update({
        ...contaPagar,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .eq('user_id', user.id)
      .select()
      .single();

    if (error) throw error;

    // Log de auditoria
    await supabase.from('audit_logs').insert({
      recurso: 'financeiro.contas_pagar',
      acao: 'update',
      entidade_tipo: 'conta_pagar',
      entidade_id: id
    });

    return data;
  } catch (error) {
    console.error('Erro ao atualizar conta a pagar:', error);
    throw error;
  }
};

export const pagarConta = async (id: string, data_pagamento?: string) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    const dataPagamento = data_pagamento || new Date().toISOString().split('T')[0];

    const { data, error } = await supabase
      .from('contas_pagar')
      .update({
        status: 'pago',
        data_pagamento: dataPagamento,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .eq('user_id', user.id)
      .select()
      .single();

    if (error) throw error;

    // Log de auditoria
    await supabase.from('audit_logs').insert({
      recurso: 'financeiro.contas_pagar',
      acao: 'pagar',
      entidade_tipo: 'conta_pagar',
      entidade_id: id,
      detalhes: { data_pagamento: dataPagamento }
    });

    return data;
  } catch (error) {
    console.error('Erro ao pagar conta:', error);
    throw error;
  }
};

export const deleteContaPagar = async (id: string) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    const { error } = await supabase
      .from('contas_pagar')
      .delete()
      .eq('id', id)
      .eq('user_id', user.id);

    if (error) throw error;

    // Log de auditoria
    await supabase.from('audit_logs').insert({
      recurso: 'financeiro.contas_pagar',
      acao: 'delete',
      entidade_tipo: 'conta_pagar',
      entidade_id: id
    });

    return true;
  } catch (error) {
    console.error('Erro ao excluir conta a pagar:', error);
    throw error;
  }
};

// Upload de boleto
export const uploadBoleto = async (file: File, contaPagarId?: string) => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    // Nome do arquivo único
    const timestamp = Date.now();
    const fileName = `${user.id}/${timestamp}-${file.name}`;

    // Upload para Storage
    const { error: uploadError } = await supabase.storage
      .from('boletos')
      .upload(fileName, file);

    if (uploadError) throw uploadError;

    // Obter URL pública
    const { data: urlData } = supabase.storage
      .from('boletos')
      .getPublicUrl(fileName);

    // Se tiver ID de conta, atualizar
    if (contaPagarId) {
      await supabase
        .from('contas_pagar')
        .update({ boleto_url: urlData.publicUrl })
        .eq('id', contaPagarId)
        .eq('user_id', user.id);
    }

    return {
      url: urlData.publicUrl,
      path: fileName
    };
  } catch (error) {
    console.error('Erro ao fazer upload de boleto:', error);
    throw error;
  }
};

// Estatísticas
export const getEstatisticasContas = async () => {
  try {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) throw new Error('Usuário não autenticado');

    const { data, error } = await supabase
      .from('contas_pagar')
      .select('status, valor')
      .eq('user_id', user.id);

    if (error) throw error;

    const stats = {
      total_pendentes: 0,
      total_pagas: 0,
      total_vencidas: 0,
      valor_pendente: 0,
      valor_pago: 0,
      valor_vencido: 0,
    };

    data?.forEach(conta => {
      switch (conta.status) {
        case 'pendente':
          stats.total_pendentes++;
          stats.valor_pendente += conta.valor;
          break;
        case 'pago':
          stats.total_pagas++;
          stats.valor_pago += conta.valor;
          break;
        case 'vencido':
          stats.total_vencidas++;
          stats.valor_vencido += conta.valor;
          break;
      }
    });

    return stats;
  } catch (error) {
    console.error('Erro ao buscar estatísticas:', error);
    throw error;
  }
};
