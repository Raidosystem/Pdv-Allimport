import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import type { OrdemServico, StatusOS, TipoEquipamento } from '../types/ordemServico'

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

  // Carregar ordens de serviço (mock data por enquanto)
  const carregarOS = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Mock data - em produção seria uma chamada real ao Supabase
      const mockData: OrdemServico[] = [
        {
          id: '1',
          cliente_id: '1',
          data_entrada: '2024-01-15',
          status: 'Em análise',
          tipo: 'Celular',
          marca: 'Samsung',
          modelo: 'Galaxy S23',
          defeito_relatado: 'Tela trincada',
          valor_orcamento: 250.00,
          checklist: { tela_quebrada: true, liga: true },
          usuario_id: '1',
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString(),
          cliente: {
            id: '1',
            nome: 'João Silva',
            telefone: '(11) 99999-9999',
            email: 'joao@email.com',
            cpf_cnpj: '123.456.789-00',
            endereco: 'Rua A, 123',
            cidade: 'São Paulo',
            estado: 'SP',
            cep: '01000-000',
            tipo: 'Física',
            ativo: true,
            criado_em: new Date().toISOString(),
            atualizado_em: new Date().toISOString()
          }
        },
        {
          id: '2',
          cliente_id: '2', 
          data_entrada: '2024-01-16',
          status: 'Em conserto',
          tipo: 'Notebook',
          marca: 'Dell',
          modelo: 'Inspiron 15',
          defeito_relatado: 'Não liga',
          valor_orcamento: 180.00,
          checklist: { liga: false },
          usuario_id: '1',
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString(),
          cliente: {
            id: '2',
            nome: 'Maria Santos',
            telefone: '(11) 88888-8888',
            email: 'maria@email.com',
            cpf_cnpj: '987.654.321-00',
            endereco: 'Rua B, 456',
            cidade: 'São Paulo',
            estado: 'SP',
            cep: '02000-000',
            tipo: 'Física',
            ativo: true,
            criado_em: new Date().toISOString(),
            atualizado_em: new Date().toISOString()
          }
        },
        {
          id: '3',
          cliente_id: '3',
          data_entrada: '2024-01-17',
          status: 'Pronto',
          tipo: 'Console',
          marca: 'Sony',
          modelo: 'PlayStation 5',
          defeito_relatado: 'Erro de leitura de disco',
          valor_orcamento: 320.00,
          checklist: { liga: true },
          usuario_id: '1',
          criado_em: new Date().toISOString(),
          atualizado_em: new Date().toISOString(),
          cliente: {
            id: '3',
            nome: 'Carlos Oliveira',
            telefone: '(11) 77777-7777',
            email: 'carlos@email.com',
            cpf_cnpj: '456.789.123-00',
            endereco: 'Rua C, 789',
            cidade: 'São Paulo',
            estado: 'SP',
            cep: '03000-000',
            tipo: 'Física',
            ativo: true,
            criado_em: new Date().toISOString(),
            atualizado_em: new Date().toISOString()
          }
        }
      ]
      
      setOrdensServico(mockData)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
      setError(errorMessage)
      toast.error(errorMessage)
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
          tipo: 'Física',
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
