import React from 'react';
import { Printer, X, FileText } from 'lucide-react';

interface PrintOrdemServicoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string; // "Ordem Criada!" ou "Ordem Encerrada!"
  ordemNumero?: string;
  clienteName?: string;
  valorTotal?: number;
}

const PrintOrdemServicoModal: React.FC<PrintOrdemServicoModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  ordemNumero,
  clienteName,
  valorTotal
}) => {
  console.log('🔍 [PrintOrdemServicoModal] Render:', {
    isOpen,
    title,
    ordemNumero,
    clienteName,
    valorTotal,
    timestamp: new Date().toISOString()
  });
  
  if (!isOpen) return null;

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[110]">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-green-100 rounded-full">
              <FileText className="w-6 h-6 text-green-600" />
            </div>
            <h2 className="text-xl font-semibold text-gray-900">
              {title}
            </h2>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="mb-6">
          <div className="bg-gray-50 rounded-lg p-4 mb-4">
            {ordemNumero && (
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-gray-600">Ordem Nº:</span>
                <span className="text-sm font-bold text-gray-900">
                  {ordemNumero}
                </span>
              </div>
            )}
            {clienteName && (
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-gray-600">Cliente:</span>
                <span className="text-sm font-medium text-gray-900">
                  {clienteName}
                </span>
              </div>
            )}
            {valorTotal !== undefined && (
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-600">Valor Total:</span>
                <span className="text-lg font-bold text-green-600">
                  {formatCurrency(valorTotal)}
                </span>
              </div>
            )}
          </div>

          <p className="text-gray-700 text-center">
            Deseja imprimir o comprovante?
          </p>
        </div>

        <div className="flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 transition-colors"
          >
            Não Imprimir
          </button>
          <button
            onClick={() => {
              console.log('🖨️ [PrintOrdemServicoModal] Botão Imprimir clicado');
              onConfirm();
              onClose();
            }}
            className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
          >
            <Printer className="w-4 h-4" />
            Imprimir
          </button>
        </div>
      </div>
    </div>
  );
};

export default PrintOrdemServicoModal;
