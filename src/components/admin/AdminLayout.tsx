import React, { useState } from 'react';
import { Link, useLocation, Outlet } from 'react-router-dom';
import { 
  LayoutDashboard,
  Users,
  Shield,
  Database,
  Settings,
  LogOut,
  Menu,
  X,
  ChevronRight,
  Building,
  User
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';

interface AdminLayoutProps {
  children?: React.ReactNode;
}

const AdminLayout: React.FC<AdminLayoutProps> = ({ children }) => {
  const location = useLocation();
  const { isAdmin, user } = usePermissions();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleLogout = async () => {
    try {
      await supabase.auth.signOut();
      window.location.href = '/login';
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
    }
  };

  const navigationItems = [
    {
      name: 'Dashboard',
      href: '/admin/dashboard',
      icon: LayoutDashboard,
      permission: 'administracao.dashboard'
    },
    {
      name: 'Usuários',
      href: '/admin/usuarios',
      icon: Users,
      permission: 'administracao.usuarios'
    },
    {
      name: 'Funções & Permissões',
      href: '/admin/funcoes-permissoes',
      icon: Shield,
      permission: 'administracao.funcoes'
    },
    {
      name: 'Backups',
      href: '/admin/backups',
      icon: Database,
      permission: 'administracao.backups'
    },
    {
      name: 'Configurações',
      href: '/admin/configuracoes',
      icon: Settings,
      permission: 'administracao.sistema'
    }
  ];

  // REGRA: Todo cliente que comprou o sistema é admin da sua empresa
  // Removido bloqueio - usuário logado tem acesso total
  console.log('🔓 AdminLayout: Acesso liberado - cliente é admin da empresa');

  return (
    <div className="h-screen flex overflow-hidden bg-gray-100">
      {/* Sidebar */}
      <div className={`${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      } fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0`}>
        
        {/* Header do Sidebar */}
        <div className="flex items-center justify-between h-16 px-6 border-b border-gray-200">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <Building className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-semibold text-gray-900">Admin</h1>
              <p className="text-xs text-gray-500">Sistema PDV</p>
            </div>
          </div>
          
          <button
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden p-1 rounded-md text-gray-400 hover:text-gray-600"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Navegação */}
        <nav className="flex-1 px-4 py-6 space-y-1">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.href;
            
            return (
              <Link
                key={item.name}
                to={item.href}
                onClick={() => setSidebarOpen(false)}
                className={`${
                  isActive
                    ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-600'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                } group flex items-center px-3 py-2 text-sm font-medium rounded-l-lg transition-colors`}
              >
                <Icon className={`${
                  isActive ? 'text-blue-600' : 'text-gray-400 group-hover:text-gray-600'
                } mr-3 flex-shrink-0 h-5 w-5`} />
                {item.name}
                {isActive && (
                  <ChevronRight className="ml-auto h-4 w-4 text-blue-600" />
                )}
              </Link>
            );
          })}
        </nav>

        {/* Footer do Sidebar - Informações do usuário */}
        <div className="flex-shrink-0 px-4 py-4 border-t border-gray-200">
          <div className="flex items-center gap-3 px-3 py-2 rounded-lg bg-gray-50">
            <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <User className="w-4 h-4 text-blue-600" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">
                {user?.email || 'Administrador'}
              </p>
              <p className="text-xs text-gray-500">
                Super Admin
              </p>
            </div>
          </div>
          
          <button
            onClick={handleLogout}
            className="w-full mt-3 flex items-center gap-2 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors"
          >
            <LogOut className="w-4 h-4" />
            Sair
          </button>
        </div>
      </div>

      {/* Overlay para mobile */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-gray-600 bg-opacity-75 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Conteúdo principal */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="flex items-center justify-between h-16 px-6">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden p-1 rounded-md text-gray-400 hover:text-gray-600"
              >
                <Menu className="w-6 h-6" />
              </button>
              
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  {(() => {
                    const currentItem = navigationItems.find(item => item.href === location.pathname);
                    return currentItem ? currentItem.name : 'Administração';
                  })()}
                </h2>
                <p className="text-sm text-gray-500">
                  Painel de controle administrativo
                </p>
              </div>
            </div>

            {/* Breadcrumb */}
            <nav className="hidden md:flex items-center space-x-2 text-sm text-gray-500">
              <Link to="/admin/dashboard" className="hover:text-gray-700">
                Admin
              </Link>
              <ChevronRight className="w-4 h-4" />
              <span className="text-gray-900">
                {(() => {
                  const currentItem = navigationItems.find(item => item.href === location.pathname);
                  return currentItem ? currentItem.name : 'Dashboard';
                })()}
              </span>
            </nav>
          </div>
        </header>

        {/* Conteúdo da página */}
        <main className="flex-1 overflow-y-auto bg-gray-50">
          {children || <Outlet />}
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;