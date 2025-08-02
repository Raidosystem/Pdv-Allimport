import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { 
  Plus, 
  TrendingUp, 
  TrendingDown, 
  DollarSign,
  FileText,
  Calendar,
  Filter
} from 'lucide-react';
import type { MovimentacaoCaixa, MovimentacaoForm } from '../../types/caixa';

// Schema de validação
const movimentacaoSchema = z.object({
  tipo: z.enum(['entrada', 'saida'], {
    message: 'Selecione o tipo de movimentação'
  }),
  descricao: z.string()
    .min(3, 'Descrição deve ter pelo menos 3 caracteres')
    .max(255, 'Descrição muito longa'),
  valor: z.number()
    .min(0.01, 'Valor deve ser maior que zero')
    .max(999999.99, 'Valor muito alto')
});

interface MovimentacoesCaixaProps {
  movimentacoes: MovimentacaoCaixa[];
  onAdicionarMovimentacao: (dados: MovimentacaoForm) => Promise<boolean>;
  loading?: boolean;
}

export function MovimentacoesCaixa({ 
  movimentacoes, 
  onAdicionarMovimentacao, 
  loading = false 
}: MovimentacoesCaixaProps) {
  const [showForm, setShowForm] = useState(false);
  const [valorInput, setValorInput] = useState('');
  const [filtroTipo, setFiltroTipo] = useState<'todos' | 'entrada' | 'saida'>('todos');

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setValue,
    watch
  } = useForm<MovimentacaoForm>({
    resolver: zodResolver(movimentacaoSchema),
    defaultValues: {
      tipo: 'entrada',
      descricao: '',
      valor: 0
    }
  });

  const tipoSelecionado = watch('tipo');

  // Função para formatar valor monetário
  const formatarValor = (value: string) => {
    const numbers = value.replace(/\D/g, '');
    const valor = parseFloat(numbers) / 100;
    setValue('valor', valor);
    
    return valor.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  const handleValorChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarValor(e.target.value);
    setValorInput(formatted);
  };

  const handleFormSubmit = async (dados: MovimentacaoForm) => {
    const sucesso = await onAdicionarMovimentacao(dados);
    if (sucesso) {
      reset();
      setValorInput('');
      setShowForm(false);
    }
  };

  const formatarMoeda = (valor: number) => {
    return valor.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  const formatarDataHora = (data: string) => {
    return new Date(data).toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  // Filtrar movimentações
  const movimentacoesFiltradas = movimentacoes.filter(mov => {
    if (filtroTipo === 'todos') return true;
    return mov.tipo === filtroTipo;
  });

  // Calcular totais
  const totalEntradas = movimentacoes
    .filter(m => m.tipo === 'entrada')
    .reduce((sum, m) => sum + m.valor, 0);
  
  const totalSaidas = movimentacoes
    .filter(m => m.tipo === 'saida')
    .reduce((sum, m) => sum + m.valor, 0);

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-lg font-bold text-gray-900 flex items-center gap-2">
              <div className="p-2 bg-blue-100 rounded-lg">
                <FileText className="w-5 h-5 text-blue-600" />
              </div>
              Movimentações do Caixa
            </h3>
            <p className="text-gray-600 text-sm mt-1">
              Registre entradas e saídas de valores
            </p>
          </div>
          
          <button
            onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-2 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors"
          >
            <Plus className="w-4 h-4" />
            Nova Movimentação
          </button>
        </div>

        {/* Resumo */}
        <div className="grid grid-cols-3 gap-4">
          <div className="text-center p-3 bg-green-50 rounded-lg">
            <TrendingUp className="w-5 h-5 text-green-600 mx-auto mb-1" />
            <p className="text-sm text-green-600 font-medium">Entradas</p>
            <p className="text-lg font-bold text-green-700">{formatarMoeda(totalEntradas)}</p>
          </div>
          
          <div className="text-center p-3 bg-red-50 rounded-lg">
            <TrendingDown className="w-5 h-5 text-red-600 mx-auto mb-1" />
            <p className="text-sm text-red-600 font-medium">Saídas</p>
            <p className="text-lg font-bold text-red-700">{formatarMoeda(totalSaidas)}</p>
          </div>
          
          <div className="text-center p-3 bg-blue-50 rounded-lg">
            <DollarSign className="w-5 h-5 text-blue-600 mx-auto mb-1" />
            <p className="text-sm text-blue-600 font-medium">Líquido</p>
            <p className="text-lg font-bold text-blue-700">{formatarMoeda(totalEntradas - totalSaidas)}</p>
          </div>
        </div>
      </div>

      {/* Formulário de Nova Movimentação */}
      {showForm && (
        <div className="p-6 border-b border-gray-200 bg-gray-50">
          <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Tipo */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo *
                </label>
                <select
                  {...register('tipo')}
                  className={`
                    w-full px-3 py-2 border rounded-lg
                    focus:ring-2 focus:ring-orange-500 focus:border-orange-500
                    ${errors.tipo ? 'border-red-500' : 'border-gray-300'}
                  `}
                >
                  <option value="entrada">💰 Entrada</option>
                  <option value="saida">💸 Saída</option>
                </select>
                {errors.tipo && (
                  <p className="mt-1 text-sm text-red-600">{errors.tipo.message}</p>
                )}
              </div>

              {/* Valor */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Valor *
                </label>
                <input
                  type="text"
                  value={valorInput}
                  onChange={handleValorChange}
                  placeholder="R$ 0,00"
                  className={`
                    w-full px-3 py-2 border rounded-lg
                    focus:ring-2 focus:ring-orange-500 focus:border-orange-500
                    ${errors.valor ? 'border-red-500' : 'border-gray-300'}
                  `}
                />
                {errors.valor && (
                  <p className="mt-1 text-sm text-red-600">{errors.valor.message}</p>
                )}
              </div>

              {/* Descrição */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Descrição *
                </label>
                <input
                  {...register('descricao')}
                  type="text"
                  placeholder={
                    tipoSelecionado === 'entrada' 
                      ? 'Ex: Venda avulsa, Recebimento...' 
                      : 'Ex: Troco, Sangria, Despesa...'
                  }
                  className={`
                    w-full px-3 py-2 border rounded-lg
                    focus:ring-2 focus:ring-orange-500 focus:border-orange-500
                    ${errors.descricao ? 'border-red-500' : 'border-gray-300'}
                  `}
                />
                {errors.descricao && (
                  <p className="mt-1 text-sm text-red-600">{errors.descricao.message}</p>
                )}
              </div>
            </div>

            {/* Botões */}
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => {
                  setShowForm(false);
                  reset();
                  setValorInput('');
                }}
                className="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                {loading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                    Salvando...
                  </>
                ) : (
                  <>
                    <Plus className="w-4 h-4" />
                    Registrar
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Filtros */}
      <div className="p-4 border-b border-gray-200 bg-gray-50">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-gray-600" />
            <span className="text-sm font-medium text-gray-700">Filtrar por:</span>
          </div>
          
          <div className="flex gap-2">
            {[
              { valor: 'todos', label: 'Todos' },
              { valor: 'entrada', label: 'Entradas' },
              { valor: 'saida', label: 'Saídas' }
            ].map((filtro) => (
              <button
                key={filtro.valor}
                onClick={() => setFiltroTipo(filtro.valor as typeof filtroTipo)}
                className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                  filtroTipo === filtro.valor
                    ? 'bg-orange-500 text-white'
                    : 'bg-white text-gray-600 hover:bg-gray-100'
                }`}
              >
                {filtro.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Lista de Movimentações */}
      <div className="p-6">
        {movimentacoesFiltradas.length === 0 ? (
          <div className="text-center py-8">
            <div className="bg-gray-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
              <FileText className="w-8 h-8 text-gray-400" />
            </div>
            <h4 className="text-lg font-medium text-gray-900 mb-2">
              Nenhuma movimentação encontrada
            </h4>
            <p className="text-gray-500 text-sm">
              {filtroTipo === 'todos' 
                ? 'Registre a primeira movimentação do caixa'
                : `Nenhuma ${filtroTipo} registrada ainda`
              }
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {movimentacoesFiltradas.map((movimentacao) => (
              <div
                key={movimentacao.id}
                className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-lg ${
                    movimentacao.tipo === 'entrada' 
                      ? 'bg-green-100' 
                      : 'bg-red-100'
                  }`}>
                    {movimentacao.tipo === 'entrada' ? (
                      <TrendingUp className="w-4 h-4 text-green-600" />
                    ) : (
                      <TrendingDown className="w-4 h-4 text-red-600" />
                    )}
                  </div>
                  
                  <div>
                    <p className="font-medium text-gray-900">
                      {movimentacao.descricao}
                    </p>
                    <div className="flex items-center gap-2 text-sm text-gray-500">
                      <Calendar className="w-3 h-3" />
                      <span>{formatarDataHora(movimentacao.data)}</span>
                    </div>
                  </div>
                </div>
                
                <div className="text-right">
                  <p className={`text-lg font-bold ${
                    movimentacao.tipo === 'entrada' 
                      ? 'text-green-600' 
                      : 'text-red-600'
                  }`}>
                    {movimentacao.tipo === 'entrada' ? '+' : '-'}{formatarMoeda(movimentacao.valor)}
                  </p>
                  <p className="text-xs text-gray-500">
                    {movimentacao.tipo === 'entrada' ? 'Entrada' : 'Saída'}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
