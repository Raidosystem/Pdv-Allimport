import React, { useState } from 'react';
import { X, AlertTriangle, Trash2 } from 'lucide-react';

interface DeleteUserModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => Promise<void>;
  userName: string;
  userEmail: string;
}

export const DeleteUserModal: React.FC<DeleteUserModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
  userName,
  userEmail
}) => {
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [confirmText, setConfirmText] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);

  const CONFIRMATION_TEXT = 'EXCLUIR PERMANENTEMENTE';

  const handleClose = () => {
    setStep(1);
    setConfirmText('');
    setIsDeleting(false);
    onClose();
  };

  const handleNext = () => {
    if (step < 3) {
      setStep((step + 1) as 1 | 2 | 3);
    }
  };

  const handleFinalConfirm = async () => {
    setIsDeleting(true);
    try {
      await onConfirm();
      handleClose();
    } catch (error) {
      console.error('Erro ao excluir usuário:', error);
      setIsDeleting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-100 rounded-lg">
              <AlertTriangle className="w-6 h-6 text-red-600" />
            </div>
            <h2 className="text-xl font-semibold text-gray-900">
              Excluir Usuário - Passo {step}/3
            </h2>
          </div>
          <button
            onClick={handleClose}
            disabled={isDeleting}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50"
          >
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6">
          {step === 1 && (
            <div className="space-y-4">
              <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                <p className="text-sm text-yellow-800">
                  <strong>⚠️ ATENÇÃO:</strong> Você está prestes a excluir o usuário:
                </p>
                <div className="mt-3 p-3 bg-white rounded border border-yellow-300">
                  <p className="font-semibold text-gray-900">{userName}</p>
                  <p className="text-sm text-gray-600">{userEmail}</p>
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-sm font-medium text-gray-700">
                  Esta ação irá excluir permanentemente:
                </p>
                <ul className="text-sm text-gray-600 space-y-1 ml-4">
                  <li>• Conta de autenticação do usuário</li>
                  <li>• Registro de funcionário</li>
                  <li>• Produtos cadastrados</li>
                  <li>• Clientes cadastrados</li>
                  <li>• Vendas realizadas</li>
                  <li>• Ordens de serviço</li>
                  <li>• Registros de caixa</li>
                  <li>• Todos os dados associados</li>
                </ul>
              </div>

              <div className="p-4 bg-red-50 border-2 border-red-500 rounded-lg">
                <p className="text-sm font-bold text-red-700 text-center">
                  ⚠️ ESTA AÇÃO É IRREVERSÍVEL ⚠️
                </p>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="space-y-4">
              <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                <p className="text-sm text-red-800 mb-4">
                  Para confirmar a exclusão permanente, digite exatamente:
                </p>
                <p className="text-center font-mono font-bold text-lg text-red-900 bg-white p-3 rounded border border-red-300">
                  {CONFIRMATION_TEXT}
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Digite aqui:
                </label>
                <input
                  type="text"
                  value={confirmText}
                  onChange={(e) => setConfirmText(e.target.value)}
                  placeholder="Digite o texto acima"
                  className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500 font-mono text-center"
                  autoFocus
                />
              </div>

              <div className="text-center">
                {confirmText && confirmText !== CONFIRMATION_TEXT && (
                  <p className="text-sm text-red-600">
                    ❌ Texto não corresponde. Digite exatamente como mostrado acima.
                  </p>
                )}
                {confirmText === CONFIRMATION_TEXT && (
                  <p className="text-sm text-green-600">
                    ✅ Texto correto! Você pode prosseguir.
                  </p>
                )}
              </div>
            </div>
          )}

          {step === 3 && (
            <div className="space-y-4">
              <div className="p-4 bg-red-100 border-2 border-red-600 rounded-lg">
                <div className="flex items-center gap-3 mb-3">
                  <Trash2 className="w-6 h-6 text-red-600" />
                  <p className="font-bold text-red-900">ÚLTIMA CONFIRMAÇÃO</p>
                </div>
                <p className="text-sm text-red-800">
                  Este é o último passo antes da exclusão permanente e irreversível do usuário:
                </p>
                <div className="mt-3 p-3 bg-white rounded border border-red-400">
                  <p className="font-semibold text-gray-900">{userName}</p>
                  <p className="text-sm text-gray-600">{userEmail}</p>
                </div>
              </div>

              <div className="p-4 bg-gray-50 rounded-lg">
                <p className="text-sm text-gray-700 text-center font-medium">
                  Após clicar em "EXCLUIR PERMANENTEMENTE", todos os dados serão removidos do sistema
                  e não poderão ser recuperados.
                </p>
              </div>

              <div className="p-4 bg-red-600 text-white rounded-lg text-center">
                <p className="font-bold text-lg">
                  ⚠️ NÃO HÁ COMO DESFAZER ESTA AÇÃO ⚠️
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-6 border-t border-gray-200 bg-gray-50">
          <button
            onClick={handleClose}
            disabled={isDeleting}
            className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Cancelar
          </button>

          {step === 1 && (
            <button
              onClick={handleNext}
              className="px-6 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors font-medium"
            >
              Continuar →
            </button>
          )}

          {step === 2 && (
            <button
              onClick={handleNext}
              disabled={confirmText !== CONFIRMATION_TEXT}
              className="px-6 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Próximo →
            </button>
          )}

          {step === 3 && (
            <button
              onClick={handleFinalConfirm}
              disabled={isDeleting}
              className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-bold disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            >
              {isDeleting ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  Excluindo...
                </>
              ) : (
                <>
                  <Trash2 className="w-4 h-4" />
                  EXCLUIR PERMANENTEMENTE
                </>
              )}
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
