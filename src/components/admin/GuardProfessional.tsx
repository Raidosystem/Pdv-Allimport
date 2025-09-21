import React from 'react'
import { Shield, AlertTriangle } from 'lucide-react'
import { hasPermissionProfessional } from '../../types/admin-professional'
import type { PermissaoProfissional } from '../../types/admin-professional'

interface GuardProfessionalProps {
  perms: string[]
  need: PermissaoProfissional | PermissaoProfissional[]
  children: React.ReactNode
  fallback?: React.ReactNode
}

/**
 * Componente de proteção para funcionalidades administrativas profissionais
 * Baseado no Blueprint Profissional do PDV Allimport
 */
export function GuardProfessional({ 
  perms, 
  need, 
  children, 
  fallback 
}: GuardProfessionalProps) {
  
  if (!hasPermissionProfessional(perms, need)) {
    if (fallback) {
      return <>{fallback}</>
    }
    
    return (
      <div className="p-6 rounded-xl bg-amber-50 border border-amber-200">
        <div className="flex items-center gap-3 mb-2">
          <div className="p-2 bg-amber-100 rounded-lg">
            <Shield className="w-5 h-5 text-amber-700" />
          </div>
          <div>
            <div className="text-amber-800 font-medium">Acesso Restrito</div>
            <div className="text-amber-700 text-sm">
              Esta área é restrita para administradores/gerentes autorizados.
            </div>
          </div>
        </div>
        
        <div className="flex items-center gap-2 text-xs text-amber-600 bg-amber-100 p-2 rounded">
          <AlertTriangle className="w-3 h-3" />
          <span>Permissão necessária: {Array.isArray(need) ? need.join(', ') : need}</span>
        </div>
      </div>
    )
  }

  return <>{children}</>
}

/**
 * Hook para verificar permissões profissionais
 */
export function usePermissionProfessional() {
  // Implementar hook de permissões quando integrar com sistema de auth
  const userPermissions: string[] = [] // Temporário
  
  const hasPermission = (needed: PermissaoProfissional | PermissaoProfissional[]) => {
    return hasPermissionProfessional(userPermissions, needed)
  }
  
  const isAdmin = userPermissions.includes('dashboard.admin.read')
  const canManageUsers = userPermissions.includes('convites.create')
  const canManageBackups = userPermissions.includes('backups.create')
  const canManageIntegrations = userPermissions.includes('integracoes.write')
  
  return {
    hasPermission,
    isAdmin,
    canManageUsers,
    canManageBackups,
    canManageIntegrations,
    permissions: userPermissions
  }
}

export default GuardProfessional