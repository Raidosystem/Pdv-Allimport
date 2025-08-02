import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { 
  Lock, 
  DollarSign, 
  Calculator, 
  AlertTriangle,
  CheckCircle,
  FileText
} from 'lucide-react';
import type { FechamentoCaixaForm, CaixaCompleto } from '../../types/caixa';

// Schema de validação
const fechamentoCaixaSchema = z.object({
  valor_contado: z.number()
    .min(0, 'Valor deve ser maior ou igual a zero')
    .max(999999.99, 'Valor muito alto'),
  observacoes: z.string().optional()
});

interface FechamentoCaixaModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (dados: FechamentoCaixaForm) => Promise<boolean>;
  caixa: CaixaCompleto;
  loading?: boolean;
}

export function FechamentoCaixaModal({ 
  isOpen, 
  onClose, 
  onSubmit, 
  caixa,
  loading = false 
}: FechamentoCaixaModalProps) {
  const [valorInput, setValorInput] = useState('');
  const [diferenca, setDiferenca] = useState<number | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setValue,
    watch
  } = useForm<FechamentoCaixaForm>({
    resolver: zodResolver(fechamentoCaixaSchema),
    defaultValues: {
      valor_contado: 0,
      observacoes: ''
    }
  });

  const valorContado = watch('valor_contado');

  // Função para formatar valor monetário
  const formatarValor = (value: string) => {
    const numbers = value.replace(/\D/g, '');
    const valor = parseFloat(numbers) / 100;
    setValue('valor_contado', valor);
    
    // Calcular diferença
    const saldoEsperado = caixa.saldo_atual || 0;
    const diff = valor - saldoEsperado;
    setDiferenca(diff);
    
    return valor.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  const handleValorChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarValor(e.target.value);
    setValorInput(formatted);
  };

  const handleFormSubmit = async (dados: FechamentoCaixaForm) => {
    const sucesso = await onSubmit(dados);
    if (sucesso) {
      reset();
      setValorInput('');
      setDiferenca(null);
      onClose();
    }
  };

  const handleClose = () => {
    reset();
    setValorInput('');
    setDiferenca(null);
    onClose();
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
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (!isOpen) return null;

  const saldoEsperado = caixa.saldo_atual || 0;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-lg">
        {/* Header */}
        <div className="bg-red-500 text-white p-6 rounded-t-xl">
          <div className="flex items-center gap-3">
            <div className="bg-white bg-opacity-20 p-2 rounded-lg">
              <Lock className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-xl font-bold">Fechamento de Caixa</h2>
              <p className="text-red-100 text-sm">Confira os valores antes de fechar</p>
            </div>
          </div>
        </div>

        {/* Resumo do Caixa */}
        <div className="p-6 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Calculator className="w-5 h-5" />
            Resumo do Caixa
          </h3>
          
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div className="p-3 bg-blue-50 rounded-lg">
              <p className="text-sm text-blue-600 font-medium">Valor Inicial</p>
              <p className="text-lg font-bold text-blue-700">{formatarMoeda(caixa.valor_inicial)}</p>
            </div>
            
            <div className="p-3 bg-green-50 rounded-lg">
              <p className="text-sm text-green-600 font-medium">Total Entradas</p>
              <p className="text-lg font-bold text-green-700">{formatarMoeda(caixa.total_entradas || 0)}</p>
            </div>
            
            <div className="p-3 bg-red-50 rounded-lg">
              <p className="text-sm text-red-600 font-medium">Total Saídas</p>
              <p className="text-lg font-bold text-red-700">{formatarMoeda(caixa.total_saidas || 0)}</p>
            </div>
            
            <div className="p-3 bg-orange-50 rounded-lg">
              <p className="text-sm text-orange-600 font-medium">Saldo Esperado</p>
              <p className="text-lg font-bold text-orange-700">{formatarMoeda(saldoEsperado)}</p>
            </div>
          </div>

          <div className="text-sm text-gray-600">
            <p><strong>Aberto em:</strong> {formatarDataHora(caixa.data_abertura)}</p>
            <p><strong>Movimentações:</strong> {caixa.movimentacoes?.length || 0} registros</p>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit(handleFormSubmit)} className="p-6">
          {/* Valor Contado */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Valor Contado no Caixa *
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <DollarSign className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                value={valorInput}
                onChange={handleValorChange}
                placeholder="R$ 0,00"
                className={`
                  w-full pl-10 pr-4 py-3 border rounded-lg text-lg font-medium
                  focus:ring-2 focus:ring-red-500 focus:border-red-500
                  ${errors.valor_contado ? 'border-red-500' : 'border-gray-300'}
                `}
              />
            </div>
            {errors.valor_contado && (
              <p className="mt-1 text-sm text-red-600">
                {errors.valor_contado.message}
              </p>
            )}
          </div>

          {/* Diferença */}
          {diferenca !== null && (
            <div className={`mb-6 p-4 rounded-lg border ${
              diferenca === 0 
                ? 'bg-green-50 border-green-200' 
                : 'bg-yellow-50 border-yellow-200'
            }`}>
              <div className="flex items-center gap-2 mb-2">
                {diferenca === 0 ? (
                  <CheckCircle className="w-5 h-5 text-green-600" />
                ) : (
                  <AlertTriangle className="w-5 h-5 text-yellow-600" />
                )}
                <span className={`font-medium ${
                  diferenca === 0 ? 'text-green-800' : 'text-yellow-800'
                }`}>
                  {diferenca === 0 ? 'Caixa Conferido!' : 'Diferença Encontrada'}
                </span>
              </div>
              
              <div className="grid grid-cols-3 gap-3 text-sm">
                <div>
                  <p className="text-gray-600">Esperado:</p>
                  <p className="font-medium">{formatarMoeda(saldoEsperado)}</p>
                </div>
                <div>
                  <p className="text-gray-600">Contado:</p>
                  <p className="font-medium">{formatarMoeda(valorContado)}</p>
                </div>
                <div>
                  <p className="text-gray-600">Diferença:</p>
                  <p className={`font-bold ${
                    diferenca === 0 
                      ? 'text-green-600' 
                      : diferenca > 0 
                        ? 'text-blue-600' 
                        : 'text-red-600'
                  }`}>
                    {diferenca > 0 ? '+' : ''}{formatarMoeda(diferenca)}
                  </p>
                </div>
              </div>
              
              {diferenca !== 0 && (
                <p className={`text-xs mt-2 ${
                  diferenca === 0 ? 'text-green-700' : 'text-yellow-700'
                }`}>
                  {diferenca > 0 
                    ? '💰 Sobra no caixa - verificar se há valores não registrados'
                    : '⚠️ Falta no caixa - verificar se todas as saídas foram registradas'
                  }
                </p>
              )}
            </div>
          )}

          {/* Observações */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Observações do Fechamento (opcional)
            </label>
            <div className="relative">
              <div className="absolute top-3 left-3 pointer-events-none">
                <FileText className="h-5 w-5 text-gray-400" />
              </div>
              <textarea
                {...register('observacoes')}
                rows={3}
                placeholder="Ex: Caixa conferido e fechado, diferença de troco..."
                className={`
                  w-full pl-10 pr-4 py-3 border rounded-lg resize-none
                  focus:ring-2 focus:ring-red-500 focus:border-red-500
                  ${errors.observacoes ? 'border-red-500' : 'border-gray-300'}
                `}
              />
            </div>
            {errors.observacoes && (
              <p className="mt-1 text-sm text-red-600">
                {errors.observacoes.message}
              </p>
            )}
          </div>

          {/* Aviso */}
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            <div className="flex items-start gap-2">
              <AlertTriangle className="w-5 h-5 text-red-600 mt-0.5" />
              <div className="text-sm">
                <p className="text-red-800 font-medium mb-1">Atenção:</p>
                <p className="text-red-700">
                  Após fechar o caixa, não será possível realizar mais vendas ou movimentações 
                  até que um novo caixa seja aberto.
                </p>
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="flex gap-3">
            <button
              type="button"
              onClick={handleClose}
              disabled={loading}
              className="flex-1 px-4 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors disabled:opacity-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading || valorContado === 0}
              className="flex-1 px-4 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  Fechando...
                </>
              ) : (
                <>
                  <Lock className="w-4 h-4" />
                  Fechar Caixa
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
