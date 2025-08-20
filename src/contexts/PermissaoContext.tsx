import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { FuncionarioPermissoes } from '../types/empresa';
import { useAuth } from '../modules/auth';

interface PermissaoContextData {
  permissoes: FuncionarioPermissoes | null;
  isPatrao: boolean;
  isFuncionario: boolean;
  funcionarioInfo: any;
  loading: boolean;
  checkPermissao: (modulo: keyof FuncionarioPermissoes) => boolean;
  checkPermissaoEspecifica: (permissao: keyof FuncionarioPermissoes) => boolean;
}

const PermissaoContext = createContext<PermissaoContextData>({} as PermissaoContextData);

export function PermissaoProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const [permissoes, setPermissoes] = useState<FuncionarioPermissoes | null>(null);
  const [funcionarioInfo, setFuncionarioInfo] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // Verificar se é patrão (tem empresa) ou funcionário
  const [isPatrao, setIsPatrao] = useState(false);
  const [isFuncionario, setIsFuncionario] = useState(false);

  useEffect(() => {
    if (!user) return;

    checkUserRole();
  }, [user]);

  const checkUserRole = async () => {
    if (!user) return;

    try {
      setLoading(true);

      // Primeiro verifica se é patrão (tem empresa própria)
      const { data: empresa, error: empresaError } = await supabase
        .from('empresas')
        .select('id, nome')
        .eq('user_id', user.id)
        .single();

      if (empresa && !empresaError) {
        // É patrão - tem acesso total
        setIsPatrao(true);
        setIsFuncionario(false);
        setPermissoes(null); // Patrão tem acesso total, não precisa de permissões específicas
        setFuncionarioInfo(null);
      } else {
        // Não é patrão, verificar se é funcionário
        // Aqui você implementaria a lógica para funcionários
        // Por exemplo, através de uma sessão de login específica
        setIsPatrao(false);
        setIsFuncionario(false);
        setPermissoes(null);
        setFuncionarioInfo(null);
      }
    } catch (error) {
      console.error('Erro ao verificar papel do usuário:', error);
      setIsPatrao(false);
      setIsFuncionario(false);
    } finally {
      setLoading(false);
    }
  };

  const checkPermissao = (modulo: keyof FuncionarioPermissoes): boolean => {
    // Patrão sempre tem acesso
    if (isPatrao) return true;
    
    // Funcionário precisa ter permissão específica
    if (isFuncionario && permissoes) {
      return permissoes[modulo] === true;
    }
    
    return false;
  };

  const checkPermissaoEspecifica = (permissao: keyof FuncionarioPermissoes): boolean => {
    // Patrão sempre tem acesso
    if (isPatrao) return true;
    
    // Funcionário precisa ter permissão específica
    if (isFuncionario && permissoes) {
      return permissoes[permissao] === true;
    }
    
    return false;
  };

  return (
    <PermissaoContext.Provider value={{
      permissoes,
      isPatrao,
      isFuncionario,
      funcionarioInfo,
      loading,
      checkPermissao,
      checkPermissaoEspecifica
    }}>
      {children}
    </PermissaoContext.Provider>
  );
}

export const usePermissoes = () => {
  const context = useContext(PermissaoContext);
  if (!context) {
    throw new Error('usePermissoes deve ser usado dentro de PermissaoProvider');
  }
  return context;
};

// Hook para verificar permissões específicas
export const useCheckPermissao = (modulo: keyof FuncionarioPermissoes) => {
  const { checkPermissao } = usePermissoes();
  return checkPermissao(modulo);
};

// Componente para proteger rotas/componentes baseado em permissões
interface ProtectedComponentProps {
  permissao: keyof FuncionarioPermissoes;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function ProtectedComponent({ 
  permissao, 
  children, 
  fallback 
}: ProtectedComponentProps) {
  const { checkPermissao, loading } = usePermissoes();

  if (loading) {
    return <div className="animate-pulse bg-gray-200 h-8 rounded"></div>;
  }

  if (!checkPermissao(permissao)) {
    return fallback ? (
      <>{fallback}</>
    ) : (
      <div className="p-4 bg-gray-100 rounded-lg text-center text-gray-500">
        <p>Você não tem permissão para acessar este recurso.</p>
      </div>
    );
  }

  return <>{children}</>;
}

// Componente para mostrar/ocultar cards baseado em permissões
interface ConditionalCardProps {
  permissao: keyof FuncionarioPermissoes;
  children: React.ReactNode;
}

export function ConditionalCard({ permissao, children }: ConditionalCardProps) {
  const { checkPermissao, loading } = usePermissoes();

  if (loading) return null;

  // Se não tem permissão, não renderiza nada
  if (!checkPermissao(permissao)) {
    return null;
  }

  return <>{children}</>;
}
