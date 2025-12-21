import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { usePermissions } from '../../hooks/usePermissions';
import { AlertTriangle, Loader } from 'lucide-react';

interface AdminGuardProps {
  children: React.ReactNode;
}

interface PermissionGuardProps {
  children: React.ReactNode;
  recurso: string;
  acao?: string;
  fallback?: React.ReactNode;
}

// Guarda para área administrativa - verifica se o usuário é admin
export const AdminGuard: React.FC<AdminGuardProps> = ({ 
  children
}) => {
  const { loading, isAdmin } = usePermissions();

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Loader className="w-8 h-8 text-blue-600 mx-auto animate-spin mb-4" />
          <p className="text-gray-600">Carregando sistema...</p>
        </div>
      </div>
    );
  }

  // Apenas admin (super_admin OU admin_empresa) pode acessar área administrativa
  // Funcionários normais NÃO têm isAdmin = true
  if (!isAdmin) {
    console.log('🔐 AdminGuard: Acesso NEGADO - usuário não é admin');
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center max-w-md">
          <AlertTriangle className="w-12 h-12 text-red-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-red-900 mb-2">Acesso Administrativo Restrito</h3>
          <p className="text-red-700">
            Você não tem permissão para acessar esta área administrativa.
          </p>
        </div>
      </div>
    );
  }

  console.log('🔐 AdminGuard: Acesso PERMITIDO - usuário é admin');
  return <>{children}</>;
};

// Guarda para permissões específicas - verifica can()
export const PermissionGuard: React.FC<PermissionGuardProps> = ({ 
  children, 
  recurso,
  acao = 'read',
  fallback
}) => {
  const { loading, can, isAdmin } = usePermissions();

  if (loading) {
    return (
      <div className="flex items-center justify-center p-4">
        <Loader className="w-6 h-6 text-blue-600 animate-spin" />
      </div>
    );
  }

  // Admin sempre tem permissão
  if (isAdmin) {
    console.log(`🔐 PermissionGuard: Admin - acesso ao recurso ${recurso}:${acao} PERMITIDO`);
    return <>{children}</>;
  }

  // Funcionários: verificar permissão específica
  const hasPermission = can(recurso, acao);
  
  if (!hasPermission) {
    console.log(`🔐 PermissionGuard: Acesso ao recurso ${recurso}:${acao} NEGADO`);
    
    if (fallback) {
      return <>{fallback}</>;
    }
    
    return (
      <div className="p-4">
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 text-center">
          <AlertTriangle className="w-8 h-8 text-yellow-600 mx-auto mb-2" />
          <p className="text-yellow-800 font-medium">Sem Permissão</p>
          <p className="text-yellow-700 text-sm mt-1">
            Você não tem permissão para {acao === 'read' ? 'ver' : 'realizar esta ação em'} {recurso}
          </p>
        </div>
      </div>
    );
  }

  console.log(`🔐 PermissionGuard: Acesso ao recurso ${recurso}:${acao} PERMITIDO`);
  return <>{children}</>;
};

// Componente que combina Admin + Permission Guard
export const AdminPermissionGuard: React.FC<PermissionGuardProps> = (props) => {
  return (
    <AdminGuard>
      <PermissionGuard {...props} />
    </AdminGuard>
  );
};

// Hook para usar em componentes
export const useAdminGuard = () => {
  const { isAdmin, loading } = usePermissions();
  const location = useLocation();

  const redirectToLogin = () => {
    return <Navigate to="/login" state={{ from: location }} replace />;
  };

  const AccessDenied = () => (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="bg-white p-8 rounded-lg shadow-lg text-center max-w-md">
        <AlertTriangle className="w-16 h-16 text-yellow-600 mx-auto mb-4" />
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Sistema Configurado
        </h2>
        <p className="text-gray-600 mb-6">
          Seu sistema está configurado com acesso completo de administrador.
        </p>
        <button
          onClick={() => window.location.reload()}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          Continuar
        </button>
      </div>
    </div>
  );

  return {
    isAdmin,
    loading,
    redirectToLogin,
    AccessDenied
  };
};

export default AdminGuard;