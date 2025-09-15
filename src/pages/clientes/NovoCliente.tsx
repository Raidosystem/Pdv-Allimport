import React, { useState, useRef } from 'react'
import { supabase } from '../../lib/supabase'
import { onlyDigits } from '../../lib/cpf'
import { CpfInput, type CpfInputRef } from '../../components/CpfInput'
import { toast } from 'react-hot-toast'

interface NovoClienteFormData {
  nome: string
  cpf: string
  email?: string
  telefone?: string
  endereco?: string
}

interface NovoClientePageProps {
  empresaId?: string
  onSuccess?: (cliente: any) => void
  onCancel?: () => void
}

export function NovoClientePage({ empresaId, onSuccess, onCancel }: NovoClientePageProps) {
  const [formData, setFormData] = useState<NovoClienteFormData>({
    nome: '',
    cpf: '',
    email: '',
    telefone: '',
    endereco: ''
  })
  
  const [isSubmitting, setIsSubmitting] = useState(false)
  const cpfInputRef = useRef<CpfInputRef>(null)

  // Verificar se o formulário pode ser submetido
  const canSubmit = () => {
    return (
      formData.nome.trim().length > 0 &&
      formData.cpf.trim().length > 0 &&
      cpfInputRef.current?.isCpfOk === true &&
      !isSubmitting
    )
  }

  // Lidar com mudanças nos campos
  const handleInputChange = (field: keyof NovoClienteFormData) => (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData(prev => ({
      ...prev,
      [field]: e.target.value
    }))
  }

  // Lidar com mudança no CPF
  const handleCpfChange = (value: string) => {
    setFormData(prev => ({
      ...prev,
      cpf: value
    }))
  }

  // Submeter formulário
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!canSubmit()) {
      toast.error('Por favor, preencha todos os campos obrigatórios e verifique o CPF.')
      return
    }

    setIsSubmitting(true)

    try {
      // Preparar dados para inserção
      const cpfDigits = onlyDigits(formData.cpf)
      
      const clienteData = {
        nome: formData.nome.trim(),
        cpf_digits: cpfDigits,
        email: formData.email?.trim() || null,
        telefone: formData.telefone?.trim() || null,
        endereco: formData.endereco?.trim() || null,
        ...(empresaId && { empresa_id: empresaId }),
        tipo: 'Física', // Assumindo pessoa física para CPF
        ativo: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }

      const { data, error } = await supabase
        .from('clientes')
        .insert([clienteData])
        .select()
        .single()

      if (error) {
        // Verificar se é erro de duplicação
        if (error.code === '23505') { // Unique violation
          toast.error('Este CPF já está cadastrado.')
          return
        }
        
        console.error('Erro ao criar cliente:', error)
        toast.error('Erro ao criar cliente. Tente novamente.')
        return
      }

      toast.success('Cliente criado com sucesso!')
      
      // Limpar formulário
      setFormData({
        nome: '',
        cpf: '',
        email: '',
        telefone: '',
        endereco: ''
      })

      // Chamar callback de sucesso se fornecido
      if (onSuccess) {
        onSuccess(data)
      }

    } catch (error) {
      console.error('Erro inesperado:', error)
      toast.error('Erro inesperado. Tente novamente.')
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Novo Cliente</h1>
          
          {onCancel && (
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </button>
          )}
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Nome */}
          <div>
            <label htmlFor="nome" className="block text-sm font-medium text-gray-700 mb-1">
              Nome Completo *
            </label>
            <input
              type="text"
              id="nome"
              value={formData.nome}
              onChange={handleInputChange('nome')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Digite o nome completo"
              required
            />
          </div>

          {/* CPF */}
          <div>
            <label htmlFor="cpf" className="block text-sm font-medium text-gray-700 mb-1">
              CPF *
            </label>
            <CpfInput
              ref={cpfInputRef}
              value={formData.cpf}
              onChange={handleCpfChange}
              empresaId={empresaId}
              placeholder="000.000.000-00"
            />
          </div>

          {/* Email */}
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
              Email
            </label>
            <input
              type="email"
              id="email"
              value={formData.email}
              onChange={handleInputChange('email')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="email@exemplo.com"
            />
          </div>

          {/* Telefone */}
          <div>
            <label htmlFor="telefone" className="block text-sm font-medium text-gray-700 mb-1">
              Telefone
            </label>
            <input
              type="tel"
              id="telefone"
              value={formData.telefone}
              onChange={handleInputChange('telefone')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="(11) 99999-9999"
            />
          </div>

          {/* Endereço */}
          <div>
            <label htmlFor="endereco" className="block text-sm font-medium text-gray-700 mb-1">
              Endereço
            </label>
            <textarea
              id="endereco"
              value={formData.endereco}
              onChange={handleInputChange('endereco')}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Endereço completo"
            />
          </div>

          {/* Status do formulário */}
          <div className="flex items-center justify-between pt-4 border-t">
            <div className="text-sm text-gray-600">
              {cpfInputRef.current?.isCpfOk ? (
                <span className="text-green-600">✓ Formulário válido</span>
              ) : (
                <span className="text-gray-500">Preencha todos os campos obrigatórios</span>
              )}
            </div>

            <button
              type="submit"
              disabled={!canSubmit()}
              className={`px-6 py-2 rounded-lg font-medium transition-colors ${
                canSubmit()
                  ? 'bg-blue-600 hover:bg-blue-700 text-white'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              {isSubmitting ? (
                <span className="flex items-center gap-2">
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  Salvando...
                </span>
              ) : (
                'Salvar Cliente'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}