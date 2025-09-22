import React, { useState } from 'react';
import { 
  ArrowLeft,
  Send,
  User,
  Phone,
  Mail,
  Shield,
  CheckCircle
} from 'lucide-react';
import type { Funcao } from '../../types/admin';

interface InviteUserFullPageProps {
  funcoes: Funcao[];
  onInvite: (userData: { email: string; nome?: string; telefone?: string; funcaoIds: string[] }) => Promise<void>;
  onBack: () => void;
}

const InviteUserFullPage: React.FC<InviteUserFullPageProps> = ({ funcoes, onInvite, onBack }) => {
  const [email, setEmail] = useState('');
  const [nome, setNome] = useState('');
  const [telefone, setTelefone] = useState('');
  const [selectedFuncoes, setSelectedFuncoes] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email || selectedFuncoes.length === 0) {
      alert('Preencha o e-mail e selecione pelo menos uma função.');
      return;
    }

    setLoading(true);
    try {
      await onInvite({
        email,
        nome: nome || undefined,
        telefone: telefone || undefined,
        funcaoIds: selectedFuncoes
      });
    } catch (error) {
      // Erro já tratado na função onInvite
    } finally {
      setLoading(false);
    }
  };

  const toggleFuncao = (funcaoId: string) => {
    setSelectedFuncoes(prev =>
      prev.includes(funcaoId)
        ? prev.filter(id => id !== funcaoId)
        : [...prev, funcaoId]
    );
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={onBack}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-800 mb-4"
          >
            <ArrowLeft className="w-4 h-4" />
            Voltar para Usuários
          </button>
          
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Convidar Novo Funcionário
            </h1>
            <p className="text-gray-600">
              Adicione um novo membro à sua equipe
            </p>
          </div>
        </div>

        {/* Formulário */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Informações Pessoais */}
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <User className="w-5 h-5 text-blue-600" />
              Informações Pessoais
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nome Completo
                </label>
                <input
                  type="text"
                  value={nome}
                  onChange={(e) => setNome(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Digite o nome completo"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  <Phone className="w-4 h-4 inline mr-1" />
                  Telefone
                </label>
                <input
                  type="tel"
                  value={telefone}
                  onChange={(e) => setTelefone(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="(17) 99999-9999"
                />
              </div>
            </div>

            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                <Mail className="w-4 h-4 inline mr-1" />
                E-mail de Acesso *
              </label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="funcionario@empresa.com"
              />
              <p className="text-sm text-gray-500 mt-1">
                Será enviado um convite para este e-mail
              </p>
            </div>
          </div>

          {/* Funções e Permissões */}
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Shield className="w-5 h-5 text-green-600" />
              Funções e Permissões *
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              {funcoes.map((funcao) => (
                <div
                  key={funcao.id}
                  onClick={() => toggleFuncao(funcao.id)}
                  className={`
                    p-4 border rounded-lg cursor-pointer transition-all duration-200 hover:shadow-md
                    ${selectedFuncoes.includes(funcao.id)
                      ? 'border-blue-500 bg-blue-50 shadow-sm'
                      : 'border-gray-200 hover:border-gray-300'
                    }
                  `}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-medium text-gray-900 mb-1">
                        {funcao.nome}
                      </h3>
                      <p className="text-sm text-gray-500">
                        {funcao.descricao}
                      </p>
                    </div>
                    {selectedFuncoes.includes(funcao.id) && (
                      <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                    )}
                  </div>
                </div>
              ))}
            </div>

            {selectedFuncoes.length > 0 && (
              <div className="text-sm text-green-600 font-medium">
                ✓ {selectedFuncoes.length} função(ões) selecionada(s)
              </div>
            )}
          </div>

          {/* Botões de Ação */}
          <div className="flex flex-col sm:flex-row gap-4 justify-end">
            <button
              type="button"
              onClick={onBack}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </button>
            
            <button
              type="submit"
              disabled={loading || !email || selectedFuncoes.length === 0}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-lg hover:from-blue-700 hover:to-blue-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 font-medium flex items-center gap-2"
            >
              {loading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  Enviando...
                </>
              ) : (
                <>
                  <Send className="w-4 h-4" />
                  Enviar Convite
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default InviteUserFullPage;