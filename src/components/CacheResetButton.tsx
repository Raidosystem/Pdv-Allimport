import React from 'react';
import { hardResetCaches } from '../utils/versionControl';

interface CacheResetButtonProps {
  className?: string;
}

export const CacheResetButton: React.FC<CacheResetButtonProps> = ({ className }) => {
  const [isResetting, setIsResetting] = React.useState(false);

  const handleReset = async () => {
    if (isResetting) return;
    
    setIsResetting(true);
    
    try {
      console.log('🚨 Reset manual de cache iniciado');
      
      // Limpar tudo
      await hardResetCaches();
      
      // Mostrar feedback
      const confirmed = window.confirm(
        '✅ Cache limpo com sucesso!\n\n' +
        'A página será recarregada para aplicar as mudanças.\n\n' +
        'Continuar?'
      );
      
      if (confirmed) {
        window.location.reload();
      }
      
    } catch (error) {
      console.error('❌ Erro no reset:', error);
      alert('❌ Erro ao limpar cache. Tente recarregar manualmente.');
    } finally {
      setIsResetting(false);
    }
  };

  return (
    <button
      onClick={handleReset}
      disabled={isResetting}
      className={`
        flex items-center gap-2 px-4 py-2 
        bg-yellow-500 hover:bg-yellow-600 
        text-white font-medium rounded-lg 
        transition-colors duration-200
        disabled:opacity-50 disabled:cursor-not-allowed
        ${className || ''}
      `}
      title="Limpar cache e resolver página em branco"
    >
      {isResetting ? (
        <>
          <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
          Limpando...
        </>
      ) : (
        <>
          🧹 Resolver Página Branca
        </>
      )}
    </button>
  );
};

export default CacheResetButton;