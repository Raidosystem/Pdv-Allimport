import React, { useState, useEffect } from 'react';
import { 
  Users, 
  ShieldCheck, 
  Database, 
  Settings, 
  Activity,
  Crown,
  TrendingUp,
  Calendar,
  Zap
} from 'lucide-react';
import { usePermissions } from '../../hooks/usePermissions';
import { supabase } from '../../lib/supabase';
import AccessFixer from '../../components/AccessFixer';
import type { AdminDashboardStats, LogAuditoria } from '../../types/admin';

const AdminDashboard: React.FC = () => {
  const { can, isAdmin, user, loading: permissionsLoading } = usePermissions();
  const [stats, setStats] = useState<AdminDashboardStats | null>(null);
  const [recentLogs, setRecentLogs] = useState<LogAuditoria[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!permissionsLoading) {
      loadDashboardData();
    }
  }, [permissionsLoading]);

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Carregar estatísticas em paralelo
      const [empresaData, usuariosData, atividadeData] = await Promise.all([
        loadEmpresaStats(),
        loadUsuariosStats(),
        loadAtividadeStats()
      ]);

      const dashboardStats: AdminDashboardStats = {
        empresa: empresaData,
        usuarios: usuariosData,
        atividade: atividadeData,
        sistema: {
          versao: '2.2.5',
          atualizacao_disponivel: false,
          uptime: Math.floor(Math.random() * 30) + 1 // Mock
        }
      };

      setStats(dashboardStats);

      // Carregar logs recentes
      if (can('administracao.logs', 'read')) {
        await loadRecentLogs();
      }

    } catch (error) {
      console.error('Erro ao carregar dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadEmpresaStats = async () => {
    try {
      // Buscar empresa do usuário atual
      const { data: { user: currentUser } } = await supabase.auth.getUser();
      
      if (!currentUser) {
        console.error('Usuário não autenticado');
        throw new Error('Usuário não autenticado');
      }

      // Buscar funcionário para pegar empresa_id
      const { data: funcionario, error: funcError } = await supabase
        .from('funcionarios')
        .select('empresa_id')
        .eq('user_id', currentUser.id)
        .single();

      if (funcError || !funcionario) {
        console.error('Erro ao buscar funcionário:', funcError);
        throw funcError || new Error('Funcionário não encontrado');
      }

      // Buscar dados da empresa
      const { data: empresa, error: empError } = await supabase
        .from('empresas')
        .select('nome, plano, status, assinatura_expires_at')
        .eq('id', funcionario.empresa_id)
        .single();

      if (empError) {
        console.error('Erro ao buscar empresa:', empError);
        throw empError;
      }

      let dias_restantes: number | undefined;
      if (empresa?.assinatura_expires_at) {
        const expiration = new Date(empresa.assinatura_expires_at);
        const now = new Date();
        dias_restantes = Math.ceil((expiration.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
      }

      return {
        nome: empresa?.nome || 'Empresa',
        plano: empresa?.plano || 'teste',
        status: empresa?.status || 'ativo',
        dias_restantes
      };
    } catch (error) {
      console.error('Erro em loadEmpresaStats:', error);
      // Retornar valores padrão em caso de erro
      return {
        nome: 'Empresa',
        plano: 'teste',
        status: 'ativo',
        dias_restantes: undefined
      };
    }
  };

  const loadUsuariosStats = async () => {
    const { data: funcionarios } = await supabase
      .from('funcionarios')
      .select('id, status, convite_token, last_login_at');

    const total = funcionarios?.length || 0;
    const ativos = funcionarios?.filter(f => f.status === 'ativo').length || 0;
    const convites_pendentes = funcionarios?.filter(f => f.convite_token && f.status === 'pendente').length || 0;

    // Sessões ativas (mock por enquanto)
    const sessoes_ativas = Math.floor(Math.random() * ativos) + 1;

    return {
      total,
      ativos,
      convites_pendentes,
      sessoes_ativas
    };
  };

  const loadAtividadeStats = async () => {
    const hoje = new Date().toISOString().split('T')[0];
    
    const { data: logs } = await supabase
      .from('audit_logs')
      .select('id, acao, created_at')
      .gte('created_at', hoje);

    const logins_hoje = logs?.filter(log => log.acao === 'login').length || 0;
    const acoes_hoje = logs?.length || 0;

    // Mock para backup e próxima cobrança
    const ultimo_backup = new Date(Date.now() - Math.random() * 86400000).toISOString();
    const proxima_cobranca = new Date(Date.now() + 30 * 86400000).toISOString();

    return {
      logins_hoje,
      acoes_hoje,
      ultimo_backup,
      proxima_cobranca
    };
  };

  const loadRecentLogs = async () => {
    const { data: logs } = await supabase
      .from('audit_logs')
      .select(`
        id,
        empresa_id,
        funcionario_id,
        recurso,
        acao,
        entidade_tipo,
        entidade_id,
        sucesso,
        created_at,
        funcionarios (nome)
      `)
      .order('created_at', { ascending: false })
      .limit(10);

    const formattedLogs: LogAuditoria[] = logs?.map(log => ({
      id: log.id,
      empresa_id: log.empresa_id,
      funcionario_id: log.funcionario_id,
      recurso: log.recurso,
      acao: log.acao,
      entidade_tipo: log.entidade_tipo,
      entidade_id: log.entidade_id,
      sucesso: log.sucesso,
      created_at: log.created_at,
      funcionario_nome: (log.funcionarios as any)?.nome || 'Sistema',
      icon: getActionIcon(log.acao),
      color: getActionColor(log.acao),
      description: getActionDescription(log.recurso, log.acao, log.entidade_tipo)
    })) || [];

    setRecentLogs(formattedLogs);
  };

  const getActionIcon = (acao: string): string => {
    switch (acao) {
      case 'create': return '➕';
      case 'update': return '✏️';
      case 'delete': return '🗑️';
      case 'login': return '🔑';
      case 'export': return '📤';
      default: return '📝';
    }
  };

  const getActionColor = (acao: string): string => {
    switch (acao) {
      case 'create': return 'text-green-600';
      case 'update': return 'text-blue-600';
      case 'delete': return 'text-red-600';
      case 'login': return 'text-purple-600';
      case 'export': return 'text-orange-600';
      default: return 'text-gray-600';
    }
  };

  const getActionDescription = (recurso: string, acao: string, entidade?: string): string => {
    const recursoMap: Record<string, string> = {
      'vendas': 'venda',
      'clientes': 'cliente',
      'produtos': 'produto',
      'ordens_servico': 'ordem de serviço',
      'administracao.usuarios': 'usuário',
      'administracao.funcoes': 'função'
    };

    const acaoMap: Record<string, string> = {
      'create': 'criou',
      'update': 'editou',
      'delete': 'excluiu',
      'login': 'fez login',
      'export': 'exportou'
    };

    const recursoNome = recursoMap[recurso] || recurso;
    const acaoNome = acaoMap[acao] || acao;

    if (acao === 'login') {
      return 'fez login no sistema';
    }

    return `${acaoNome} ${recursoNome}${entidade ? ` (${entidade})` : ''}`;
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ativo': return 'text-green-600 bg-green-100';
      case 'suspenso': return 'text-yellow-600 bg-yellow-100';
      case 'cancelado': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPlanoNome = (plano: string): string => {
    // Mapeamento de planos para nomes amigáveis
    const planoMap: Record<string, string> = {
      'teste': 'Teste',
      'basic': 'Básico',
      'premium': 'Premium',
      'enterprise': 'Empresarial'
    };
    
    return planoMap[plano.toLowerCase()] || plano.charAt(0).toUpperCase() + plano.slice(1);
  };

  if (permissionsLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Carregando...</p>
        </div>
      </div>
    );
  }

  // REGRA: Todo usuário logado é admin da sua própria empresa (comprador do PDV)
  // Não precisa verificar isAdmin - se está autenticado, tem acesso
  if (!isAdmin && !user) {
    return (
      <div className="p-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Área Administrativa</h1>
          <p className="text-gray-600">
            Esta área é restrita para administradores da empresa.
          </p>
        </div>
        <AccessFixer onFixed={() => window.location.reload()} />
      </div>
    );
  }

  if (loading || !stats) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-xl"></div>
            ))}
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="h-96 bg-gray-200 rounded-xl"></div>
            <div className="h-96 bg-gray-200 rounded-xl"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard Administrativo</h1>
        <p className="text-gray-600">Visão geral do sistema e empresa</p>
      </div>

      {/* Cards de Status */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Status da Empresa */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Empresa</p>
              <p className="text-2xl font-bold text-gray-900">{stats.empresa.nome}</p>
            </div>
            <Crown className="w-8 h-8 text-yellow-500" />
          </div>
          <div className="mt-4 flex items-center justify-between">
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(stats.empresa.status)}`}>
              {stats.empresa.status.charAt(0).toUpperCase() + stats.empresa.status.slice(1)}
            </span>
            <span className="text-sm text-gray-500">
              Plano {getPlanoNome(stats.empresa.plano)}
            </span>
          </div>
          {stats.empresa.dias_restantes && (
            <div className="mt-2 text-xs text-gray-500">
              {stats.empresa.dias_restantes > 0 
                ? `${stats.empresa.dias_restantes} dias restantes`
                : 'Assinatura vencida'
              }
            </div>
          )}
        </div>

        {/* Usuários */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Usuários</p>
              <p className="text-2xl font-bold text-gray-900">{stats.usuarios.ativos}</p>
            </div>
            <Users className="w-8 h-8 text-blue-500" />
          </div>
          <div className="mt-4 text-sm text-gray-500">
            <div className="flex justify-between">
              <span>Total: {stats.usuarios.total}</span>
              <span>Ativos: {stats.usuarios.ativos}</span>
            </div>
            <div className="flex justify-between mt-1">
              <span>Convites: {stats.usuarios.convites_pendentes}</span>
              <span>Online: {stats.usuarios.sessoes_ativas}</span>
            </div>
          </div>
        </div>

        {/* Atividade */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Atividade Hoje</p>
              <p className="text-2xl font-bold text-gray-900">{stats.atividade.acoes_hoje}</p>
            </div>
            <Activity className="w-8 h-8 text-green-500" />
          </div>
          <div className="mt-4 text-sm text-gray-500">
            <div className="flex justify-between">
              <span>Logins: {stats.atividade.logins_hoje}</span>
              <span>Ações: {stats.atividade.acoes_hoje}</span>
            </div>
            <div className="mt-1 text-xs">
              Último backup: {new Date(stats.atividade.ultimo_backup!).toLocaleDateString('pt-BR')}
            </div>
          </div>
        </div>

        {/* Sistema */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Sistema</p>
              <p className="text-2xl font-bold text-gray-900">v{stats.sistema.versao}</p>
            </div>
            <Zap className="w-8 h-8 text-purple-500" />
          </div>
          <div className="mt-4 text-sm text-gray-500">
            <div className="flex justify-between">
              <span>Uptime: {stats.sistema.uptime}d</span>
              <span className={`${stats.sistema.atualizacao_disponivel ? 'text-orange-600' : 'text-green-600'}`}>
                {stats.sistema.atualizacao_disponivel ? 'Atualização disponível' : 'Atualizado'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Seção Principal */}
      <div className="grid grid-cols-1 gap-6">
        {/* Log de Auditoria Recente */}
        {can('administracao.logs', 'read') && (
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Atividade Recente</h3>
              <button 
                onClick={loadRecentLogs}
                className="text-blue-600 hover:text-blue-700 text-sm font-medium"
              >
                Atualizar
              </button>
            </div>
            <div className="space-y-3 max-h-80 overflow-y-auto">
              {recentLogs.length > 0 ? (
                recentLogs.map((log) => (
                  <div key={log.id} className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                    <span className="text-lg">{log.icon}</span>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">
                        {log.funcionario_nome} {log.description}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        {new Date(log.created_at).toLocaleString('pt-BR')}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">Nenhuma atividade recente</p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Actions Panel */}
      <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xl font-bold mb-2">Ações Rápidas</h3>
            <p className="text-blue-100">
              Acesse rapidamente as principais funcionalidades administrativas
            </p>
          </div>
          <TrendingUp className="w-12 h-12 text-blue-200" />
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
          {can('administracao.usuarios', 'read') && (
            <button className="flex items-center gap-2 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors">
              <Users className="w-5 h-5" />
              <span className="text-sm font-medium">Usuários</span>
            </button>
          )}
          
          {can('administracao.funcoes', 'read') && (
            <button className="flex items-center gap-2 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors">
              <ShieldCheck className="w-5 h-5" />
              <span className="text-sm font-medium">Permissões</span>
            </button>
          )}
          
          {can('administracao.backups', 'read') && (
            <button className="flex items-center gap-2 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors">
              <Database className="w-5 h-5" />
              <span className="text-sm font-medium">Backups</span>
            </button>
          )}
          
          {can('administracao.sistema', 'read') && (
            <button className="flex items-center gap-2 p-3 bg-white/10 rounded-lg hover:bg-white/20 transition-colors">
              <Settings className="w-5 h-5" />
              <span className="text-sm font-medium">Sistema</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;