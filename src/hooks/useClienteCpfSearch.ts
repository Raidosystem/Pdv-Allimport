import { useState, useEffect, useCallback } from 'react'
import { ClienteService } from '../services/clienteService'
import type { Cliente } from '../types/cliente'

export interface UseClienteCpfSearchResult {
  loading: boolean
  clientes: Cliente[]
  clienteExato: Cliente | null
  temDuplicatas: boolean
  erro: string | null
}

export function useClienteCpfSearch(cpf: string, enabled: boolean = true) {
  const [loading, setLoading] = useState(false)
  const [clientes, setClientes] = useState<Cliente[]>([])
  const [clienteExato, setClienteExato] = useState<Cliente | null>(null)
  const [erro, setErro] = useState<string | null>(null)

  const buscarPorCpf = useCallback(async (cpfBusca: string) => {
    if (!cpfBusca || !enabled) return

    // Limpar pontos e traços para busca
    const cpfLimpo = cpfBusca.replace(/\D/g, '')
    
    // Só buscar se tiver pelo menos 8 dígitos
    if (cpfLimpo.length < 8) {
      setClientes([])
      setClienteExato(null)
      setErro(null)
      return
    }

    setLoading(true)
    setErro(null)

    try {
      console.log('🔍 Buscando clientes por CPF:', cpfLimpo)
      
      // Buscar todos os clientes que tenham CPF que comece com os dígitos
      const resultados = await ClienteService.buscarPorCpf(cpfLimpo)
      
      console.log(`📋 Encontrados ${resultados.length} clientes`)
      
      setClientes(resultados)
      
      // Verificar se há um match exato (CPF completo - 11 ou 14 dígitos)
      if (cpfLimpo.length === 11 || cpfLimpo.length === 14) {
        const clienteExatoMatch = resultados.find((c: Cliente) => 
          c.cpf_cnpj?.replace(/\D/g, '') === cpfLimpo
        )
        setClienteExato(clienteExatoMatch || null)
      } else {
        setClienteExato(null)
      }
      
    } catch (error) {
      console.error('❌ Erro ao buscar por CPF:', error)
      setErro('Erro ao buscar cliente')
      setClientes([])
      setClienteExato(null)
    } finally {
      setLoading(false)
    }
  }, [enabled])

  // Debounce para evitar muitas requisições
  useEffect(() => {
    const timer = setTimeout(() => {
      buscarPorCpf(cpf)
    }, 500)

    return () => clearTimeout(timer)
  }, [cpf, buscarPorCpf])

  const temDuplicatas = clientes.length > 0
  
  return {
    loading,
    clientes,
    clienteExato,
    temDuplicatas,
    erro
  }
}