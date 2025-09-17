import { useState, useEffect, useCallback, createContext, useContext } from 'react';
import { supabase } from '../lib/supabase';
import type { PermissaoContext, UsePermissionsReturn } from '../types/admin';

// ========================================
// CONTEXT DE PERMISSÕES
// ========================================

const PermissionsContext = createContext<PermissaoContext | null>(null);

export const usePermissionsContext = () => {
  const context = useContext(PermissionsContext);
  if (!context) {
    throw new Error('usePermissionsContext deve ser usado dentro do PermissionsProvider');
  }
  return context;
};

// ========================================
// PROVIDER DE PERMISSÕES
// ========================================

interface PermissionsProviderProps {
  children: React.ReactNode;
}

export const PermissionsProvider: React.FC<PermissionsProviderProps> = ({ children }) => {
  const [context, setContext] = useState<PermissaoContext | null>(null);

  const loadPermissions = useCallback(async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      // Buscar dados do funcionário e suas permissões
      const { data: funcionarioData, error } = await supabase
        .from('funcionarios')
        .select(`
          id,
          empresa_id,
          nome,
          status,
          tipo_admin,
          lojas,
          funcionario_funcoes (
            funcao_id,
            funcoes (
              id,
              nome,
              escopo_lojas,
              funcao_permissoes (
                permissao_id,
                permissoes (
                  id,
                  recurso,
                  acao
                )
              )
            )
          )
        `)
        .eq('user_id', user.id)
        .eq('status', 'ativo')
        .single();

      if (error || !funcionarioData) {
        console.error('Erro ao carregar permissões:', error);
        console.log('Tentando criar funcionário padrão para o usuário...');
        
        // Se não existe funcionário, tentar criar um padrão como admin_empresa
        if (!funcionarioData && user.email) {
          try {
            const { data: novoFuncionario } = await supabase
              .from('funcionarios')
              .insert({
                user_id: user.id,
                nome: user.email.split('@')[0],
                email: user.email,
                tipo_admin: 'admin_empresa',
                status: 'ativo',
                empresa_id: '00000000-0000-0000-0000-000000000001' // Empresa padrão
              })
              .select()
              .single();
              
            if (novoFuncionario) {
              console.log('Funcionário criado com sucesso:', novoFuncionario);
              // Recarregar após criar
              setTimeout(() => loadPermissions(), 1000);
            }
          } catch (createError) {
            console.error('Erro ao criar funcionário padrão:', createError);
          }
        }
        return;
      }

      // Extrair permissões únicas
      const permissoes = new Set<string>();
      const funcoes: string[] = [];
      let escopo_lojas: string[] = [];

      funcionarioData.funcionario_funcoes?.forEach((ff: any) => {
        const funcao = ff.funcoes;
        funcoes.push(funcao.id);
        
        // Merge escopo de lojas
        if (funcao.escopo_lojas?.length > 0) {
          escopo_lojas = [...new Set([...escopo_lojas, ...funcao.escopo_lojas])];
        }

        // Adicionar permissões desta função
        funcao.funcao_permissoes?.forEach((fp: any) => {
          const perm = fp.permissoes;
          permissoes.add(`${perm.recurso}:${perm.acao}`);
        });
      });

      // Determinar tipo de admin baseado no campo tipo_admin
      const tipo_admin = funcionarioData.tipo_admin || 'funcionario';
      const is_super_admin = tipo_admin === 'super_admin';
      const is_admin_empresa = tipo_admin === 'admin_empresa';

      // Admin da empresa e super admin têm acesso administrativo total
      // Admin empresa pode gerenciar usuários, permissões, etc. da sua empresa
      const is_admin = is_super_admin || is_admin_empresa || permissoes.has('administracao.usuarios:create');

      // Admin da empresa tem permissões automáticas para administração
      if (is_admin_empresa) {
        permissoes.add('administracao.usuarios:create');
        permissoes.add('administracao.usuarios:read');
        permissoes.add('administracao.usuarios:update');
        permissoes.add('administracao.usuarios:delete');
        permissoes.add('administracao.funcoes:create');
        permissoes.add('administracao.funcoes:read');
        permissoes.add('administracao.funcoes:update');
        permissoes.add('administracao.funcoes:delete');
        permissoes.add('administracao.sistema:read');
        permissoes.add('administracao.sistema:update');
        permissoes.add('administracao.backup:create');
        permissoes.add('administracao.backup:read');
        permissoes.add('administracao.logs:read');
        permissoes.add('admin.dashboard:read');
      }

      // Super admin tem todas as permissões
      if (is_super_admin) {
        permissoes.add('super_admin:all');
      }

      const newContext: PermissaoContext = {
        empresa_id: funcionarioData.empresa_id,
        user_id: user.id,
        funcionario_id: funcionarioData.id,
        funcoes,
        permissoes: Array.from(permissoes),
        is_admin: is_admin || is_super_admin || is_admin_empresa,
        is_super_admin,
        is_admin_empresa,
        tipo_admin,
        escopo_lojas: escopo_lojas.length > 0 ? escopo_lojas : [] // vazio = todas as lojas
      };

      setContext(newContext);

    } catch (error) {
      console.error('Erro ao carregar contexto de permissões:', error);
    }
  }, []);

  useEffect(() => {
    loadPermissions();

    // Escutar mudanças na autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event) => {
      if (event === 'SIGNED_IN') {
        loadPermissions();
      } else if (event === 'SIGNED_OUT') {
        setContext(null);
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [loadPermissions]);

  return (
    <PermissionsContext.Provider value={context}>
      {children}
    </PermissionsContext.Provider>
  );
};

// ========================================
// HOOK DE PERMISSÕES
// ========================================

export const usePermissions = (): UsePermissionsReturn => {
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<{ id: string; email?: string } | null>(null);
  const context = useContext(PermissionsContext);

  useEffect(() => {
    if (context !== null) {
      setLoading(false);
    }
  }, [context]);

  useEffect(() => {
    const getUser = async () => {
      const { data: { user: authUser } } = await supabase.auth.getUser();
      if (authUser) {
        setUser({
          id: authUser.id,
          email: authUser.email
        });
      }
    };
    getUser();
  }, []);

  const can = useCallback((recurso: string, acao: string): boolean => {
    if (!context) return false;
    
    // Super admin pode tudo
    if (context.is_super_admin) return true;
    
    // Admin da empresa pode gerenciar recursos administrativos da sua empresa
    if (context.is_admin_empresa) {
      const adminResources = [
        'administracao.usuarios',
        'administracao.funcoes', 
        'administracao.sistema',
        'administracao.backup',
        'administracao.logs',
        'admin.dashboard'
      ];
      
      if (adminResources.some(resource => recurso.startsWith(resource))) {
        return true;
      }
    }
    
    // Verificação normal de permissões para funcionários
    return context.permissoes.includes(`${recurso}:${acao}`);
  }, [context]);

  const refresh = useCallback(async () => {
    setLoading(true);
    // Forçar reload do contexto
    window.location.reload();
  }, []);

  return {
    can,
    isAdmin: context?.is_admin || false,
    isSuperAdmin: context?.is_super_admin || false,
    isAdminEmpresa: context?.is_admin_empresa || false,
    tipoAdmin: context?.tipo_admin || 'funcionario',
    loading,
    permissoes: context?.permissoes || [],
    refresh,
    user
  };
};

// ========================================
// HOOK ESPECÍFICO PARA VERIFICAÇÃO ADMIN
// ========================================

export const useIsAdmin = (): boolean => {
  const { isAdmin } = usePermissions();
  return isAdmin;
};

// ========================================
// HOOK PARA CONTROLE DE ROTAS
// ========================================

export const useRoutePermission = (recurso: string, acao: string = 'read') => {
  const { can, loading } = usePermissions();
  
  return {
    hasAccess: can(recurso, acao),
    loading,
    canAccess: (r: string, a: string = 'read') => can(r, a)
  };
};

// ========================================
// HOC PARA PROTEÇÃO DE ROTAS
// ========================================

interface WithPermissionProps {
  recurso: string;
  acao?: string;
  fallback?: React.ReactNode;
  children: React.ReactNode;
}

export const WithPermission: React.FC<WithPermissionProps> = ({ 
  recurso, 
  acao = 'read', 
  fallback = null, 
  children 
}) => {
  const { can, loading } = usePermissions();

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!can(recurso, acao)) {
    return fallback ? (
      <>{fallback}</>
    ) : (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <div className="text-red-600 mb-2">
          <svg className="w-12 h-12 mx-auto" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
          </svg>
        </div>
        <h3 className="text-lg font-semibold text-red-900 mb-2">Acesso Negado</h3>
        <p className="text-red-700">
          Você não tem permissão para acessar esta funcionalidade.
        </p>
      </div>
    );
  }

  return <>{children}</>;
};

// ========================================
// HOOK PARA FILTRAR ITENS DE MENU
// ========================================

interface MenuItem {
  id: string;
  permission?: {
    recurso: string;
    acao: string;
  };
  [key: string]: any;
}

export const useFilteredMenuItems = <T extends MenuItem>(items: T[]): T[] => {
  const { can } = usePermissions();

  return items.filter(item => {
    if (!item.permission) return true;
    return can(item.permission.recurso, item.permission.acao);
  });
};

// ========================================
// HOOK PARA AUDITORIA
// ========================================

export const useAuditLog = () => {
  const context = usePermissionsContext();

  const logAction = useCallback(async (
    recurso: string,
    acao: string,
    entidade_tipo?: string,
    entidade_id?: string,
    dados_anteriores?: any,
    dados_novos?: any
  ) => {
    if (!context) return;

    try {
      await supabase.rpc('log_audit', {
        p_recurso: recurso,
        p_acao: acao,
        p_entidade_tipo: entidade_tipo,
        p_entidade_id: entidade_id,
        p_dados_anteriores: dados_anteriores,
        p_dados_novos: dados_novos
      });
    } catch (error) {
      console.error('Erro ao registrar log de auditoria:', error);
    }
  }, [context]);

  return { logAction };
};

// ========================================
// UTILS PARA PERMISSÕES
// ========================================

export const formatPermission = (recurso: string, acao: string): string => {
  return `${recurso}:${acao}`;
};

export const parsePermission = (permission: string): { recurso: string; acao: string } => {
  const [recurso, acao] = permission.split(':');
  return { recurso, acao };
};

export const groupPermissionsByResource = (permissoes: string[]) => {
  const groups: Record<string, string[]> = {};
  
  permissoes.forEach(perm => {
    const { recurso, acao } = parsePermission(perm);
    if (!groups[recurso]) {
      groups[recurso] = [];
    }
    groups[recurso].push(acao);
  });
  
  return groups;
};

// ========================================
// CONSTANTES DE PERMISSÕES
// ========================================

export const PERMISSIONS = {
  // Vendas
  VENDAS_READ: 'vendas:read',
  VENDAS_CREATE: 'vendas:create',
  VENDAS_UPDATE: 'vendas:update',
  VENDAS_DELETE: 'vendas:delete',
  VENDAS_CANCEL: 'vendas:cancel',
  VENDAS_REFUND: 'vendas:refund',
  VENDAS_DISCOUNT: 'vendas:discount',

  // Caixa
  CAIXA_READ: 'caixa:read',
  CAIXA_OPEN: 'caixa:open',
  CAIXA_CLOSE: 'caixa:close',
  CAIXA_SUPPLY: 'caixa:supply',
  CAIXA_WITHDRAW: 'caixa:withdraw',
  CAIXA_MANAGE: 'caixa:manage',

  // Clientes
  CLIENTES_READ: 'clientes:read',
  CLIENTES_CREATE: 'clientes:create',
  CLIENTES_UPDATE: 'clientes:update',
  CLIENTES_DELETE: 'clientes:delete',
  CLIENTES_EXPORT: 'clientes:export',

  // Produtos
  PRODUTOS_READ: 'produtos:read',
  PRODUTOS_CREATE: 'produtos:create',
  PRODUTOS_UPDATE: 'produtos:update',
  PRODUTOS_DELETE: 'produtos:delete',
  PRODUTOS_MANAGE_STOCK: 'produtos:manage_stock',
  PRODUTOS_ADJUST_PRICE: 'produtos:adjust_price',
  PRODUTOS_EXPORT: 'produtos:export',

  // Ordens de Serviço
  OS_READ: 'ordens_servico:read',
  OS_CREATE: 'ordens_servico:create',
  OS_UPDATE: 'ordens_servico:update',
  OS_DELETE: 'ordens_servico:delete',
  OS_APPROVE: 'ordens_servico:approve',
  OS_COMPLETE: 'ordens_servico:complete',
  OS_EXPORT: 'ordens_servico:export',

  // Relatórios
  RELATORIOS_OVERVIEW: 'relatorios.overview:read',
  RELATORIOS_DETALHADO: 'relatorios.detalhado:read',
  RELATORIOS_RANKING: 'relatorios.ranking:read',
  RELATORIOS_GRAFICOS: 'relatorios.graficos:read',
  RELATORIOS_ANALYTICS: 'relatorios.analytics:read',
  RELATORIOS_EXPORTACOES: 'relatorios.exportacoes:read',
  RELATORIOS_EXPORT: 'relatorios:export',

  // Administração
  ADMIN_USUARIOS_READ: 'administracao.usuarios:read',
  ADMIN_USUARIOS_CREATE: 'administracao.usuarios:create',
  ADMIN_USUARIOS_UPDATE: 'administracao.usuarios:update',
  ADMIN_USUARIOS_DELETE: 'administracao.usuarios:delete',
  ADMIN_USUARIOS_INVITE: 'administracao.usuarios:invite',
  ADMIN_USUARIOS_IMPERSONATE: 'administracao.usuarios:impersonate',

  ADMIN_FUNCOES_READ: 'administracao.funcoes:read',
  ADMIN_FUNCOES_CREATE: 'administracao.funcoes:create',
  ADMIN_FUNCOES_UPDATE: 'administracao.funcoes:update',
  ADMIN_FUNCOES_DELETE: 'administracao.funcoes:delete',

  ADMIN_SISTEMA_READ: 'administracao.sistema:read',
  ADMIN_SISTEMA_UPDATE: 'administracao.sistema:update',

  ADMIN_BACKUPS_READ: 'administracao.backups:read',
  ADMIN_BACKUPS_CREATE: 'administracao.backups:create',
  ADMIN_BACKUPS_RESTORE: 'administracao.backups:restore',

  ADMIN_LOGS_READ: 'administracao.logs:read'
} as const;