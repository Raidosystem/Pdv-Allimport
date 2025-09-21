import React from 'react';

interface CacheResetButtonProps {
  className?: string;
}

export const CacheResetButton: React.FC<CacheResetButtonProps> = ({ className }) => {
  const [isResetting, setIsResetting] = React.useState(false);

  const handleReset = async () => {
    if (isResetting) return;
    
    setIsResetting(true);
    
    try {
      console.log('🚨 Reset universal de cache iniciado');
      
      // Usar o limpador universal do index.html
      if (typeof (window as any).__forceCleanAndReload === 'function') {
        const confirmed = window.confirm(
          '🧹 Resolver tela em branco?\n\n' +
          'Isso vai limpar TODO o cache (Edge, Chrome, Safari) e recarregar.\n\n' +
          'Continuar?'
        );
        
        if (confirmed) {
          (window as any).__forceCleanAndReload();
        }
      } else {
        // Fallback manual
        console.warn('⚠️ Função universal não encontrada, usando fallback');
        
        try {
          localStorage.clear();
          sessionStorage.clear();
        } catch (e) {
          console.warn('Cache local não pôde ser limpo:', e);
        }
        
        const confirmed = window.confirm(
          '⚠️ Cache parcialmente limpo.\n\n' +
          'A página será recarregada.\n\n' +
          'Continuar?'
        );
        
        if (confirmed) {
          window.location.reload();
        }
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