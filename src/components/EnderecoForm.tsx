import { useState } from 'react'
import { MapPin, Search, Loader2, CheckCircle2 } from 'lucide-react'
import { fetchAddressByCep, formatCep, isValidCep } from '../services/cepService'
import toast from 'react-hot-toast'

export interface EnderecoData {
  cep: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
}

interface EnderecoFormProps {
  endereco: EnderecoData
  onChange: (field: keyof EnderecoData, value: string) => void
  disabled?: boolean
}

export function EnderecoForm({ endereco, onChange, disabled = false }: EnderecoFormProps) {
  const [searching, setSearching] = useState(false)
  const [cepFound, setCepFound] = useState(false)

  const handleCepChange = (value: string) => {
    // Formatar CEP enquanto digita
    const formatted = value.replace(/\D/g, '').slice(0, 8)
    const display = formatted.length > 5 
      ? `${formatted.slice(0, 5)}-${formatted.slice(5)}`
      : formatted
    
    onChange('cep', display)
    setCepFound(false)
  }

  const handleCepBlur = async () => {
    if (!endereco.cep || endereco.cep.length < 8) return
    
    // Validar e buscar CEP
    if (isValidCep(endereco.cep)) {
      await searchCep()
    }
  }

  const searchCep = async () => {
    if (!endereco.cep || searching) return

    setSearching(true)
    setCepFound(false)

    try {
      const result = await fetchAddressByCep(endereco.cep)

      if (result.success && result.data) {
        // Preencher campos automaticamente
        onChange('logradouro', result.data.logradouro)
        onChange('bairro', result.data.bairro)
        onChange('cidade', result.data.cidade)
        onChange('estado', result.data.estado)
        onChange('cep', formatCep(result.data.cep))
        
        setCepFound(true)
        toast.success('CEP encontrado! Endereço preenchido automaticamente')
        
        // Focar no campo número após busca
        setTimeout(() => {
          const numeroInput = document.getElementById('endereco-numero') as HTMLInputElement
          numeroInput?.focus()
        }, 100)
      } else {
        toast.error(result.error || 'CEP não encontrado')
      }
    } catch (error) {
      console.error('Erro ao buscar CEP:', error)
      toast.error('Erro ao buscar CEP. Tente novamente.')
    } finally {
      setSearching(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 mb-2">
        <MapPin className="h-5 w-5 text-gray-600" />
        <h4 className="font-medium text-gray-900">Endereço</h4>
      </div>

      {/* CEP com busca automática */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="md:col-span-1">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            CEP <span className="text-red-500">*</span>
          </label>
          <div className="relative">
            <input
              type="text"
              value={endereco.cep}
              onChange={(e) => handleCepChange(e.target.value)}
              onBlur={handleCepBlur}
              placeholder="00000-000"
              maxLength={9}
              disabled={disabled || searching}
              className="w-full pl-3 pr-10 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
            />
            <div className="absolute inset-y-0 right-0 flex items-center pr-3">
              {searching ? (
                <Loader2 className="h-4 w-4 text-blue-500 animate-spin" />
              ) : cepFound ? (
                <CheckCircle2 className="h-4 w-4 text-green-500" />
              ) : (
                <button
                  type="button"
                  onClick={searchCep}
                  disabled={!isValidCep(endereco.cep) || disabled}
                  className="text-blue-600 hover:text-blue-700 disabled:text-gray-400 disabled:cursor-not-allowed"
                  title="Buscar CEP"
                >
                  <Search className="h-4 w-4" />
                </button>
              )}
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-1">
            Digite o CEP e clique na lupa
          </p>
        </div>
      </div>

      {/* Logradouro e Número */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Logradouro (Rua, Avenida) <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={endereco.logradouro}
            onChange={(e) => onChange('logradouro', e.target.value)}
            placeholder="Ex: Rua das Flores"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Número <span className="text-red-500">*</span>
          </label>
          <input
            id="endereco-numero"
            type="text"
            value={endereco.numero}
            onChange={(e) => onChange('numero', e.target.value)}
            placeholder="123"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
      </div>

      {/* Complemento e Bairro */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Complemento
          </label>
          <input
            type="text"
            value={endereco.complemento}
            onChange={(e) => onChange('complemento', e.target.value)}
            placeholder="Apto, Sala, Bloco (opcional)"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Bairro <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={endereco.bairro}
            onChange={(e) => onChange('bairro', e.target.value)}
            placeholder="Ex: Centro"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
      </div>

      {/* Cidade e Estado */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Cidade <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={endereco.cidade}
            onChange={(e) => onChange('cidade', e.target.value)}
            placeholder="Ex: São Paulo"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Estado <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            value={endereco.estado}
            onChange={(e) => onChange('estado', e.target.value)}
            placeholder="Ex: São Paulo - SP"
            disabled={disabled}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100"
          />
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
        <p className="text-sm text-blue-800">
          💡 <strong>Dica:</strong> Digite o CEP e pressione Tab ou clique na lupa para buscar o endereço automaticamente
        </p>
      </div>
    </div>
  )
}
