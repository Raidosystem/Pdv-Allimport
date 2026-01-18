import React, { useState } from 'react'
import { FileText, Calculator } from 'lucide-react'
import LaudoTecnicoPage from './LaudoTecnicoPage'
import OrcamentoPage from './OrcamentoPage'

type SubsectionType = 'laudo' | 'orcamento'

const FerramentasPage: React.FC = () => {
  const [subsection, setSubsection] = useState<SubsectionType>('laudo')

  return (
    <div className="space-y-6">
      {/* Header com botões de navegação */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex items-center gap-4">
          <h2 className="text-xl font-semibold text-gray-800 flex items-center gap-2">
            <FileText className="w-6 h-6 text-gray-600" />
            Ferramentas
          </h2>
          
          <div className="flex gap-3 ml-auto">
            {/* Botão Laudo - Cor fixa azul */}
            <button
              onClick={() => setSubsection('laudo')}
              className="flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all bg-blue-600 text-white shadow-md hover:bg-blue-700"
            >
              <FileText className="w-5 h-5" />
              Laudo Técnico
            </button>

            {/* Botão Orçamento - Cor fixa verde */}
            <button
              onClick={() => setSubsection('orcamento')}
              className="flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all bg-green-600 text-white shadow-md hover:bg-green-700"
            >
              <Calculator className="w-5 h-5" />
              Orçamento
            </button>
          </div>
        </div>
      </div>

      {/* Conteúdo baseado na subseção selecionada */}
      <div className="animate-in fade-in duration-300">
        {subsection === 'laudo' && <LaudoTecnicoPage />}
        {subsection === 'orcamento' && <OrcamentoPage />}
      </div>
    </div>
  )
}

export default FerramentasPage
