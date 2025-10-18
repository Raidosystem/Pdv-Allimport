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
  const { loading } = usePermissions();

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

  // REGRA: Todo usuário logado tem acesso administrativo à sua empresa
  // Não bloquear mais com base em isAdmin
  console.log('🔐 AdminGuard: Permitindo acesso - todo usuário é admin da sua empresa');
  
  return <>{children}</>;
};

// Guarda para permissões específicas - também liberado
export const PermissionGuard: React.FC<PermissionGuardProps> = ({ 
  children, 
  recurso,
  acao = 'read'
}) => {
  const { loading } = usePermissions();

  if (loading) {
    return (
      <div className="flex items-center justify-center p-4">
        <Loader className="w-6 h-6 text-blue-600 animate-spin" />
      </div>
    );
  }

  // REGRA: Todo usuário logado pode usar qualquer recurso do sistema
  console.log(`🔐 PermissionGuard: Permitindo acesso ao recurso ${recurso}:${acao}`);
  
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