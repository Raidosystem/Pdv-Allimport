import { useState, useEffect } from 'react'
import { ordemServicoService } from '../services/ordemServicoService'
import type { OrdemServico, FiltrosOS } from '../types/ordemServico'

export function useOrdensServico(filtros?: FiltrosOS) {
  const [ordens, setOrdens] = useState<OrdemServico[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const carregarOrdens = async () => {
    const timestamp = Date.now()
    console.log('🔄 [Hook] Carregando ordens de serviço... Timestamp:', timestamp)
    setLoading(true)
    setError(null)
    
    try {
      const dados = await ordemServicoService.buscarOrdens(filtros)
      console.log('📋 [Hook] Ordens carregadas:', dados.length)
      console.log('📋 [Hook] Status das ordens:', dados.map(o => ({ 
        id: o.id.slice(-6), 
        status: o.status,
        data_entrega: o.data_entrega
      })))
      setOrdens(dados)
    } catch (err: unknown) {
      console.error('❌ [Hook] Erro ao carregar ordens:', err)
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar ordens de serviço'
      setError(errorMessage)
    } finally {
      setLoading(false)
      console.log('✅ [Hook] Carregamento finalizado')
    }
  }

  useEffect(() => {
    carregarOrdens()
  }, [filtros])

  const recarregar = () => {
    carregarOrdens()
  }

  return {
    ordens,
    loading,
    error,
    recarregar
  }
}

export function useOrdemServico(id: string) {
  const [ordem, setOrdem] = useState<OrdemServico | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const carregarOrdem = async () => {
    if (!id) return
    
    setLoading(true)
    setError(null)
    
    try {
      const dados = await ordemServicoService.buscarPorId(id)
      setOrdem(dados)
    } catch (err: unknown) {
      console.error('Erro ao carregar ordem:', err)
      const errorMessage = err instanceof Error ? err.message : 'Erro ao carregar ordem de serviço'
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    carregarOrdem()
  }, [id])

  const recarregar = () => {
    carregarOrdem()
  }

  return {
    ordem,
    loading,
    error,
    recarregar
  }
}

export function useEstatisticasOS() {
  const [estatisticas, setEstatisticas] = useState({
    total: 0,
    emAnalise: 0,
    emConserto: 0,
    prontos: 0,
    encerradas: 0
  })
  const [loading, setLoading] = useState(true)

  const carregarEstatisticas = async () => {
    setLoading(true)
    
    try {
      const dados = await ordemServicoService.obterEstatisticas()
      setEstatisticas(dados)
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    carregarEstatisticas()
  }, [])

  return {
    estatisticas,
    loading,
    recarregar: carregarEstatisticas
  }
}
