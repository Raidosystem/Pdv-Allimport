import { useState, useEffect } from 'react'
import { ordemServicoService } from '../services/ordemServicoService'
import type { OrdemServico, FiltrosOS } from '../types/ordemServico'

export function useOrdensServico(filtros?: FiltrosOS) {
  const [ordens, setOrdens] = useState<OrdemServico[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const carregarOrdens = async () => {
    setLoading(true)
    setError(null)
    
    try {
      const dados = await ordemServicoService.buscarOrdens(filtros)
      setOrdens(dados)
    } catch (err: any) {
      console.error('Erro ao carregar ordens:', err)
      setError(err.message || 'Erro ao carregar ordens de serviço')
    } finally {
      setLoading(false)
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
    } catch (err: any) {
      console.error('Erro ao carregar ordem:', err)
      setError(err.message || 'Erro ao carregar ordem de serviço')
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
    entregues: 0
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
