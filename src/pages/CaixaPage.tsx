import { useState } from 'react';
import { 
  DollarSign, 
  Plus, 
  Lock, 
  History,
  AlertCircle,
  RefreshCw
} from 'lucide-react';
import { useCaixa } from '../hooks/useCaixa';
import { StatusCaixa } from '../components/caixa/StatusCaixa';
import { AberturaCaixaModal } from '../components/caixa/AberturaCaixaModal';
import { FechamentoCaixaModal } from '../components/caixa/FechamentoCaixaModal';
import { MovimentacoesCaixa } from '../components/caixa/MovimentacoesCaixa';
import type { AberturaCaixaForm, FechamentoCaixaForm, MovimentacaoForm } from '../types/caixa';

export function CaixaPage() {
  const [showAbertura, setShowAbertura] = useState(false);
  const [showFechamento, setShowFechamento] = useState(false);

  const {
    caixaAtual,
    loading,
    error,
    abrirCaixa,
    fecharCaixa,
    adicionarMovimentacao,
    carregarCaixaAtual,
    verificarCaixaAberto
  } = useCaixa();

  // Handlers
  const handleAbrirCaixa = async (dados: AberturaCaixaForm): Promise<boolean> => {
    return await abrirCaixa(dados);
  };

  const handleFecharCaixa = async (dados: FechamentoCaixaForm): Promise<boolean> => {
    if (!caixaAtual) return false;
    return await fecharCaixa(caixaAtual.id, dados);
  };

  const handleAdicionarMovimentacao = async (dados: MovimentacaoForm): Promise<boolean> => {
    if (!caixaAtual) return false;
    return await adicionarMovimentacao(caixaAtual.id, dados);
  };

  const caixaAberto = verificarCaixaAberto();

  return (
    <div className="min-h-screen bg-gray-50 p-4 md:p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
                <div className="bg-orange-500 p-3 rounded-xl">
                  <DollarSign className="w-8 h-8 text-white" />
                </div>
                Controle de Caixa
              </h1>
              <p className="text-gray-600 mt-2">
                Gerencie abertura, movimentações e fechamento do caixa
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-3">
              {/* Botão Atualizar */}
              <button
                onClick={carregarCaixaAtual}
                disabled={loading}
                className="flex items-center justify-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors disabled:opacity-50"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                Atualizar
              </button>

              {/* Botão Abrir Caixa */}
              {!caixaAberto && (
                <button
                  onClick={() => setShowAbertura(true)}
                  className="flex items-center justify-center gap-2 px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  Abrir Caixa
                </button>
              )}

              {/* Botão Fechar Caixa */}
              {caixaAberto && (
                <button
                  onClick={() => setShowFechamento(true)}
                  className="flex items-center justify-center gap-2 px-6 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                >
                  <Lock className="w-4 h-4" />
                  Fechar Caixa
                </button>
              )}

              {/* Botão Histórico */}
              <button
                onClick={() => {/* TODO: Implementar histórico */}}
                className="flex items-center justify-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              >
                <History className="w-4 h-4" />
                Histórico
              </button>
            </div>
          </div>
        </div>

        {/* Mensagem de Erro */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            <div className="flex items-start gap-2">
              <AlertCircle className="w-5 h-5 text-red-600 mt-0.5" />
              <div>
                <h4 className="text-red-800 font-medium">Erro no sistema</h4>
                <p className="text-red-700 text-sm mt-1">{error}</p>
              </div>
            </div>
          </div>
        )}

        {/* Status do Caixa */}
        <div className="mb-8">
          <StatusCaixa caixa={caixaAtual} loading={loading} />
        </div>

        {/* Movimentações (só se caixa aberto) */}
        {caixaAberto && caixaAtual && (
          <div className="mb-8">
            <MovimentacoesCaixa
              movimentacoes={caixaAtual.movimentacoes || []}
              onAdicionarMovimentacao={handleAdicionarMovimentacao}
              loading={loading}
            />
          </div>
        )}

        {/* Cards de Ações Rápidas */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Card Abrir Caixa */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="text-center">
              <div className="bg-green-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <Plus className="w-8 h-8 text-green-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                Abertura de Caixa
              </h3>
              <p className="text-gray-600 text-sm mb-4">
                Inicie as operações do dia abrindo o caixa com valor inicial
              </p>
              <button
                onClick={() => setShowAbertura(true)}
                disabled={caixaAberto}
                className="w-full px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {caixaAberto ? 'Caixa já Aberto' : 'Abrir Caixa'}
              </button>
            </div>
          </div>

          {/* Card Movimentações */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="text-center">
              <div className="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <DollarSign className="w-8 h-8 text-blue-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                Movimentações
              </h3>
              <p className="text-gray-600 text-sm mb-4">
                Registre entradas e saídas de dinheiro durante o expediente
              </p>
              <div className="text-lg font-bold text-gray-900 mb-2">
                {caixaAtual ? `${caixaAtual.movimentacoes?.length || 0} registros` : '0 registros'}
              </div>
            </div>
          </div>

          {/* Card Fechamento */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="text-center">
              <div className="bg-red-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <Lock className="w-8 h-8 text-red-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                Fechamento
              </h3>
              <p className="text-gray-600 text-sm mb-4">
                Encerre o expediente fechando o caixa e conferindo valores
              </p>
              <button
                onClick={() => setShowFechamento(true)}
                disabled={!caixaAberto}
                className="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {!caixaAberto ? 'Caixa não Aberto' : 'Fechar Caixa'}
              </button>
            </div>
          </div>
        </div>

        {/* Dicas */}
        <div className="mt-8 p-6 bg-orange-50 border border-orange-200 rounded-xl">
          <h4 className="text-lg font-semibold text-orange-800 mb-3">
            💡 Dicas de Uso
          </h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-orange-700">
            <div>
              <h5 className="font-medium mb-1">🌅 Abertura de Caixa:</h5>
              <p>Sempre abra o caixa com o valor real disponível. Confira notas e moedas.</p>
            </div>
            <div>
              <h5 className="font-medium mb-1">💰 Movimentações:</h5>
              <p>Registre todas as entradas e saídas de dinheiro para maior controle.</p>
            </div>
            <div>
              <h5 className="font-medium mb-1">🔒 Fechamento:</h5>
              <p>Conte todo o dinheiro antes de fechar. Anote diferenças nas observações.</p>
            </div>
            <div>
              <h5 className="font-medium mb-1">📊 Relatórios:</h5>
              <p>Use o histórico para acompanhar a evolução financeira do negócio.</p>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      <AberturaCaixaModal
        isOpen={showAbertura}
        onClose={() => setShowAbertura(false)}
        onSubmit={handleAbrirCaixa}
        loading={loading}
      />

      {caixaAtual && (
        <FechamentoCaixaModal
          isOpen={showFechamento}
          onClose={() => setShowFechamento(false)}
          onSubmit={handleFecharCaixa}
          caixa={caixaAtual}
          loading={loading}
        />
      )}
    </div>
  );
}
