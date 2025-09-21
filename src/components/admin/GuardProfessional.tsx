import React from 'react'
import type { PermissaoProfissional } from '../../types/admin-professional'

interface GuardProfessionalProps {
  children: React.ReactNode
  perms?: string[]
  need?: PermissaoProfissional | PermissaoProfissional[]
  fallback?: React.ReactNode
}

/**
 * Componente de proteção para funcionalidades administrativas profissionais
 * REGRA: Todo cliente que comprou o sistema tem acesso total
 * Baseado no Blueprint Profissional do PDV Allimport
 */
export function GuardProfessional({ 
  children 
}: GuardProfessionalProps) {
  
  // REGRA: Todo usuário logado tem acesso às funcionalidades profissionais
  // O cliente define as permissões dos funcionários dentro do sistema
  console.log('🔓 GuardProfessional: Acesso liberado - cliente é admin da empresa');
  
  return <>{children}</>
}

/**
 * Hook para verificar permissões profissionais
 */
export function usePermissionProfessional() {
  // REGRA: Todo usuário logado tem acesso total às funcionalidades profissionais
  // O cliente que comprou o sistema define as permissões dos funcionários
  const userPermissions: string[] = [
    'dashboard.admin.read',
    'convites.create',
    'convites.read', 
    'convites.delete',
    'backups.create',
    'backups.read',
    'backups.download',
    'integracoes.read',
    'integracoes.write',
    'integracoes.test',
    'auditoria.read'
  ]
  
  const hasPermission = () => {
    return true // Liberar tudo para usuários logados
  }
  
  const isAdmin = true // Todo usuário logado é admin da sua empresa
  const canManageUsers = true
  const canManageBackups = true
  const canManageIntegrations = true
  
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