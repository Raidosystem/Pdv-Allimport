import React from 'react';
import { Routes, Route } from 'react-router-dom';
import AdminLayout from '../components/admin/AdminLayout';
import { AdminGuard, PermissionGuard } from '../components/admin/AdminGuard';
import AdminDashboard from '../pages/admin/AdminDashboard';
import AdminUsersPage from '../pages/admin/AdminUsersPage';
import AdminRolesPermissionsPage from '../pages/admin/AdminRolesPermissionsPage';
import AdminBackupsPage from '../pages/admin/AdminBackupsPage';
import AdminSystemSettingsPage from '../pages/admin/AdminSystemSettingsPage';

/**
 * EXEMPLO DE COMO INTEGRAR AS ROTAS ADMINISTRATIVAS
 * 
 * Este arquivo demonstra como configurar todas as páginas administrativas
 * com proteção de rotas e layout específico.
 * 
 * Para usar, adicione essas rotas no seu arquivo principal de rotas (App.tsx ou Routes.tsx)
 */

const AdminRoutes: React.FC = () => {
  return (
    <AdminGuard>
      <AdminLayout>
        <Routes>
          {/* Dashboard - Acesso livre para admins */}
          <Route path="/dashboard" element={<AdminDashboard />} />
          
          {/* Usuários - Requer permissão específica */}
          <Route 
            path="/usuarios" 
            element={
              <PermissionGuard recurso="administracao.usuarios" acao="read">
                <AdminUsersPage />
              </PermissionGuard>
            } 
          />

          {/* Funções e Permissões - Requer permissão específica */}
          <Route 
            path="/funcoes-permissoes" 
            element={
              <PermissionGuard recurso="administracao.funcoes" acao="read">
                <AdminRolesPermissionsPage />
              </PermissionGuard>
            } 
          />
          
          {/* Backups - Requer permissão específica */}
          <Route 
            path="/backups" 
            element={
              <PermissionGuard recurso="administracao.backups" acao="read">
                <AdminBackupsPage />
              </PermissionGuard>
            } 
          />
          
          {/* Configurações do Sistema - Requer permissão específica */}
          <Route 
            path="/configuracoes" 
            element={
              <PermissionGuard recurso="administracao.sistema" acao="read">
                <AdminSystemSettingsPage />
              </PermissionGuard>
            } 
          />
          
          {/* Rota padrão - redireciona para o dashboard */}
          <Route path="/" element={<AdminDashboard />} />
        </Routes>
      </AdminLayout>
    </AdminGuard>
  );
};

export default AdminRoutes;