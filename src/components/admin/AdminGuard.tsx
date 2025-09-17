import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { usePermissions } from '../../hooks/usePermissions';
import { AlertTriangle, Loader } from 'lucide-react';

interface AdminGuardProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

interface PermissionGuardProps {
  children: React.ReactNode;
  recurso: string;
  acao?: string;
  fallback?: React.ReactNode;
}

// Guarda para área administrativa - verifica se o usuário é admin
export const AdminGuard: React.FC<AdminGuardProps> = ({ 
  children, 
  fallback 
}) => {
  const { isAdmin, loading } = usePermissions();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Loader className="w-8 h-8 text-blue-600 mx-auto animate-spin mb-4" />
          <p className="text-gray-600">Verificando permissões...</p>
        </div>
      </div>
    );
  }

  if (!isAdmin) {
    if (fallback) {
      return <>{fallback}</>;
    }
    
    // Redirecionar para login se não autenticado
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

// Guarda para permissões específicas
export const PermissionGuard: React.FC<PermissionGuardProps> = ({ 
  children, 
  recurso, 
  acao = 'read',
  fallback 
}) => {
  const { can, loading } = usePermissions();

  if (loading) {
    return (
      <div className="flex items-center justify-center p-4">
        <Loader className="w-6 h-6 text-blue-600 animate-spin" />
      </div>
    );
  }

  if (!can(recurso, acao)) {
    if (fallback) {
      return <>{fallback}</>;
    }

    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <AlertTriangle className="w-12 h-12 text-red-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-red-900 mb-2">
            Acesso Negado
          </h3>
          <p className="text-red-700">
            Você não tem permissão para acessar este recurso.
          </p>
        </div>
      </div>
    );
  }

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
        <AlertTriangle className="w-16 h-16 text-red-600 mx-auto mb-4" />
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Acesso Restrito
        </h2>
        <p className="text-gray-600 mb-6">
          Apenas administradores podem acessar esta área.
        </p>
        <button
          onClick={() => window.history.back()}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          Voltar
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