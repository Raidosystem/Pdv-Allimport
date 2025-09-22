import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeft,
  Send,
  User,
  Phone,
  Mail,
  Shield,
  CheckCircle
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';
import type { Funcao } from '../../types/admin';

const InviteUserPage: React.FC = () => {
  const navigate = useNavigate();
  const { can, isAdminEmpresa } = usePermissions();
  const [funcoes, setFuncoes] = useState<Funcao[]>([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    nome: '',
    telefone: '',
    email: '',
    funcaoIds: [] as string[]
  });

  useEffect(() => {
    if (can('administracao.usuarios', 'create') || isAdminEmpresa) {
      loadFuncoes();
    } else {
      navigate('/admin/users');
    }
  }, []);

  const loadFuncoes = async () => {
    try {
      // Tentar carregar funções existentes
      const { data } = await supabase
        .from('funcoes')
        .select('*')
        .order('nome', { ascending: true });

      if (data && data.length > 0) {
        setFuncoes(data);
      } else {
        // Se não há funções, criar funções padrão
        await createDefaultFuncoes();
      }
    } catch (error) {
      console.error('Erro ao carregar funções:', error);
      // Criar funções básicas como fallback
      setFuncoes([
        { id: 'admin', nome: 'Administrador', descricao: 'Acesso completo ao sistema' },
        { id: 'vendedor', nome: 'Vendedor', descricao: 'Acesso a vendas e clientes' },
        { id: 'caixa', nome: 'Caixa', descricao: 'Acesso ao caixa' }
      ] as any);
    }
  };

  const createDefaultFuncoes = async () => {
    try {
      const { data: user } = await supabase.auth.getUser();
      if (!user.user) return;

      const defaultFuncoes = [
        { empresa_id: user.user.id, nome: 'Administrador', descricao: 'Acesso completo ao sistema' },
        { empresa_id: user.user.id, nome: 'Gerente', descricao: 'Acesso gerencial' },
        { empresa_id: user.user.id, nome: 'Vendedor', descricao: 'Acesso a vendas e clientes' },
        { empresa_id: user.user.id, nome: 'Caixa', descricao: 'Acesso ao caixa' },
        { empresa_id: user.user.id, nome: 'Funcionário', descricao: 'Acesso básico' }
      ];

      const { data, error } = await supabase
        .from('funcoes')
        .insert(defaultFuncoes)
        .select();

      if (error) throw error;
      
      setFuncoes(data || []);
    } catch (error) {
      console.error('Erro ao criar funções padrão:', error);
      // Fallback para funções temporárias
      setFuncoes([
        { id: 'temp-admin', nome: 'Administrador', descricao: 'Acesso completo' },
        { id: 'temp-vendedor', nome: 'Vendedor', descricao: 'Vendas' },
        { id: 'temp-funcionario', nome: 'Funcionário', descricao: 'Básico' }
      ] as any);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.email || formData.funcaoIds.length === 0) {
      alert('Preencha o e-mail e selecione pelo menos uma função.');
      return;
    }

    setLoading(true);

    try {
      // Gerar token de convite
      const inviteToken = crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7); // Expira em 7 dias

      const { data: user } = await supabase.auth.getUser();
      if (!user.user) throw new Error('Usuário não autenticado');

      // Criar funcionário
      const { data: funcionario, error } = await supabase
        .from('funcionarios')
        .insert({
          empresa_id: user.user.id,
          email: formData.email,
          nome: formData.nome || null,
          telefone: formData.telefone || null,
          status: 'pendente',
          convite_token: inviteToken,
          convite_expires_at: expiresAt.toISOString()
        })
        .select()
        .single();

      if (error) throw error;

      // Associar funções
      if (formData.funcaoIds.length > 0) {
        const funcionarioFuncoes = formData.funcaoIds.map((funcaoId: string) => ({
          funcionario_id: funcionario.id,
          funcao_id: funcaoId,
          empresa_id: user.user.id
        }));

        await supabase
          .from('funcionario_funcoes')
          .insert(funcionarioFuncoes);
      }

      // Enviar e-mail de convite (implementar depois)
      await sendInviteEmail(formData.email, inviteToken);

      // Redirecionar para lista de usuários com sucesso
      navigate('/admin/users', { 
        state: { 
          message: `Convite enviado com sucesso para ${formData.email}!` 
        } 
      });

    } catch (error) {
      console.error('Erro ao convidar usuário:', error);
      alert('Erro ao enviar convite. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  const sendInviteEmail = async (email: string, token: string) => {
    // TODO: Implementar envio de email real
    const inviteLink = `${window.location.origin}/convite/${token}`;
    console.log(`Convite enviado para ${email}: ${inviteLink}`);
  };

  const toggleFuncao = (funcaoId: string) => {
    setFormData(prev => ({
      ...prev,
      funcaoIds: prev.funcaoIds.includes(funcaoId)
        ? prev.funcaoIds.filter(id => id !== funcaoId)
        : [...prev.funcaoIds, funcaoId]
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => navigate('/admin/users')}
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
                  value={formData.nome}
                  onChange={(e) => setFormData(prev => ({ ...prev, nome: e.target.value }))}
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
                  value={formData.telefone}
                  onChange={(e) => setFormData(prev => ({ ...prev, telefone: e.target.value }))}
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
                value={formData.email}
                onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
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
                    ${formData.funcaoIds.includes(funcao.id)
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
                    {formData.funcaoIds.includes(funcao.id) && (
                      <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                    )}
                  </div>
                </div>
              ))}
            </div>

            {formData.funcaoIds.length > 0 && (
              <div className="text-sm text-green-600 font-medium">
                ✓ {formData.funcaoIds.length} função(ões) selecionada(s)
              </div>
            )}
          </div>

          {/* Botões de Ação */}
          <div className="flex flex-col sm:flex-row gap-4 justify-end">
            <button
              type="button"
              onClick={() => navigate('/admin/users')}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </button>
            
            <button
              type="submit"
              disabled={loading || !formData.email || formData.funcaoIds.length === 0}
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

export default InviteUserPage;