import { useState, useEffect } from 'react';
import { useAuth } from '../modules/auth/AuthContext';
import { toast } from 'react-hot-toast';
import { supabase } from '../lib/supabase';

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
  const [permissions] = useState<UserPermissions>({});
  const [userProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) {
      setLoading(false);
    }
  }, [user]);

  // Verificar se é conta principal (qualquer usuário logado é considerado proprietário)
  const isMainAccount = () => {
    // Todos os usuários autenticados são considerados proprietários do sistema
    // pois cada sistema vendido é para um proprietário específico
    return !!user?.email;
  };

  // Verificar se é admin
  const isAdmin = () => {
    console.log('Debug isAdmin - isMainAccount:', isMainAccount());
    return isMainAccount();
  };

  // Verificar se é owner
  const isOwner = () => {
    console.log('Debug isOwner - isMainAccount:', isMainAccount());
    return isMainAccount();
  };

  // Verificar se é employee
  const isEmployee = () => {
    return !isMainAccount();
  };

  // Verificar se tem permissão para um módulo
  const hasPermission = (moduleName: string, action: 'view' | 'create' | 'edit' | 'delete' = 'view') => {
    // Conta principal sempre tem permissão
    if (isMainAccount()) return true;
    
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

  // Obter módulos visíveis para o dashboard
  const getVisibleModules = () => {
    // Conta principal tem acesso a todos os módulos
    if (isMainAccount()) {
      return [
        {
          name: 'sales',
          display_name: 'Vendas',
          description: 'Realizar vendas e emitir cupons fiscais',
          icon: 'ShoppingCart',
          path: '/vendas',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        },
        {
          name: 'clients',
          display_name: 'Clientes',
          description: 'Gerenciar cadastro de clientes',
          icon: 'Users',
          path: '/clientes',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        },
        {
          name: 'products',
          display_name: 'Produtos',
          description: 'Controle de estoque e produtos',
          icon: 'Package',
          path: '/produtos',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        },
        {
          name: 'cashier',
          display_name: 'Caixa',
          description: 'Controle de caixa e movimento',
          icon: 'DollarSign',
          path: '/caixa',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        },
        {
          name: 'orders',
          display_name: 'OS - Ordem de Serviço',
          description: 'Gestão de ordens de serviço',
          icon: 'FileText',
          path: '/ordens-servico',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        },
        {
          name: 'reports',
          display_name: 'Relatórios',
          description: 'Análises e relatórios de vendas',
          icon: 'BarChart3',
          path: '/relatorios',
          can_view: true,
          can_create: true,
          can_edit: true,
          can_delete: true
        }
      ];
    }

    // Para outros usuários, usar permissões do banco
    return Object.entries(permissions)
      .filter(([_, perms]) => perms.can_view)
      .map(([name, perms]) => ({
        name,
        ...perms
      }));
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
