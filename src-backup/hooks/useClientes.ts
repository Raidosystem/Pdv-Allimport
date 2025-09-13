import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { ClienteService } from '../services/clienteService'
import type { Cliente, ClienteInput, ClienteFilters } from '../types/cliente'

export function useClientes() {
  const [clientes, setClientes] = useState<Cliente[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Carregar clientes
  const carregarClientes = async (filtros: ClienteFilters = {}) => {
    try {
      setLoading(true)
      setError(null)
      const data = await ClienteService.buscarClientes(filtros)
      setClientes(data)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  // Criar cliente
  const criarCliente = async (cliente: ClienteInput) => {
    try {
      setLoading(true)
      
      // Verificar CPF/CNPJ duplicado se fornecido
      if (cliente.cpf_cnpj) {
        const existe = await ClienteService.verificarCpfCnpjExiste(cliente.cpf_cnpj)
        if (existe) {
          throw new Error('CPF/CNPJ já cadastrado para outro cliente')
        }
      }

      const novoCliente = await ClienteService.criarCliente(cliente)
      setClientes(prev => [novoCliente, ...prev])
      toast.success('Cliente criado com sucesso!')
      return novoCliente
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao criar cliente'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Atualizar cliente
  const atualizarCliente = async (id: string, cliente: Partial<ClienteInput>) => {
    try {
      setLoading(true)

      // Verificar CPF/CNPJ duplicado se fornecido
      if (cliente.cpf_cnpj) {
        const existe = await ClienteService.verificarCpfCnpjExiste(cliente.cpf_cnpj, id)
        if (existe) {
          throw new Error('CPF/CNPJ já cadastrado para outro cliente')
        }
      }

      const clienteAtualizado = await ClienteService.atualizarCliente(id, cliente)
      setClientes(prev => prev.map(c => c.id === id ? clienteAtualizado : c))
      toast.success('Cliente atualizado com sucesso!')
      return clienteAtualizado
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao atualizar cliente'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Deletar cliente
  const deletarCliente = async (id: string) => {
    try {
      setLoading(true)
      await ClienteService.deletarCliente(id)
      setClientes(prev => prev.filter(c => c.id !== id))
      toast.success('Cliente deletado com sucesso!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao deletar cliente'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Alternar status
  const alternarStatus = async (id: string, ativo: boolean) => {
    try {
      const clienteAtualizado = await ClienteService.alternarStatusCliente(id, ativo)
      setClientes(prev => prev.map(c => c.id === id ? clienteAtualizado : c))
      toast.success(`Cliente ${ativo ? 'ativado' : 'desativado'} com sucesso!`)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao alterar status'
      toast.error(errorMessage)
    }
  }

  // Buscar cliente por ID
  const buscarClientePorId = async (id: string) => {
    try {
      setLoading(true)
      return await ClienteService.buscarClientePorId(id)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao buscar cliente'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Carregar clientes na inicialização
  useEffect(() => {
    carregarClientes()
  }, [])

  return {
    clientes,
    loading,
    error,
    carregarClientes,
    criarCliente,
    atualizarCliente,
    deletarCliente,
    alternarStatus,
    buscarClientePorId
  }
}
