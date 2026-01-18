import React, { useState, useEffect } from 'react';
import { X, Save, Upload as UploadIcon } from 'lucide-react';
import type { ContaPagar, ContaPagarForm as ContaPagarFormType } from './api';
import { createContaPagar, updateContaPagar } from './api';
import BoletoUpload from './BoletoUpload';

interface ContaPagarFormProps {
  conta?: ContaPagar;
  onSave: () => void;
  onClose: () => void;
}

const ContaPagarForm: React.FC<ContaPagarFormProps> = ({
  conta,
  onSave,
  onClose
}) => {
  const [formData, setFormData] = useState<ContaPagarFormType>({
    fornecedor: '',
    descricao: '',
    valor: 0,
    data_vencimento: '',
    categoria: '',
    observacoes: '',
    boleto_url: '',
    boleto_codigo_barras: '',
    boleto_linha_digitavel: ''
  });

  const [valorDisplay, setValorDisplay] = useState('');
  const [loading, setLoading] = useState(false);
  const [showBoletoUpload, setShowBoletoUpload] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Preencher formulário ao editar
  useEffect(() => {
    if (conta) {
      setFormData({
        fornecedor: conta.fornecedor,
        descricao: conta.descricao,
        valor: conta.valor,
        data_vencimento: conta.data_vencimento,
        categoria: conta.categoria,
        observacoes: conta.observacoes || '',
        boleto_url: conta.boleto_url || '',
        boleto_codigo_barras: conta.boleto_codigo_barras || '',
        boleto_linha_digitavel: conta.boleto_linha_digitavel || ''
      });
      // Formatar valor para exibição
      setValorDisplay(conta.valor.toFixed(2).replace('.', ','));
    }
  }, [conta]);

  // Função para formatar valor monetário
  const formatarValor = (value: string) => {
    // Remove tudo que não é número
    const apenasNumeros = value.replace(/\D/g, '');
    
    if (!apenasNumeros) return '';
    
    // Converte para número e divide por 100 para ter os centavos
    const numero = parseInt(apenasNumeros) / 100;
    
    // Formata com 2 casas decimais e vírgula
    return numero.toFixed(2).replace('.', ',');
  };

  // Handler para mudança no campo de valor
  const handleValorChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const formatted = formatarValor(value);
    
    setValorDisplay(formatted);
    
    // Converte para número e atualiza formData
    const numeroValor = parseFloat(formatted.replace(',', '.')) || 0;
    setFormData(prev => ({ ...prev, valor: numeroValor }));
    
    // Limpar erro do campo
    if (errors.valor) {
      setErrors(prev => ({ ...prev, valor: '' }));
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.fornecedor.trim()) {
      newErrors.fornecedor = 'Fornecedor é obrigatório';
    }
    if (!formData.descricao.trim()) {
      newErrors.descricao = 'Descrição é obrigatória';
    }
    if (formData.valor <= 0) {
      newErrors.valor = 'Valor deve ser maior que zero';
    }
    if (!formData.data_vencimento) {
      newErrors.data_vencimento = 'Data de vencimento é obrigatória';
    }
    if (!formData.categoria.trim()) {
      newErrors.categoria = 'Categoria é obrigatória';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    setLoading(true);
    try {
      if (conta) {
        await updateContaPagar(conta.id, formData);
      } else {
        await createContaPagar(formData);
      }

      onSave();
      onClose();
    } catch (error) {
      console.error('Erro ao salvar conta:', error);
      alert('Erro ao salvar conta a pagar. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  const handleBoletoUploadSuccess = (url: string) => {
    setFormData(prev => ({ ...prev, boleto_url: url }));
    setShowBoletoUpload(false);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-bold text-gray-900">
            {conta ? 'Editar Conta a Pagar' : 'Nova Conta a Pagar'}
          </h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Fornecedor */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Fornecedor *
            </label>
            <input
              type="text"
              name="fornecedor"
              value={formData.fornecedor}
              onChange={handleChange}
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.fornecedor ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Nome do fornecedor"
            />
            {errors.fornecedor && (
              <p className="text-sm text-red-600 mt-1">{errors.fornecedor}</p>
            )}
          </div>

          {/* Descrição */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Descrição *
            </label>
            <input
              type="text"
              name="descricao"
              value={formData.descricao}
              onChange={handleChange}
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.descricao ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="Descrição da conta"
            />
            {errors.descricao && (
              <p className="text-sm text-red-600 mt-1">{errors.descricao}</p>
            )}
          </div>

          {/* Valor e Vencimento */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Valor (R$) *
              </label>
              <input
                type="text"
                inputMode="numeric"
                name="valor"
                value={valorDisplay}
                onChange={handleValorChange}
                className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                  errors.valor ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="0,00"
              />
              {errors.valor && (
                <p className="text-sm text-red-600 mt-1">{errors.valor}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Vencimento *
              </label>
              <input
                type="date"
                name="data_vencimento"
                value={formData.data_vencimento}
                onChange={handleChange}
                className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                  errors.data_vencimento ? 'border-red-500' : 'border-gray-300'
                }`}
              />
              {errors.data_vencimento && (
                <p className="text-sm text-red-600 mt-1">{errors.data_vencimento}</p>
              )}
            </div>
          </div>

          {/* Categoria */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Categoria *
            </label>
            <select
              name="categoria"
              value={formData.categoria}
              onChange={handleChange}
              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.categoria ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">Selecione...</option>
              <option value="Fornecedores">Fornecedores</option>
              <option value="Aluguel">Aluguel</option>
              <option value="Energia">Energia</option>
              <option value="Água">Água</option>
              <option value="Internet">Internet</option>
              <option value="Telefone">Telefone</option>
              <option value="Impostos">Impostos</option>
              <option value="Salários">Salários</option>
              <option value="Manutenção">Manutenção</option>
              <option value="Marketing">Marketing</option>
              <option value="Outros">Outros</option>
            </select>
            {errors.categoria && (
              <p className="text-sm text-red-600 mt-1">{errors.categoria}</p>
            )}
          </div>

          {/* Observações */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Observações
            </label>
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Observações adicionais..."
            />
          </div>

          {/* Dados do Boleto */}
          <div className="border-t border-gray-200 pt-4">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-gray-900">Dados do Boleto (Opcional)</h3>
              {!showBoletoUpload && (
                <button
                  type="button"
                  onClick={() => setShowBoletoUpload(true)}
                  className="flex items-center gap-2 px-3 py-1 text-sm text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                >
                  <UploadIcon className="w-4 h-4" />
                  Anexar Boleto PDF
                </button>
              )}
            </div>

            {showBoletoUpload && (
              <div className="mb-4">
                <BoletoUpload
                  contaPagarId={conta?.id}
                  onUploadSuccess={handleBoletoUploadSuccess}
                  onClose={() => setShowBoletoUpload(false)}
                />
              </div>
            )}

            {formData.boleto_url && (
              <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
                <p className="text-sm text-green-800">
                  ✓ Boleto anexado
                </p>
              </div>
            )}

            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Código de Barras
                </label>
                <input
                  type="text"
                  name="boleto_codigo_barras"
                  value={formData.boleto_codigo_barras}
                  onChange={handleChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="00000.00000 00000.000000 00000.000000 0 00000000000000"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Linha Digitável
                </label>
                <input
                  type="text"
                  name="boleto_linha_digitavel"
                  value={formData.boleto_linha_digitavel}
                  onChange={handleChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="00000000000000000000000000000000000000000000000"
                />
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="px-4 py-2 text-gray-700 hover:text-gray-900 transition-colors disabled:opacity-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  Salvando...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  {conta ? 'Atualizar' : 'Salvar'}
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ContaPagarForm;
