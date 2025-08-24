import React, { useState } from 'react'
import { Settings, Users, Shield, Database, Server, Activity, Lock, Plus, Edit, Trash2, CheckCircle, XCircle, AlertTriangle, Save } from 'lucide-react'

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
  // Estados comentados para evitar warnings - podem ser implementados futuramente
  // const [searchTerm, setSearchTerm] = useState('')
  // const [selectedUser, setSelectedUser] = useState<Usuario | null>(null)
  // const [showUserForm, setShowUserForm] = useState(false)
  // const [loading, setLoading] = useState(false)

  // Mock data para administração
  const usuariosMock: Usuario[] = [
    {
      id: '1',
      nome: 'João Silva',
      email: 'joao.silva@allimport.com',
      cargo: 'Administrador',
      nivel: 'admin',
      status: 'ativo',
      ultimo_acesso: '2024-01-20T14:30:00',
      criado_em: '2023-06-15T09:00:00'
    },
    {
      id: '2',
      nome: 'Ana Costa',
      email: 'ana.costa@allimport.com',
      cargo: 'Gerente de Vendas',
      nivel: 'gerente',
      status: 'ativo',
      ultimo_acesso: '2024-01-20T16:45:00',
      criado_em: '2023-08-10T10:30:00'
    },
    {
      id: '3',
      nome: 'Carlos Oliveira',
      email: 'carlos.oliveira@allimport.com',
      cargo: 'Vendedor',
      nivel: 'vendedor',
      status: 'ativo',
      ultimo_acesso: '2024-01-19T18:20:00',
      criado_em: '2023-09-05T11:15:00'
    },
    {
      id: '4',
      nome: 'Maria Santos',
      email: 'maria.santos@allimport.com',
      cargo: 'Operador de Caixa',
      nivel: 'operador',
      status: 'inativo',
      ultimo_acesso: '2024-01-15T12:00:00',
      criado_em: '2023-10-20T14:45:00'
    },
    {
      id: '5',
      nome: 'Pedro Lima',
      email: 'pedro.lima@allimport.com',
      cargo: 'Vendedor',
      nivel: 'vendedor',
      status: 'bloqueado',
      ultimo_acesso: '2024-01-10T09:30:00',
      criado_em: '2023-11-12T16:20:00'
    }
  ]

  const permissoesMock: Permissao[] = [
    {
      id: '1',
      modulo: 'Vendas',
      acao: 'Criar Venda',
      descricao: 'Permite criar novas vendas no sistema',
      nivel_minimo: 'vendedor'
    },
    {
      id: '2',
      modulo: 'Vendas',
      acao: 'Cancelar Venda',
      descricao: 'Permite cancelar vendas existentes',
      nivel_minimo: 'gerente'
    },
    {
      id: '3',
      modulo: 'Produtos',
      acao: 'Cadastrar Produto',
      descricao: 'Permite adicionar novos produtos',
      nivel_minimo: 'gerente'
    },
    {
      id: '4',
      modulo: 'Relatórios',
      acao: 'Visualizar Relatórios',
      descricao: 'Acesso aos relatórios do sistema',
      nivel_minimo: 'vendedor'
    },
    {
      id: '5',
      modulo: 'Administração',
      acao: 'Gerenciar Usuários',
      descricao: 'Permite gerenciar usuários do sistema',
      nivel_minimo: 'admin'
    }
  ]

  const configuracoesSystema: ConfiguracaoSistema[] = [
    {
      id: '1',
      categoria: 'Geral',
      chave: 'nome_empresa',
      valor: 'Allimport Technology',
      descricao: 'Nome da empresa no sistema',
      tipo: 'texto'
    },
    {
      id: '2',
      categoria: 'Vendas',
      chave: 'desconto_maximo',
      valor: '20',
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
      valor: 'true',
      descricao: 'Enviar notificações por email',
      tipo: 'boolean'
    },
    {
      id: '5',
      categoria: 'Estoque',
      chave: 'alerta_estoque_baixo',
      valor: '10',
      descricao: 'Quantidade mínima para alerta',
      tipo: 'numero'
    }
  ]

  const logsSistema: LogSistema[] = [
    {
      id: '1',
      usuario: 'João Silva',
      acao: 'Login realizado',
      modulo: 'Autenticação',
      detalhes: 'Login bem-sucedido via navegador',
      ip: '192.168.1.100',
      timestamp: '2024-01-20T14:30:00',
      nivel: 'info'
    },
    {
      id: '2',
      usuario: 'Ana Costa',
      acao: 'Produto criado',
      modulo: 'Produtos',
      detalhes: 'Novo produto: Smartphone Samsung A54',
      ip: '192.168.1.101',
      timestamp: '2024-01-20T15:45:00',
      nivel: 'info'
    },
    {
      id: '3',
      usuario: 'Sistema',
      acao: 'Backup realizado',
      modulo: 'Sistema',
      detalhes: 'Backup automático concluído com sucesso',
      ip: 'localhost',
      timestamp: '2024-01-20T02:00:00',
      nivel: 'info'
    },
    {
      id: '4',
      usuario: 'Pedro Lima',
      acao: 'Tentativa de login falhada',
      modulo: 'Autenticação',
      detalhes: 'Senha incorreta',
      ip: '192.168.1.105',
      timestamp: '2024-01-19T18:30:00',
      nivel: 'warning'
    },
    {
      id: '5',
      usuario: 'Sistema',
      acao: 'Erro de conexão',
      modulo: 'Database',
      detalhes: 'Falha na conexão com banco de dados',
      ip: 'localhost',
      timestamp: '2024-01-19T10:15:00',
      nivel: 'error'
    }
  ]

  // Estatísticas do dashboard
  const stats = {
    total_usuarios: usuariosMock.length,
    usuarios_ativos: usuariosMock.filter(u => u.status === 'ativo').length,
    usuarios_bloqueados: usuariosMock.filter(u => u.status === 'bloqueado').length,
    logins_hoje: 8,
    backup_ultimo: '2024-01-20T02:00:00',
    espaco_disco: 75,
    memoria_uso: 68,
    uptime_sistema: '15 dias, 8 horas'
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
          {viewMode === 'sistema' && <SistemaView />}
        </div>
      </div>
    </div>
  )
}
