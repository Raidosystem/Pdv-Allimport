import { useState } from 'react';
import { X, Eye, EyeOff, Shield, Mail, Lock, User } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { supabase } from '../lib/supabase';
import { useAuth } from '../modules/auth';

interface AdminCreationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function AdminCreationModal({ isOpen, onClose, onSuccess }: AdminCreationModalProps) {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    nome: '',
    email: '',
    senha: '',
    confirmaSenha: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isCreating, setIsCreating] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validações
    if (!formData.nome.trim()) {
      toast.error('Nome é obrigatório');
      return;
    }

    if (!formData.email.trim()) {
      toast.error('Email é obrigatório');
      return;
    }

    if (!formData.email.includes('@')) {
      toast.error('Email inválido');
      return;
    }

    if (formData.senha.length < 8) {
      toast.error('Senha deve ter pelo menos 8 caracteres');
      return;
    }

    if (formData.senha !== formData.confirmaSenha) {
      toast.error('As senhas não coincidem');
      return;
    }

    setIsCreating(true);
    const loadingToast = toast.loading('Criando administrador principal...');

    try {
      if (!user) {
        throw new Error('Usuário não autenticado');
      }

      // 1. Buscar empresa_id do usuário
      const { data: empresaData, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .eq('user_id', user.id)
        .single();

      if (empresaError || !empresaData) {
        throw new Error('Empresa não encontrada');
      }

      // 2. Buscar função de Administrador
      const { data: funcaoAdmin, error: funcaoError } = await supabase
        .from('funcoes')
        .select('id')
        .eq('empresa_id', empresaData.id)
        .eq('nome', 'Administrador')
        .single();

      if (funcaoError || !funcaoAdmin) {
        throw new Error('Função de Administrador não encontrada');
      }

      // 3. Criar funcionário (trigger vai atribuir funcao_id automaticamente)
      const { data: funcionarioData, error: funcionarioError } = await supabase
        .from('funcionarios')
        .insert({
          empresa_id: empresaData.id,
          user_id: user.id,
          nome: formData.nome.trim(),
          email: formData.email.trim().toLowerCase(),
          senha_hash: formData.senha, // Em produção, isso deve ser hash no backend
          funcao_id: funcaoAdmin.id, // Passa o funcao_id correto
          status: 'ativo',
          ativo: true,
          usuario_ativo: true,
          senha_definida: true,
          primeiro_acesso: true
        })
        .select()
        .single();

      if (funcionarioError) {
        console.error('Erro ao criar funcionário:', funcionarioError);
        throw new Error(funcionarioError.message || 'Erro ao criar administrador');
      }

      toast.dismiss(loadingToast);
      toast.success('✅ Administrador principal criado com sucesso!');

      // Resetar form
      setFormData({
        nome: '',
        email: '',
        senha: '',
        confirmaSenha: ''
      });

      // Chamar callback de sucesso
      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('Erro ao criar administrador:', error);
      toast.dismiss(loadingToast);
      toast.error(error.message || 'Erro ao criar administrador');
    } finally {
      setIsCreating(false);
    }
  };

  const handleClose = () => {
    if (!isCreating) {
      setFormData({
        nome: '',
        email: '',
        senha: '',
        confirmaSenha: ''
      });
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20">
        {/* Backdrop */}
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm" 
          onClick={handleClose}
        />
        
        {/* Modal */}
        <div className="relative bg-white rounded-2xl shadow-2xl max-w-lg w-full">
          {/* Header */}
          <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-6 rounded-t-2xl">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center mr-4">
                  <Shield className="w-6 h-6" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold">Criar Administrador Principal</h2>
                  <p className="text-blue-100 mt-1 text-sm">
                    Este será o primeiro funcionário com acesso completo
                  </p>
                </div>
              </div>
              <button
                onClick={handleClose}
                disabled={isCreating}
                className="w-10 h-10 flex items-center justify-center rounded-full bg-white/20 hover:bg-white/30 transition-colors disabled:opacity-50"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="p-8">
            <div className="space-y-5">
              {/* Nome Completo */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  <div className="flex items-center">
                    <User className="w-4 h-4 mr-2 text-blue-600" />
                    Nome Completo *
                  </div>
                </label>
                <input
                  type="text"
                  value={formData.nome}
                  onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                  placeholder="Digite o nome completo"
                  disabled={isCreating}
                  required
                />
              </div>

              {/* Email */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  <div className="flex items-center">
                    <Mail className="w-4 h-4 mr-2 text-blue-600" />
                    Email *
                  </div>
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                  placeholder="email@exemplo.com"
                  disabled={isCreating}
                  required
                />
              </div>

              {/* Senha */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  <div className="flex items-center">
                    <Lock className="w-4 h-4 mr-2 text-blue-600" />
                    Senha *
                  </div>
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={formData.senha}
                    onChange={(e) => setFormData({ ...formData, senha: e.target.value })}
                    className="w-full px-4 py-3 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                    placeholder="Mínimo 8 caracteres"
                    disabled={isCreating}
                    required
                    minLength={8}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    disabled={isCreating}
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  A senha deve ter pelo menos 8 caracteres
                </p>
              </div>

              {/* Confirmar Senha */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  <div className="flex items-center">
                    <Lock className="w-4 h-4 mr-2 text-blue-600" />
                    Confirmar Senha *
                  </div>
                </label>
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={formData.confirmaSenha}
                  onChange={(e) => setFormData({ ...formData, confirmaSenha: e.target.value })}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors"
                  placeholder="Digite a senha novamente"
                  disabled={isCreating}
                  required
                />
              </div>
            </div>

            {/* Info Box */}
            <div className="mt-6 bg-blue-50 border-2 border-blue-200 rounded-xl p-4">
              <div className="flex items-start">
                <Shield className="w-5 h-5 text-blue-600 mt-0.5 mr-3 flex-shrink-0" />
                <div className="text-sm text-blue-900">
                  <p className="font-semibold mb-1">Importante:</p>
                  <ul className="space-y-1 text-blue-800">
                    <li>• Este será o administrador principal do sistema</li>
                    <li>• Terá acesso completo a todas as funcionalidades</li>
                    <li>• Poderá criar outros funcionários após esta etapa</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Botões */}
            <div className="flex gap-4 mt-8">
              <button
                type="button"
                onClick={handleClose}
                disabled={isCreating}
                className="flex-1 px-6 py-3 text-sm font-semibold text-gray-700 bg-gray-100 border-2 border-gray-200 rounded-xl hover:bg-gray-200 transition-all disabled:opacity-50"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={isCreating}
                className="flex-1 px-6 py-3 text-sm font-semibold text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl hover:from-blue-700 hover:to-blue-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                {isCreating ? (
                  <span className="flex items-center justify-center">
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                    Criando...
                  </span>
                ) : (
                  'Criar Administrador'
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
