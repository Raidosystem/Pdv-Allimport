import React, { useState } from 'react';
import { HelpCircle, ExternalLink, Shield } from 'lucide-react';

interface AccessSOSProps {
  variant?: 'button' | 'floating' | 'text';
  className?: string;
}

export const AccessSOS: React.FC<AccessSOSProps> = ({ 
  variant = 'button',
  className = ''
}) => {
  const [showTooltip, setShowTooltip] = useState(false);

  const handleClick = () => {
    // Abrir em nova aba ou redirecionar
    const url = '/access-helper';
    if (window.location.pathname !== url) {
      window.open(url, '_blank');
    }
  };

  if (variant === 'floating') {
    return (
      <div 
        className={`fixed bottom-4 right-4 z-50 ${className}`}
        onMouseEnter={() => setShowTooltip(true)}
        onMouseLeave={() => setShowTooltip(false)}
      >
        <button
          onClick={handleClick}
          className="w-14 h-14 bg-red-500 hover:bg-red-600 text-white rounded-full shadow-lg hover:shadow-xl transition-all duration-200 flex items-center justify-center group"
          title="Problemas de acesso? Clique para ajuda"
        >
          <HelpCircle className="w-6 h-6" />
        </button>
        
        {showTooltip && (
          <div className="absolute bottom-16 right-0 bg-black text-white text-xs rounded px-2 py-1 whitespace-nowrap">
            Problemas de acesso?
            <div className="absolute top-full right-4 w-0 h-0 border-l-4 border-r-4 border-t-4 border-l-transparent border-r-transparent border-t-black"></div>
          </div>
        )}
      </div>
    );
  }

  if (variant === 'text') {
    return (
      <button
        onClick={handleClick}
        className={`inline-flex items-center gap-2 text-blue-600 hover:text-blue-700 underline text-sm ${className}`}
      >
        <HelpCircle className="w-4 h-4" />
        Problemas de acesso?
        <ExternalLink className="w-3 h-3" />
      </button>
    );
  }

  // variant === 'button' (default)
  return (
    <button
      onClick={handleClick}
      className={`inline-flex items-center gap-2 px-4 py-2 bg-yellow-100 border border-yellow-300 text-yellow-800 rounded-lg hover:bg-yellow-200 transition-colors ${className}`}
    >
      <Shield className="w-4 h-4" />
      Problemas de Acesso?
      <ExternalLink className="w-4 h-4" />
    </button>
  );
};

export default AccessSOS;