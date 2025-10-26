import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import type { OrdemServico, StatusOS, TipoEquipamento } from '../types/ordemServico'
import { supabase } from '../lib/supabase'

// Interface simplificada para o hook
interface OrdemServicoInput {
  cliente_nome: string
  cliente_telefone?: string
  tipo: TipoEquipamento
  marca: string
  modelo: string
  defeito_relatado: string
  observacoes?: string
  valor_orcamento?: number
  status?: StatusOS
}

export function useOrdemServico() {
  const [ordensServico, setOrdensServico] = useState<OrdemServico[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Carregar ordens de serviço do Supabase
  const carregarOS = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Buscar dados reais do Supabase
      const { data: ordensServico, error: osError } = await supabase
        .from('ordens_servico')
        .select(`
          *,
          clientes (
            id,
            nome,
            telefone,
            email,
            cpf_cnpj,
            endereco,
            cidade,
            estado,
            cep
          )
        `)
        .order('criado_em', { ascending: false })
      
      if (osError) {
        throw new Error(`Erro ao buscar ordens de serviço: ${osError.message}`)
      }
      
      // Mapear dados para o formato esperado
      const ordensFormatadas: OrdemServico[] = (ordensServico || []).map((os: any) => ({
        ...os,
        cliente: os.clientes ? {
          ...os.clientes,
          tipo: 'Física',
          ativo: true,
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString()
        } : undefined
      }))
      
      setOrdensServico(ordensFormatadas)
      
      if (ordensFormatadas.length === 0) {
        console.log('✅ Nenhuma ordem de serviço encontrada - sistema limpo!')
      }
      
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      setError(errorMessage)
      console.error('Erro ao carregar ordens de serviço:', errorMessage)
      
      // Em caso de erro, mostrar lista vazia ao invés de dados simulados
      setOrdensServico([])
    } finally {
      setLoading(false)
    }
  }

  // Criar OS
  const criarOS = async (osData: OrdemServicoInput) => {
    try {
      setLoading(true)
      
      const novaOS: OrdemServico = {
        id: Date.now().toString(),
        cliente_id: Date.now().toString(),
        data_entrada: new Date().toISOString().split('T')[0],
        status: osData.status || 'Em análise',
        tipo: osData.tipo,
        marca: osData.marca,
        modelo: osData.modelo,
        defeito_relatado: osData.defeito_relatado,
        observacoes: osData.observacoes,
        valor_orcamento: osData.valor_orcamento,
        checklist: { liga: true },
        usuario_id: '1',
        criado_em: new Date().toISOString(),
        atualizado_em: new Date().toISOString(),
        cliente: {
          id: Date.now().toString(),
          nome: osData.cliente_nome,
          telefone: osData.cliente_telefone || '',
          email: '',
          cpf_cnpj: '',
          endereco: '',
          cidade: '',
          estado: '',
          cep: '',
          tipo: 'fisica',
          ativo: true,
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString()
        }
      }
      
      setOrdensServico(prev => [novaOS, ...prev])
      toast.success('OS criada com sucesso!')
      return novaOS
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao criar OS'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Atualizar OS
  const atualizarOS = async (id: string, osData: Partial<OrdemServicoInput>) => {
    try {
      setLoading(true)
      
      setOrdensServico(prev => prev.map((os: OrdemServico) => 
        os.id === id 
          ? { 
              ...os, 
              status: osData.status || os.status,
              observacoes: osData.observacoes || os.observacoes,
              valor_orcamento: osData.valor_orcamento || os.valor_orcamento
            }
          : os
      ))
      
      toast.success('OS atualizada com sucesso!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao atualizar OS'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Deletar OS
  const deletarOS = async (id: string) => {
    try {
      setLoading(true)
      setOrdensServico(prev => prev.filter((os: OrdemServico) => os.id !== id))
      toast.success('OS deletada com sucesso!')
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao deletar OS'
      toast.error(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  // Buscar OS por ID
  const buscarOSPorId = async (id: string) => {
    return ordensServico.find((os: OrdemServico) => os.id === id) || null
  }

  // Carregar dados ao montar o componente
  useEffect(() => {
    carregarOS()
  }, [])

  return {
    ordensServico,
    loading,
    error,
    carregarOS,
    criarOS,
    atualizarOS,
    deletarOS,
    buscarOSPorId
  }
}
