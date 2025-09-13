import { AlertTriangle, CheckCircle, RefreshCw, User, Database, Settings } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from '../ui/Button';
import { Card } from '../ui/Card';

interface QuickFixProps {
  onRetryLogin?: () => void;
}

export function QuickFix({ onRetryLogin }: QuickFixProps) {
  const commonProblems = [
    {
      problem: "Usuário não autenticado",
      icon: <User className="w-5 h-5 text-orange-600" />,
      solutions: [
        "Faça login com suas credenciais de acesso",
        "Verifique se sua conta está aprovada pelo administrador",
        "Verifique se está usando o email e senha corretos"
      ]
    },
    {
      problem: "Erro de conexão com o banco",
      icon: <Database className="w-5 h-5 text-red-600" />,
      solutions: [
        "Execute o script SQL completo no Supabase",
        "Verifique se as tabelas 'categories' e 'caixa' existem",
        "Confirme se o projeto Supabase está ativo"
      ]
    },
    {
      problem: "Configuração incorreta",
      icon: <Settings className="w-5 h-5 text-yellow-600" />,
      solutions: [
        "Verifique o arquivo .env na raiz do projeto",
        "Confirme se VITE_SUPABASE_URL está correto",
        "Confirme se VITE_SUPABASE_ANON_KEY está correto"
      ]
    }
  ];

  return (
    <Card className="p-6 bg-gradient-to-r from-orange-50 to-red-50 border-orange-200">
      <div className="flex items-center gap-3 mb-4">
        <AlertTriangle className="w-6 h-6 text-orange-600" />
        <h3 className="text-lg font-semibold text-orange-800">
          Soluções Rápidas para Problemas Comuns
        </h3>
      </div>

      <div className="space-y-4 mb-6">
        {commonProblems.map((item, index) => (
          <div key={index} className="bg-white rounded-lg p-4 border border-orange-200">
            <div className="flex items-center gap-3 mb-2">
              {item.icon}
              <h4 className="font-medium text-gray-800">{item.problem}</h4>
            </div>
            <ul className="space-y-1 text-sm text-gray-600">
              {item.solutions.map((solution, sIndex) => (
                <li key={sIndex} className="flex items-start gap-2">
                  <span className="text-orange-500 mt-1">•</span>
                  <span>{solution}</span>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-3 justify-center">
        <Link to="/test-login">
          <Button className="gap-2 bg-green-600 hover:bg-green-700">
            <CheckCircle className="w-4 h-4" />
            Testar Login
          </Button>
        </Link>
        
        <Link to="/diagnostic">
          <Button variant="outline" className="gap-2 border-orange-300 text-orange-700 hover:bg-orange-50">
            <Settings className="w-4 h-4" />
            Diagnóstico Completo
          </Button>
        </Link>
        
        {onRetryLogin && (
          <Button onClick={onRetryLogin} variant="outline" className="gap-2">
            <RefreshCw className="w-4 h-4" />
            Tentar Novamente
          </Button>
        )}
        
        <Button 
          onClick={() => window.location.reload()} 
          variant="outline" 
          className="gap-2"
        >
          <RefreshCw className="w-4 h-4" />
          Recarregar Página
        </Button>
      </div>
    </Card>
  );
}
