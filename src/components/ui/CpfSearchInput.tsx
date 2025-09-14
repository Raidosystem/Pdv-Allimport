import React, { useState, useEffect } from 'react'
import { User, UserCheck, Edit, Loader2, AlertTriangle } from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { useClienteCpfSearch } from '../../hooks/useClienteCpfSearch'
import { formatarCpfCnpj, formatarTelefone } from '../../utils/formatacao'
import type { Cliente } from '../../types/cliente'

interface CpfSearchInputProps {
  value: string
  onChange: (value: string) => void
  onClienteEncontrado?: (cliente: Cliente) => void
  onEditarCliente?: (cliente: Cliente) => void
  disabled?: boolean
  placeholder?: string
  error?: string
}

export function CpfSearchInput({
  value,
  onChange,
  onClienteEncontrado,
  onEditarCliente,
  disabled = false,
  placeholder = "Digite o CPF/CNPJ",
  error
}: CpfSearchInputProps) {
  const [showDuplicates, setShowDuplicates] = useState(false)
  const [selectedCliente, setSelectedCliente] = useState<Cliente | null>(null)
  
  const { loading, clientes, clienteExato, temDuplicatas } = useClienteCpfSearch(value, !disabled)

  // Formatar CPF/CNPJ conforme o usuário digita
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const rawValue = e.target.value
    const formattedValue = formatarCpfCnpj(rawValue)
    onChange(formattedValue)
  }

  // Mostrar/esconder painel de duplicatas
  useEffect(() => {
    if (temDuplicatas && !loading) {
      setShowDuplicates(true)
    } else {
      setShowDuplicates(false)
    }
  }, [temDuplicatas, loading])

  // Auto-selecionar cliente se houver match exato
  useEffect(() => {
    if (clienteExato && !selectedCliente) {
      setSelectedCliente(clienteExato)
      if (onClienteEncontrado) {
        onClienteEncontrado(clienteExato)
      }
    }
  }, [clienteExato, selectedCliente, onClienteEncontrado])

  const handleUsarCliente = (cliente: Cliente) => {
    setSelectedCliente(cliente)
    setShowDuplicates(false)
    
    // Preencher o campo com o CPF do cliente selecionado
    if (cliente.cpf_cnpj) {
      onChange(formatarCpfCnpj(cliente.cpf_cnpj))
    }
    
    if (onClienteEncontrado) {
      onClienteEncontrado(cliente)
    }
  }

  const handleEditarCliente = (cliente: Cliente) => {
    if (onEditarCliente) {
      onEditarCliente(cliente)
    }
  }

  // Determinar cor do input baseado no estado
  const getInputStyle = () => {
    if (error) {
      return 'border-red-300 bg-red-50 focus:border-red-500 focus:ring-red-500'
    }
    if (loading) {
      return 'border-blue-300 bg-blue-50 focus:border-blue-500 focus:ring-blue-500'
    }
    if (temDuplicatas) {
      return 'border-orange-300 bg-orange-50 focus:border-orange-500 focus:ring-orange-500'
    }
    if (selectedCliente) {
      return 'border-green-300 bg-green-50 focus:border-green-500 focus:ring-green-500'
    }
    return 'border-gray-300 bg-white focus:border-orange-500 focus:ring-orange-500'
  }

  return (
    <div className="space-y-3">
      {/* Campo de Input */}
      <div className="relative">
        <Input
          type="text"
          value={value}
          onChange={handleInputChange}
          disabled={disabled}
          placeholder={placeholder}
          className={`pr-10 ${getInputStyle()}`}
          maxLength={18} // CPF: 14 chars, CNPJ: 18 chars com formatação
        />
        
        {/* Ícone de status */}
        <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
          {loading && (
            <Loader2 className="w-4 h-4 text-blue-500 animate-spin" />
          )}
          {!loading && temDuplicatas && (
            <AlertTriangle className="w-4 h-4 text-orange-500" />
          )}
          {!loading && selectedCliente && (
            <UserCheck className="w-4 h-4 text-green-500" />
          )}
        </div>
      </div>

      {/* Mensagem de erro */}
      {error && (
        <p className="text-sm text-red-600 flex items-center gap-1">
          <AlertTriangle className="w-4 h-4" />
          {error}
        </p>
      )}

      {/* Status do cliente selecionado */}
      {selectedCliente && !showDuplicates && (
        <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
          <div className="flex items-center gap-2 text-green-700">
            <UserCheck className="w-4 h-4" />
            <span className="text-sm font-medium">
              ✅ Cliente selecionado: {selectedCliente.nome}
            </span>
          </div>
        </div>
      )}

      {/* Painel de duplicatas encontradas */}
      {showDuplicates && clientes.length > 0 && (
        <div className="border border-orange-200 rounded-lg bg-orange-50 p-4">
          <div className="flex items-center gap-2 text-orange-700 mb-3">
            <AlertTriangle className="w-5 h-5" />
            <h4 className="font-medium">
              ⚡ {clientes.length === 1 ? 'Cliente encontrado' : `${clientes.length} clientes encontrados`} automaticamente
            </h4>
          </div>
          
          <p className="text-sm text-orange-600 mb-3">
            {clientes.length === 1 
              ? 'Detectamos um cliente com este CPF/CNPJ:' 
              : 'Detectamos clientes com CPF/CNPJ similar:'
            }
          </p>
          
          <div className="space-y-2">
            {clientes.slice(0, 3).map((cliente) => (
              <div 
                key={cliente.id} 
                className="bg-white border border-orange-200 rounded-lg p-3"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <User className="w-4 h-4 text-gray-500" />
                      <span className="font-medium text-gray-900">
                        {cliente.nome}
                      </span>
                    </div>
                    <div className="mt-1 text-sm text-gray-600">
                      {cliente.telefone && (
                        <span>{formatarTelefone(cliente.telefone)}</span>
                      )}
                      {cliente.telefone && cliente.email && ' • '}
                      {cliente.email && (
                        <span>{cliente.email}</span>
                      )}
                    </div>
                    {cliente.cpf_cnpj && (
                      <div className="mt-1 text-xs text-gray-500">
                        CPF/CNPJ: {formatarCpfCnpj(cliente.cpf_cnpj)}
                      </div>
                    )}
                  </div>
                  
                  <div className="flex gap-2 ml-3">
                    <Button
                      size="sm"
                      onClick={() => handleUsarCliente(cliente)}
                      className="bg-orange-500 hover:bg-orange-600 text-white"
                    >
                      Usar este
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => handleEditarCliente(cliente)}
                      className="border-orange-300 text-orange-700 hover:bg-orange-100"
                    >
                      <Edit className="w-3 h-3" />
                    </Button>
                  </div>
                </div>
              </div>
            ))}
            
            {clientes.length > 3 && (
              <p className="text-xs text-orange-600 text-center">
                E mais {clientes.length - 3} cliente(s)...
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  )
}