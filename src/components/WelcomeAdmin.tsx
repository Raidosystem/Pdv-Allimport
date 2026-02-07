import React from 'react';
import { CheckCircle, Crown, ArrowRight, Users, Settings, BarChart3 } from 'lucide-react';

interface WelcomeAdminProps {
  onGetStarted?: () => void;
}

export const WelcomeAdmin: React.FC<WelcomeAdminProps> = ({ onGetStarted }) => {
  const features = [
    {
      icon: Users,
      title: 'Gerenciar Usuários',
      description: 'Controle quem tem acesso ao sistema e suas permissões',
      link: '/admin/ativar-usuarios'
    },
    {
      icon: Settings,
      title: 'Configurações',
      description: 'Personalize o sistema conforme suas necessidades',
      link: '/configuracoes'
    },
    {
      icon: BarChart3,
      title: 'Relatórios',
      description: 'Visualize dados e métricas importantes do negócio',
      link: '/relatorios'
    }
  ];

  return (
    <div className="max-w-4xl mx-auto p-6">
      {/* Header de Boas-vindas */}
      <div className="text-center mb-8">
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Crown className="w-10 h-10 text-green-600" />
        </div>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Bem-vindo à Área Administrativa!
        </h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          Agora você tem acesso completo ao sistema. Use as ferramentas administrativas 
          para gerenciar seu negócio de forma eficiente.
        </p>
      </div>

      {/* Status de Acesso */}
      <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-8 flex items-center gap-3">
        <CheckCircle className="w-6 h-6 text-green-600" />
        <div>
          <h3 className="font-semibold text-green-900">Acesso Administrativo Ativado</h3>
          <p className="text-green-700">
            Você agora tem permissões de administrador da empresa.
          </p>
        </div>
      </div>

      {/* Recursos Disponíveis */}
      <div className="mb-8">
        <h2 className="text-xl font-bold text-gray-900 mb-4">
          O que você pode fazer agora:
        </h2>
        <div className="grid md:grid-cols-3 gap-6">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <div key={index} className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow">
                <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
                  <Icon className="w-6 h-6 text-blue-600" />
                </div>
                <h3 className="font-semibold text-gray-900 mb-2">{feature.title}</h3>
                <p className="text-gray-600 text-sm mb-4">{feature.description}</p>
                <a
                  href={feature.link}
                  className="inline-flex items-center gap-2 text-blue-600 hover:text-blue-700 font-medium text-sm"
                >
                  Acessar
                  <ArrowRight className="w-4 h-4" />
                </a>
              </div>
            );
          })}
        </div>
      </div>

      {/* Próximos Passos */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h3 className="font-semibold text-blue-900 mb-3">Primeiros Passos Recomendados:</h3>
        <ol className="list-decimal list-inside text-blue-800 space-y-2">
          <li>Configure as informações da sua empresa</li>
          <li>Adicione outros usuários se necessário</li>
          <li>Explore os relatórios e métricas disponíveis</li>
          <li>Personalize as configurações do sistema</li>
        </ol>
        <div className="mt-4 flex gap-3">
          <button
            onClick={onGetStarted}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Começar Configuração
          </button>
          <a
            href="/admin"
            className="px-4 py-2 bg-white border border-blue-300 text-blue-700 rounded-lg hover:bg-blue-50 transition-colors"
          >
            Ir para Dashboard Admin
          </a>
        </div>
      </div>
    </div>
  );
};

export default WelcomeAdmin;