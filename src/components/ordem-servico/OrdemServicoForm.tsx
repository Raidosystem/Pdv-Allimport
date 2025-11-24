import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  Settings,
  Calendar,
  DollarSign,
  Save,
  History,
  Smartphone,
  Plus,
  X
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ClienteSelector } from '../ui/ClienteSelectorSimples'
import { SenhaDesenho } from './SenhaDesenho'
import { ordemServicoService } from '../../services/ordemServicoService'
import * as checklistTemplateService from '../../services/checklistTemplateService'
import { supabase } from '../../lib/supabase'
import type { 
  NovaOrdemServicoForm, 
  TipoEquipamento 
} from '../../types/ordemServico'
import type { Cliente } from '../../types/cliente'

// Schema de validação
const ordemServicoSchema = z.object({
  tipo: z.enum(['Celular', 'Notebook', 'Console', 'Tablet', 'Outro']),
  marca: z.string().min(2, 'Marca é obrigatória'),
  modelo: z.string().min(2, 'Modelo é obrigatório'),
  cor: z.string().optional(),
  numero_serie: z.string().optional(),
  defeito_relatado: z.string().min(5, 'Defeito relatado é obrigatório (mínimo 5 caracteres)'),
  observacoes: z.string().optional(),
  data_previsao: z.string().optional().refine((val) => {
    // Se for uma string vazia, permitir
    if (!val || val === '') return true
    // Se tiver valor, deve ser uma data válida
    const date = new Date(val)
    return !isNaN(date.getTime())
  }, 'Data deve ser válida'),
  valor_orcamento: z.number().min(0, 'Valor deve ser positivo').optional()
})

type FormData = z.infer<typeof ordemServicoSchema>

interface OrdemServicoFormProps {
  ordem?: any // Ordem para edição
  onSuccess?: (ordem: Record<string, unknown>) => void
  onCancel?: () => void
}

const TIPOS_EQUIPAMENTO_BASE: { value: TipoEquipamento; label: string }[] = [
  { value: 'Celular', label: 'Celular' },
  { value: 'Notebook', label: 'Notebook' },
  { value: 'Console', label: 'Console' },
  { value: 'Tablet', label: 'Tablet' }
]

// ✅ CHECKLIST PADRÃO FIXO - Aparece em todas as OS
const CHECKLIST_PADRAO = [
  { id: 'aparelho_liga', label: 'Aparelho liga?' },
  { id: 'tela_funciona', label: 'Tela funciona?' },
  { id: 'touch_funciona', label: 'Touch funciona?' },
  { id: 'bateria_ok', label: 'Bateria OK?' },
  { id: 'camera_ok', label: 'Câmera OK?' },
  { id: 'audio_ok', label: 'Áudio OK?' },
  { id: 'botoes_ok', label: 'Botões OK?' },
  { id: 'wifi_ok', label: 'Wi-Fi OK?' },
  { id: 'bluetooth_ok', label: 'Bluetooth OK?' },
  { id: 'carregamento_ok', label: 'Carregamento OK?' }
]

export function OrdemServicoForm({ ordem, onSuccess, onCancel }: OrdemServicoFormProps) {
  console.log('🏗️ [COMPONENT] OrdemServicoForm montado/renderizado', ordem ? 'EDITANDO' : 'NOVO')
  
  const [loading, setLoading] = useState(false)
  const [clienteSelecionado, setClienteSelecionado] = useState<Cliente | null>(null)
  const [checklist, setChecklist] = useState<Record<string, boolean>>({})
  const [tipoPersonalizado, setTipoPersonalizado] = useState('')
  const [mostrarCampoPersonalizado, setMostrarCampoPersonalizado] = useState(false)
  
  // Estados para senha do aparelho
  const [tipoSenha, setTipoSenha] = useState<'nenhuma' | 'texto' | 'pin' | 'desenho'>('nenhuma')
  const [senhaTexto, setSenhaTexto] = useState('')
  const [senhaPIN, setSenhaPIN] = useState('')
  const [senhaDesenho, setSenhaDesenho] = useState<string>('') // Base64 da imagem do desenho
  
  // Estados para autocomplete de aparelhos
  const [marcaSugestoes, setMarcaSugestoes] = useState<string[]>([])
  const [modeloSugestoes, setModeloSugestoes] = useState<string[]>([])
  const [marcaBusca, setMarcaBusca] = useState('')
  const [modeloBusca, setModeloBusca] = useState('')
  const [aparelhosCadastrados, setAparelhosCadastrados] = useState<Array<{
    tipo: string
    marca: string
    modelo: string
    cor?: string
  }>>([])
  
  // Estados para checklist dinâmico - CARREGA DO BANCO DE DADOS
  const [itensChecklist, setItensChecklist] = useState<Array<{id: string, label: string}>>([])
  const [carregandoChecklist, setCarregandoChecklist] = useState(true)
  const [novoItemChecklist, setNovoItemChecklist] = useState('')
  const [mostrandoFormNovoItem, setMostrandoFormNovoItem] = useState(false)
  
  // Estado para o status da ordem
  const [statusOrdem, setStatusOrdem] = useState<'Fazendo orçamento' | 'Em conserto' | 'Pronto'>('Fazendo orçamento')
  
  const [equipamentosAnteriores, setEquipamentosAnteriores] = useState<Array<{
    tipo: string
    marca: string
    modelo: string
    cor?: string
    defeitos: string[]
    ordens: Array<{
      id: string
      data: string
      defeito: string
      status: string
      valor?: number
    }>
    totalReparos: number
  }>>([])

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
    getValues,
    reset
  } = useForm<FormData>({
    resolver: zodResolver(ordemServicoSchema),
    defaultValues: {
      tipo: 'Celular'
    }
  })

  // ✅ Carregar template de checklist do banco de dados
  useEffect(() => {
    const carregarChecklistTemplate = async () => {
      console.log('📋 [CHECKLIST] Carregando template do banco de dados...')
      setCarregandoChecklist(true)
      try {
        const items = await checklistTemplateService.buscarTemplateChecklist()
        console.log('✅ [CHECKLIST] Template carregado com', items.length, 'itens')
        setItensChecklist(items.map(item => ({ id: item.id, label: item.label })))
      } catch (error) {
        console.error('❌ [CHECKLIST] Erro ao carregar template:', error)
        toast.error('Erro ao carregar checklist personalizado')
      } finally {
        setCarregandoChecklist(false)
      }
    }
    
    carregarChecklistTemplate()
  }, [])

  // Buscar todos os aparelhos cadastrados no Supabase
  useEffect(() => {
    const buscarAparelhosCadastrados = async () => {
      try {
        const data = await ordemServicoService.buscarOrdens()
        
        if (data) {
          // Extrair aparelhos únicos
          const aparelhosUnicos = new Map<string, {tipo: string, marca: string, modelo: string, cor?: string}>()
          
          data.forEach((ordem: any) => {
            const chave = `${ordem.tipo}-${ordem.marca}-${ordem.modelo}`
            if (!aparelhosUnicos.has(chave)) {
              aparelhosUnicos.set(chave, {
                tipo: ordem.tipo,
                marca: ordem.marca,
                modelo: ordem.modelo,
                cor: ordem.cor
              })
            }
          })
          
          setAparelhosCadastrados(Array.from(aparelhosUnicos.values()))
          console.log('📱 Aparelhos cadastrados carregados:', aparelhosUnicos.size)
        }
      } catch (error) {
        console.error('Erro ao buscar aparelhos:', error)
      }
    }
    
    buscarAparelhosCadastrados()
  }, [])

  // Popular formulário quando estiver editando uma ordem (padrão igual ClienteForm)
  useEffect(() => {
    if (ordem) {
      console.log('✏️ [EDITAR] Populando formulário com ordem:', ordem)
      console.log('✏️ [EDITAR] Dados do aparelho:', {
        tipo: ordem.tipo,
        marca: ordem.marca,
        modelo: ordem.modelo,
        cor: ordem.cor,
        numero_serie: ordem.numero_serie,
        defeito_relatado: ordem.defeito_relatado,
        observacoes: ordem.observacoes
      })
      
      // Popular campos do formulário usando reset para forçar re-render
      reset({
        tipo: ordem.tipo || 'Celular',
        marca: ordem.marca || '',
        modelo: ordem.modelo || '',
        cor: ordem.cor || '',
        numero_serie: ordem.numero_serie || '',
        defeito_relatado: ordem.defeito_relatado || ordem.descricao_problema || '',
        observacoes: ordem.observacoes || '',
        data_previsao: ordem.data_previsao || '',
        valor_orcamento: ordem.valor_orcamento || 0
      })
      
      console.log('✅ [EDITAR] reset() chamado com todos os campos')
      console.log('🎨 [COR] Valor da cor:', ordem.cor, '- Reset com:', ordem.cor || '')
      
      // Popular campos de busca para exibição visual
      setMarcaBusca(ordem.marca || '')
      setModeloBusca(ordem.modelo || '')
      
      // Carregar status (apenas se for um dos editáveis)
      if (ordem.status && ['Fazendo orçamento', 'Em conserto', 'Pronto'].includes(ordem.status)) {
        setStatusOrdem(ordem.status as 'Fazendo orçamento' | 'Em conserto' | 'Pronto')
      }
      
      // Se houver cliente, setar
      if (ordem.cliente) {
        setClienteSelecionado(ordem.cliente)
      }
      
      // Se houver checklist, setar (pode ser objeto ou array)
      if (ordem.checklist) {
        console.log('📋 [CHECKLIST] Dados recebidos:', ordem.checklist)
        console.log('📋 [CHECKLIST] Tipo:', typeof ordem.checklist)
        
        if (typeof ordem.checklist === 'object' && !Array.isArray(ordem.checklist)) {
          // Se for objeto Record<string, boolean>, usar direto
          console.log('📋 [CHECKLIST] Setando checklist como objeto')
          setChecklist(ordem.checklist as Record<string, boolean>)
        } else if (Array.isArray(ordem.checklist)) {
          // Se for array, converter para objeto
          console.log('📋 [CHECKLIST] Convertendo array para objeto')
          const checklistObj: Record<string, boolean> = {}
          ordem.checklist.forEach((item: any) => {
            if (typeof item === 'object' && item.id !== undefined) {
              checklistObj[item.id] = item.checked || false
            }
          })
          setChecklist(checklistObj)
        }
      } else {
        console.log('📋 [CHECKLIST] Nenhum checklist encontrado, iniciando vazio')
        setChecklist({})
      }
      
      // Carregar senha do aparelho se existir
      if (ordem.senha_aparelho) {
        console.log('🔐 [SENHA] Dados recebidos:', ordem.senha_aparelho)
        const senhaData = ordem.senha_aparelho
        
        if (senhaData.tipo) {
          setTipoSenha(senhaData.tipo)
          
          if (senhaData.tipo === 'texto' && senhaData.valor) {
            setSenhaTexto(senhaData.valor)
          } else if (senhaData.tipo === 'pin' && senhaData.valor) {
            setSenhaPIN(senhaData.valor)
          } else if (senhaData.tipo === 'desenho' && senhaData.valor) {
            setSenhaDesenho(senhaData.valor)
          }
        }
      }
      
      console.log('✅ [EDITAR] Formulário totalmente populado')
      
      // Verificar valores após popular
      setTimeout(() => {
        const valoresAtuais = getValues()
        console.log('� [DEBUG] Valores do formulário após popular:', valoresAtuais)
      }, 50)
    } else {
      console.log('📝 [NOVO] Modo de criação - formulário limpo')
      // Limpar formulário completamente
      reset({
        tipo: 'Celular',
        marca: '',
        modelo: '',
        cor: '',
        numero_serie: '',
        defeito_relatado: '',
        observacoes: '',
        data_previsao: '',
        valor_orcamento: 0
      })
    }
  }, [ordem, reset, getValues])
  
  // Monitorar o campo cor especificamente
  useEffect(() => {
    const valorCor = watch('cor')
    console.log('🎨 [COR WATCH] Valor atual do campo cor:', valorCor)
  }, [watch('cor')])
  
  // Monitorar mudanças nos campos do formulário
  useEffect(() => {
    const subscription = watch((value, { name }) => {
      if (name === 'marca' || name === 'modelo') {
        console.log(`� [WATCH] Campo ${name} mudou para:`, value[name])
      }
    })
    return () => subscription.unsubscribe()
  }, [watch])

  // Filtrar marcas baseado na busca (NÃO mostrar em modo de edição inicialmente)
  useEffect(() => {
    // Se estiver editando e ainda não interagiu, não mostrar sugestões
    if (ordem && marcaBusca === ordem.marca) {
      setMarcaSugestoes([])
      return
    }
    
    if (marcaBusca && marcaBusca.length >= 2) {
      const marcasUnicas = [...new Set(aparelhosCadastrados.map(a => a.marca))]
      const filtradas = marcasUnicas.filter(marca => 
        (marca || '').toLowerCase().includes((marcaBusca || '').toLowerCase())
      )
      setMarcaSugestoes(filtradas.slice(0, 5))
    } else {
      setMarcaSugestoes([])
    }
  }, [marcaBusca, aparelhosCadastrados, ordem])

  // Filtrar modelos baseado na busca e marca selecionada (NÃO mostrar em modo de edição inicialmente)
  useEffect(() => {
    // Se estiver editando e ainda não interagiu, não mostrar sugestões
    if (ordem && modeloBusca === ordem.modelo) {
      setModeloSugestoes([])
      return
    }
    
    if (modeloBusca && modeloBusca.length >= 2) {
      const aparelhosDaMarca = marcaBusca 
        ? aparelhosCadastrados.filter(a => (a.marca || '').toLowerCase() === (marcaBusca || '').toLowerCase())
        : aparelhosCadastrados
      
      const modelosUnicos = [...new Set(aparelhosDaMarca.map(a => a.modelo))]
      const filtrados = modelosUnicos.filter(modelo => 
        (modelo || '').toLowerCase().includes((modeloBusca || '').toLowerCase())
      )
      setModeloSugestoes(filtrados.slice(0, 5))
    } else {
      setModeloSugestoes([])
    }
  }, [modeloBusca, marcaBusca, aparelhosCadastrados, ordem])

  // Função para buscar equipamentos anteriores do cliente no Supabase
  const buscarEquipamentosAnteriores = async (clienteId: string) => {
    try {
      console.log('🔍 [BUSCAR EQUIPAMENTOS] ============ INICIANDO ===========')
      console.log('🔍 [BUSCAR EQUIPAMENTOS] Iniciando busca para:', clienteId)
      console.log('🔍 [BUSCAR EQUIPAMENTOS] Cliente selecionado completo:', clienteSelecionado)
      console.log('🔍 [BUSCAR EQUIPAMENTOS] Função chamada com sucesso!')
      
      // Buscar todas as ordens do Supabase
      const ordens = await ordemServicoService.buscarOrdens()
      
      console.log('📋 [BUSCAR EQUIPAMENTOS] Total de ordens retornadas:', ordens?.length || 0)
      
      if (!ordens || ordens.length === 0) {
        console.log('❌ [BUSCAR EQUIPAMENTOS] Nenhuma ordem encontrada no Supabase')
        setEquipamentosAnteriores([])
        return
      }

      // Log das primeiras 3 ordens para debug
      console.log('� [BUSCAR EQUIPAMENTOS] Primeiras 3 ordens:', ordens.slice(0, 3).map((o: any) => ({
        id: o.id,
        cliente_id: o.cliente_id,
        client_name: o.client_name,
        cliente_nome: o.cliente_nome,
        tipo: o.tipo,
        marca: o.marca,
        modelo: o.modelo
      })))
      
      // 🆕 LOG CRÍTICO: Verificar se ALGUMA ordem tem cliente_id
      const ordensComClienteId = ordens.filter((o: any) => o.cliente_id).length
      const ordensComClientName = ordens.filter((o: any) => o.client_name && o.client_name !== 'Cliente não informado').length
      console.log('🔍 [ANÁLISE] Das 328 ordens:')
      console.log(`   - ${ordensComClienteId} têm cliente_id preenchido`)
      console.log(`   - ${ordensComClientName} têm client_name válido`)
      console.log(`   - Exemplo de ordem COM dados:`, ordens.find((o: any) => o.cliente_id))
      
      // 🆕 VERIFICAR se alguma ordem tem o cliente_id que estamos procurando
      const ordensComEsteCliente = ordens.filter((o: any) => o.cliente_id === clienteId)
      console.log(`🔎 [VERIFICAÇÃO] Ordens com cliente_id = ${clienteId}:`, ordensComEsteCliente.length)
      
      // Se não encontrou por ID, listar os IDs únicos para debug
      if (ordensComEsteCliente.length === 0) {
        const idsUnicos = [...new Set(ordens.map((o: any) => o.cliente_id))].slice(0, 20)
        console.log('📋 [DEBUG] Primeiros 20 cliente_id diferentes nas ordens:', idsUnicos)
        console.log('🎯 [DEBUG] Cliente que estamos buscando:', clienteId, '-', clienteSelecionado?.nome)
        
        // 🆕 VERIFICAR: Buscar nos clientes se esses IDs existem
        console.log('🔍 [INVESTIGAÇÃO] Buscando quais desses IDs correspondem a clientes cadastrados...')
        const { data: clientesExistentes } = await supabase
          .from('clientes')
          .select('id, nome, cpf_cnpj, telefone')
          .in('id', idsUnicos.slice(0, 10))
        
        console.log('📊 [RESULTADO] Clientes encontrados para esses IDs:', clientesExistentes?.length || 0)
        if (clientesExistentes && clientesExistentes.length > 0) {
          console.log('👥 [CLIENTES] Primeiros clientes das ordens:')
          clientesExistentes.slice(0, 5).forEach((c: any, i: number) => {
            console.log(`   ${i + 1}. ${c.nome} (ID: ${c.id}) - CPF: ${c.cpf_cnpj}`)
          })
        }
        
        // 🆕 VERIFICAR: Cliente com mesmo CPF/telefone mas ID diferente?
        console.log('🔍 [INVESTIGAÇÃO] Buscando se existe outro cliente com mesmo CPF ou telefone...')
        const { data: clientesDuplicados } = await supabase
          .from('clientes')
          .select('id, nome, cpf_cnpj, telefone, created_at')
          .or(`cpf_cnpj.eq.${clienteSelecionado?.cpf_cnpj},telefone.eq.${clienteSelecionado?.telefone}`)
          .order('created_at', { ascending: false })
        
        console.log(`🔎 [DUPLICAÇÃO] Resultado da busca:`, clientesDuplicados?.length || 0, 'registros encontrados')
        
        if (clientesDuplicados && clientesDuplicados.length > 1) {
          console.log('⚠️ [DUPLICAÇÃO DETECTADA] Encontrados', clientesDuplicados.length, 'clientes com mesmo CPF/telefone:')
          clientesDuplicados.forEach((c: any, i: number) => {
            const isAtual = c.id === clienteId ? '⭐ ATUAL' : ''
            console.log(`   ${i + 1}. ID: ${c.id} ${isAtual}`)
            console.log(`      Nome: ${c.nome}`)
            console.log(`      CPF: ${c.cpf_cnpj} | Tel: ${c.telefone}`)
            console.log(`      Criado em: ${c.created_at}`)
          })
        } else if (clientesDuplicados && clientesDuplicados.length === 1) {
          console.log('✅ [DUPLICAÇÃO] Apenas 1 cliente encontrado - SEM duplicação')
        } else {
          console.log('❌ [DUPLICAÇÃO] NENHUM cliente encontrado com esse CPF/telefone!')
        }
      }
      
      // Buscar ordens onde o cliente_id OU usuario_id corresponda ao ID do cliente
      console.log('🔎 [DEBUG] Buscando com clienteId:', clienteId, 'e nome:', clienteSelecionado?.nome)
      
      const ordensDoCliente = ordens.filter((ordem: any) => {
        // Tentar match por ID do cliente
        if (ordem.cliente_id === clienteId || ordem.usuario_id === clienteId || ordem.user_id === clienteId) {
          console.log('✅ Match por ID:', ordem.id)
          return true
        }
        
        // Tentar match por nome
        const nomeClienteBusca = clienteSelecionado?.nome?.toLowerCase() || ''
        if (nomeClienteBusca) {
          const nomes = [
            ordem.client_name,
            ordem.cliente_nome,
            typeof ordem.cliente === 'string' ? ordem.cliente : ordem.cliente?.nome
          ].filter(Boolean)
          
          for (const nome of nomes) {
            const nomeStr = String(nome).toLowerCase()
            if (nomeStr.includes(nomeClienteBusca)) {
              console.log('✅ Match por nome:', ordem.id, 'Nome encontrado:', nomeStr)
              return true
            }
          }
        }
        
        return false
      })

      console.log('📱 [BUSCAR EQUIPAMENTOS] Ordens deste cliente:', ordensDoCliente.length)

      if (ordensDoCliente.length === 0) {
        console.log('⚠️ [BUSCAR EQUIPAMENTOS] Nenhuma ordem encontrada pelo ID ou nome')
        
        // 🆕 ESTRATÉGIA ALTERNATIVA: Buscar TODOS os IDs de clientes com mesmo CPF/telefone
        console.log('🔄 [BUSCAR ÓRFÃS] Buscando outros IDs do mesmo cliente (CPF/telefone)...')
        
        try {
          // Buscar todos os clientes que tenham o mesmo CPF ou telefone
          const { data: clientesComMesmoDado, error: errorClientes } = await supabase
            .from('clientes')
            .select('id, nome, cpf_cnpj, telefone, created_at')
            .or(`cpf_cnpj.eq.${clienteSelecionado?.cpf_cnpj},telefone.eq.${clienteSelecionado?.telefone}`)
          
          if (errorClientes) {
            console.error('❌ [BUSCAR ÓRFÃS] Erro ao buscar clientes:', errorClientes)
          } else if (clientesComMesmoDado && clientesComMesmoDado.length > 0) {
            console.log(`✅ [BUSCAR ÓRFÃS] Encontrados ${clientesComMesmoDado.length} registros com mesmo CPF/telefone:`)
            clientesComMesmoDado.forEach((c: any, i: number) => {
              const isAtual = c.id === clienteId ? '⭐' : ''
              console.log(`   ${i + 1}. ${isAtual} ${c.nome} - ID: ${c.id} - Criado: ${c.created_at}`)
            })
            
            // Buscar ordens usando TODOS esses IDs
            const idsParaBuscar = clientesComMesmoDado.map((c: any) => c.id)
            console.log('🔍 [BUSCAR ÓRFÃS] Buscando ordens com IDs:', idsParaBuscar)
            
            const ordensEncontradas = ordens.filter((ordem: any) => 
              idsParaBuscar.includes(ordem.cliente_id)
            )
            
            console.log(`✅ [BUSCAR ÓRFÃS] Encontradas ${ordensEncontradas.length} ordens com IDs alternativos`)
            
            if (ordensEncontradas.length > 0) {
              ordensDoCliente.push(...ordensEncontradas)
            }
          }
        } catch (err) {
          console.error('❌ [BUSCAR ÓRFÃS] Exceção:', err)
        }
        
        // Se ainda não encontrou nada, desistir
        if (ordensDoCliente.length === 0) {
          console.log('❌ [FINAL] Nenhuma ordem encontrada após todas as tentativas')
          setEquipamentosAnteriores([])
          return
        } else {
          console.log(`✅ [FINAL] Total de ${ordensDoCliente.length} ordens encontradas!`)
        }
      }

      // Agrupar por equipamento (tipo + marca + modelo)
      const equipamentosMap = new Map<string, any>()

      ordensDoCliente.forEach((ordem: any) => {
        const chave = `${ordem.tipo || ''}-${ordem.marca || ''}-${ordem.modelo || ''}`.toLowerCase()
        
        if (!equipamentosMap.has(chave)) {
          equipamentosMap.set(chave, {
            tipo: ordem.tipo || 'Não informado',
            marca: ordem.marca || 'Não informado',
            modelo: ordem.modelo || 'Não informado',
            cor: ordem.cor || null,
            defeitos: [],
            ordens: [],
            totalReparos: 0
          })
        }

        const equipamento = equipamentosMap.get(chave)
        
        // Garantir que defeitos e ordens são arrays
        if (!equipamento.defeitos) equipamento.defeitos = []
        if (!equipamento.ordens) equipamento.ordens = []
        
        // Adicionar defeito se existir
        if (ordem.defeito_relatado) {
          equipamento.defeitos.push(ordem.defeito_relatado)
        }
        
        // Adicionar ordem
        equipamento.ordens.push({
          id: ordem.id,
          data: ordem.data_entrada,
          defeito: ordem.defeito_relatado || 'Não informado',
          status: ordem.status,
          valor: ordem.valor_final || ordem.valor_orcamento || 0
        })
        equipamento.totalReparos++
      })

      const equipamentosArray = Array.from(equipamentosMap.values())
      console.log('✅ [BUSCAR EQUIPAMENTOS] Equipamentos encontrados:', equipamentosArray.length)
      console.log('✅ [BUSCAR EQUIPAMENTOS] Equipamentos:', equipamentosArray)
      
      // Validação final: verificar se algum equipamento tem defeitos ou ordens null
      equipamentosArray.forEach((eq, index) => {
        if (!eq.defeitos) {
          console.warn(`⚠️ Equipamento ${index} tem defeitos NULL - corrigindo`)
          eq.defeitos = []
        }
        if (!eq.ordens) {
          console.warn(`⚠️ Equipamento ${index} tem ordens NULL - corrigindo`)
          eq.ordens = []
        }
        console.log(`📱 Equipamento ${index + 1}:`, {
          tipo: eq.tipo,
          marca: eq.marca,
          modelo: eq.modelo,
          defeitos: eq.defeitos?.length || 0,
          ordens: eq.ordens?.length || 0
        })
      })
      
      console.log('🎯 [FINAL] Atualizando estado com', equipamentosArray.length, 'equipamentos')
      setEquipamentosAnteriores(equipamentosArray)
      console.log('✅ [FINAL] Estado atualizado!')
      
    } catch (error) {
      console.error('❌ [BUSCAR EQUIPAMENTOS] Erro ao buscar equipamentos:', error)
      setEquipamentosAnteriores([])
    }
  }

  // Efeito para buscar equipamentos quando cliente é selecionado (APENAS em modo de criação)
  useEffect(() => {
    console.log('👤 Cliente selecionado mudou:', clienteSelecionado)
    
    // NÃO buscar equipamentos se estiver editando
    if (ordem) {
      console.log('🚫 Modo de edição - não buscar equipamentos anteriores')
      return
    }
    
    if (clienteSelecionado?.nome) {
      console.log('🔍 Iniciando busca para cliente:', clienteSelecionado.nome)
      // Usar o ID ou nome como identificador
      const idParaBusca = clienteSelecionado.id || clienteSelecionado.nome
      buscarEquipamentosAnteriores(idParaBusca)
    } else {
      console.log('❌ Nenhum cliente selecionado, limpando equipamentos')
      setEquipamentosAnteriores([])
    }
  }, [clienteSelecionado, ordem])

  // Efeito para monitorar mudanças no estado equipamentosAnteriores
  useEffect(() => {
    console.log('🔄 [ESTADO] equipamentosAnteriores mudou:', equipamentosAnteriores.length, 'itens')
    if (equipamentosAnteriores.length > 0) {
      console.log('📋 [ESTADO] Equipamentos no estado:', equipamentosAnteriores.map(e => `${e.marca} ${e.modelo}`))
    }
  }, [equipamentosAnteriores])

  // Função de teste para buscar um cliente específico (apenas para debug)
  const testarBuscaCliente = async (nomeCliente: string) => {
    console.log('🧪 Testando busca para cliente:', nomeCliente)
    const clienteTeste = { nome: nomeCliente, id: nomeCliente }
    setClienteSelecionado(clienteTeste as any)
  }

  // Expor função de teste no console para debug
  useEffect(() => {
    ;(window as any).testarBuscaCliente = testarBuscaCliente
    ;(window as any).verificarEquipamentosAtual = () => {
      console.log('📊 Estado atual dos equipamentos:', equipamentosAnteriores)
      console.log('👤 Cliente atual:', clienteSelecionado)
    }
    ;(window as any).buscarEquipamentosDebug = buscarEquipamentosAnteriores
    ;(window as any).testeSimples = async () => {
      console.log('🧪 Teste simples - criando cliente fixo')
      const clienteTeste = { 
        id: 'test-id', 
        nome: 'EDVANIA DA SILVA', 
        telefone: '(11) 99999-9999',
        email: 'test@test.com'
      }
      setClienteSelecionado(clienteTeste as any)
      console.log('👤 Cliente definido:', clienteTeste)
      
      // Aguardar um pouco e buscar equipamentos
      setTimeout(() => {
        console.log('� Buscando equipamentos após 1 segundo')
        buscarEquipamentosAnteriores('EDVANIA DA SILVA')
      }, 1000)
    }
    console.log('�🛠️ Funções de teste disponíveis:')
    console.log('- window.testarBuscaCliente("EDVANIA DA SILVA")')
    console.log('- window.verificarEquipamentosAtual()')
    console.log('- window.buscarEquipamentosDebug("EDVANIA DA SILVA")')
    console.log('- window.testeSimples() // Teste com cliente fixo')
  }, [equipamentosAnteriores, clienteSelecionado])

  // Função para preencher dados do equipamento anterior
  const preencherEquipamentoAnterior = (equipamento: any) => {
    setValue('marca', equipamento.marca)
    setValue('modelo', equipamento.modelo)
    if (equipamento.cor) setValue('cor', equipamento.cor)
    
    // Tentar identificar o tipo
    const tipoEquipamento = (equipamento.tipo || '').toLowerCase()
    if (tipoEquipamento.includes('celular') || tipoEquipamento.includes('smartphone')) {
      setValue('tipo', 'Celular')
    } else if (tipoEquipamento.includes('notebook') || tipoEquipamento.includes('laptop')) {
      setValue('tipo', 'Notebook')
    } else if (tipoEquipamento.includes('tablet')) {
      setValue('tipo', 'Tablet')
    } else if (tipoEquipamento.includes('console')) {
      setValue('tipo', 'Console')
    } else {
      setValue('tipo', 'Outro')
      setTipoPersonalizado(equipamento.tipo)
      setMostrarCampoPersonalizado(true)
    }
    
    toast.success('Dados do equipamento preenchidos!')
  }

  // Atualizar checklist
  const atualizarChecklist = (itemId: string, valor: boolean) => {
    setChecklist(prev => ({
      ...prev,
      [itemId]: valor
    }))
  }

  // Adicionar novo item ao checklist
  const adicionarItemChecklist = async () => {
    if (novoItemChecklist.trim()) {
      console.log('➕ [CHECKLIST] Adicionando item:', novoItemChecklist.trim())
      
      const novosItens = await checklistTemplateService.adicionarItemChecklist(novoItemChecklist.trim())
      
      if (novosItens) {
        setItensChecklist(novosItens.map(item => ({ id: item.id, label: item.label })))
        setNovoItemChecklist('')
        setMostrandoFormNovoItem(false)
        toast.success('✅ Item adicionado e salvo no banco de dados!')
        console.log('✅ [CHECKLIST] Item adicionado com sucesso')
      } else {
        toast.error('❌ Erro ao adicionar item ao checklist')
        console.error('❌ [CHECKLIST] Falha ao adicionar item')
      }
    }
  }

  // Remover item do checklist
  const removerItemChecklist = async (itemId: string) => {
    console.log('➖ [CHECKLIST] Removendo item:', itemId)
    
    const novosItens = await checklistTemplateService.removerItemChecklist(itemId)
    
    if (novosItens) {
      setItensChecklist(novosItens.map(item => ({ id: item.id, label: item.label })))
      
      setChecklist(prev => {
        const novoChecklist = { ...prev }
        delete novoChecklist[itemId]
        return novoChecklist
      })
      
      toast.success('✅ Item removido e salvo no banco de dados!')
      console.log('✅ [CHECKLIST] Item removido com sucesso')
    } else {
      toast.error('❌ Erro ao remover item do checklist')
      console.error('❌ [CHECKLIST] Falha ao remover item')
    }
  }

  // Submeter formulário
  const onSubmit = async (data: FormData) => {
    if (!clienteSelecionado) {
      toast.error('Selecione um cliente para continuar')
      return
    }

    setLoading(true)
    
    try {
      if (ordem) {
        // MODO EDIÇÃO - Atualizar ordem existente
        console.log('✏️ [EDITAR] Atualizando ordem:', ordem.id)
        console.log('✏️ [EDITAR] Dados do formulário:', data)
        console.log('✏️ [EDITAR] Cor do formulário:', data.cor)
        console.log('✏️ [EDITAR] Checklist atual:', checklist)
        
        // Preparar dados da senha
        const senhaAparelho = tipoSenha !== 'nenhuma' ? {
          tipo: tipoSenha,
          valor: tipoSenha === 'texto' ? senhaTexto : 
                 tipoSenha === 'pin' ? senhaPIN : 
                 tipoSenha === 'desenho' ? senhaDesenho : null
        } : null
        
        const dadosAtualizados = {
          tipo: data.tipo,
          marca: data.marca,
          modelo: data.modelo,
          cor: data.cor,
          numero_serie: data.numero_serie,
          checklist: checklist,
          senha_aparelho: senhaAparelho,
          observacoes: data.observacoes,
          defeito_relatado: data.defeito_relatado,
          data_previsao: data.data_previsao,
          valor_orcamento: data.valor_orcamento,
          cliente_id: clienteSelecionado.id,
          status: statusOrdem // Adicionar status
        }

        console.log('💾 [EDITAR] Enviando para banco:', dadosAtualizados)
        await ordemServicoService.atualizarOrdem(ordem.id, dadosAtualizados)
        
        toast.success('Ordem de serviço atualizada com sucesso!')
        
        // Sinalizar que a lista de OS precisa ser recarregada
        localStorage.setItem('os_list_needs_refresh', 'true')
        
        if (onSuccess) {
          onSuccess({ ...ordem, ...dadosAtualizados } as unknown as Record<string, unknown>)
        }
      } else {
        // MODO CRIAÇÃO - Criar nova ordem
        console.log('➕ [CRIAR] Dados do formulário:', data)
        console.log('➕ [CRIAR] Cor do formulário:', data.cor)
        console.log('➕ [CRIAR] Checklist atual:', checklist)
        console.log('➕ [CRIAR] Tipo de senha:', tipoSenha)
        console.log('➕ [CRIAR] Valor senha texto:', senhaTexto)
        console.log('➕ [CRIAR] Valor senha PIN:', senhaPIN)
        console.log('➕ [CRIAR] Valor senha desenho (length):', senhaDesenho?.length)
        
        // Preparar dados da senha
        const senhaAparelho = tipoSenha !== 'nenhuma' ? {
          tipo: tipoSenha,
          valor: tipoSenha === 'texto' ? senhaTexto : 
                 tipoSenha === 'pin' ? senhaPIN : 
                 tipoSenha === 'desenho' ? senhaDesenho : null
        } : null
        
        console.log('➕ [CRIAR] Senha preparada:', senhaAparelho)
        
        const novaOrdem: NovaOrdemServicoForm = {
          cliente_nome: clienteSelecionado.nome,
          cliente_telefone: clienteSelecionado.telefone,
          cliente_email: clienteSelecionado.email,
          tipo: data.tipo,
          marca: data.marca,
          modelo: data.modelo,
          cor: data.cor,
          numero_serie: data.numero_serie,
          checklist,
          senha_aparelho: senhaAparelho,
          observacoes: data.observacoes,
          defeito_relatado: data.defeito_relatado,
          data_previsao: data.data_previsao,
          valor_orcamento: data.valor_orcamento,
          status: statusOrdem // Adicionar status
        }

        console.log('💾 [CRIAR] Enviando para banco:', novaOrdem)
        const ordemCriada = await ordemServicoService.criarOrdem(novaOrdem)
        
        toast.success('Ordem de serviço criada com sucesso!')
        
        // Sinalizar que a lista de OS precisa ser recarregada
        localStorage.setItem('os_list_needs_refresh', 'true')
        
        if (onSuccess) {
          onSuccess(ordemCriada as unknown as Record<string, unknown>)
        }
      }
    } catch (error: unknown) {
      console.error('Erro ao salvar ordem:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro ao salvar ordem de serviço'
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6" noValidate>
        
        {/* Seção: Cliente */}
        <ClienteSelector 
          onClienteSelect={setClienteSelecionado}
          clienteSelecionado={clienteSelecionado}
        />

        {/* Seção: Equipamentos Anteriores - APENAS no modo de CRIAÇÃO */}
        {(() => {
          console.log('🎨 [RENDER] Verificando renderização de equipamentos:', {
            isEditMode: !!ordem,
            length: equipamentosAnteriores.length,
            shouldRender: !ordem && equipamentosAnteriores.length > 0,
            equipamentos: equipamentosAnteriores.map(e => `${e.marca} ${e.modelo}`)
          })
          return null
        })()}
        
        {!ordem && equipamentosAnteriores.length > 0 && (
          <Card className="p-6 bg-blue-50 border-blue-200">
            <div className="flex items-center gap-2 mb-4">
              <History className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold text-gray-900">Histórico de Equipamentos</h2>
              <span className="text-sm text-gray-600">
                ({equipamentosAnteriores.length} equipamento{equipamentosAnteriores.length > 1 ? 's' : ''})
              </span>
            </div>
            
            {/* Grid responsivo para mostrar cards lado a lado - mais compacto */}
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
              {equipamentosAnteriores.map((equipamento, index) => (
                <div 
                  key={index}
                  className="bg-white p-3 rounded-lg border border-blue-200 hover:border-blue-400 hover:shadow-md transition-all cursor-pointer"
                  onClick={() => preencherEquipamentoAnterior(equipamento)}
                >
                  {/* Cabeçalho ultra compacto */}
                  <div className="flex items-start gap-2 mb-2">
                    <Smartphone className="w-4 h-4 text-blue-600 mt-0.5 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-bold text-gray-900 truncate" title={`${equipamento.marca} ${equipamento.modelo}`}>
                        {equipamento.marca}
                      </div>
                      <div className="text-xs text-gray-600 truncate" title={equipamento.modelo}>
                        {equipamento.modelo}
                      </div>
                      <div className="text-xs text-gray-500 truncate">
                        {equipamento.tipo}
                      </div>
                    </div>
                  </div>
                  
                  {/* Badge de reparos mini */}
                  <div className="flex items-center justify-between mb-2">
                    <span className="inline-flex items-center bg-blue-100 text-blue-800 px-2 py-0.5 rounded-full text-xs font-medium">
                      {equipamento.totalReparos} rep.
                    </span>
                    {equipamento.cor && (
                      <span className="text-xs text-gray-500 truncate" title={`Cor: ${equipamento.cor}`}>
                        {equipamento.cor}
                      </span>
                    )}
                  </div>
                  
                  {/* Defeito mais recente (só 1) */}
                  {equipamento.defeitos && equipamento.defeitos.length > 0 && (
                    <div className="mb-2">
                      <div className="bg-orange-100 text-orange-800 px-2 py-0.5 rounded text-xs truncate" title={equipamento.defeitos[0]}>
                        {equipamento.defeitos[0].length > 20 ? 
                          equipamento.defeitos[0].substring(0, 20) + '...' : 
                          equipamento.defeitos[0]
                        }
                      </div>
                      {equipamento.defeitos.length > 1 && (
                        <div className="text-xs text-gray-400 mt-0.5">
                          +{equipamento.defeitos.length - 1} outros
                        </div>
                      )}
                    </div>
                  )}
                  
                  {/* Última ordem (ultra resumida) */}
                  {equipamento.ordens && equipamento.ordens.length > 0 && (
                    <div className="bg-gray-50 p-2 rounded border-l-2 border-blue-300">
                      <div className="flex justify-between items-center mb-1">
                        <span className="text-xs text-gray-500">
                          {equipamento.ordens[0]?.data?.split('-').reverse().join('/') || '--/--'}
                        </span>
                        <span className={`text-xs px-1 py-0.5 rounded ${
                          equipamento.ordens[0]?.status === 'fechada' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {equipamento.ordens[0]?.status === 'fechada' ? '✓' : '⏳'}
                        </span>
                      </div>
                      {(equipamento.ordens[0]?.valor || 0) > 0 && (
                        <div className="text-xs font-medium text-green-600">
                          R$ {(equipamento.ordens[0]?.valor || 0).toFixed(0)}
                        </div>
                      )}
                    </div>
                  )}
                  
                  {/* Indicador de clique mini */}
                  <div className="text-xs text-blue-600 mt-1 text-center opacity-50 hover:opacity-100">
                    Clique aqui
                  </div>
                </div>
              ))}
            </div>
            
            <div className="mt-4 p-3 bg-blue-100 rounded-lg">
              <p className="text-sm text-blue-800">
                💡 <strong>Histórico Completo:</strong> Todos os aparelhos e reparos anteriores do cliente. 
                Clique no nome do equipamento para preencher automaticamente os dados.
              </p>
            </div>
          </Card>
        )}

        {/* Seção: Informações do Aparelho */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Settings className="w-5 h-5 text-green-600" />
            <h2 className="text-lg font-semibold text-gray-900">Informações do Aparelho</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Equipamento *
              </label>
              <select
                {...register('tipo')}
                onChange={(e) => {
                  const valor = e.target.value as TipoEquipamento
                  setValue('tipo', valor)
                  setMostrarCampoPersonalizado(valor === 'Outro')
                }}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {TIPOS_EQUIPAMENTO_BASE.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
                  </option>
                ))}
                <option value="Outro">Outro (personalizado)</option>
              </select>
              {errors.tipo && (
                <span className="text-red-500 text-sm">{errors.tipo.message}</span>
              )}
            </div>

            {mostrarCampoPersonalizado && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Especifique o Tipo
                </label>
                <input
                  type="text"
                  value={tipoPersonalizado}
                  onChange={(e) => setTipoPersonalizado(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Ex: Smartwatch, Drone, etc."
                />
                <p className="text-xs text-gray-500 mt-1">
                  Tipo personalizado para este equipamento
                </p>
              </div>
            )}
            
            <div className="relative">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Marca *
              </label>
              <input
                {...register('marca', {
                  onChange: (e) => {
                    setMarcaBusca(e.target.value)
                  }
                })}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Samsung, Apple, Dell..."
                autoComplete="off"
              />
              {errors.marca && (
                <span className="text-red-500 text-sm">{errors.marca.message}</span>
              )}
              
              {/* Sugestões de marcas */}
              {marcaSugestoes.length > 0 && (
                <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-48 overflow-y-auto">
                  {marcaSugestoes.map((marca, index) => (
                    <button
                      key={index}
                      type="button"
                      onClick={() => {
                        setValue('marca', marca)
                        setMarcaBusca(marca)
                        setMarcaSugestoes([])
                      }}
                      className="w-full text-left px-3 py-2 hover:bg-blue-50 focus:bg-blue-50 text-sm"
                    >
                      📱 {marca}
                    </button>
                  ))}
                </div>
              )}
            </div>
            
            <div className="relative">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Modelo *
              </label>
              <input
                {...register('modelo', {
                  onChange: (e) => {
                    setModeloBusca(e.target.value)
                  }
                })}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Galaxy S21, iPhone 13..."
                autoComplete="off"
              />
              {errors.modelo && (
                <span className="text-red-500 text-sm">{errors.modelo.message}</span>
              )}
              
              {/* Sugestões de modelos */}
              {modeloSugestoes.length > 0 && (
                <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-48 overflow-y-auto">
                  {modeloSugestoes.map((modelo, index) => (
                    <button
                      key={index}
                      type="button"
                      onClick={() => {
                        setValue('modelo', modelo)
                        setModeloBusca(modelo)
                        setModeloSugestoes([])
                      }}
                      className="w-full text-left px-3 py-2 hover:bg-blue-50 focus:bg-blue-50 text-sm"
                    >
                      📱 {modelo}
                    </button>
                  ))}
                </div>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cor
              </label>
              <input
                {...register('cor')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Preto, Branco, Azul..."
              />
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Série
              </label>
              <input
                {...register('numero_serie')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="IMEI ou número de série"
              />
            </div>
          </div>
        </Card>

        {/* Seção: Senha do Aparelho */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <svg className="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
            <h2 className="text-lg font-semibold text-gray-900">Senha do Aparelho</h2>
          </div>
          
          <div className="space-y-4">
            {/* Seletor de tipo de senha */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Senha
              </label>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
                <button
                  type="button"
                  onClick={() => setTipoSenha('nenhuma')}
                  className={`px-4 py-2 rounded-lg border-2 transition-all ${
                    tipoSenha === 'nenhuma' 
                      ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' 
                      : 'border-gray-300 hover:border-gray-400'
                  }`}
                >
                  🚫 Nenhuma
                </button>
                <button
                  type="button"
                  onClick={() => setTipoSenha('texto')}
                  className={`px-4 py-2 rounded-lg border-2 transition-all ${
                    tipoSenha === 'texto' 
                      ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' 
                      : 'border-gray-300 hover:border-gray-400'
                  }`}
                >
                  🔤 Texto
                </button>
                <button
                  type="button"
                  onClick={() => setTipoSenha('pin')}
                  className={`px-4 py-2 rounded-lg border-2 transition-all ${
                    tipoSenha === 'pin' 
                      ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' 
                      : 'border-gray-300 hover:border-gray-400'
                  }`}
                >
                  🔢 PIN
                </button>
                <button
                  type="button"
                  onClick={() => setTipoSenha('desenho')}
                  className={`px-4 py-2 rounded-lg border-2 transition-all ${
                    tipoSenha === 'desenho' 
                      ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' 
                      : 'border-gray-300 hover:border-gray-400'
                  }`}
                >
                  ✏️ Desenho
                </button>
              </div>
            </div>

            {/* Campo de senha - Texto */}
            {tipoSenha === 'texto' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Senha Alfanumérica
                </label>
                <input
                  type="text"
                  value={senhaTexto}
                  onChange={(e) => setSenhaTexto(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Digite a senha do aparelho..."
                />
              </div>
            )}

            {/* Campo de senha - PIN */}
            {tipoSenha === 'pin' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Código PIN
                </label>
                <input
                  type="text"
                  value={senhaPIN}
                  onChange={(e) => {
                    // Permitir apenas números
                    const valor = e.target.value.replace(/\D/g, '')
                    setSenhaPIN(valor)
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-2xl tracking-widest text-center font-mono"
                  placeholder="0000"
                  maxLength={6}
                />
                <p className="text-xs text-gray-500 mt-1">Apenas números (4-6 dígitos)</p>
              </div>
            )}

            {/* Campo de senha - Desenho */}
            {tipoSenha === 'desenho' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Padrão de Desbloqueio
                </label>
                <SenhaDesenho 
                  value={senhaDesenho} 
                  onChange={setSenhaDesenho}
                />
              </div>
            )}
          </div>
        </Card>

        {/* Seção: Checklist Técnico */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Settings className="w-5 h-5 text-purple-600" />
              <h2 className="text-lg font-semibold text-gray-900">Checklist Técnico</h2>
              <span className="text-sm text-gray-500">({itensChecklist.length} itens)</span>
            </div>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setMostrandoFormNovoItem(true)}
              className="flex items-center gap-1"
            >
              <Plus className="w-4 h-4" />
              Adicionar Item
            </Button>
          </div>

          {/* Form para adicionar novo item */}
          {mostrandoFormNovoItem && (
            <div className="mb-4 p-4 bg-gray-50 rounded-lg border">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={novoItemChecklist}
                  onChange={(e) => setNovoItemChecklist(e.target.value)}
                  placeholder="Ex: Tela funcionando? / Aparelho carrega? / etc..."
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  onKeyPress={(e) => e.key === 'Enter' && adicionarItemChecklist()}
                />
                <Button
                  type="button"
                  onClick={adicionarItemChecklist}
                  size="sm"
                  disabled={!novoItemChecklist.trim()}
                >
                  Adicionar
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setMostrandoFormNovoItem(false)
                    setNovoItemChecklist('')
                  }}
                >
                  Cancelar
                </Button>
              </div>
              <p className="text-xs text-gray-500 mt-2">
                💡 Dica: Adicione verificações que você sempre faz, como "Tela quebrada?", "Aparelho liga?", etc.
              </p>
            </div>
          )}
          
          {/* Lista de itens do checklist */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {itensChecklist.map((item) => (
              <div key={item.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border">
                <label className="flex items-center gap-2 cursor-pointer flex-1">
                  <input
                    type="checkbox"
                    checked={checklist[item.id] || false}
                    onChange={(e) => atualizarChecklist(item.id, e.target.checked)}
                    className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">{item.label}</span>
                </label>
                
                {/* Botão para remover item (só para itens personalizados) */}
                {item.id !== 'aparelho_liga' && (
                  <button
                    type="button"
                    onClick={() => removerItemChecklist(item.id)}
                    className="ml-2 p-1 text-red-500 hover:text-red-700 hover:bg-red-50 rounded"
                    title="Remover item"
                  >
                    <X className="w-3 h-3" />
                  </button>
                )}
              </div>
            ))}
            
            {/* Mensagem quando não há itens */}
            {itensChecklist.length === 0 && (
              <div className="col-span-full text-center py-8 text-gray-500">
                <Settings className="w-8 h-8 mx-auto mb-2 opacity-50" />
                <p>Nenhum item no checklist.</p>
                <p className="text-sm">Clique em "Adicionar Item" para começar.</p>
              </div>
            )}
          </div>

          {/* Sugestões rápidas */}
          {itensChecklist.length <= 3 && (
            <div className="mt-4 p-3 bg-blue-50 rounded-lg">
              <p className="text-sm text-blue-800 font-medium mb-2">💡 Sugestões de itens:</p>
              <div className="flex flex-wrap gap-2">
                {[
                  'Tela quebrada?',
                  'Aparelho molhado?', 
                  'Com senha?',
                  'Bateria boa?',
                  'Tampa presente?',
                  'Carregador entregue?'
                ].map((sugestao) => (
                  <button
                    key={sugestao}
                    type="button"
                    onClick={() => {
                      setNovoItemChecklist(sugestao)
                      setMostrandoFormNovoItem(true)
                    }}
                    className="text-xs bg-white text-blue-700 px-2 py-1 rounded border border-blue-200 hover:bg-blue-100"
                  >
                    + {sugestao}
                  </button>
                ))}
              </div>
            </div>
          )}
        </Card>

        {/* Seção: Detalhes do Problema */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Detalhes do Problema</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Defeito Relatado *
              </label>
              <textarea
                {...register('defeito_relatado')}
                rows={3}
                required={false}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Ex: Celular não liga, tela quebrada, bateria não carrega..."
              />
              {errors.defeito_relatado && (
                <span className="text-red-500 text-sm">{errors.defeito_relatado.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações Adicionais
              </label>
              <textarea
                {...register('observacoes')}
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Observações gerais, estado do aparelho, etc..."
              />
            </div>
          </div>
        </Card>

        {/* Seção: Prazos e Valores */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Prazos e Valores</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Previsão de Entrega
              </label>
              <div className="relative">
                <Calendar className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('data_previsao')}
                  type="date"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor do Orçamento (R$)
              </label>
              <div className="relative">
                <DollarSign className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('valor_orcamento', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  step="0.01"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="0,00"
                />
              </div>
              {errors.valor_orcamento && (
                <span className="text-red-500 text-sm">{errors.valor_orcamento.message}</span>
              )}
            </div>
          </div>

          {/* Campo de Status */}
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Status da Ordem
            </label>
            <select
              value={statusOrdem}
              onChange={(e) => setStatusOrdem(e.target.value as 'Fazendo orçamento' | 'Em conserto' | 'Pronto')}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="Fazendo orçamento">Fazendo orçamento</option>
              <option value="Em conserto">Em conserto</option>
              <option value="Pronto">Pronto</option>
            </select>
            <p className="text-xs text-gray-500 mt-1">
              O status "Entregue" é definido automaticamente ao encerrar a ordem
            </p>
          </div>
        </Card>

        {/* Botões de Ação */}
        <div className="flex gap-4 justify-end">
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
          )}
          
          <Button type="submit" loading={loading} className="gap-2">
            <Save className="w-4 h-4" />
            {ordem ? 'Salvar Ordem de Serviço' : 'Criar Ordem de Serviço'}
          </Button>
        </div>
      </form>
    </div>
  )
}
