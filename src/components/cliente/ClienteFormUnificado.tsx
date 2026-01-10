import React, { useState, useRef, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { onlyDigits } from '../../lib/cpf'
import { CpfInput, type CpfInputRef } from '../CpfInput'
import { toast } from 'react-hot-toast'
import { X, Save } from 'lucide-react'
import { useEmpresaId } from '../../hooks/useEmpresaId'

interface ClienteFormData {
  nome: string
  cpf: string
  email?: string
  telefone?: string
  rua?: string
  numero?: string
  cep?: string
  cidade?: string
  estado?: string
  endereco?: string // Manter para compatibilidade
}

interface ClienteFormUnificadoProps {
  empresaId?: string // Opcional - se não fornecido, usa o hook
  cliente?: any // Cliente para edição
  onSuccess?: (cliente: any) => void
  onCancel?: () => void
  isModal?: boolean
  titulo?: string
  showHeader?: boolean
  showToastOnSelect?: boolean // Nova prop para controlar toast
  allowClientEdit?: boolean // Nova prop para controlar se permite editar cliente encontrado
  showUseClientButton?: boolean // Nova prop para controlar se mostra botão "Usar Cliente"
}

export function ClienteFormUnificado({ 
  empresaId: empresaIdProp, 
  cliente,
  onSuccess, 
  onCancel,
  isModal = false,
  titulo = cliente ? "Editar Cliente" : "Novo Cliente",
  showHeader = true,
  showToastOnSelect = true,
  allowClientEdit = false, // Mudado para false - remover "Editar Dados" em todos os contextos
  showUseClientButton = true // VOLTOU para true - por padrão mostra o botão "Usar Cliente"
}: ClienteFormUnificadoProps) {
  // Usar hook para pegar empresa_id automaticamente se não foi fornecido
  const { empresaId: empresaIdFromHook } = useEmpresaId()
  const empresaId = empresaIdProp || empresaIdFromHook
  
  const [formData, setFormData] = useState<ClienteFormData>({
    nome: cliente?.nome || '',
    cpf: cliente?.cpf_cnpj || '',
    email: cliente?.email || '',
    telefone: cliente?.telefone || '',
    rua: cliente?.rua || '',
    numero: cliente?.numero || '',
    cep: cliente?.cep || '',
    cidade: cliente?.cidade || '',
    estado: cliente?.estado || '',
    endereco: cliente?.endereco || ''
  })
  
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isEditMode, setIsEditMode] = useState(!!cliente) // True se cliente foi passado
  const [cpfStatus, setCpfStatus] = useState<'idle' | 'invalid' | 'checking' | 'duplicate' | 'ok'>('idle')
  const [clienteEncontrado, setClienteEncontrado] = useState<any>(null)
  const cpfInputRef = useRef<CpfInputRef>(null)

  // Atualizar dados quando cliente prop mudar
  useEffect(() => {
    if (cliente) {
      // Se o endereço unificado existe mas não tem campos separados, deixar no campo endereco
      // Caso contrário, usar os campos separados
      const temCamposSeparados = cliente.logradouro || cliente.numero || cliente.cidade
      
      setFormData({
        nome: cliente.nome || '',
        cpf: cliente.cpf_cnpj || '',
        email: cliente.email || '',
        telefone: cliente.telefone || '',
        rua: cliente.logradouro || '', // CORRIGIDO: banco usa 'logradouro'
        numero: cliente.numero || '',
        cep: cliente.cep || '',
        cidade: cliente.cidade || '',
        estado: cliente.estado || '',
        // Se não tem campos separados, colocar o endereço completo no campo "endereco"
        endereco: cliente.bairro || (!temCamposSeparados ? (cliente.endereco || '') : '')
      })
      setIsEditMode(true)
    }
  }, [cliente])

  // Monitorar mudanças no status do CPF para atualizar os estados locais
  useEffect(() => {
    const interval = setInterval(() => {
      if (cpfInputRef.current) {
        const newStatus = cpfInputRef.current.status
        const newClienteEncontrado = cpfInputRef.current.clienteEncontrado || null
        
        if (newStatus !== cpfStatus) {
          console.log('🔍 [ClienteForm] Status CPF mudou:', newStatus)
          setCpfStatus(newStatus)
        }
        
        if (newClienteEncontrado !== clienteEncontrado) {
          console.log('🔍 [ClienteForm] Cliente encontrado mudou:', newClienteEncontrado)
          setClienteEncontrado(newClienteEncontrado)
        }
      }
    }, 100) // Verificar a cada 100ms

    return () => clearInterval(interval)
  }, [cpfStatus, clienteEncontrado])

  // Verificar se o formulário pode ser submetido
  const canSubmit = () => {
    const canSubmitValue = (
      formData.nome.trim().length > 0 &&
      !isSubmitting &&
      (formData.cpf.trim().length === 0 || cpfStatus === 'ok' || cpfStatus === 'idle') // CPF opcional: vazio ou válido
    )
    console.log('🔍 [DEBUG] canSubmit():', canSubmitValue, {
      nome: formData.nome.trim().length > 0,
      isSubmitting,
      cpfStatus,
      isEditMode
    })
    return canSubmitValue
  }

  // Buscar endereço via CEP
  const buscarEnderecoPorCep = async (cep: string) => {
    const cepDigits = cep.replace(/\D/g, '')
    if (cepDigits.length !== 8) return
    
    try {
      const response = await fetch(`https://viacep.com.br/ws/${cepDigits}/json/`)
      const data = await response.json()
      
      if (!data.erro) {
        setFormData(prev => ({
          ...prev,
          rua: data.logradouro || prev.rua,
          cidade: data.localidade || prev.cidade,
          estado: data.uf || prev.estado
        }))
        toast.success('Endereço encontrado!')
      }
    } catch (error) {
      console.log('Erro ao buscar CEP:', error)
    }
  }

  // Lidar com mudanças nos campos
  const handleInputChange = (field: keyof ClienteFormData) => (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    let value = e.target.value
    
    // Formatação especial para CEP
    if (field === 'cep') {
      // Remove tudo que não é número
      value = value.replace(/\D/g, '')
      // Aplica máscara 00000-000
      if (value.length > 5) {
        value = value.replace(/(\d{5})(\d{1,3})/, '$1-$2')
      }
      
      // Buscar endereço automaticamente quando CEP estiver completo
      const cepDigits = value.replace(/\D/g, '')
      if (cepDigits.length === 8) {
        buscarEnderecoPorCep(value)
      }
    }
    
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))
  }

  // Lidar com mudança no CPF
  const handleCpfChange = (value: string) => {
    setFormData(prev => ({
      ...prev,
      cpf: value
    }))
    
    // Se o CPF foi limpo, sair do modo de edição
    if (!value.trim()) {
      setIsEditMode(false)
    }
  }

  // Lidar com uso direto do cliente encontrado (sem editar)
  const handleUsarClienteEncontrado = (clienteEncontrado: any) => {
    if (!clienteEncontrado) return
    
    // Chamar callback de sucesso diretamente com o cliente encontrado
    if (onSuccess) {
      onSuccess(clienteEncontrado)
    }
    
    // Mostrar toast informativo apenas se solicitado
    if (showToastOnSelect) {
      toast.success(`Cliente "${clienteEncontrado.nome}" selecionado!`)
    }
  }

  // Lidar com edição do cliente encontrado
  const handleEditarClienteEncontrado = (clienteEncontrado: any) => {
    if (!clienteEncontrado) return
    
    // Preencher o formulário com os dados do cliente encontrado
    setFormData({
      nome: clienteEncontrado.nome || '',
      cpf: formData.cpf, // Manter o CPF digitado
      email: clienteEncontrado.email || '',
      telefone: clienteEncontrado.telefone || '',
      rua: clienteEncontrado.rua || '',
      numero: clienteEncontrado.numero || '',
      cep: clienteEncontrado.cep || '',
      cidade: clienteEncontrado.cidade || '',
      estado: clienteEncontrado.estado || '',
      endereco: clienteEncontrado.endereco || ''
    })
    
    // Marcar como modo de edição (isso esconderá os botões)
    setIsEditMode(true)
    
    // Mostrar toast informativo
    toast.success(`Editando dados do cliente "${clienteEncontrado.nome}"`)
  }

  // Submeter formulário
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    console.log('📝 [DEBUG] handleSubmit chamado', {
      isEditMode,
      cliente: cliente?.nome,
      clienteEncontrado: clienteEncontrado?.nome,
      formData: formData.nome,
      canSubmit: canSubmit()
    })
    
    if (!canSubmit()) {
      toast.error('Por favor, preencha o nome (obrigatório). Se informar CPF, deve ser válido.')
      return
    }

    setIsSubmitting(true)

    try {
      // Preparar dados para inserção/atualização
      const cpfDigits = onlyDigits(formData.cpf)
      
      // Determinar tipo baseado no CPF (se houver) - IMPORTANTE: usar minúsculas
      let tipo = 'fisica' // Padrão
      if (cpfDigits) {
        tipo = cpfDigits.length === 11 ? 'fisica' : cpfDigits.length === 14 ? 'juridica' : 'fisica'
      }
      
      // Montar endereço unificado a partir dos campos detalhados
      const montarEnderecoCompleto = () => {
        const partes = []
        if (formData.rua) partes.push(formData.rua)
        if (formData.numero) partes.push(`nº ${formData.numero}`)
        if (formData.cidade) partes.push(formData.cidade)
        if (formData.estado) partes.push(formData.estado)
        if (formData.cep) partes.push(`CEP: ${formData.cep}`)
        return partes.join(', ') || formData.endereco || null
      }

      const clienteData = {
        nome: formData.nome.trim(),
        cpf_cnpj: formData.cpf.trim() || null,
        cpf_digits: cpfDigits || null,
        email: formData.email?.trim() || null,
        telefone: formData.telefone?.trim() || null,
        logradouro: formData.rua?.trim() || null,
        numero: formData.numero?.trim() || null,
        bairro: formData.endereco?.trim() || null, // Usar campo endereco como bairro temporariamente
        cidade: formData.cidade?.trim() || null,
        estado: formData.estado?.trim() || null,
        cep: formData.cep?.trim() || null,
        empresa_id: empresaId || null,
        tipo,
        ativo: true
      }

      console.log('🔍 [DEBUG] Dados limpos do cliente:', clienteData)

      // Verificar se estamos editando um cliente existente
      if (isEditMode && (clienteEncontrado || cliente)) {
        // Usar cliente da prop ou clienteEncontrado (dupla funcionalidade)
        const clienteParaAtualizar = cliente || clienteEncontrado
        
        if (!clienteParaAtualizar?.id) {
          toast.error('ID do cliente não encontrado')
          return
        }

        console.log('🔍 [DEBUG] Dados do cliente a ser atualizado:', clienteData)

        // Chamar RPC para atualizar
        const { data, error } = await supabase.rpc('atualizar_cliente_seguro', {
          p_cliente_id: clienteParaAtualizar.id,
          p_nome: clienteData.nome,
          p_cpf_cnpj: clienteData.cpf_cnpj,
          p_cpf_digits: clienteData.cpf_digits,
          p_email: clienteData.email,
          p_telefone: clienteData.telefone,
          p_logradouro: clienteData.logradouro,
          p_numero: clienteData.numero,
          p_bairro: clienteData.bairro,
          p_cidade: clienteData.cidade,
          p_estado: clienteData.estado,
          p_cep: clienteData.cep,
          p_tipo: clienteData.tipo
        })

        console.log('📊 [DEBUG] Resultado da atualização:', { data, error })

        if (error) {
          console.error('Erro ao atualizar cliente:', error)
          toast.error(`Erro ao atualizar cliente: ${error.message}`)
          return
        }

        toast.success('Cliente atualizado com sucesso!')
        
        // Chamar callback de sucesso se fornecido
        if (onSuccess) {
          // Buscar o cliente completo atualizado
          const { data: clienteAtualizado, error: errorBusca } = await supabase
            .from('clientes')
            .select('*')
            .eq('id', clienteParaAtualizar.id)
            .single()
          
          if (!errorBusca && clienteAtualizado) {
            onSuccess(clienteAtualizado)
          } else {
            console.warn('⚠️ Erro ao buscar cliente atualizado, usando data do RPC:', errorBusca)
            onSuccess(data)
          }
        }
      } else {
        // Modo de criação de novo cliente
        console.log('🔍 [DEBUG] Dados do cliente a ser criado:', clienteData)

        // Chamar RPC para criar
        const { data, error } = await supabase.rpc('criar_cliente_seguro', {
          p_nome: clienteData.nome,
          p_cpf_cnpj: clienteData.cpf_cnpj,
          p_cpf_digits: clienteData.cpf_digits,
          p_email: clienteData.email,
          p_telefone: clienteData.telefone,
          p_logradouro: clienteData.logradouro,
          p_numero: clienteData.numero,
          p_bairro: clienteData.bairro,
          p_cidade: clienteData.cidade,
          p_estado: clienteData.estado,
          p_cep: clienteData.cep,
          p_empresa_id: clienteData.empresa_id,
          p_tipo: clienteData.tipo
        })

        console.log('📊 [DEBUG] Resultado da inserção:', { data, error })

        if (error) {
          // Verificar se é erro de duplicação
          if (error.message && error.message.includes('duplicate')) {
            toast.error('Este CPF já está cadastrado.')
            return
          }
          
          console.error('Erro ao criar cliente:', error)
          toast.error(`Erro ao criar cliente: ${error.message}`)
          return
        }

        toast.success('Cliente criado com sucesso!')
        
        // Chamar callback de sucesso se fornecido
        if (onSuccess) {
          // Buscar o cliente completo recém-criado
          const { data: clienteCriado, error: errorBusca } = await supabase
            .from('clientes')
            .select('*')
            .eq('id', data)
            .single()
          
          if (!errorBusca && clienteCriado) {
            onSuccess(clienteCriado)
          } else {
            console.warn('⚠️ Erro ao buscar cliente criado, usando ID do RPC:', errorBusca)
            onSuccess(data)
          }
        }
      }
      
      // Limpar formulário e resetar modo de edição
      setFormData({
        nome: '',
        cpf: '',
        email: '',
        telefone: '',
        rua: '',
        numero: '',
        cep: '',
        cidade: '',
        estado: '',
        endereco: ''
      })
      setIsEditMode(false)

    } catch (error) {
      console.error('Erro inesperado:', error)
      toast.error('Erro inesperado. Tente novamente.')
    } finally {
      setIsSubmitting(false)
    }
  }

  const containerClasses = isModal 
    ? "bg-white rounded-lg p-6" 
    : "max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-md"

  return (
    <div className={containerClasses}>
      {showHeader && (
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-900">
            {isEditMode ? 'Editar Cliente' : titulo}
          </h1>
          
          {onCancel && (
            <button
              type="button"
              onClick={() => {
                console.log('🔴 ClienteFormUnificado - Botão X clicado')
                onCancel()
              }}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          )}
        </div>
      )}

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
            CPF (opcional)
          </label>
          <CpfInput
            ref={cpfInputRef}
            value={formData.cpf}
            onChange={handleCpfChange}
            empresaId={empresaId || undefined}
            excludeId={cliente?.id} // Excluir o próprio cliente em modo de edição
            placeholder="000.000.000-00 (opcional)"
          />
          
          {/* Opções para cliente encontrado - só mostrar se não estiver em modo de edição */}
          {cpfStatus === 'duplicate' && clienteEncontrado && !isEditMode && (
            <div className="mt-3 space-y-2">
              <div className="p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                <p className="text-sm text-yellow-800 font-medium">Este CPF/CNPJ já está cadastrado.</p>
                <div className="mt-2 text-sm text-gray-700">
                  <p><strong>Cliente já cadastrado:</strong></p>
                  <p><strong>Nome:</strong> {clienteEncontrado.nome}</p>
                  {clienteEncontrado.telefone && <p><strong>Telefone:</strong> {clienteEncontrado.telefone}</p>}
                  {clienteEncontrado.endereco && <p><strong>Endereço:</strong> {clienteEncontrado.endereco}</p>}
                  {clienteEncontrado.criado_em && (
                    <p><strong>Cadastrado em:</strong> {new Date(clienteEncontrado.criado_em).toLocaleDateString('pt-BR')}</p>
                  )}
                </div>
              </div>
              
              {/* Mostrar botões apenas se showUseClientButton for true */}
              {showUseClientButton && (
                <div className="flex gap-3">
                  {/* Botão para usar o cliente encontrado */}
                  <button
                    type="button"
                    onClick={() => handleUsarClienteEncontrado(clienteEncontrado)}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Usar Cliente
                  </button>
                  
                  {/* Botão para editar cliente encontrado - só mostrar se allowClientEdit for true */}
                  {allowClientEdit && (
                    <button
                      type="button"
                      onClick={() => handleEditarClienteEncontrado(clienteEncontrado)}
                      className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
                    >
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                      Editar Dados
                    </button>
                  )}
                </div>
              )}
            </div>
          )}
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

        {/* Endereço Detalhado */}
        <div className="space-y-4">
          <h3 className="text-sm font-medium text-gray-700 border-b pb-2">Endereço</h3>
          
          {/* CEP primeiro para busca automática */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label htmlFor="cep" className="block text-sm font-medium text-gray-700 mb-1">
                CEP <span className="text-xs text-gray-500">(busca automática)</span>
              </label>
              <input
                type="text"
                id="cep"
                value={formData.cep}
                onChange={handleInputChange('cep')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="00000-000"
                maxLength={9}
              />
            </div>
            
            <div>
              <label htmlFor="cidade" className="block text-sm font-medium text-gray-700 mb-1">
                Cidade
              </label>
              <input
                type="text"
                id="cidade"
                value={formData.cidade}
                onChange={handleInputChange('cidade')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Nome da cidade"
              />
            </div>
            
            <div>
              <label htmlFor="estado" className="block text-sm font-medium text-gray-700 mb-1">
                Estado
              </label>
              <select
                id="estado"
                value={formData.estado}
                onChange={handleInputChange('estado')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Selecione</option>
                <option value="AC">Acre</option>
                <option value="AL">Alagoas</option>
                <option value="AP">Amapá</option>
                <option value="AM">Amazonas</option>
                <option value="BA">Bahia</option>
                <option value="CE">Ceará</option>
                <option value="DF">Distrito Federal</option>
                <option value="ES">Espírito Santo</option>
                <option value="GO">Goiás</option>
                <option value="MA">Maranhão</option>
                <option value="MT">Mato Grosso</option>
                <option value="MS">Mato Grosso do Sul</option>
                <option value="MG">Minas Gerais</option>
                <option value="PA">Pará</option>
                <option value="PB">Paraíba</option>
                <option value="PR">Paraná</option>
                <option value="PE">Pernambuco</option>
                <option value="PI">Piauí</option>
                <option value="RJ">Rio de Janeiro</option>
                <option value="RN">Rio Grande do Norte</option>
                <option value="RS">Rio Grande do Sul</option>
                <option value="RO">Rondônia</option>
                <option value="RR">Roraima</option>
                <option value="SC">Santa Catarina</option>
                <option value="SP">São Paulo</option>
                <option value="SE">Sergipe</option>
                <option value="TO">Tocantins</option>
              </select>
            </div>
          </div>

          {/* Rua e Número após CEP */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label htmlFor="rua" className="block text-sm font-medium text-gray-700 mb-1">
                Rua/Avenida
              </label>
              <input
                type="text"
                id="rua"
                value={formData.rua}
                onChange={handleInputChange('rua')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Nome da rua ou avenida"
              />
            </div>
            
            <div>
              <label htmlFor="numero" className="block text-sm font-medium text-gray-700 mb-1">
                Número
              </label>
              <input
                type="text"
                id="numero"
                value={formData.numero}
                onChange={handleInputChange('numero')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="123"
              />
            </div>
          </div>

          {/* Endereço Completo (opcional - para observações) */}
          <div>
            <label htmlFor="endereco" className="block text-sm font-medium text-gray-700 mb-1">
              Complemento (opcional)
            </label>
            <textarea
              id="endereco"
              value={formData.endereco}
              onChange={handleInputChange('endereco')}
              rows={2}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Apartamento, bloco, observações adicionais..."
            />
          </div>
        </div>

        {/* Status do formulário */}
        <div className="flex items-center justify-between pt-4 border-t">
          <div className="text-sm text-gray-600">
            {cpfStatus === 'ok' ? (
              <span className="text-green-600">✓ Formulário válido</span>
            ) : (
              <span className="text-gray-500">Preencha todos os campos obrigatórios</span>
            )}
          </div>

          <div className="flex gap-3">
            {onCancel && (
              <button
                type="button"
                onClick={() => {
                  console.log('🔴 ClienteFormUnificado - Botão Cancelar clicado')
                  onCancel()
                }}
                className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancelar
              </button>
            )}

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
                  {isEditMode ? 'Atualizando...' : 'Salvando...'}
                </span>
              ) : (
                <>
                  <Save className="w-4 h-4 inline mr-2" />
                  {isEditMode ? 'Atualizar Cliente' : 'Salvar Cliente'}
                </>
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  )
}