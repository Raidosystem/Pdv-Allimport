import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Eye, EyeOff, Lock, AlertCircle, CheckCircle2 } from 'lucide-react';
import toast from 'react-hot-toast';

interface LocationState {
  funcionarioId: string;
  email: string;
  isFirstLogin: boolean;
}

export default function TrocarSenhaPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state as LocationState;

  const [senhaAtual, setSenhaAtual] = useState('');
  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [mostrarSenhaAtual, setMostrarSenhaAtual] = useState(false);
  const [mostrarNovaSenha, setMostrarNovaSenha] = useState(false);
  const [mostrarConfirmarSenha, setMostrarConfirmarSenha] = useState(false);
  const [loading, setLoading] = useState(false);

  // Validações em tempo real
  const senhaTemTamanhoMinimo = novaSenha.length >= 6;
  const senhasConferem = novaSenha === confirmarSenha && confirmarSenha.length > 0;
  const formularioValido = senhaAtual.length >= 6 && senhaTemTamanhoMinimo && senhasConferem;

  const handleTrocarSenha = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!state?.funcionarioId) {
      toast.error('Sessão inválida. Faça login novamente.');
      navigate('/funcionarios/login');
      return;
    }

    if (!formularioValido) {
      toast.error('Preencha todos os campos corretamente');
      return;
    }

    setLoading(true);

    try {
      console.log('🔑 Trocando senha própria do funcionário:', state.funcionarioId);

      // Chamar RPC para trocar senha (valida senha antiga internamente)
      const { data, error } = await supabase.rpc('trocar_senha_propria', {
        p_funcionario_id: state.funcionarioId,
        p_senha_antiga: senhaAtual,
        p_senha_nova: novaSenha
      });

      if (error) {
        console.error('❌ Erro ao trocar senha:', error);
        
        // Tratamento específico por tipo de erro
        if (error.code === 'PGRST202') {
          toast.error('❌ Função de troca de senha não encontrada. Contate o administrador.');
        } else if (error.message.includes('Senha antiga incorreta') || error.message.includes('Senha atual incorreta')) {
          toast.error('❌ Senha atual incorreta');
        } else if (error.message.includes('6 caracteres')) {
          toast.error('❌ A nova senha deve ter pelo menos 6 caracteres');
        } else {
          toast.error('❌ Erro ao trocar senha: ' + error.message);
        }
        
        setLoading(false);
        return; // 🔥 PARE AQUI - não continue se houver erro!
      }

      // Verificar se a resposta indica sucesso
      if (data && typeof data === 'object' && 'success' in data && !data.success) {
        console.error('❌ Erro retornado pela função:', data);
        toast.error('❌ ' + (data.error || 'Erro ao trocar senha'));
        setLoading(false);
        return;
      }

      console.log('✅ Senha trocada com sucesso!');
      console.log('📦 Resposta da função:', data);
      
      toast.success(
        state.isFirstLogin 
          ? '🎉 Senha definida com sucesso! Faça login novamente com sua nova senha.'
          : '✅ Senha alterada com sucesso! Faça login novamente.'
      , { duration: 3000 });

      // 🔥 CRÍTICO: Fazer logout completo da sessão Supabase
      // Isso garante que o LocalLoginPage não confunda com sessões antigas
      console.log('🚪 Fazendo logout da sessão Supabase...');
      
      // Limpar localStorage antes do logout
      localStorage.removeItem('pdv_local_session');
      localStorage.removeItem('funcionario_id');
      
      // Aguardar um pouco para mostrar a mensagem, depois fazer logout
      setTimeout(async () => {
        try {
          await supabase.auth.signOut();
          console.log('✅ Logout concluído');
          
          // Redirecionar para login principal (não funcionários/login)
          navigate('/login', { replace: true });
        } catch (error) {
          console.error('❌ Erro ao fazer logout:', error);
          // Mesmo com erro, redirecionar
          navigate('/login', { replace: true });
        }
      }, 2000);

    } catch (error) {
      console.error('❌ Erro inesperado ao trocar senha:', error);
      toast.error('❌ Erro inesperado. Tente novamente.');
      setLoading(false);
    }
  };

  const handleCancelar = () => {
    // Se é primeiro login, não pode cancelar - faz logout
    if (state?.isFirstLogin) {
      toast.error('Você precisa definir uma senha antes de continuar');
      navigate('/funcionarios/login', { replace: true });
    } else {
      navigate(-1);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        {/* Header com ícone e mensagem */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-blue-100 rounded-full mb-4">
            <Lock className="w-8 h-8 text-blue-600" />
          </div>
          <h1 className="text-3xl font-bold text-gray-800 mb-2">
            {state?.isFirstLogin ? 'Defina sua Senha' : 'Trocar Senha'}
          </h1>
          <p className="text-gray-600">
            {state?.isFirstLogin 
              ? 'Por segurança, defina uma senha pessoal que só você saberá'
              : 'Altere sua senha para uma nova que só você saberá'
            }
          </p>
          {state?.email && (
            <p className="text-sm text-gray-500 mt-2">
              Usuário: <span className="font-medium">{state.email}</span>
            </p>
          )}
        </div>

        {/* Card do formulário */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <form onSubmit={handleTrocarSenha} className="space-y-6">
            {/* Senha Atual (temporária do admin) */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Senha {state?.isFirstLogin ? 'Temporária' : 'Atual'}
              </label>
              <div className="relative">
                <input
                  type={mostrarSenhaAtual ? 'text' : 'password'}
                  value={senhaAtual}
                  onChange={(e) => setSenhaAtual(e.target.value)}
                  placeholder={state?.isFirstLogin ? 'Senha fornecida pelo administrador' : 'Digite sua senha atual'}
                  className="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                />
                <button
                  type="button"
                  onClick={() => setMostrarSenhaAtual(!mostrarSenhaAtual)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {mostrarSenhaAtual ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              <p className="mt-1 text-xs text-gray-500">
                {state?.isFirstLogin 
                  ? 'Use a senha que o administrador te passou'
                  : 'Digite sua senha atual para confirmar'
                }
              </p>
            </div>

            {/* Nova Senha */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nova Senha
              </label>
              <div className="relative">
                <input
                  type={mostrarNovaSenha ? 'text' : 'password'}
                  value={novaSenha}
                  onChange={(e) => setNovaSenha(e.target.value)}
                  placeholder="Digite sua nova senha (mín. 6 caracteres)"
                  className={`w-full px-4 py-3 pr-12 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                    novaSenha.length > 0 && !senhaTemTamanhoMinimo 
                      ? 'border-red-300 bg-red-50' 
                      : 'border-gray-300'
                  }`}
                  required
                  minLength={6}
                />
                <button
                  type="button"
                  onClick={() => setMostrarNovaSenha(!mostrarNovaSenha)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {mostrarNovaSenha ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              {/* Indicador de força da senha */}
              <div className="mt-2 space-y-1">
                <div className="flex items-center gap-2 text-xs">
                  {senhaTemTamanhoMinimo ? (
                    <CheckCircle2 className="w-4 h-4 text-green-500" />
                  ) : (
                    <AlertCircle className="w-4 h-4 text-gray-400" />
                  )}
                  <span className={senhaTemTamanhoMinimo ? 'text-green-600' : 'text-gray-500'}>
                    Mínimo 6 caracteres
                  </span>
                </div>
              </div>
            </div>

            {/* Confirmar Senha */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Confirmar Nova Senha
              </label>
              <div className="relative">
                <input
                  type={mostrarConfirmarSenha ? 'text' : 'password'}
                  value={confirmarSenha}
                  onChange={(e) => setConfirmarSenha(e.target.value)}
                  placeholder="Digite novamente sua nova senha"
                  className={`w-full px-4 py-3 pr-12 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                    confirmarSenha.length > 0 && !senhasConferem 
                      ? 'border-red-300 bg-red-50' 
                      : 'border-gray-300'
                  }`}
                  required
                />
                <button
                  type="button"
                  onClick={() => setMostrarConfirmarSenha(!mostrarConfirmarSenha)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {mostrarConfirmarSenha ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
              {confirmarSenha.length > 0 && (
                <div className="mt-2 flex items-center gap-2 text-xs">
                  {senhasConferem ? (
                    <>
                      <CheckCircle2 className="w-4 h-4 text-green-500" />
                      <span className="text-green-600">Senhas conferem</span>
                    </>
                  ) : (
                    <>
                      <AlertCircle className="w-4 h-4 text-red-500" />
                      <span className="text-red-600">Senhas não conferem</span>
                    </>
                  )}
                </div>
              )}
            </div>

            {/* Aviso de segurança */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex gap-3">
                <Lock className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="text-sm text-blue-800">
                  <strong>Privacidade garantida:</strong> Sua senha é criptografada e ninguém 
                  (nem administradores) terá acesso a ela.
                </div>
              </div>
            </div>

            {/* Botões */}
            <div className="flex gap-3 pt-2">
              {!state?.isFirstLogin && (
                <button
                  type="button"
                  onClick={handleCancelar}
                  disabled={loading}
                  className="flex-1 px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition-colors disabled:opacity-50"
                >
                  Cancelar
                </button>
              )}
              <button
                type="submit"
                disabled={!formularioValido || loading}
                className={`px-4 py-3 bg-blue-600 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                  state?.isFirstLogin ? 'w-full' : 'flex-1'
                } ${formularioValido && !loading ? 'hover:bg-blue-700' : ''}`}
              >
                {loading ? 'Salvando...' : state?.isFirstLogin ? 'Definir Senha e Continuar' : 'Salvar Nova Senha'}
              </button>
            </div>
          </form>
        </div>

        {/* Footer */}
        <p className="text-center text-sm text-gray-500 mt-6">
          Lembre-se de escolher uma senha forte e única
        </p>
      </div>
    </div>
  );
}
