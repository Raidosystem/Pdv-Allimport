import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { DollarSign, Calendar, User, FileText } from 'lucide-react';
import type { AberturaCaixaForm } from '../../types/caixa';

// Schema de validação
const aberturaCaixaSchema = z.object({
  valor_inicial: z.number()
    .min(0, 'Valor deve ser maior ou igual a zero')
    .max(999999.99, 'Valor muito alto'),
  observacoes: z.string().optional()
});

interface AberturaCaixaModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (dados: AberturaCaixaForm) => Promise<boolean>;
  loading?: boolean;
}

export function AberturaCaixaModal({ 
  isOpen, 
  onClose, 
  onSubmit, 
  loading = false 
}: AberturaCaixaModalProps) {
  const [valorInput, setValorInput] = useState('');

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setValue
  } = useForm<AberturaCaixaForm>({
    resolver: zodResolver(aberturaCaixaSchema),
    defaultValues: {
      valor_inicial: 0,
      observacoes: ''
    }
  });

  // Função para formatar valor monetário
  const formatarValor = (value: string) => {
    // Remove tudo que não é número
    const numbers = value.replace(/\D/g, '');
    
    // Converte para formato monetário
    const valor = parseFloat(numbers) / 100;
    
    // Atualiza o campo do formulário
    setValue('valor_inicial', valor);
    
    // Formata para exibição
    return valor.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  };

  const handleValorChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarValor(e.target.value);
    setValorInput(formatted);
  };

  const handleFormSubmit = async (dados: AberturaCaixaForm) => {
    const sucesso = await onSubmit(dados);
    if (sucesso) {
      reset();
      setValorInput('');
      onClose();
    }
  };

  const handleClose = () => {
    reset();
    setValorInput('');
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-md">
        {/* Header */}
        <div className="bg-orange-500 text-white p-6 rounded-t-xl">
          <div className="flex items-center gap-3">
            <div className="bg-white bg-opacity-20 p-2 rounded-lg">
              <DollarSign className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-xl font-bold">Abertura de Caixa</h2>
              <p className="text-orange-100 text-sm">Informe o valor inicial do caixa</p>
            </div>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit(handleFormSubmit)} className="p-6">
          {/* Informações do sistema */}
          <div className="mb-6 p-4 bg-orange-50 rounded-lg border border-orange-200">
            <div className="flex items-center gap-2 text-orange-700 mb-2">
              <Calendar className="w-4 h-4" />
              <span className="text-sm font-medium">
                {new Date().toLocaleDateString('pt-BR', {
                  weekday: 'long',
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric'
                })}
              </span>
            </div>
            <div className="flex items-center gap-2 text-orange-600">
              <User className="w-4 h-4" />
              <span className="text-sm">
                {new Date().toLocaleTimeString('pt-BR', {
                  hour: '2-digit',
                  minute: '2-digit'
                })}
              </span>
            </div>
          </div>

          {/* Valor Inicial */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Valor Inicial em Caixa *
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
                  focus:ring-2 focus:ring-orange-500 focus:border-orange-500
                  ${errors.valor_inicial ? 'border-red-500' : 'border-gray-300'}
                `}
              />
            </div>
            {errors.valor_inicial && (
              <p className="mt-1 text-sm text-red-600">
                {errors.valor_inicial.message}
              </p>
            )}
          </div>

          {/* Observações */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Observações (opcional)
            </label>
            <div className="relative">
              <div className="absolute top-3 left-3 pointer-events-none">
                <FileText className="h-5 w-5 text-gray-400" />
              </div>
              <textarea
                {...register('observacoes')}
                rows={3}
                placeholder="Ex: Abertura do caixa manhã..."
                className={`
                  w-full pl-10 pr-4 py-3 border rounded-lg resize-none
                  focus:ring-2 focus:ring-orange-500 focus:border-orange-500
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
              disabled={loading}
              className="flex-1 px-4 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  Abrindo...
                </>
              ) : (
                <>
                  <DollarSign className="w-4 h-4" />
                  Abrir Caixa
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
