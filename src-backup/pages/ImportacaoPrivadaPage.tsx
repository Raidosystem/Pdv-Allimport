import { useState } from 'react';
import { ImportadorPrivado } from '../utils/importador-privado';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Database, Upload, CheckCircle, AlertCircle, Shield, Users, Package, Wrench } from 'lucide-react';
import toast from 'react-hot-toast';
import { useAuth } from '../modules/auth/AuthContext';

export default function ImportacaoPrivadaPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  const [resultado, setResultado] = useState<{
    sucesso: boolean;
    total: number;
    detalhes: Record<string, number>;
    erros: string[];
  } | null>(null);

  const executarImportacaoAutomatica = async () => {
    if (!user) {
      toast.error('Você precisa estar logado para importar dados');
      return;
    }

    setLoading(true);
    setResultado(null);

    try {
      // Carregar o backup do arquivo no projeto
      const response = await fetch('/backup-allimport.json');
      if (!response.ok) {
        throw new Error('Arquivo de backup não encontrado no projeto');
      }
      
      const backupJson = await response.text();
      
      toast.success('Iniciando importação com privacidade total...');
      
      // Executar importação privada
      // Criar importador e executar
      const importador = new ImportadorPrivado(user.id);
      const resultado = await importador.importarBackup(backupJson);
      
      setResultado(resultado);
      
      if (resultado.sucesso) {
        toast.success(`🎉 ${resultado.total} registros importados com privacidade total!`);
      } else {
        toast.error(`Erro na importação: ${resultado.erros.join(', ')}`);
      }
      
    } catch (error) {
      console.error('Erro na importação:', error);
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
      toast.error(`Erro: ${errorMessage}`);
      
      setResultado({
        sucesso: false,
        total: 0,
        detalhes: {},
        erros: [errorMessage]
      });
    } finally {
      setLoading(false);
    }
  };

  const resetarImportacao = () => {
    setResultado(null);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <Shield className="w-8 h-8 text-green-600" />
              <div>
                <h1 className="text-xl font-bold">Importação Privada Allimport</h1>
                <p className="text-sm text-gray-600">Dados isolados por usuário</p>
              </div>
            </div>
            
            {user && (
              <div className="text-sm text-gray-600">
                <span className="font-medium">{user.email}</span>
              </div>
            )}
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto p-6 space-y-6">
        {/* Status da Importação */}
        {resultado ? (
          <Card className="p-6">
            {resultado.sucesso ? (
              <div className="text-center space-y-4">
                <CheckCircle className="w-16 h-16 text-green-500 mx-auto" />
                <h2 className="text-2xl font-bold text-green-800">
                  Importação Concluída!
                </h2>
                <p className="text-green-700">
                  {resultado.total} registros importados com total privacidade
                </p>
                
                {/* Detalhes por tabela */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                  {Object.entries(resultado.detalhes).map(([tabela, quantidade]) => {
                    const config = {
                      'clientes': { icon: Users, label: 'Clientes', color: 'text-blue-600 bg-blue-50' },
                      'products': { icon: Package, label: 'Produtos', color: 'text-green-600 bg-green-50' },
                      'categories': { icon: Database, label: 'Categorias', color: 'text-purple-600 bg-purple-50' },
                      'service_orders': { icon: Wrench, label: 'Ordens de Serviço', color: 'text-orange-600 bg-orange-50' },
                      'establishments': { icon: Database, label: 'Estabelecimentos', color: 'text-gray-600 bg-gray-50' }
                    }[tabela] || { icon: Database, label: tabela, color: 'text-gray-600 bg-gray-50' };
                    
                    const Icon = config.icon;
                    
                    return (
                      <div key={tabela} className={`p-4 rounded-lg ${config.color}`}>
                        <div className="flex items-center gap-2">
                          <Icon className="w-5 h-5" />
                          <div>
                            <div className="font-medium">{config.label}</div>
                            <div className="text-lg font-bold">{quantidade}</div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
                
                {/* Garantias de Privacidade */}
                <div className="mt-6 p-4 bg-green-50 border border-green-200 rounded-lg">
                  <h3 className="font-medium text-green-800 mb-2">🔒 Privacidade Garantida</h3>
                  <ul className="text-green-700 text-sm space-y-1 text-left">
                    <li>✅ Todos os dados estão vinculados ao seu usuário ({user?.email})</li>
                    <li>✅ RLS (Row Level Security) ativo - isolamento automático</li>
                    <li>✅ Outros usuários NUNCA verão estes dados</li>
                    <li>✅ Cada conta tem acesso apenas aos próprios dados</li>
                  </ul>
                </div>
                
                <div className="flex gap-3">
                  <Button 
                    onClick={resetarImportacao}
                    variant="outline"
                  >
                    Nova Importação
                  </Button>
                  <Button 
                    onClick={() => window.history.back()}
                    className="bg-blue-600 hover:bg-blue-700"
                  >
                    Voltar
                  </Button>
                </div>
              </div>
            ) : (
              <div className="text-center space-y-4">
                <AlertCircle className="w-16 h-16 text-red-500 mx-auto" />
                <h2 className="text-2xl font-bold text-red-800">
                  Erro na Importação
                </h2>
                <div className="text-red-700">
                  {resultado.erros.map((erro, index) => (
                    <p key={index}>• {erro}</p>
                  ))}
                </div>
                
                <Button 
                  onClick={resetarImportacao}
                  variant="outline"
                >
                  Tentar Novamente
                </Button>
              </div>
            )}
          </Card>
        ) : (
          /* Interface de Importação */
          <Card className="p-8">
            <div className="text-center space-y-6">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                <Database className="w-10 h-10 text-green-600" />
              </div>
              
              <div>
                <h2 className="text-2xl font-bold">Importar Backup Allimport</h2>
                <p className="text-gray-600 mt-2">
                  Importe todos os dados do sistema anterior com total privacidade
                </p>
              </div>
              
              {/* Dados a serem importados */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="p-3 bg-blue-50 rounded-lg">
                  <Users className="w-6 h-6 text-blue-600 mx-auto mb-1" />
                  <div className="text-sm font-medium text-blue-800">141 Clientes</div>
                </div>
                <div className="p-3 bg-green-50 rounded-lg">
                  <Package className="w-6 h-6 text-green-600 mx-auto mb-1" />
                  <div className="text-sm font-medium text-green-800">813 Produtos</div>
                </div>
                <div className="p-3 bg-orange-50 rounded-lg">
                  <Wrench className="w-6 h-6 text-orange-600 mx-auto mb-1" />
                  <div className="text-sm font-medium text-orange-800">160 Ordens</div>
                </div>
                <div className="p-3 bg-purple-50 rounded-lg">
                  <Database className="w-6 h-6 text-purple-600 mx-auto mb-1" />
                  <div className="text-sm font-medium text-purple-800">69 Categorias</div>
                </div>
              </div>
              
              {/* Garantias de Privacidade */}
              <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                <Shield className="w-6 h-6 text-green-600 mx-auto mb-2" />
                <h3 className="font-medium text-green-800 mb-2">Total Privacidade</h3>
                <ul className="text-green-700 text-sm space-y-1">
                  <li>🔒 Dados vinculados apenas ao seu usuário</li>
                  <li>👁️ Invisível para outros usuários</li>
                  <li>🛡️ Proteção RLS ativa</li>
                </ul>
              </div>
              
              <Button 
                onClick={executarImportacaoAutomatica}
                disabled={loading || !user}
                className="bg-green-600 hover:bg-green-700 text-white px-8 py-3 text-lg"
              >
                {loading ? (
                  <>
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                    Importando com Privacidade...
                  </>
                ) : (
                  <>
                    <Upload className="w-5 h-5 mr-2" />
                    Importar Backup Privado
                  </>
                )}
              </Button>
              
              {!user && (
                <p className="text-red-600 text-sm">
                  Você precisa estar logado para importar dados
                </p>
              )}
            </div>
          </Card>
        )}
        
        {/* Informações Técnicas */}
        <Card className="p-4">
          <h3 className="font-medium text-gray-800 mb-2">🔧 Como funciona a privacidade:</h3>
          <ul className="text-gray-600 text-sm space-y-1">
            <li>• Todos os registros recebem automaticamente o seu user_id</li>
            <li>• RLS (Row Level Security) impede acesso de outros usuários</li>
            <li>• Cada tabela filtra dados por usuário automaticamente</li>
            <li>• Sistema multi-tenant com isolamento completo</li>
          </ul>
        </Card>
      </div>
    </div>
  );
}
