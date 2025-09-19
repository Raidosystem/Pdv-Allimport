import React from 'react';
import { Shield, Crown, User, AlertTriangle, CheckCircle } from 'lucide-react';
import { usePermissions } from '../hooks/usePermissions';
import AccessSOS from './AccessSOS';

interface AccessStatusBadgeProps {
  showDetails?: boolean;
  className?: string;
}

export const AccessStatusBadge: React.FC<AccessStatusBadgeProps> = ({ 
  showDetails = false,
  className = ''
}) => {
  const { isAdmin, isAdminEmpresa, isSuperAdmin, tipoAdmin, loading, user } = usePermissions();

  if (loading) {
    return (
      <div className={`flex items-center gap-2 px-3 py-1 bg-gray-100 rounded-full text-gray-600 ${className}`}>
        <div className="w-4 h-4 animate-spin rounded-full border-2 border-gray-300 border-t-gray-600"></div>
        <span className="text-sm">Verificando...</span>
      </div>
    );
  }

  const getStatusInfo = () => {
    if (isSuperAdmin) {
      return {
        icon: Crown,
        text: 'Super Admin',
        color: 'bg-purple-100 text-purple-800 border-purple-200',
        description: 'Acesso total ao sistema'
      };
    }
    
    if (isAdminEmpresa || isAdmin) {
      return {
        icon: Shield,
        text: 'Admin Empresa',
        color: 'bg-green-100 text-green-800 border-green-200',
        description: 'Administrador da empresa'
      };
    }

    if (tipoAdmin === 'funcionario') {
      return {
        icon: User,
        text: 'Funcionário',
        color: 'bg-blue-100 text-blue-800 border-blue-200',
        description: 'Usuário padrão'
      };
    }

    return {
      icon: AlertTriangle,
      text: 'Sem Permissão',
      color: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      description: 'Acesso limitado'
    };
  };

  const statusInfo = getStatusInfo();
  const Icon = statusInfo.icon;
  const hasAdminAccess = isAdmin || isAdminEmpresa || isSuperAdmin;

  if (!showDetails) {
    return (
      <div className={`flex items-center gap-2 px-3 py-1 border rounded-full ${statusInfo.color} ${className}`}>
        <Icon className="w-4 h-4" />
        <span className="text-sm font-medium">{statusInfo.text}</span>
        {hasAdminAccess && <CheckCircle className="w-3 h-3" />}
      </div>
    );
  }

  return (
    <div className={`bg-white border border-gray-200 rounded-lg p-4 ${className}`}>
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className={`p-2 rounded-lg ${statusInfo.color.replace('text-', 'bg-').replace('bg-', 'bg-opacity-20 text-')}`}>
            <Icon className="w-5 h-5" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900">{statusInfo.text}</h3>
            <p className="text-sm text-gray-600">{statusInfo.description}</p>
          </div>
        </div>
        {hasAdminAccess ? (
          <CheckCircle className="w-6 h-6 text-green-500" />
        ) : (
          <AlertTriangle className="w-6 h-6 text-yellow-500" />
        )}
      </div>

      <div className="space-y-2 text-sm">
        <div className="flex justify-between">
          <span className="text-gray-600">Email:</span>
          <span className="font-medium">{user?.email}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Tipo:</span>
          <span className="font-medium">{tipoAdmin || 'Indefinido'}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Status:</span>
          <span className={`font-medium ${hasAdminAccess ? 'text-green-600' : 'text-yellow-600'}`}>
            {hasAdminAccess ? 'Acesso Liberado' : 'Acesso Restrito'}
          </span>
        </div>
      </div>

      {!hasAdminAccess && (
        <div className="mt-4 pt-3 border-t border-gray-200">
          <AccessSOS variant="text" className="w-full justify-center" />
        </div>
      )}
    </div>
  );
};

export default AccessStatusBadge;