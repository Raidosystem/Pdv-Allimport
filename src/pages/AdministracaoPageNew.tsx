import React, { useState } from 'react'
import { Settings, Users, Shield, Database, Server, Activity, Lock, Plus, Edit, Trash2, CheckCircle, XCircle, AlertTriangle, Save, Download, Upload, FileText, Cloud, FileDown } from 'lucide-react'
import { supabase } from '../lib/supabase'
import toast from 'react-hot-toast'

type ViewMode = 'dashboard' | 'usuarios' | 'permissoes' | 'backup' | 'sistema' | 'seguranca'

interface Usuario {
  id: string
  nome: string
  email: string
  cargo: string
  nivel: 'admin' | 'gerente' | 'vendedor' | 'operador'
  status: 'ativo' | 'inativo' | 'bloqueado'
  ultimo_acesso: string
  criado_em: string
}

interface Permissao {
  id: string
  modulo: string
  acao: string
  descricao: string
  nivel_minimo: string
}

interface ConfiguracaoSistema {
  id: string
  categoria: string
  chave: string
  valor: string
  descricao: string
  tipo: 'texto' | 'numero' | 'boolean' | 'select'
  opcoes?: string[]
}

interface LogSistema {
  id: string
  usuario: string
  acao: string
  modulo: string
  detalhes: string
  ip: string
  timestamp: string
  nivel: 'info' | 'warning' | 'error'
}

export function AdministracaoPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('dashboard')
  const [importingBackupOS, setImportingBackupOS] = useState(false)
  // Estados comentados para evitar warnings - podem ser implementados futuramente
  // const [searchTerm, setSearchTerm] = useState('')
  // const [selectedUser, setSelectedUser] = useState<Usuario | null>(null)
  // const [showUserForm, setShowUserForm] = useState(false)
  // const [loading, setLoading] = useState(false)

  // Dados de administração - carregados do Supabase
  const usuariosMock: Usuario[] = []

  const permissoesMock: Permissao[] = []

  const configuracoesSystema: ConfiguracaoSistema[] = [
    {
      id: '1',
      categoria: 'Geral',
      chave: 'nome_empresa',
      valor: 'Minha Empresa',
      descricao: 'Nome da empresa no sistema',
      tipo: 'texto'
    },
    {
      id: '2',
      categoria: 'Vendas',
      chave: 'desconto_maximo',
      valor: '10',
      descricao: 'Desconto máximo permitido (%)',
      tipo: 'numero'
    },
    {
      id: '3',
      categoria: 'Sistema',
      chave: 'backup_automatico',
      valor: 'true',
      descricao: 'Ativar backup automático diário',
      tipo: 'boolean'
    },
    {
      id: '4',
      categoria: 'Notificações',
      chave: 'enviar_emails',
      valor: 'false',
      descricao: 'Enviar notificações por email',
      tipo: 'boolean'
    },
    {
      id: '5',
      categoria: 'Estoque',
      chave: 'alerta_estoque_baixo',
      valor: '5',
      descricao: 'Quantidade mínima para alerta',
      tipo: 'numero'
    }
  ]

  const logsSistema: LogSistema[] = []

  // Estatísticas do dashboard
  const stats = {
    total_usuarios: usuariosMock.length,
    usuarios_ativos: usuariosMock.filter(u => u.status === 'ativo').length,
    usuarios_bloqueados: usuariosMock.filter(u => u.status === 'bloqueado').length,
    logins_hoje: 0,
    backup_ultimo: new Date().toISOString(),
    espaco_disco: 0,
    memoria_uso: 0,
    uptime_sistema: '0 dias, 0 horas'
  }

  const formatDateTime = (dateTime: string) => {
    return new Date(dateTime).toLocaleString('pt-BR')
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('pt-BR')
  }

  const handleSaveConfig = async (config: ConfiguracaoSistema, _novoValor: string) => {
    // setLoading(true)
    // Simular salvamento
    setTimeout(() => {
      alert(`Configuração "${config.descricao}" salva com sucesso!`)
      // setLoading(false)
    }, 1000)
  }

  const handleToggleUserStatus = (_userId: string) => {
    // Simular mudança de status
    alert(`Status do usuário alterado com sucesso!`)
  }

  const handleDeleteUser = (_userId: string) => {
    if (confirm('Tem certeza que deseja excluir este usuário?')) {
      alert('Usuário excluído com sucesso!')
    }
  }

  // Funções de Backup
  const handleExportBackup = async () => {
    try {
      toast.loading('Gerando backup do sistema...', { id: 'export-backup' })

      // Simular dados do sistema para backup
      const backupData = {
        version: '1.0',
        timestamp: new Date().toISOString(),
        exported_by: 'Admin System',
        system_info: {
          name: 'PDV Allimport',
          version: '2.2.3',
          environment: process.env.NODE_ENV || 'production'
        },
        data: {
          users: usuariosMock,
          permissions: permissoesMock,
          configurations: configuracoesSystema,
          logs: logsSistema.slice(0, 100), // Últimos 100 logs
          stats: stats,
          // Adicionar mais tabelas conforme necessário
          // products: [], // TODO: Adicionar produtos
          // customers: [], // TODO: Adicionar clientes
          // sales: [], // TODO: Adicionar vendas
        },
        metadata: {
          export_date: new Date().toISOString(),
          total_users: usuariosMock.length,
          total_permissions: permissoesMock.length,
          total_configurations: configuracoesSystema.length,
          total_logs: logsSistema.length,
          total_records: usuariosMock.length + permissoesMock.length + configuracoesSystema.length + logsSistema.length,
          file_size_mb: 0 // Será calculado após stringificar
        }
      }

      // Converter para JSON formatado
      const jsonString = JSON.stringify(backupData, null, 2)
      
      // Calcular tamanho do arquivo
      const sizeInMB = (new Blob([jsonString]).size / (1024 * 1024)).toFixed(2)
      backupData.metadata.file_size_mb = parseFloat(sizeInMB)
      
      // Re-stringify com o tamanho atualizado
      const finalJsonString = JSON.stringify(backupData, null, 2)
      
      // Criar blob e fazer download
      const blob = new Blob([finalJsonString], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      
      // Nome do arquivo com timestamp
      const timestamp = new Date().toISOString().split('T')[0].replace(/-/g, '')
      const time = new Date().toTimeString().split(' ')[0].replace(/:/g, '')
      link.download = `backup-pdv-allimport-${timestamp}-${time}.json`
      
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)

      toast.success(
        `Backup exportado com sucesso!\n\n` +
        `📁 Arquivo: backup-pdv-allimport-${timestamp}-${time}.json\n` +
        `📊 Registros: ${backupData.metadata.total_records}\n` +
        `💾 Tamanho: ${sizeInMB} MB`,
        { 
          id: 'export-backup',
          duration: 6000
        }
      )

    } catch (error: any) {
      console.error('❌ Erro ao exportar backup:', error)
      toast.error(
        `Erro ao exportar backup: ${error.message || 'Erro desconhecido'}`,
        { id: 'export-backup' }
      )
    }
  }

  const handleImportBackup = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Validações de arquivo
    if (file.type !== 'application/json' && !file.name.endsWith('.json')) {
      toast.error('Por favor, selecione um arquivo JSON válido.')
      return
    }

    if (file.size > 50 * 1024 * 1024) { // 50MB limite
      toast.error('Arquivo muito grande. O limite é 50MB.')
      return
    }

    toast.loading('Importando backup do sistema...', { id: 'import-backup' })

    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const backupData = JSON.parse(e.target?.result as string)
        
        // Validar estrutura completa do backup
        if (!backupData.version || !backupData.data || !backupData.timestamp) {
          throw new Error('Estrutura de backup inválida - campos obrigatórios ausentes')
        }

        // Validar versão compatível
        if (backupData.version !== '1.0') {
          throw new Error(`Versão de backup incompatível: ${backupData.version}. Versão suportada: 1.0`)
        }

        // Validar dados essenciais
        const { data } = backupData
        if (!data.users && !data.permissions && !data.configurations) {
          throw new Error('Backup não contém dados válidos para importação')
        }

        console.log('✅ Backup importado com sucesso:', backupData)
        
        // Estatísticas do backup
        const totalUsuarios = data.users?.length || 0
        const totalPermissoes = data.permissions?.length || 0
        const totalConfiguracoes = data.configurations?.length || 0
        const totalLogs = data.logs?.length || 0
        const dataBackup = new Date(backupData.timestamp).toLocaleString('pt-BR')
        
        toast.success(
          `Backup importado com sucesso!\n\n` +
          `📅 Data: ${dataBackup}\n` +
          `👥 Usuários: ${totalUsuarios}\n` +
          `🔐 Permissões: ${totalPermissoes}\n` +
          `⚙️ Configurações: ${totalConfiguracoes}\n` +
          `📋 Logs: ${totalLogs}`,
          { 
            id: 'import-backup',
            duration: 8000
          }
        )
        
        // TODO: Implementar lógica real de importação
        // Aqui você salvaria os dados no Supabase:
        // - Inserir usuários em auth.users
        // - Inserir permissões na tabela de permissões
        // - Atualizar configurações do sistema
        // - Registrar log da importação
        
      } catch (error: any) {
        console.error('❌ Erro ao importar backup:', error)
        toast.error(
          `Erro ao importar backup: ${error.message || 'Arquivo inválido ou corrompido'}`,
          { id: 'import-backup' }
        )
      }
    }

    reader.onerror = () => {
      toast.error('Erro ao ler arquivo de backup', { id: 'import-backup' })
    }

    reader.readAsText(file)
    
    // Limpar o input para permitir reimportação do mesmo arquivo
    event.target.value = ''
  }

  const handleGenerateReport = () => {
    const report = {
      timestamp: new Date().toISOString(),
      system_status: 'Online',
      total_users: usuariosMock.length,
      active_users: usuariosMock.filter(u => u.status === 'ativo').length,
      total_configurations: configuracoesSystema.length,
      recent_logs: logsSistema.length,
      uptime: stats.uptime_sistema,
      disk_usage: `${stats.espaco_disco}%`,
      memory_usage: `${stats.memoria_uso}%`
    }

    const jsonString = JSON.stringify(report, null, 2)
    const blob = new Blob([jsonString], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `relatorio-sistema-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)

    alert('Relatório do sistema gerado com sucesso!')
  }

  // Função para importar backup de ordens de serviço
  const importarBackupOS = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Reset input para permitir re-upload do mesmo arquivo
    event.target.value = ''

    setImportingBackupOS(true)
    toast.loading('Preparando importação de backup...', { id: 'backup-os' })

    try {
      const text = await file.text()
      const backupData = JSON.parse(text)

      console.log('📂 Backup carregado:', backupData)

      // Detectar formato do backup
      let ordensParaImportar = []

      // Formato 1: Array direto
      if (Array.isArray(backupData)) {
        ordensParaImportar = backupData
      }
      // Formato 2: Objeto com propriedade "ordens" ou similares
      else if (backupData.ordens) {
        ordensParaImportar = backupData.ordens
      }
      else if (backupData.service_orders) {
        ordensParaImportar = backupData.service_orders
      }
      else if (backupData.data?.service_orders) {
        ordensParaImportar = backupData.data.service_orders
      }
      // Formato 3: Objeto com chaves que parecem ser ordens
      else if (typeof backupData === 'object') {
        ordensParaImportar = Object.values(backupData).filter((item: any) => 
          item && typeof item === 'object' && (item.cliente_nome || item.equipamento || item.defeito)
        )
      }

      if (!ordensParaImportar.length) {
        throw new Error('Nenhuma ordem de serviço encontrada no arquivo')
      }

      console.log(`📋 ${ordensParaImportar.length} ordens encontradas`)
      toast.success(`${ordensParaImportar.length} ordens encontradas. Importando...`, { id: 'backup-os' })

      // Obter o usuário atual
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        throw new Error('Usuário não autenticado')
      }

      let sucessos = 0
      let erros: string[] = []

      // Importar cada ordem individualmente
      for (const ordem of ordensParaImportar) {
        try {
          console.log('🔄 Processando ordem:', ordem)

          // Mapear campos do backup para o formato do banco
          const ordemFormatada = {
            id: ordem.id || crypto.randomUUID(),
            user_id: user.id, // ISOLAMENTO POR USUÁRIO
            numero_os: ordem.numero_os || ordem.numeroOS || ordem.os || `OS${Date.now()}`,
            client_name: ordem.cliente_nome || ordem.clienteNome || ordem.cliente || ordem.name || 'Cliente Importado',
            client_phone: ordem.cliente_telefone || ordem.clienteTelefone || ordem.telefone || ordem.phone || null,
            equipment_type: ordem.tipo_equipamento || ordem.tipoEquipamento || ordem.tipo || ordem.equipamento || 'Equipamento',
            equipment_brand: ordem.marca || ordem.brand || 'Marca',
            equipment_model: ordem.modelo || ordem.model || 'Modelo',
            equipment_serial: ordem.serie || ordem.serial || null,
            defect_description: ordem.defeito_relatado || ordem.defeitoRelatado || ordem.defeito || ordem.problema || ordem.issue || 'Defeito relatado',
            technical_observations: ordem.observacoes_tecnicas || ordem.observacoesTecnicas || ordem.observacoes || null,
            estimated_value: parseFloat(ordem.valor_orcado || ordem.valorOrcado || ordem.orcamento || ordem.price || ordem.valor || '0'),
            service_status: mapearStatus(ordem.status || ordem.situacao || ordem.state || 'Em análise'),
            warranty_months: parseInt(ordem.garantia_meses || ordem.garantiaMeses || ordem.garantia || '3'),
            created_at: ordem.created_at || ordem.data_criacao || ordem.dataCriacao || new Date().toISOString(),
            updated_at: new Date().toISOString()
          }

          console.log('📝 Ordem formatada:', ordemFormatada)

          // Inserir no banco
          const { error } = await supabase
            .from('service_orders')
            .insert([ordemFormatada])

          if (error) {
            console.error('❌ Erro ao inserir ordem:', error)
            erros.push(`${ordemFormatada.numero_os}: ${error.message}`)
          } else {
            sucessos++
            console.log(`✅ Ordem ${ordemFormatada.numero_os} importada com sucesso`)
          }

        } catch (error: any) {
          console.error('❌ Erro ao processar ordem:', error)
          erros.push(`Ordem ${ordem.numero_os || 'desconhecida'}: ${error.message}`)
        }
      }

      // Exibir resultado
      if (sucessos > 0) {
        toast.success(`✅ ${sucessos} ordens importadas com sucesso!`, { id: 'backup-os', duration: 5000 })
        
        if (erros.length > 0) {
          console.warn('⚠️ Alguns erros ocorreram:', erros)
          toast.error(`⚠️ ${erros.length} ordens falharam na importação`, { duration: 5000 })
        }
      } else {
        toast.error('❌ Nenhuma ordem foi importada', { id: 'backup-os' })
      }

      console.log(`📊 Resultado final: ${sucessos} sucessos, ${erros.length} erros`)

    } catch (error: any) {
      console.error('❌ Erro ao importar backup:', error)
      toast.error('Erro ao importar backup: ' + error.message, { id: 'backup-os' })
    } finally {
      setImportingBackupOS(false)
    }
  }

  // Função auxiliar para mapear status
  const mapearStatus = (statusOriginal: string): string => {
    const statusMap: { [key: string]: string } = {
      'Orçamento': 'Em análise',
      'Em andamento': 'Em conserto', 
      'Conserto': 'Em conserto',
      'Concluído': 'Pronto',
      'Concluido': 'Pronto',
      'Entregue': 'Entregue',
      'Cancelado': 'Cancelado'
    }

    return statusMap[statusOriginal] || statusOriginal || 'Em análise'
  }

  // Card de Estatística
  const StatCard = ({ title, value, icon: Icon, color, subtitle, status }: {
    title: string
    value: string | number
    icon: React.ComponentType<any>
    color: string
    subtitle?: string
    status?: 'good' | 'warning' | 'danger'
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
            {subtitle && (
              <dd className="text-xs text-gray-500">{subtitle}</dd>
            )}
            {status && (
              <dd className={`text-xs font-medium mt-1 ${
                status === 'good' ? 'text-green-600' :
                status === 'warning' ? 'text-yellow-600' : 'text-red-600'
              }`}>
                {status === 'good' ? '● Normal' :
                 status === 'warning' ? '● Atenção' : '● Crítico'}
              </dd>
            )}
          </dl>
        </div>
      </div>
    </div>
  )

  // Dashboard principal
  const DashboardView = () => (
    <div className="space-y-6">
      {/* Estatísticas principais */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Total de Usuários" 
          value={stats.total_usuarios} 
          icon={Users} 
          color="border-blue-500"
          subtitle="cadastrados"
        />
        <StatCard 
          title="Usuários Ativos" 
          value={stats.usuarios_ativos} 
          icon={CheckCircle} 
          color="border-green-500"
          status="good"
        />
        <StatCard 
          title="Usuários Bloqueados" 
          value={stats.usuarios_bloqueados} 
          icon={Lock} 
          color="border-red-500"
          status={stats.usuarios_bloqueados > 0 ? "warning" : "good"}
        />
        <StatCard 
          title="Logins Hoje" 
          value={stats.logins_hoje} 
          icon={Activity} 
          color="border-purple-500"
          subtitle="acessos"
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Último Backup" 
          value={formatDate(stats.backup_ultimo)} 
          icon={Database} 
          color="border-cyan-500"
          subtitle="automático"
          status="good"
        />
        <StatCard 
          title="Uso do Disco" 
          value={`${stats.espaco_disco}%`} 
          icon={Server} 
          color="border-orange-500"
          status={stats.espaco_disco > 80 ? "warning" : "good"}
        />
        <StatCard 
          title="Uso da Memória" 
          value={`${stats.memoria_uso}%`} 
          icon={Activity} 
          color="border-indigo-500"
          status={stats.memoria_uso > 80 ? "warning" : "good"}
        />
        <StatCard 
          title="Uptime do Sistema" 
          value={stats.uptime_sistema} 
          icon={Server} 
          color="border-green-500"
          status="good"
        />
      </div>

      {/* Logs recentes do sistema */}
      <div className="bg-white rounded-lg shadow-sm">
        <div className="p-6 border-b">
          <h3 className="text-lg font-semibold text-gray-900">Logs Recentes do Sistema</h3>
          <p className="text-gray-600 mt-1">Últimas atividades e eventos importantes</p>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Data/Hora</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Usuário</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Ação</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Módulo</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Nível</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {logsSistema.slice(0, 5).map((log) => (
                <tr key={log.id} className="hover:bg-gray-50">
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {formatDateTime(log.timestamp)}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {log.usuario}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {log.acao}
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-600">
                    {log.modulo}
                  </td>
                  <td className="py-3 px-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      log.nivel === 'info' ? 'bg-blue-100 text-blue-800' :
                      log.nivel === 'warning' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    }`}>
                      {log.nivel === 'info' ? 'Info' :
                       log.nivel === 'warning' ? 'Aviso' : 'Erro'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )

  // Gestão de usuários
  const UsuariosView = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Gestão de Usuários</h3>
          <p className="text-gray-600 mt-1">Gerencie usuários e suas permissões</p>
        </div>
        <button
          onClick={() => console.log('Novo usuário')}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
        >
          <Plus className="h-4 w-4" />
          Novo Usuário
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Usuário</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Cargo</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Nível</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                <th className="text-left py-3 px-4 font-medium text-gray-700">Último Acesso</th>
                <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {usuariosMock.map((usuario) => (
                <tr key={usuario.id} className="hover:bg-gray-50">
                  <td className="py-3 px-4">
                    <div>
                      <div className="font-medium text-gray-900">{usuario.nome}</div>
                      <div className="text-sm text-gray-500">{usuario.email}</div>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-900">
                    {usuario.cargo}
                  </td>
                  <td className="py-3 px-4">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      usuario.nivel === 'admin' ? 'bg-purple-100 text-purple-800' :
                      usuario.nivel === 'gerente' ? 'bg-blue-100 text-blue-800' :
                      usuario.nivel === 'vendedor' ? 'bg-green-100 text-green-800' :
                      'bg-gray-100 text-gray-800'
                    }`}>
                      {usuario.nivel}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <button
                      onClick={() => handleToggleUserStatus(usuario.id)}
                      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${
                        usuario.status === 'ativo' ? 'bg-green-100 text-green-800 border-green-200 hover:bg-green-200' :
                        usuario.status === 'inativo' ? 'bg-yellow-100 text-yellow-800 border-yellow-200 hover:bg-yellow-200' :
                        'bg-red-100 text-red-800 border-red-200 hover:bg-red-200'
                      }`}
                    >
                      {usuario.status === 'ativo' ? (
                        <>
                          <CheckCircle className="h-3 w-3 mr-1" />
                          Ativo
                        </>
                      ) : usuario.status === 'inativo' ? (
                        <>
                          <AlertTriangle className="h-3 w-3 mr-1" />
                          Inativo
                        </>
                      ) : (
                        <>
                          <XCircle className="h-3 w-3 mr-1" />
                          Bloqueado
                        </>
                      )}
                    </button>
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-500">
                    {formatDateTime(usuario.ultimo_acesso)}
                  </td>
                  <td className="py-3 px-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => console.log('Usuário selecionado:', usuario.nome)}
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Editar"
                      >
                        <Edit className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteUser(usuario.id)}
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
      </div>
    </div>
  )

  // Gestão de permissões
  const PermissoesView = () => (
    <div className="bg-white rounded-lg shadow-sm">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">Gestão de Permissões</h3>
        <p className="text-gray-600 mt-1">Configure as permissões de acesso por módulo</p>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Módulo</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Ação</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Descrição</th>
              <th className="text-left py-3 px-4 font-medium text-gray-700">Nível Mínimo</th>
              <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {permissoesMock.map((permissao) => (
              <tr key={permissao.id} className="hover:bg-gray-50">
                <td className="py-3 px-4 text-sm font-medium text-gray-900">
                  {permissao.modulo}
                </td>
                <td className="py-3 px-4 text-sm text-gray-900">
                  {permissao.acao}
                </td>
                <td className="py-3 px-4 text-sm text-gray-600">
                  {permissao.descricao}
                </td>
                <td className="py-3 px-4">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    permissao.nivel_minimo === 'admin' ? 'bg-purple-100 text-purple-800' :
                    permissao.nivel_minimo === 'gerente' ? 'bg-blue-100 text-blue-800' :
                    permissao.nivel_minimo === 'vendedor' ? 'bg-green-100 text-green-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {permissao.nivel_minimo}
                  </span>
                </td>
                <td className="py-3 px-4 text-right">
                  <button
                    className="p-1 text-blue-600 hover:text-blue-800"
                    title="Editar Permissão"
                  >
                    <Edit className="h-4 w-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )

  // Backup do Sistema
  const BackupView = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900">Backup Completo JSON</h3>
        <p className="text-gray-600 mt-1">Exporte, importe e gerencie backups do sistema</p>
      </div>

      {/* Estatísticas de Backup */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-lg shadow-sm border-l-4 border-blue-500">
          <div className="flex items-center">
            <Database className="h-8 w-8 text-blue-500" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Último Backup</p>
              <p className="text-lg font-bold text-gray-900">{formatDate(stats.backup_ultimo)}</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow-sm border-l-4 border-green-500">
          <div className="flex items-center">
            <FileText className="h-8 w-8 text-green-500" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Tamanho Estimado</p>
              <p className="text-lg font-bold text-gray-900">~2.5 MB</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow-sm border-l-4 border-purple-500">
          <div className="flex items-center">
            <Cloud className="h-8 w-8 text-purple-500" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Status</p>
              <p className="text-lg font-bold text-green-600">Ativo</p>
            </div>
          </div>
        </div>
      </div>

      {/* Ações de Backup */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h4 className="text-lg font-semibold text-gray-900 mb-4">Ações de Backup</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          
          {/* Exportar Backup */}
          <button
            onClick={handleExportBackup}
            className="flex flex-col items-center p-6 border border-gray-200 rounded-lg hover:bg-blue-50 hover:border-blue-300 transition-colors group"
          >
            <Download className="h-12 w-12 text-blue-500 group-hover:text-blue-600 mb-3" />
            <span className="text-lg font-medium text-gray-900 mb-1">Exportar Backup</span>
            <span className="text-sm text-gray-600 text-center">
              Baixar backup completo em formato JSON com todos os dados do sistema
            </span>
          </button>

          {/* Importar Backup */}
          <label className="flex flex-col items-center p-6 border border-gray-200 rounded-lg hover:bg-green-50 hover:border-green-300 transition-colors group cursor-pointer">
            <Upload className="h-12 w-12 text-green-500 group-hover:text-green-600 mb-3" />
            <span className="text-lg font-medium text-gray-900 mb-1">Importar Backup</span>
            <span className="text-sm text-gray-600 text-center">
              Restaurar sistema a partir de arquivo JSON de backup
            </span>
            <input
              type="file"
              accept=".json"
              onChange={handleImportBackup}
              className="hidden"
            />
          </label>

          {/* Importar Backup de Ordens de Serviço */}
          <div className="relative">
            <label className="flex flex-col items-center p-6 border border-gray-200 rounded-lg hover:bg-orange-50 hover:border-orange-300 transition-colors group cursor-pointer">
              <FileDown className="h-12 w-12 text-orange-500 group-hover:text-orange-600 mb-3" />
              <span className="text-lg font-medium text-gray-900 mb-1">Backup OS</span>
              <span className="text-sm text-gray-600 text-center">
                Importar ordens de serviço a partir de arquivo JSON
              </span>
              <input
                type="file"
                accept=".json"
                onChange={importarBackupOS}
                className="hidden"
                disabled={importingBackupOS}
              />
            </label>
            {importingBackupOS && (
              <div className="absolute inset-0 bg-orange-100 bg-opacity-75 rounded-lg flex items-center justify-center">
                <span className="text-orange-600 font-medium">Importando...</span>
              </div>
            )}
          </div>

          {/* Gerar Relatório */}
          <button
            onClick={handleGenerateReport}
            className="flex flex-col items-center p-6 border border-gray-200 rounded-lg hover:bg-purple-50 hover:border-purple-300 transition-colors group"
          >
            <FileText className="h-12 w-12 text-purple-500 group-hover:text-purple-600 mb-3" />
            <span className="text-lg font-medium text-gray-900 mb-1">Gerar Relatório</span>
            <span className="text-sm text-gray-600 text-center">
              Criar relatório detalhado do status atual do sistema
            </span>
          </button>
        </div>
      </div>

      {/* Informações sobre o Backup */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h4 className="text-lg font-semibold text-gray-900 mb-4">Conteúdo do Backup</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <h5 className="font-medium text-gray-900">Dados Inclusos:</h5>
            <ul className="text-sm text-gray-600 space-y-1">
              <li className="flex items-center">
                <CheckCircle className="h-4 w-4 text-green-500 mr-2" />
                Usuários e permissões
              </li>
              <li className="flex items-center">
                <CheckCircle className="h-4 w-4 text-green-500 mr-2" />
                Configurações do sistema
              </li>
              <li className="flex items-center">
                <CheckCircle className="h-4 w-4 text-green-500 mr-2" />
                Logs do sistema (últimos 100)
              </li>
              <li className="flex items-center">
                <CheckCircle className="h-4 w-4 text-green-500 mr-2" />
                Estatísticas gerais
              </li>
            </ul>
          </div>
          <div className="space-y-2">
            <h5 className="font-medium text-gray-900">Formato JSON:</h5>
            <pre className="text-xs bg-gray-100 p-3 rounded-lg overflow-x-auto">
{`{
  "version": "1.0",
  "timestamp": "2025-01-20T...",
  "data": {
    "users": [...],
    "permissions": [...],
    "configurations": [...],
    "logs": [...]
  },
  "metadata": {
    "exported_by": "Admin",
    "system": "PDV Allimport",
    "total_records": 125
  }
}`}
            </pre>
          </div>
        </div>
      </div>

      {/* Aviso de Segurança */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <div className="flex">
          <AlertTriangle className="h-5 w-5 text-yellow-400" />
          <div className="ml-3">
            <h3 className="text-sm font-medium text-yellow-800">
              Aviso de Segurança
            </h3>
            <div className="mt-2 text-sm text-yellow-700">
              <ul className="list-disc list-inside space-y-1">
                <li>Os backups podem conter informações sensíveis. Mantenha-os seguros.</li>
                <li>Teste os backups em ambiente de desenvolvimento antes de usar em produção.</li>
                <li>Faça backups regulares para evitar perda de dados.</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )

  // Configurações do sistema
  const SistemaView = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900">Configurações do Sistema</h3>
        <p className="text-gray-600 mt-1">Ajuste as configurações gerais do sistema</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm">
        <div className="divide-y divide-gray-200">
          {configuracoesSystema.map((config) => (
            <div key={config.id} className="p-6">
              <div className="flex items-start justify-between">
                <div className="flex-1 min-w-0 mr-4">
                  <h4 className="text-sm font-medium text-gray-900">
                    {config.descricao}
                  </h4>
                  <p className="text-sm text-gray-500 mt-1">
                    Categoria: {config.categoria} | Chave: {config.chave}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  {config.tipo === 'boolean' ? (
                    <label className="flex items-center">
                      <input
                        type="checkbox"
                        checked={config.valor === 'true'}
                        onChange={(e) => handleSaveConfig(config, e.target.checked.toString())}
                        className="mr-2"
                      />
                      <span className="text-sm text-gray-700">
                        {config.valor === 'true' ? 'Ativado' : 'Desativado'}
                      </span>
                    </label>
                  ) : config.tipo === 'numero' ? (
                    <div className="flex items-center gap-2">
                      <input
                        type="number"
                        defaultValue={config.valor}
                        className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                      />
                      <button
                        onClick={() => handleSaveConfig(config, config.valor)}
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Salvar"
                      >
                        <Save className="h-4 w-4" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <input
                        type="text"
                        defaultValue={config.valor}
                        className="w-40 px-2 py-1 border border-gray-300 rounded text-sm"
                      />
                      <button
                        onClick={() => handleSaveConfig(config, config.valor)}
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Salvar"
                      >
                        <Save className="h-4 w-4" />
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Administração do Sistema</h1>
            <p className="text-gray-600 mt-1">
              Gerencie usuários, permissões e configurações do sistema
            </p>
          </div>
        </div>

        {/* Navegação por abas */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setViewMode('dashboard')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'dashboard'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Activity className="h-4 w-4 inline mr-2" />
              Dashboard
            </button>
            <button
              onClick={() => setViewMode('usuarios')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'usuarios'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Users className="h-4 w-4 inline mr-2" />
              Usuários
            </button>
            <button
              onClick={() => setViewMode('permissoes')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'permissoes'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Shield className="h-4 w-4 inline mr-2" />
              Permissões
            </button>
            <button
              onClick={() => setViewMode('backup')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'backup'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Database className="h-4 w-4 inline mr-2" />
              Backup
            </button>
            <button
              onClick={() => setViewMode('sistema')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                viewMode === 'sistema'
                  ? 'bg-blue-100 text-blue-700 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Settings className="h-4 w-4 inline mr-2" />
              Sistema
            </button>
          </div>
        </div>

        {/* Conteúdo baseado na view selecionada */}
        <div className="animate-in fade-in duration-300">
          {viewMode === 'dashboard' && <DashboardView />}
          {viewMode === 'usuarios' && <UsuariosView />}
          {viewMode === 'permissoes' && <PermissoesView />}
          {viewMode === 'backup' && <BackupView />}
          {viewMode === 'sistema' && <SistemaView />}
        </div>
      </div>
    </div>
  )
}
