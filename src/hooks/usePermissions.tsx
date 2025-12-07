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
    console.error('🚨 Erro: usePermissionsContext deve ser usado dentro do PermissionsProvider');
    throw new Error('usePermissionsContext deve ser usado dentro do PermissionsProvider');
  }
  return context;
};

// Hook seguro que não lança erro se contexto não existir
export const usePermissionsContextSafe = () => {
  return useContext(PermissionsContext);
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
      if (!user) {
        console.log('❌ Nenhum usuário logado');
        return;
      }

      console.log('🔍 [usePermissions] Carregando permissões para user:', user.email, 'ID:', user.id);
      console.log('🔍 [usePermissions] user.user_metadata:', user.user_metadata);
      console.log('🔑 [usePermissions] Buscando funcionário por user.id:', user.id);
      
      // ✅ BUSCAR FUNCIONÁRIO APENAS POR user_id (auth.uid())
      // Cada funcionário tem sua própria conta no Supabase Auth
      console.log('🔍 [usePermissions] Buscando funcionário por user_id');
      const { data: funcionarioData, error } = await supabase
        .from('funcionarios')
        .select(`
          *,
          funcoes:funcao_id (
            id,
            nome,
            escopo_lojas,
            funcao_permissoes (
              permissoes (
                id,
                recurso,
                acao,
                descricao
              )
            )
          )
        `)
        .eq('user_id', user.id)
        .maybeSingle();

      if (funcionarioData) {
        console.log('✅ [usePermissions] Funcionário encontrado:', funcionarioData.nome);
      } else {
        console.log('ℹ️ [usePermissions] Nenhum funcionário cadastrado (normal para donos de empresa)');
      }
      
      if (error && error.code !== 'PGRST116') {
        console.error('⚠️ [usePermissions] Erro ao buscar funcionário:', error);
      }

      console.log('📦 [usePermissions] Resposta funcionarioData:', funcionarioData);

      // ✅ SE NÃO TEM FUNCIONÁRIO: Verificar se é dono da empresa (primeiro usuário cadastrado)
      if (!funcionarioData) {
        console.log('ℹ️ [usePermissions] Usuário sem registro de funcionário');
        
        // APENAS UM EMAIL AUTORIZADO - Super Admin do Sistema
        const SUPER_ADMIN_EMAIL = 'novaradiosystem@outlook.com';
        const isSuperAdmin = user.email?.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase();
        
        console.log('🔐 [usePermissions] Verificando super admin:', {
          email: user.email,
          autorizado: isSuperAdmin
        });
        
        if (isSuperAdmin) {
          console.log('✅ SUPER ADMIN AUTORIZADO:', user.email);
          
          // ✅ Permissões COMPLETAS para super admin
          const adminContext: PermissaoContext = {
            empresa_id: user.id,
            user_id: user.id,
            funcionario_id: user.id,
            funcoes: ['admin_empresa'],
            permissoes: [
              // Vendas
              'vendas:read',
              'vendas:create',
              'vendas:update',
              'vendas:delete',
              // Produtos
              'produtos:read',
              'produtos:create',
              'produtos:update',
              'produtos:delete',
              // Clientes
              'clientes:read',
              'clientes:create',
              'clientes:update',
              'clientes:delete',
              // Caixa
              'caixa:read',
              'caixa:open',
              'caixa:close',
              'caixa:supply',
              'caixa:withdraw',
              // Ordens de Serviço
              'ordens_servico:read',
              'ordens_servico:create',
              'ordens_servico:update',
              'ordens_servico:delete',
              // Relatórios
              'relatorios:read',
              'relatorios:export',
              // Configurações
              'configuracoes:read',
              'configuracoes:update',
              // Backup
              'backup:create',
              'backup:read',
              // Administração
              'administracao.usuarios:create',
              'administracao.usuarios:read', 
              'administracao.usuarios:update',
              'administracao.usuarios:delete',
              'administracao.funcoes:create',
              'administracao.funcoes:read',
              'administracao.funcoes:update', 
              'administracao.funcoes:delete',
              'administracao.sistema:read',
              'administracao.sistema:update',
              'administracao.backup:create',
              'administracao.backup:read',
              'administracao.logs:read',
              'admin.dashboard:read'
            ],
            is_admin: true,
            is_super_admin: isSuperAdmin,
            is_admin_empresa: true,
            tipo_admin: isSuperAdmin ? 'super_admin' : 'admin_empresa',
            escopo_lojas: []
          };
          
          setContext(adminContext);
          console.log('🎯 ADMIN AUTORIZADO:', adminContext);
        } else {
          // Usuário comum sem funcionário = SEM PERMISSÕES
          console.log('❌ [usePermissions] ACESSO NEGADO - Email não autorizado:', user.email);
          console.log('💡 [usePermissions] Apenas novaradiosystem@outlook.com tem acesso direto');
          console.log('💡 [usePermissions] Outros usuários precisam ser cadastrados como funcionários');
          
          const basicContext: PermissaoContext = {
            empresa_id: user.id,
            user_id: user.id,
            funcionario_id: '', // String vazia ao invés de null
            funcoes: [],
            permissoes: [],
            is_admin: false,
            is_super_admin: false,
            is_admin_empresa: false,
            tipo_admin: 'funcionario', // Tipo padrão
            escopo_lojas: []
          };
          
          setContext(basicContext);
          console.log('🚫 USUÁRIO SEM PERMISSÕES:', basicContext);
        }
        return;
      }

      console.log('✅ [usePermissions] Funcionário encontrado:', funcionarioData.nome);
      console.log('📋 [usePermissions] funcoes:', funcionarioData.funcoes);

      // Extrair permissões únicas
      const permissoes = new Set<string>();
      const funcoes: string[] = [];
      let escopo_lojas: string[] = [];

      // A função vem direto de funcao_id (não de funcionario_funcoes)
      const funcao = funcionarioData.funcoes;
      
      if (funcao) {
        funcoes.push(funcao.id);
        
        console.log(`🔑 [usePermissions] Processando função: ${funcao.nome}`);
        console.log(`📦 [usePermissions] funcao_permissoes:`, funcao.funcao_permissoes);
        
        // Merge escopo de lojas
        if (funcao.escopo_lojas?.length > 0) {
          escopo_lojas = [...new Set([...escopo_lojas, ...funcao.escopo_lojas])];
        }

        // Adicionar permissões desta função
        funcao.funcao_permissoes?.forEach((fp: any) => {
          const perm = fp.permissoes;
          if (perm) {
            const permissaoStr = `${perm.recurso}:${perm.acao}`;
            permissoes.add(permissaoStr);
            console.log(`  ✅ Permissão adicionada: ${permissaoStr}`);
          } else {
            console.log(`  ⚠️ Permissão sem dados:`, fp);
          }
        });
      } else {
        console.warn('⚠️ [usePermissions] Funcionário sem função atribuída');
      }

      console.log(`🎯 [usePermissions] Total de permissões extraídas: ${permissoes.size}`);
      console.log(`📋 [usePermissions] Permissões:`, Array.from(permissoes));

      // ✅ CONVERTER JSONB PERMISSÕES PARA FORMATO NOVO
      // Se o funcionário tem permissoes JSONB mas não tem funcao_permissoes
      if (permissoes.size === 0 && funcionarioData.permissoes) {
        console.log('🔄 [usePermissions] Convertendo permissões JSONB para formato novo...');
        console.log('📦 [usePermissions] JSONB original:', funcionarioData.permissoes);
        
        const permissoesJSONB = funcionarioData.permissoes;
        
        // Mapeamento: módulo → permissões
        const moduloPermissoes: Record<string, string[]> = {
          vendas: ['vendas:read', 'vendas:create', 'vendas:update', 'vendas:delete'],
          produtos: ['produtos:read', 'produtos:create', 'produtos:update', 'produtos:delete'],
          clientes: ['clientes:read', 'clientes:create', 'clientes:update', 'clientes:delete'],
          caixa: ['caixa:read', 'caixa:open', 'caixa:close', 'caixa:supply', 'caixa:withdraw'],
          ordens_servico: ['ordens_servico:read', 'ordens_servico:create', 'ordens_servico:update', 'ordens_servico:delete'],
          relatorios: ['relatorios:read', 'relatorios:export'],
          configuracoes: ['configuracoes:read', 'configuracoes:update'],
          backup: ['backup:create', 'backup:read']
        };
        
        // Converter cada módulo JSONB em permissões do formato novo
        Object.keys(moduloPermissoes).forEach(modulo => {
          if (permissoesJSONB[modulo] === true) {
            moduloPermissoes[modulo].forEach(perm => {
              permissoes.add(perm);
              console.log(`  ✅ Convertido: ${modulo} → ${perm}`);
            });
          } else {
            console.log(`  ❌ Módulo ${modulo} não ativo no JSONB`);
          }
        });
        
        console.log(`🎉 [usePermissions] Total após conversão JSONB: ${permissoes.size}`);
      }

      // ✅ Determinar tipo de admin APENAS pelo campo tipo_admin do banco
      // NÃO promover automaticamente baseado em nome de função
      let tipo_admin = funcionarioData.tipo_admin || 'funcionario';
      
      const is_super_admin = tipo_admin === 'super_admin';
      const is_admin_empresa = tipo_admin === 'admin_empresa';

      console.log(`👤 [usePermissions] Tipo admin: ${tipo_admin}`);
      console.log(`🔑 [usePermissions] is_admin_empresa: ${is_admin_empresa}`);
      console.log(`👑 [usePermissions] is_super_admin: ${is_super_admin}`);

      // ✅ APENAS super_admin e admin_empresa são considerados admin
      // Funcionários normais NÃO são admin, mesmo que tenham algumas permissões
      const is_admin = is_super_admin || is_admin_empresa;

      // Admin da empresa tem permissões automáticas para administração
      if (is_admin_empresa) {
        console.log('✅ [usePermissions] Adicionando permissões automáticas de admin_empresa');
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

      console.log('🎉 [usePermissions] Contexto final criado:', newContext);
      console.log(`   📊 Total permissões no contexto: ${newContext.permissoes.length}`);
      console.log(`   🔑 is_admin: ${newContext.is_admin}`);
      console.log(`   🏢 is_admin_empresa: ${newContext.is_admin_empresa}`);

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

    // ✅ NOVO: Escutar mudanças no localStorage (login local)
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'pdv_funcionario_id' && e.newValue) {
        console.log('🔄 [usePermissions] funcionario_id mudou no localStorage, recarregando...', e.newValue);
        loadPermissions();
      }
    };

    window.addEventListener('storage', handleStorageChange);

    // ✅ NOVO: Também criar um custom event para mudanças no mesmo tab
    const handleCustomStorageChange = (e: CustomEvent) => {
      if (e.detail?.key === 'pdv_funcionario_id') {
        console.log('🔄 [usePermissions] funcionario_id mudou (custom event), recarregando...', e.detail.value);
        // Dar um delay pequeno para garantir que o localStorage foi atualizado
        setTimeout(() => loadPermissions(), 100);
      }
    };

    window.addEventListener('pdv_storage_change' as any, handleCustomStorageChange as EventListener);

    return () => {
      subscription.unsubscribe();
      window.removeEventListener('storage', handleStorageChange);
      window.removeEventListener('pdv_storage_change' as any, handleCustomStorageChange as EventListener);
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
    if (!context) {
      console.log(`❌ [can] Sem contexto para verificar ${recurso}:${acao}`);
      return false;
    }
    
    console.log(`🔍 [can] Verificando ${recurso}:${acao}`);
    console.log(`   Context:`, {
      is_super_admin: context.is_super_admin,
      is_admin_empresa: context.is_admin_empresa,
      is_admin: context.is_admin,
      tipo_admin: context.tipo_admin,
      total_permissoes: context.permissoes.length
    });
    
    // Super admin e Admin Empresa podem tudo
    if (context.is_super_admin || context.is_admin_empresa) {
      console.log(`   👑 ${context.is_super_admin ? 'Super admin' : 'Admin empresa'} - PERMITIDO (acesso total)`);
      return true;
    }
    
    // ✅ Funcionários normais: Verificar permissão no array
    const permissaoCompleta = `${recurso}:${acao}`;
    const hasPermission = context.permissoes.includes(permissaoCompleta);
    
    console.log(`   🔍 Verificando no array (${context.permissoes.length} permissões): ${permissaoCompleta} = ${hasPermission ? 'PERMITIDO' : 'NEGADO'}`);
    
    if (!hasPermission) {
      console.log(`   ❌ NEGADO - Permissão não encontrada no array`);
      if (context.permissoes.length > 0) {
        console.log(`   📋 Permissões disponíveis (primeiras 10):`, context.permissoes.slice(0, 10));
      }
    } else {
      console.log(`   ✅ PERMITIDO - Permissão encontrada no array`);
    }
    
    return hasPermission;
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

// ========================================
// HOOK PARA MÓDULOS VISÍVEIS (JSONB-BASED)
// ========================================
// Este hook lê direto do JSONB funcionarios.permissoes
// para verificar quais módulos o usuário pode ver
// ========================================

export const useVisibleModulesJSONB = () => {
  const [modules, setModules] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const context = usePermissionsContext();

  useEffect(() => {
    const loadModules = async () => {
      try {
        // Admin sempre vê tudo
        if (context?.is_admin_empresa || context?.is_super_admin) {
          console.log('👑 [useVisibleModules] Admin/Super - todos os módulos visíveis');
          setModules([
            { name: 'sales', display_name: 'Vendas', icon: 'ShoppingCart', path: '/vendas', permission: 'vendas', can_view: true },
            { name: 'clients', display_name: 'Clientes', icon: 'Users', path: '/clientes', permission: 'clientes', can_view: true },
            { name: 'products', display_name: 'Produtos', icon: 'Package', path: '/produtos', permission: 'produtos', can_view: true },
            { name: 'cashier', display_name: 'Caixa', icon: 'DollarSign', path: '/caixa', permission: 'caixa', can_view: true },
            { name: 'orders', display_name: 'OS', icon: 'FileText', path: '/ordens-servico', permission: 'ordens_servico', can_view: true },
            { name: 'reports', display_name: 'Relatórios', icon: 'BarChart3', path: '/relatorios', permission: 'relatorios', can_view: true }
          ]);
          setLoading(false);
          return;
        }

        // Funcionário: buscar permissões do banco
        const funcionarioId = context?.funcionario_id || localStorage.getItem('pdv_funcionario_id');
        
        if (!funcionarioId) {
          console.log('❌ [useVisibleModules] Sem funcionario_id');
          setModules([]);
          setLoading(false);
          return;
        }

        console.log('🔍 [useVisibleModules] Buscando permissões JSONB para:', funcionarioId);

        const { data: funcionario, error } = await supabase
          .from('funcionarios')
          .select('permissoes')
          .eq('id', funcionarioId)
          .single();

        if (error || !funcionario) {
          console.error('❌ [useVisibleModules] Erro ao buscar funcionário:', error);
          setModules([]);
          setLoading(false);
          return;
        }

        const permissoesJSONB = funcionario.permissoes || {};
        console.log('📦 [useVisibleModules] Permissões JSONB:', permissoesJSONB);

        // Mapear módulos baseado no JSONB
        const allModules = [
          { name: 'sales', display_name: 'Vendas', icon: 'ShoppingCart', path: '/vendas', permission: 'vendas' },
          { name: 'clients', display_name: 'Clientes', icon: 'Users', path: '/clientes', permission: 'clientes' },
          { name: 'products', display_name: 'Produtos', icon: 'Package', path: '/produtos', permission: 'produtos' },
          { name: 'cashier', display_name: 'Caixa', icon: 'DollarSign', path: '/caixa', permission: 'caixa' },
          { name: 'orders', display_name: 'OS', icon: 'FileText', path: '/ordens-servico', permission: 'ordens_servico' },
          { name: 'reports', display_name: 'Relatórios', icon: 'BarChart3', path: '/relatorios', permission: 'relatorios' }
        ];

        const visibleModules = allModules.filter(module => {
          const hasPermission = permissoesJSONB[module.permission] === true;
          console.log(`  ${hasPermission ? '✅' : '❌'} ${module.display_name}: ${permissoesJSONB[module.permission]}`);
          return hasPermission;
        }).map(module => ({ ...module, can_view: true }));

        console.log(`📊 [useVisibleModules] Total módulos visíveis: ${visibleModules.length}`);
        setModules(visibleModules);
        setLoading(false);

      } catch (error) {
        console.error('❌ [useVisibleModules] Erro:', error);
        setModules([]);
        setLoading(false);
      }
    };

    if (context !== null) {
      loadModules();
    }
  }, [context]);

  return { modules, loading };
};