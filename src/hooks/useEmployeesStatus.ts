import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth';

interface EmployeesStatus {
  hasEmployees: boolean;
  employeesCount: number;
  isLoading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

/**
 * Hook para verificar se a empresa possui funcionários cadastrados
 * Usado para controlar o estado bloqueado/desbloqueado da página de Gerenciar Funcionários
 */
export const useEmployeesStatus = (): EmployeesStatus => {
  const { user } = useAuth();
  const [hasEmployees, setHasEmployees] = useState(false);
  const [employeesCount, setEmployeesCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchEmployeesStatus = async () => {
    if (!user) {
      setIsLoading(false);
      return;
    }

    try {
      setIsLoading(true);
      setError(null);

      let empresaId: string | null = null;

      // Verificar se é um funcionário logado
      if (user.user_metadata?.funcionario_id) {
        // É um funcionário - buscar empresa_id do funcionário
        const { data: funcionarioData, error: funcError } = await supabase
          .from('funcionarios')
          .select('empresa_id')
          .eq('id', user.user_metadata.funcionario_id)
          .single();

        if (funcError) {
          throw funcError;
        }

        empresaId = funcionarioData?.empresa_id;
      } else {
        // É o dono da empresa - buscar empresa_id pela tabela empresas
        const { data: empresaData, error: empresaError } = await supabase
          .from('empresas')
          .select('id')
          .eq('user_id', user.id)
          .single();

        if (empresaError) {
          throw empresaError;
        }

        empresaId = empresaData?.id;
      }

      if (!empresaId) {
        setHasEmployees(false);
        setEmployeesCount(0);
        setIsLoading(false);
        return;
      }

      // Conta funcionários da empresa
      const { count, error: countError } = await supabase
        .from('funcionarios')
        .select('*', { count: 'exact', head: true })
        .eq('empresa_id', empresaId)
        .eq('status', 'ativo');

      if (countError) {
        throw countError;
      }

      const totalEmployees = count || 0;
      setEmployeesCount(totalEmployees);
      setHasEmployees(totalEmployees > 0);
    } catch (err) {
      console.error('Erro ao verificar status de funcionários:', err);
      setError(err as Error);
      setHasEmployees(false);
      setEmployeesCount(0);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchEmployeesStatus();
  }, [user]);

  return {
    hasEmployees,
    employeesCount,
    isLoading,
    error,
    refetch: fetchEmployeesStatus
  };
};
