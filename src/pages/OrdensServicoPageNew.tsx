import React, { useState, useEffect } from 'react'
import { Plus, Search, Filter, Edit, Trash2, Wrench, Clock, CheckCircle, FileDown, Eye, EyeOff } from 'lucide-react'
import { useOrdemServico } from '../hooks/useOrdemServico'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { EditarOrdemModal } from '../components/ordem-servico/EditarOrdemModal'
import type { OrdemServico, StatusOS } from '../types/ordemServico'
import { STATUS_COLORS, TIPO_ICONS } from '../types/ordemServico'
import { supabase } from '../lib/supabase'
import toast from 'react-hot-toast'

type ViewMode = 'list' | 'form'

export function OrdensServicoPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<StatusOS | ''>('')
  const [currentUser, setCurrentUser] = useState<any>(null)
  const [importingBackup, setImportingBackup] = useState(false)
  const [isCleaningOS, setIsCleaningOS] = useState(false)
  const [editingOrdem, setEditingOrdem] = useState<OrdemServico | null>(null)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [showAllOrders, setShowAllOrders] = useState(false)

  // Verificar usuário atual
  useEffect(() => {
    const getCurrentUser = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser()
        setCurrentUser(user)
      } catch (error) {
        console.error('Erro ao obter usuário:', error)
      }
    }
    getCurrentUser()
  }, [])

  // Função para abrir modal de edição
  const handleEditOrdem = (ordem: OrdemServico) => {
    setEditingOrdem(ordem)
    setIsEditModalOpen(true)
    
    // Rolar suavemente para o topo da página
    setTimeout(() => {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      })
    }, 100)
  }

  // Função para fechar modal
  const handleCloseEditModal = () => {
    setIsEditModalOpen(false)
    setEditingOrdem(null)
  }

  // Função chamada quando ordem é atualizada com sucesso
  const handleUpdateSuccess = () => {
    handleCloseEditModal()
    // Recarregar dados ou atualizar estado local
    window.location.reload()
  }

  // Função para limpar todas as ordens de serviço
  const limparTodasOS = async () => {
    if (!currentUser?.email || currentUser.email !== 'assistenciaallimport10@gmail.com') {
      toast.error('Acesso restrito para assistenciaallimport10@gmail.com')
      return
    }

    const confirmar = confirm('⚠️ ATENÇÃO: Isso vai DELETAR TODAS as ordens de serviço! Tem certeza?')
    if (!confirmar) return

    const confirmar2 = confirm('🚨 ÚLTIMA CHANCE: Todas as ordens serão PERMANENTEMENTE excluídas. Continuar?')
    if (!confirmar2) return

    setIsCleaningOS(true)
    toast.loading('Limpando todas as ordens de serviço...')

    try {
      // Deletar todas as ordens do usuário atual
      const { error } = await supabase
        .from('ordens_servico')
        .delete()
        .eq('usuario_id', currentUser.id)

      if (error) {
        console.error('Erro ao limpar ordens:', error)
        throw error
      }

      toast.dismiss()
      toast.success('✅ Todas as ordens de serviço foram removidas!')
      
      // Recarregar a página
      window.location.reload()
    } catch (error) {
      console.error('❌ Erro ao limpar ordens:', error)
      toast.dismiss()
      toast.error('Erro ao limpar ordens de serviço: ' + (error as Error).message)
    } finally {
      setIsCleaningOS(false)
    }
  }

  // Função para importar backup de ordens de serviço
  const importarBackupOS = async (event: React.ChangeEvent<HTMLInputElement>) => {
    if (!currentUser?.email || currentUser.email !== 'assistenciaallimport10@gmail.com') {
      toast.error('Acesso restrito para assistenciaallimport10@gmail.com')
      return
    }

    const file = event.target.files?.[0]
    if (!file) return

    if (!file.name.endsWith('.json')) {
      toast.error('Por favor, selecione um arquivo JSON')
      return
    }

    setImportingBackup(true)
    toast.loading('Importando backup de ordens de serviço...')

    try {
      const fileContent = await file.text()
      const backupData = JSON.parse(fileContent)

      console.log('📦 Dados brutos do backup:', backupData)

      // Detectar e normalizar diferentes formatos de backup
      let ordensArray: any[] = []

      if (Array.isArray(backupData)) {
        // Formato 1: Array direto de ordens
        ordensArray = backupData
      } else if (backupData && typeof backupData === 'object') {
        // Formato 2: Objeto com propriedades que podem conter arrays
        if (backupData.ordens && Array.isArray(backupData.ordens)) {
          ordensArray = backupData.ordens
        } else if (backupData.ordensServico && Array.isArray(backupData.ordensServico)) {
          ordensArray = backupData.ordensServico
        } else if (backupData.ordens_servico && Array.isArray(backupData.ordens_servico)) {
          ordensArray = backupData.ordens_servico
        } else if (backupData.data && Array.isArray(backupData.data)) {
          ordensArray = backupData.data
        } else if (backupData.items && Array.isArray(backupData.items)) {
          ordensArray = backupData.items
        } else {
          // Formato 3: Verificar se há propriedades que parecem ser arrays de ordens
          const possibleArrays = Object.values(backupData).filter(val => Array.isArray(val))
          if (possibleArrays.length === 1) {
            ordensArray = possibleArrays[0] as any[]
          } else {
            throw new Error(`Formato de backup inválido. 
Formatos aceitos:
- Array direto: [ordem1, ordem2, ...]
- Objeto com array: { "ordens": [...] } ou { "data": [...] }
- Estrutura encontrada: ${typeof backupData} com propriedades: ${Object.keys(backupData).join(', ')}`)
          }
        }
      } else {
        throw new Error('Formato de backup inválido. Esperado um array de ordens ou objeto com array de ordens.')
      }

      if (!Array.isArray(ordensArray) || ordensArray.length === 0) {
        throw new Error('Nenhuma ordem de serviço encontrada no arquivo de backup.')
      }

      console.log('📦 Dados do backup:', ordensArray)

      // Função auxiliar para buscar campos alternativos
      const getField = (obj: any, ...keys: string[]) => {
        for (const key of keys) {
          if (obj[key] !== undefined && obj[key] !== null && obj[key] !== '') {
            return obj[key]
          }
        }
        return null
      }

      // Primeiro, vamos processar e criar/encontrar clientes se necessário
      const ordensComClientes = []
      let ordensRejeitadas = 0
      
      console.log(`🔄 Processando ${ordensArray.length} ordens...`)
      
      for (const [index, ordem] of ordensArray.entries()) {
        console.log(`Processando ordem ${index + 1}/${ordensArray.length}`)
        
        // ⚠️ VALIDAÇÃO RIGOROSA - Rejeitar ordens sem dados essenciais
        const marca = getField(ordem, 'marca', 'brand')
        const modelo = getField(ordem, 'modelo', 'model') 
        const problema = getField(ordem, 'defeito_relatado', 'defeitoRelatado', 'defeito', 'problema', 'issue')
        
        // Se não tem dados essenciais, pular esta ordem
        if (!marca || marca === 'Não informado' || 
            !modelo || modelo === 'Não informado' ||
            !problema || problema === 'Não informado' || problema === 'Problema não informado') {
          ordensRejeitadas++
          console.log(`⚠️ Ordem ${index + 1} rejeitada: dados insuficientes`, { marca, modelo, problema })
          continue
        }
        
        let clienteId = null
        
        // Processar cliente (simplificado)
        const nomeCliente = getField(ordem, 'cliente_nome', 'clienteNome', 'cliente', 'nome', 'name')
        const telefoneCliente = getField(ordem, 'cliente_telefone', 'clienteTelefone', 'telefone', 'phone')
        const emailCliente = getField(ordem, 'cliente_email', 'clienteEmail', 'email')
        
        if (nomeCliente) {
          try {
            // Tentar encontrar cliente existente
            const { data: clienteExistente, error: errorBusca } = await supabase
              .from('clientes')
              .select('id')
              .ilike('nome', `%${nomeCliente}%`)
              .eq('usuario_id', currentUser.id)
              .limit(1)
              .maybeSingle()
            
            if (!errorBusca && clienteExistente) {
              clienteId = clienteExistente.id
            } else {
              // Criar novo cliente
              const { data: clienteCriado, error: erroCliente } = await supabase
                .from('clientes')
                .insert({
                  nome: nomeCliente,
                  telefone: telefoneCliente || '',
                  email: emailCliente || '',
                  endereco: '',
                  cidade: '',
                  cep: '',
                  usuario_id: currentUser.id
                })
                .select('id')
                .single()
              
              if (!erroCliente && clienteCriado) {
                clienteId = clienteCriado.id
              }
            }
          } catch (error) {
            console.warn('Erro ao processar cliente:', error)
            // Continuar sem cliente se der erro
          }
        }

        ordensComClientes.push({ ordem, clienteId, index })
      }
      
      console.log(`✅ Processamento concluído: ${ordensComClientes.length} ordens válidas, ${ordensRejeitadas} rejeitadas`)
      
      if (ordensComClientes.length === 0) {
        throw new Error('Nenhuma ordem válida encontrada no backup')
      }

      // Agora vamos inserir as ordens de forma simples
      console.log('📦 Inserindo ordens no banco de dados...')
      
      const ordensParaInserir = ordensComClientes.map(({ ordem, clienteId }) => {
        const numeroOrdem = `OS-${Date.now()}-${Math.random().toString(36).substring(2, 5)}`
        
        // Usar datas originais do backup quando disponíveis
        const dataEntrada = getField(ordem, 'data_entrada', 'dataEntrada', 'opening_date') || new Date().toISOString().split('T')[0]
        const dataCriacao = getField(ordem, 'created_at', 'createdAt', 'criado_em') || new Date().toISOString()
        const dataAtualizacao = getField(ordem, 'updated_at', 'updatedAt', 'atualizado_em') || dataCriacao
        
        return {
          numero_os: numeroOrdem,
          cliente_id: clienteId,
          equipamento: `${getField(ordem, 'marca', 'brand')} ${getField(ordem, 'modelo', 'model')}`,
          marca: getField(ordem, 'marca', 'brand'),
          modelo: getField(ordem, 'modelo', 'model'),
          descricao_problema: getField(ordem, 'defeito_relatado', 'defeitoRelatado', 'defeito', 'problema', 'issue'),
          data_entrada: dataEntrada,
          data_finalizacao: getField(ordem, 'data_conclusao', 'dataConclusao', 'closing_date') || null,
          status: getField(ordem, 'status') || 'Em análise',
          valor: parseFloat(getField(ordem, 'valor_final', 'valorFinal', 'valor', 'total_amount') || '0') || 0,
          garantia_meses: parseInt(getField(ordem, 'garantia_meses', 'garantiaMeses', 'warranty_days') || '0') || null,
          observacoes: getField(ordem, 'observacoes', 'obs') || '',
          usuario_id: currentUser.id,
          criado_em: dataCriacao,
          atualizado_em: dataAtualizacao
        }
      })

      // Inserir todas de uma vez
      const { error: errorInsercao } = await supabase
        .from('ordens_servico')
        .insert(ordensParaInserir)
      
      if (errorInsercao) {
        console.error('Erro na inserção:', errorInsercao)
        throw errorInsercao
      }
      
      setImportingBackup(false)
      toast.dismiss()
      toast.success(`✅ Backup importado! ${ordensParaInserir.length} ordens de serviço restauradas.`)
      
      // Recarregar a página para mostrar os dados
      window.location.reload()

    } catch (error: any) {
      console.error('❌ Erro ao importar backup:', error)
      toast.dismiss()
      toast.error('Erro ao importar backup: ' + error.message)
    } finally {
      setImportingBackup(false)
      // Limpar o input
      event.target.value = ''
    }
  }

  const {
    ordensServico,
    loading,
    error,
    deletarOS
  } = useOrdemServico()

  // Filtrar ordens
  const ordensFiltradas = ordensServico.filter((ordem: OrdemServico) => {
    const matchesSearch = ordem.cliente?.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.marca.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.modelo.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesStatus = !statusFilter || ordem.status === statusFilter
    
    return matchesSearch && matchesStatus
  })

  // Aplicar limitação de exibição (últimas 10 ordens por padrão)
  const ordensExibidas = showAllOrders || searchTerm || statusFilter 
    ? ordensFiltradas 
    : ordensFiltradas.slice(-10).reverse() // Últimas 10 ordens, mais recentes primeiro

  // Estatísticas
  const stats = {
    total: ordensServico.length,
    emAnalise: ordensServico.filter((os: OrdemServico) => os.status === 'Em análise').length,
    emAndamento: ordensServico.filter((os: OrdemServico) => os.status === 'Em conserto').length,
    prontas: ordensServico.filter((os: OrdemServico) => os.status === 'Pronto').length,
    entregues: ordensServico.filter((os: OrdemServico) => os.status === 'Entregue').length
  }

  const handleDelete = async (id: string) => {
    if (confirm('Tem certeza que deseja excluir esta OS?')) {
      try {
        await deletarOS(id)
      } catch (error) {
        console.error('Erro ao deletar OS:', error)
      }
    }
  }

  const handleNewOS = () => {
    setViewMode('form')
  }

  const handleFormSuccess = () => {
    setViewMode('list')
  }

  const handleFormCancel = () => {
    setViewMode('list')
  }

  const formatCurrency = (value: number | undefined) => {
    if (!value) return 'R$ 0,00'
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('pt-BR')
  }

  // Estatísticas Cards
  const StatCard = ({ title, value, icon: Icon, color }: {
    title: string
    value: number
    icon: React.ComponentType<any>
    color: string
  }) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <Icon className="h-6 w-6 text-gray-600" />
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">
              {title}
            </dt>
            <dd className="text-lg font-medium text-gray-900">
              {value}
            </dd>
          </dl>
        </div>
      </div>
    </div>
  )

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-red-600">Erro: {error}</p>
          </div>
        </div>
      </div>
    )
  }

  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-4xl mx-auto">
          <OrdemServicoForm
            onSuccess={handleFormSuccess}
            onCancel={handleFormCancel}
          />
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Ordens de Serviço</h1>
            <p className="text-gray-600 mt-1">
              Gerencie as ordens de serviço da assistência técnica
            </p>
          </div>
          
          <div className="flex gap-3 self-start sm:self-auto">
            {/* Botões apenas para usuário específico */}
            {currentUser?.email === 'assistenciaallimport10@gmail.com' && (
              <>
                {/* Botão de Importar Backup */}
                <div className="relative">
                  <input
                    type="file"
                    accept=".json"
                    onChange={importarBackupOS}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                    disabled={importingBackup}
                  />
                  <button
                    disabled={importingBackup}
                    className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2 disabled:opacity-50"
                  >
                    <FileDown className="h-5 w-5" />
                    {importingBackup ? 'Importando...' : 'Importar Backup'}
                  </button>
                </div>

                {/* Botão de Limpar Todas as OS */}
                <button
                  onClick={limparTodasOS}
                  disabled={isCleaningOS}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 flex items-center gap-2 disabled:opacity-50"
                >
                  <Trash2 className="h-5 w-5" />
                  {isCleaningOS ? 'Limpando...' : 'Limpar Todas'}
                </button>
              </>
            )}
            
            <button
              onClick={handleNewOS}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
            >
              <Plus className="h-5 w-5" />
              Nova OS
            </button>
          </div>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard 
            title="Total de OS" 
            value={stats.total} 
            icon={Wrench} 
            color="border-blue-500" 
          />
          <StatCard 
            title="Em Análise" 
            value={stats.emAnalise} 
            icon={Clock} 
            color="border-yellow-500" 
          />
          <StatCard 
            title="Em Conserto" 
            value={stats.emAndamento} 
            icon={Wrench} 
            color="border-orange-500" 
          />
          <StatCard 
            title="Prontas" 
            value={stats.prontas} 
            icon={CheckCircle} 
            color="border-green-500" 
          />
        </div>

        {/* Filtros */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por cliente, marca ou modelo..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div className="relative">
              <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as StatusOS | '')}
                className="pl-10 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
              >
                <option value="">Todos os status</option>
                <option value="Em análise">Em análise</option>
                <option value="Aguardando aprovação">Aguardando aprovação</option>
                <option value="Em conserto">Em conserto</option>
                <option value="Pronto">Pronto</option>
                <option value="Entregue">Entregue</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>

            {/* Botão para alternar visualização */}
            {!searchTerm && !statusFilter && (
              <button
                onClick={() => setShowAllOrders(!showAllOrders)}
                className={`px-4 py-2 rounded-lg border transition-colors flex items-center gap-2 ${
                  showAllOrders 
                    ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-700' 
                    : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'
                }`}
              >
                {showAllOrders ? (
                  <>
                    <EyeOff className="h-4 w-4" />
                    Ver últimas 10
                  </>
                ) : (
                  <>
                    <Eye className="h-4 w-4" />
                    Ver todas ({ordensFiltradas.length})
                  </>
                )}
              </button>
            )}
          </div>

          {/* Indicador de quantas ordens estão sendo exibidas */}
          {!searchTerm && !statusFilter && (
            <div className="mt-3 text-sm text-gray-600">
              {showAllOrders 
                ? `Exibindo todas as ${ordensFiltradas.length} ordens de serviço`
                : `Exibindo as últimas ${Math.min(10, ordensFiltradas.length)} ordens de serviço${ordensFiltradas.length > 10 ? ` de ${ordensFiltradas.length} total` : ''}`
              }
            </div>
          )}
        </div>

        {/* Tabela de Ordens */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
              <p className="text-gray-600">Carregando ordens de serviço...</p>
            </div>
          ) : ordensExibidas.length === 0 ? (
            <div className="p-8 text-center">
              <Wrench className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600 text-lg">
                {searchTerm || statusFilter 
                  ? 'Nenhuma ordem encontrada com os filtros aplicados'
                  : 'Nenhuma ordem de serviço cadastrada'
                }
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Cliente</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Equipamento</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Defeito</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Datas</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Financeiro</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Garantia</th>
                    <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {ordensExibidas.map((ordem: OrdemServico) => (
                    <tr key={ordem.id} className="hover:bg-gray-50">
                      <td className="py-3 px-4">
                        <div>
                          <div className="font-medium text-gray-900">
                            {ordem.cliente?.nome}
                          </div>
                          <div className="text-sm text-gray-500">
                            📞 {ordem.cliente?.telefone || 'Não informado'}
                          </div>
                          {ordem.cliente?.email && (
                            <div className="text-sm text-gray-500">
                              📧 {ordem.cliente.email}
                            </div>
                          )}
                          {ordem.cliente?.endereco && (
                            <div className="text-sm text-gray-500 max-w-xs truncate">
                              📍 {ordem.cliente.endereco}{ordem.cliente?.cidade ? `, ${ordem.cliente.cidade}` : ''}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">
                            {TIPO_ICONS[ordem.tipo]}
                          </span>
                          <div>
                            <div className="font-medium text-gray-900">
                              {ordem.marca} {ordem.modelo}
                            </div>
                            <div className="text-sm text-gray-500">
                              {ordem.equipamento || `${ordem.marca} ${ordem.modelo}`}
                            </div>
                            {ordem.numero_os && (
                              <div className="text-xs text-blue-600 font-mono">
                                #{ordem.numero_os}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="text-sm text-gray-900">
                          <div className="max-w-xs">
                            {ordem.descricao_problema || ordem.defeito_relatado}
                          </div>
                          {ordem.observacoes && (
                            <div className="text-xs text-gray-500 mt-1 max-w-xs truncate">
                              💬 {ordem.observacoes}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${STATUS_COLORS[ordem.status]}`}>
                          {ordem.status}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-sm text-gray-500">
                        <div>
                          <div className="font-medium">
                            📅 Entrada: {formatDate(ordem.data_entrada)}
                          </div>
                          {ordem.data_finalizacao && (
                            <div className="text-green-600">
                              ✅ Finalizada: {formatDate(ordem.data_finalizacao)}
                            </div>
                          )}
                          {ordem.data_entrega && (
                            <div className="text-blue-600">
                              📦 Entrega: {formatDate(ordem.data_entrega)}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4 text-sm">
                        <div>
                          <div className="font-medium text-gray-900">
                            💰 {formatCurrency(ordem.valor || ordem.valor_orcamento || 0)}
                          </div>
                          {ordem.forma_pagamento && (
                            <div className="text-xs text-gray-500">
                              💳 {ordem.forma_pagamento}
                            </div>
                          )}
                          {ordem.mao_de_obra && ordem.mao_de_obra > 0 && (
                            <div className="text-xs text-gray-500">
                              🔧 Mão de obra: {formatCurrency(ordem.mao_de_obra)}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4 text-sm text-gray-500">
                        <div>
                          {ordem.garantia_meses ? (
                            <div className="text-green-600">
                              🛡️ {ordem.garantia_meses} {ordem.garantia_meses === 1 ? 'mês' : 'meses'}
                            </div>
                          ) : (
                            <div className="text-gray-400">
                              ❌ Sem garantia
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleEditOrdem(ordem)}
                            className="p-1 text-blue-600 hover:text-blue-800"
                            title="Editar"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(ordem.id)}
                            className="p-1 text-red-600 hover:text-red-800"
                            title="Excluir"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Modal de Edição */}
        <EditarOrdemModal
          ordem={editingOrdem}
          isOpen={isEditModalOpen}
          onClose={handleCloseEditModal}
          onSuccess={handleUpdateSuccess}
        />
      </div>
    </div>
  )
}
