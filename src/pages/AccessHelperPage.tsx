import React from 'react';
import { ArrowLeft } from 'lucide-react';
import AccessFixer from '../components/AccessFixer';
import PermissionsDebugger from '../components/PermissionsDebugger';

const AccessHelperPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-4">
              <button
                onClick={() => window.history.back()}
                className="p-2 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <div>
                <h1 className="text-xl font-semibold text-gray-900">
                  Assistente de Acesso
                </h1>
                <p className="text-sm text-gray-500">
                  Resolva problemas de acesso ao sistema
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-8">
          {/* Seção de Correção Automática */}
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">
                Correção Automática de Acesso
              </h2>
              <p className="text-gray-600 mt-1">
                Use esta ferramenta para configurar automaticamente suas permissões administrativas.
              </p>
            </div>
            <div className="p-6">
              <AccessFixer onFixed={() => {
                setTimeout(() => {
                  window.location.href = '/admin';
                }, 3000);
              }} />
            </div>
          </div>

          {/* Seção de Debug Avançado */}
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">
                Diagnóstico Avançado
              </h2>
              <p className="text-gray-600 mt-1">
                Ferramenta de debug para desenvolvedores e administradores técnicos.
              </p>
            </div>
            <div className="p-6">
              <PermissionsDebugger />
            </div>
          </div>

          {/* Instruções Manuais */}
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">
                Instruções Manuais
              </h2>
              <p className="text-gray-600 mt-1">
                Se a correção automática não funcionar, siga estas instruções.
              </p>
            </div>
            <div className="p-6">
              <div className="prose max-w-none">
                <h3 className="text-base font-semibold text-gray-900 mb-3">
                  Para corrigir manualmente via SQL:
                </h3>
                <ol className="list-decimal list-inside space-y-2 text-gray-700">
                  <li>Acesse o Supabase Dashboard</li>
                  <li>Vá para SQL Editor</li>
                  <li>Execute o script <code className="bg-gray-100 px-2 py-1 rounded">quick-admin-fix.sql</code></li>
                  <li>Substitua 'SEU_EMAIL_AQUI' pelo seu email</li>
                  <li>Execute o script</li>
                  <li>Recarregue a página</li>
                </ol>

                <h3 className="text-base font-semibold text-gray-900 mb-3 mt-6">
                  Estrutura de Permissões:
                </h3>
                <ul className="list-disc list-inside space-y-1 text-gray-700">
                  <li><strong>Empresas:</strong> Representam organizações no sistema</li>
                  <li><strong>Funcionários:</strong> Usuários vinculados a empresas</li>
                  <li><strong>Funções:</strong> Conjuntos de permissões (ex: Administrador)</li>
                  <li><strong>Permissões:</strong> Ações específicas no sistema</li>
                </ul>

                <h3 className="text-base font-semibold text-gray-900 mb-3 mt-6">
                  Tipos de Admin:
                </h3>
                <ul className="list-disc list-inside space-y-1 text-gray-700">
                  <li><strong>super_admin:</strong> Acesso total (desenvolvedores)</li>
                  <li><strong>admin_empresa:</strong> Admin da empresa (clientes)</li>
                  <li><strong>funcionario:</strong> Usuário comum</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AccessHelperPage;