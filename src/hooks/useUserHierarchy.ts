import { useState, useEffect } from 'react';
import { useAuth } from '../modules/auth/AuthContext';
import { toast } from 'react-hot-toast';
import { supabase } from '../lib/supabase';
import { usePermissionsContext } from './usePermissions';

export interface UserPermissions {
  [moduleName: string]: {
    can_view: boolean;
    can_create: boolean;
    can_edit: boolean;
    can_delete: boolean;
    display_name: string;
    icon: string;
    path: string;
  };
}

export interface Employee {
  id: string;
  name: string;
  email: string;
  position?: string;
  is_active: boolean;
  user_id?: string;
  created_at: string;
  permissions: Array<{
    id: string;
    module_name: string;
    can_read: boolean;
    can_write: boolean;
    can_delete: boolean;
  }>;
}

export interface UserProfile {
  id: string;
  user_id: string;
  owner_id?: string;
  user_type: 'admin' | 'owner' | 'employee';
  company_name?: string;
  is_active: boolean;
}

export function useUserHierarchy() {
  const { user } = useAuth();
  const permissionsContext = usePermissionsContext();
  const [permissions] = useState<UserPermissions>({});
  const [userProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) {
      setLoading(false);
    }
  }, [user]);

  // ✅ Verificar se é conta principal usando o contexto de permissões
  const isMainAccount = () => {
    // Apenas admin_empresa e super_admin são considerados conta principal
    return permissionsContext?.is_admin_empresa || permissionsContext?.is_super_admin || false;
  };

  // ✅ Verificar se é admin usando o contexto de permissões
  const isAdmin = () => {
    const result = permissionsContext?.is_admin || false;
    console.log('Debug isAdmin - resultado:', result, 'tipo_admin:', permissionsContext?.tipo_admin);
    return result;
  };

  // ✅ Verificar se é owner usando o contexto de permissões
  const isOwner = () => {
    const result = permissionsContext?.is_admin_empresa || false;
    console.log('Debug isOwner - resultado:', result);
    return result;
  };

  // ✅ Verificar se é employee
  const isEmployee = () => {
    return permissionsContext?.tipo_admin === 'funcionario';
  };

  // ✅ Verificar se tem permissão para um módulo
  const hasPermission = (moduleName: string, action: 'view' | 'create' | 'edit' | 'delete' = 'view') => {
    // Super admin pode tudo
    if (permissionsContext?.is_super_admin) return true;
    
    // Admin da empresa pode tudo
    if (permissionsContext?.is_admin_empresa) return true;
    
    const modulePermissions = permissions[moduleName];
    if (!modulePermissions) return false;

    switch (action) {
      case 'view':
        return modulePermissions.can_view;
      case 'create':
        return modulePermissions.can_create;
      case 'edit':
        return modulePermissions.can_edit;
      case 'delete':
        return modulePermissions.can_delete;
      default:
        return false;
    }
  };

  // ✅ Obter módulos visíveis baseado nas permissões reais
  const getVisibleModules = () => {
    const modules = [];
    
    // Verificar cada módulo individualmente baseado nas permissões
    const allModules = [
      {
        name: 'sales',
        display_name: 'Vendas',
        description: 'Realizar vendas e emitir cupons fiscais',
        icon: 'ShoppingCart',
        path: '/vendas',
        permission: 'vendas'
      },
      {
        name: 'clients',
        display_name: 'Clientes',
        description: 'Gerenciar cadastro de clientes',
        icon: 'Users',
        path: '/clientes',
        permission: 'clientes'
      },
      {
        name: 'products',
        display_name: 'Produtos',
        description: 'Controle de estoque e produtos',
        icon: 'Package',
        path: '/produtos',
        permission: 'produtos'
      },
      {
        name: 'cashier',
        display_name: 'Caixa',
        description: 'Controle de caixa e movimento',
        icon: 'DollarSign',
        path: '/caixa',
        permission: 'caixa'
      },
      {
        name: 'orders',
        display_name: 'OS - Ordem de Serviço',
        description: 'Gestão de ordens de serviço',
        icon: 'FileText',
        path: '/ordens-servico',
        permission: 'ordens'
      },
      {
        name: 'reports',
        display_name: 'Relatórios',
        description: 'Análises e relatórios de vendas',
        icon: 'BarChart3',
        path: '/relatorios',
        permission: 'relatorios'
      }
    ];
    
    for (const module of allModules) {
      // Verificar se tem pelo menos permissão de leitura
      const hasReadPermission = permissionsContext?.permissoes.some(
        p => p.startsWith(`${module.permission}:read`) || p.startsWith(`${module.permission}:`)
      ) || false;
      
      if (hasReadPermission || permissionsContext?.is_admin_empresa || permissionsContext?.is_super_admin) {
        // Verificar permissões específicas
        const can_create = permissionsContext?.permissoes.includes(`${module.permission}:create`) || 
                          permissionsContext?.is_admin_empresa || 
                          permissionsContext?.is_super_admin || false;
        
        const can_edit = permissionsContext?.permissoes.includes(`${module.permission}:update`) || 
                        permissionsContext?.is_admin_empresa || 
                        permissionsContext?.is_super_admin || false;
        
        const can_delete = permissionsContext?.permissoes.includes(`${module.permission}:delete`) || 
                          permissionsContext?.is_admin_empresa || 
                          permissionsContext?.is_super_admin || false;
        
        modules.push({
          ...module,
          can_view: true,
          can_create,
          can_edit,
          can_delete
        });
      }
    }
    
    return modules;
  };

  // Obter funcionários
  const getEmployees = async (): Promise<Employee[]> => {
    try {
      console.log('Buscando funcionários do Supabase...');
      
      const { data: funcionarios, error } = await supabase
        .from('funcionarios')
        .select(`
          *,
          login_funcionarios (
            usuario,
            ativo,
            ultimo_acesso
          )
        `)
        .order('criado_em', { ascending: false });

      if (error) {
        console.error('Erro ao buscar funcionários:', error);
        toast.error('Erro ao carregar funcionários');
        return [];
      }

      // Mapear dados para o formato esperado
      const employeesFormatted: Employee[] = (funcionarios || []).map((func: any) => ({
        id: func.id,
        name: func.nome,
        email: func.email || '',
        position: func.cargo || 'Funcionário',
        is_active: func.ativo,
        user_id: func.user_id,
        created_at: func.criado_em,
        permissions: [] // Permissions serão carregadas separadamente se necessário
      }));

      console.log(`✅ Carregados ${employeesFormatted.length} funcionários`);
      return employeesFormatted;
      
    } catch (error) {
      console.error('Erro ao buscar funcionários:', error);
      toast.error('Erro ao carregar funcionários');
      return [];
    }
  };

  // Criar funcionário
  const createEmployee = async (email: string, name?: string) => {
    console.log('createEmployee - simulando criação:', { email, name });
    toast.success('Funcionalidade de funcionários será implementada em breve!');
    return true;
  };

  // Atualizar funcionário
  const updateEmployee = async (employeeId: string, updates: Partial<Employee>) => {
    console.log('updateEmployee - simulando atualização:', { employeeId, updates });
    toast.success('Funcionalidade será implementada em breve!');
    return true;
  };

  // Excluir funcionário
  const deleteEmployee = async (employeeId: string) => {
    console.log('deleteEmployee - simulando exclusão:', employeeId);
    toast.success('Funcionalidade será implementada em breve!');
    return true;
  };

  // Atualizar permissões de funcionário
  const updateEmployeePermissions = async (employeeUserId: string, modulePermissions: any) => {
    console.log('updateEmployeePermissions - simulando atualização:', { employeeUserId, modulePermissions });
    toast.success('Funcionalidade será implementada em breve!');
    return true;
  };

  // Obter módulos do sistema
  const getSystemModules = async () => {
    try {
      // Primeiro tenta buscar módulos da tabela, se existir
      const { data: modulosDB, error: modulosError } = await supabase
        .from('modulos_sistema')
        .select('*')
        .eq('is_active', true)
        .order('name');

      // Se a tabela existe e tem dados, usa ela
      if (!modulosError && modulosDB && modulosDB.length > 0) {
        console.log('✅ Módulos carregados da tabela modulos_sistema');
        return modulosDB;
      }

      // Caso contrário, retorna módulos padrão do sistema
      console.log('📋 Usando módulos padrão do sistema');
      return [
        {
          id: 'sales',
          name: 'sales',
          display_name: 'Vendas',
          description: 'Realizar vendas e emitir cupons fiscais',
          is_active: true
        },
        {
          id: 'clients',
          name: 'clients',
          display_name: 'Clientes',
          description: 'Gerenciar cadastro de clientes',
          is_active: true
        },
        {
          id: 'products',
          name: 'products',
          display_name: 'Produtos',
          description: 'Controle de estoque e produtos',
          is_active: true
        },
        {
          id: 'cashier',
          name: 'cashier',
          display_name: 'Caixa',
          description: 'Controle de caixa e movimento',
          is_active: true
        },
        {
          id: 'orders',
          name: 'orders',
          display_name: 'OS - Ordem de Serviço',
          description: 'Gestão de ordens de serviço',
          is_active: true
        },
        {
          id: 'reports',
          name: 'reports',
          display_name: 'Relatórios',
          description: 'Análises e relatórios de vendas',
          is_active: true
        }
      ];
      
    } catch (error) {
      console.error('Erro ao buscar módulos:', error);
      // Em caso de erro, retorna módulos básicos
      return [
        {
          id: 'sales',
          name: 'sales', 
          display_name: 'Vendas',
          description: 'Sistema de vendas',
          is_active: true
        }
      ];
    }
  };

  return {
    permissions,
    userProfile,
    loading,
    isAdmin,
    isOwner,
    isEmployee,
    hasPermission,
    getVisibleModules,
    getEmployees,
    createEmployee,
    updateEmployee,
    deleteEmployee,
    updateEmployeePermissions,
    getSystemModules
  };
}
