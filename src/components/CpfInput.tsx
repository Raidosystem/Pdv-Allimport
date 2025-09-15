import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { onlyDigits, formatCpfCnpj, isValidCpfCnpj } from '../lib/cpf'
import { useDebounce } from '../hooks/useDebounce'

type CpfCnpjStatus = 'idle' | 'invalid' | 'checking' | 'duplicate' | 'ok'

interface ClienteEncontrado {
  id: string
  nome: string
  telefone?: string
  email?: string
  cpf_cnpj?: string
  endereco?: string
  criado_em: string
}

interface CpfInputProps {
  value: string
  onChange: (value: string) => void
  empresaId?: string
  excludeId?: string // ID do cliente a ser excluído da verificação de duplicata
  className?: string
  placeholder?: string
  disabled?: boolean
}

export interface CpfInputRef {
  isCpfOk: boolean
  status: CpfCnpjStatus
  clienteEncontrado?: ClienteEncontrado
}

export const CpfInput = React.forwardRef<CpfInputRef, CpfInputProps>(
  ({ value, onChange, empresaId, excludeId, className = '', placeholder = 'CPF ou CNPJ', disabled = false }, ref) => {
    const [status, setStatus] = useState<CpfCnpjStatus>('idle')
    const [isChecking, setIsChecking] = useState(false)
    const [clienteEncontrado, setClienteEncontrado] = useState<ClienteEncontrado | undefined>(undefined)
    
    // Debounce do valor para evitar muitas consultas ao Supabase
    const debouncedValue = useDebounce(value, 250)
    
    // Expor estado através do ref
    React.useImperativeHandle(ref, () => ({
      isCpfOk: status === 'ok',
      status,
      clienteEncontrado
    }))

    // Verificar CPF no Supabase quando o valor debounced mudar
    useEffect(() => {
      const checkCpfInDatabase = async () => {
        const digits = onlyDigits(debouncedValue)
        
        // Se não tem dígitos suficientes, marcar como idle
        if (digits.length === 0) {
          setStatus('idle')
          setClienteEncontrado(undefined)
          return
        }
        
        // Se não tem 11 dígitos (CPF) ou 14 dígitos (CNPJ) ou é inválido, marcar como invalid
        if ((digits.length !== 11 && digits.length !== 14) || !isValidCpfCnpj(digits)) {
          setStatus('invalid')
          setClienteEncontrado(undefined)
          return
        }
        
        // CPF/CNPJ válido localmente, verificar no banco
        setStatus('checking')
        setIsChecking(true)
        
        try {
          // Normalizar o valor para busca (apenas dígitos)
          const normalizedValue = debouncedValue.replace(/\D/g, '')
          
          // Buscar tanto na coluna cpf_cnpj (com formatação) quanto cpf_digits (só números)
          let query = supabase
            .from('clientes')
            .select('id, nome, telefone, email, cpf_cnpj, endereco, criado_em')
          
          // Buscar em ambas as colunas: cpf_cnpj e cpf_digits
          query = query.or(`cpf_cnpj.eq.${debouncedValue},cpf_digits.eq.${normalizedValue}`)
          
          // Se empresaId for fornecido, filtrar por empresa
          if (empresaId) {
            query = query.eq('empresa_id', empresaId)
          }
          
          // Se excludeId for fornecido, excluir esse cliente da verificação
          if (excludeId) {
            query = query.neq('id', excludeId)
          }
          
          console.log('🔍 [CPF INPUT] Verificando duplicata para:', { 
            formatted: debouncedValue, 
            digits: normalizedValue,
            excludeId,
            empresaId
          })
          
          const { data, error } = await query
          
          if (error) {
            console.error('❌ [CPF INPUT] Erro ao verificar CPF/CNPJ:', error)
            setStatus('invalid')
            setClienteEncontrado(undefined)
            return
          }
          
          console.log('📊 [CPF INPUT] Resultado da verificação:', { 
            data, 
            found: data && data.length > 0,
            cliente: data?.[0] 
          })
          
          // Se encontrou dados, CPF/CNPJ já está cadastrado
          if (data && data.length > 0) {
            setStatus('duplicate')
            setClienteEncontrado(data[0])
          } else {
            setStatus('ok')
            setClienteEncontrado(undefined)
          }
        } catch (error) {
          console.error('💥 [CPF INPUT] Erro inesperado ao verificar CPF/CNPJ:', error)
          setStatus('invalid')
          setClienteEncontrado(undefined)
        } finally {
          setIsChecking(false)
        }
      }

      checkCpfInDatabase()
    }, [debouncedValue, empresaId, excludeId])

    // Lidar com mudanças no input
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      const rawValue = e.target.value
      const formatted = formatCpfCnpj(rawValue)
      onChange(formatted)
    }

    // Determinar classes CSS baseadas no status
    const getInputClasses = () => {
      const baseClasses = `w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 transition-colors ${className}`
      
      switch (status) {
        case 'invalid':
        case 'duplicate':
          return `${baseClasses} border-red-500 focus:ring-red-500 focus:border-red-500`
        case 'checking':
          return `${baseClasses} border-yellow-500 focus:ring-yellow-500 focus:border-yellow-500`
        case 'ok':
          return `${baseClasses} border-green-500 focus:ring-green-500 focus:border-green-500`
        default:
          return `${baseClasses} border-gray-300 focus:ring-blue-500 focus:border-blue-500`
      }
    }

    // Determinar mensagem de ajuda
    const getHelpMessage = () => {
      switch (status) {
        case 'idle':
          return { text: 'Digite o CPF ou CNPJ.', color: 'text-gray-500' }
        case 'invalid':
          return { text: 'CPF ou CNPJ inválido.', color: 'text-red-600' }
        case 'checking':
          return { text: 'Verificando…', color: 'text-yellow-600' }
        case 'duplicate':
          return { text: 'Este CPF/CNPJ já está cadastrado.', color: 'text-red-600' }
        case 'ok':
          return { text: 'CPF/CNPJ válido.', color: 'text-green-600' }
        default:
          return { text: '', color: 'text-gray-500' }
      }
    }

    const helpMessage = getHelpMessage()

    return (
      <div className="w-full">
        <div className="relative">
          <input
            type="text"
            value={value}
            onChange={handleChange}
            placeholder={placeholder}
            className={getInputClasses()}
            disabled={disabled}
            maxLength={18} // 00.000.000/0000-00 (CNPJ formatado)
            aria-invalid={status === 'invalid' || status === 'duplicate'}
            aria-describedby="cpf-cnpj-help"
          />
          
          {/* Indicador de carregamento */}
          {isChecking && (
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
              <div className="w-4 h-4 border-2 border-yellow-500 border-t-transparent rounded-full animate-spin"></div>
            </div>
          )}
        </div>
        
        {/* Mensagem de ajuda */}
        {helpMessage.text && (
          <p 
            id="cpf-cnpj-help"
            className={`mt-1 text-sm ${helpMessage.color}`}
            aria-live="polite"
          >
            {helpMessage.text}
          </p>
        )}
        
        {/* Card com dados do cliente encontrado */}
        {status === 'duplicate' && clienteEncontrado && (
          <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <h4 className="text-sm font-semibold text-red-800 mb-2">
                  Cliente já cadastrado:
                </h4>
                <div className="space-y-1 text-sm text-red-700">
                  <p><strong>Nome:</strong> {clienteEncontrado.nome}</p>
                  {clienteEncontrado.telefone && (
                    <p><strong>Telefone:</strong> {clienteEncontrado.telefone}</p>
                  )}
                  {clienteEncontrado.email && (
                    <p><strong>E-mail:</strong> {clienteEncontrado.email}</p>
                  )}
                  {clienteEncontrado.endereco && (
                    <p><strong>Endereço:</strong> {clienteEncontrado.endereco}</p>
                  )}
                  <p className="text-xs text-red-600">
                    <strong>Cadastrado em:</strong> {new Date(clienteEncontrado.criado_em).toLocaleDateString('pt-BR')}
                  </p>
                </div>
              </div>
              <div className="ml-3">
                <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center">
                  <svg className="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 15.5c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    )
  }
)

CpfInput.displayName = 'CpfInput'