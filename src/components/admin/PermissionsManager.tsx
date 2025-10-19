import React, { useState } from 'react';
import { 
  Shield, 
  Eye, 
  Edit, 
  Trash2, 
  Plus, 
  Check,
  ShoppingCart,
  Package,
  Users,
  Wallet,
  Wrench,
  BarChart3,
  Settings,
  Database,
  Crown,
  UserCheck,
  DollarSign,
  ChevronDown,
  ChevronUp,
  Copy
} from 'lucide-react';
import type { FuncionarioPermissoes } from '../../types/empresa';

interface PermissionsManagerProps {
  permissoes: FuncionarioPermissoes;
  onChange: (permissoes: FuncionarioPermissoes) => void;
  isAdmin?: boolean;
}

// Templates de permissões predefinidos
const TEMPLATES = {
  admin: {
    nome: 'Administrador',
    icon: Crown,
    color: 'red',
    descricao: 'Acesso total ao sistema',
    permissoes: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: true,
      funcionarios: true,
      relatorios: true,
      configuracoes: true,
      backup: true,
      pode_criar_vendas: true,
      pode_editar_vendas: true,
      pode_cancelar_vendas: true,
      pode_aplicar_desconto: true,
      pode_criar_produtos: true,
      pode_editar_produtos: true,
      pode_deletar_produtos: true,
      pode_gerenciar_estoque: true,
      pode_criar_clientes: true,
      pode_editar_clientes: true,
      pode_deletar_clientes: true,
      pode_abrir_caixa: true,
      pode_fechar_caixa: true,
      pode_gerenciar_movimentacoes: true,
      pode_criar_os: true,
      pode_editar_os: true,
      pode_finalizar_os: true,
      pode_ver_todos_relatorios: true,
      pode_exportar_dados: true,
      pode_alterar_configuracoes: true,
      pode_gerenciar_funcionarios: true,
      pode_fazer_backup: true,
    }
  },
  gerente: {
    nome: 'Gerente',
    icon: Shield,
    color: 'purple',
    descricao: 'Gerencia vendas, estoque e relatórios',
    permissoes: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: true,
      funcionarios: false,
      relatorios: true,
      configuracoes: false,
      backup: false,
      pode_criar_vendas: true,
      pode_editar_vendas: true,
      pode_cancelar_vendas: true,
      pode_aplicar_desconto: true,
      pode_criar_produtos: true,
      pode_editar_produtos: true,
      pode_deletar_produtos: false,
      pode_gerenciar_estoque: true,
      pode_criar_clientes: true,
      pode_editar_clientes: true,
      pode_deletar_clientes: false,
      pode_abrir_caixa: true,
      pode_fechar_caixa: true,
      pode_gerenciar_movimentacoes: true,
      pode_criar_os: true,
      pode_editar_os: true,
      pode_finalizar_os: true,
      pode_ver_todos_relatorios: true,
      pode_exportar_dados: true,
      pode_alterar_configuracoes: false,
      pode_gerenciar_funcionarios: false,
      pode_fazer_backup: false,
    }
  },
  vendedor: {
    nome: 'Vendedor',
    icon: ShoppingCart,
    color: 'blue',
    descricao: 'Realiza vendas e atende clientes',
    permissoes: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: false,
      funcionarios: false,
      relatorios: false,
      configuracoes: false,
      backup: false,
      pode_criar_vendas: true,
      pode_editar_vendas: false,
      pode_cancelar_vendas: false,
      pode_aplicar_desconto: false,
      pode_criar_produtos: false,
      pode_editar_produtos: false,
      pode_deletar_produtos: false,
      pode_gerenciar_estoque: false,
      pode_criar_clientes: true,
      pode_editar_clientes: true,
      pode_deletar_clientes: false,
      pode_abrir_caixa: false,
      pode_fechar_caixa: false,
      pode_gerenciar_movimentacoes: false,
      pode_criar_os: false,
      pode_editar_os: false,
      pode_finalizar_os: false,
      pode_ver_todos_relatorios: false,
      pode_exportar_dados: false,
      pode_alterar_configuracoes: false,
      pode_gerenciar_funcionarios: false,
      pode_fazer_backup: false,
    }
  },
  tecnico: {
    nome: 'Técnico',
    icon: Wrench,
    color: 'green',
    descricao: 'Gerencia ordens de serviço',
    permissoes: {
      vendas: false,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: true,
      funcionarios: false,
      relatorios: false,
      configuracoes: false,
      backup: false,
      pode_criar_vendas: false,
      pode_editar_vendas: false,
      pode_cancelar_vendas: false,
      pode_aplicar_desconto: false,
      pode_criar_produtos: false,
      pode_editar_produtos: false,
      pode_deletar_produtos: false,
      pode_gerenciar_estoque: false,
      pode_criar_clientes: true,
      pode_editar_clientes: true,
      pode_deletar_clientes: false,
      pode_abrir_caixa: false,
      pode_fechar_caixa: false,
      pode_gerenciar_movimentacoes: false,
      pode_criar_os: true,
      pode_editar_os: true,
      pode_finalizar_os: true,
      pode_ver_todos_relatorios: false,
      pode_exportar_dados: false,
      pode_alterar_configuracoes: false,
      pode_gerenciar_funcionarios: false,
      pode_fazer_backup: false,
    }
  },
  caixa: {
    nome: 'Operador de Caixa',
    icon: Wallet,
    color: 'yellow',
    descricao: 'Opera caixa e realiza vendas',
    permissoes: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: false,
      funcionarios: false,
      relatorios: false,
      configuracoes: false,
      backup: false,
      pode_criar_vendas: true,
      pode_editar_vendas: false,
      pode_cancelar_vendas: false,
      pode_aplicar_desconto: false,
      pode_criar_produtos: false,
      pode_editar_produtos: false,
      pode_deletar_produtos: false,
      pode_gerenciar_estoque: false,
      pode_criar_clientes: true,
      pode_editar_clientes: false,
      pode_deletar_clientes: false,
      pode_abrir_caixa: true,
      pode_fechar_caixa: true,
      pode_gerenciar_movimentacoes: false,
      pode_criar_os: false,
      pode_editar_os: false,
      pode_finalizar_os: false,
      pode_ver_todos_relatorios: false,
      pode_exportar_dados: false,
      pode_alterar_configuracoes: false,
      pode_gerenciar_funcionarios: false,
      pode_fazer_backup: false,
    }
  }
};

// Estrutura de categorias de permissões
const PERMISSION_CATEGORIES = [
  {
    id: 'vendas',
    nome: 'Vendas',
    icon: ShoppingCart,
    color: 'blue',
    modulo: 'vendas',
    permissoes: [
      { key: 'pode_criar_vendas', label: 'Criar vendas', icon: Plus },
      { key: 'pode_editar_vendas', label: 'Editar vendas', icon: Edit },
      { key: 'pode_cancelar_vendas', label: 'Cancelar vendas', icon: Trash2 },
      { key: 'pode_aplicar_desconto', label: 'Aplicar descontos', icon: DollarSign },
    ]
  },
  {
    id: 'produtos',
    nome: 'Produtos',
    icon: Package,
    color: 'green',
    modulo: 'produtos',
    permissoes: [
      { key: 'pode_criar_produtos', label: 'Criar produtos', icon: Plus },
      { key: 'pode_editar_produtos', label: 'Editar produtos', icon: Edit },
      { key: 'pode_deletar_produtos', label: 'Deletar produtos', icon: Trash2 },
      { key: 'pode_gerenciar_estoque', label: 'Gerenciar estoque', icon: Package },
    ]
  },
  {
    id: 'clientes',
    nome: 'Clientes',
    icon: Users,
    color: 'purple',
    modulo: 'clientes',
    permissoes: [
      { key: 'pode_criar_clientes', label: 'Criar clientes', icon: Plus },
      { key: 'pode_editar_clientes', label: 'Editar clientes', icon: Edit },
      { key: 'pode_deletar_clientes', label: 'Deletar clientes', icon: Trash2 },
    ]
  },
  {
    id: 'caixa',
    nome: 'Caixa',
    icon: Wallet,
    color: 'yellow',
    modulo: 'caixa',
    permissoes: [
      { key: 'pode_abrir_caixa', label: 'Abrir caixa', icon: Plus },
      { key: 'pode_fechar_caixa', label: 'Fechar caixa', icon: Check },
      { key: 'pode_gerenciar_movimentacoes', label: 'Gerenciar movimentações', icon: DollarSign },
    ]
  },
  {
    id: 'ordens_servico',
    nome: 'Ordens de Serviço',
    icon: Wrench,
    color: 'orange',
    modulo: 'ordens_servico',
    permissoes: [
      { key: 'pode_criar_os', label: 'Criar OS', icon: Plus },
      { key: 'pode_editar_os', label: 'Editar OS', icon: Edit },
      { key: 'pode_finalizar_os', label: 'Finalizar OS', icon: Check },
    ]
  },
  {
    id: 'relatorios',
    nome: 'Relatórios',
    icon: BarChart3,
    color: 'indigo',
    modulo: 'relatorios',
    permissoes: [
      { key: 'pode_ver_todos_relatorios', label: 'Ver todos relatórios', icon: Eye },
      { key: 'pode_exportar_dados', label: 'Exportar dados', icon: Database },
    ]
  },
  {
    id: 'administracao',
    nome: 'Administração',
    icon: Shield,
    color: 'red',
    modulo: null,
    permissoes: [
      { key: 'funcionarios', label: 'Acessar funcionários', icon: Users },
      { key: 'pode_gerenciar_funcionarios', label: 'Gerenciar funcionários', icon: UserCheck },
      { key: 'configuracoes', label: 'Acessar configurações', icon: Settings },
      { key: 'pode_alterar_configuracoes', label: 'Alterar configurações', icon: Edit },
      { key: 'backup', label: 'Acessar backup', icon: Database },
      { key: 'pode_fazer_backup', label: 'Fazer backup', icon: Database },
    ]
  }
];

const PermissionsManager: React.FC<PermissionsManagerProps> = ({ 
  permissoes, 
  onChange,
  isAdmin = true
}) => {
  const [expandedCategories, setExpandedCategories] = useState<string[]>(['vendas', 'produtos']);
  const [showTemplates, setShowTemplates] = useState(false);

  const toggleCategory = (categoryId: string) => {
    setExpandedCategories(prev =>
      prev.includes(categoryId)
        ? prev.filter(id => id !== categoryId)
        : [...prev, categoryId]
    );
  };

  const updatePermissao = (key: keyof FuncionarioPermissoes, value: boolean) => {
    onChange({ ...permissoes, [key]: value });
  };

  const toggleModulo = (moduloKey: keyof FuncionarioPermissoes) => {
    const novoValor = !permissoes[moduloKey];
    onChange({ ...permissoes, [moduloKey]: novoValor });
  };

  const applyTemplate = (templateKey: keyof typeof TEMPLATES) => {
    const template = TEMPLATES[templateKey];
    onChange(template.permissoes as FuncionarioPermissoes);
    setShowTemplates(false);
  };

  const getColorClasses = (color: string) => {
    const colors: Record<string, { bg: string; text: string; hover: string; border: string }> = {
      blue: { bg: 'bg-blue-50', text: 'text-blue-700', hover: 'hover:bg-blue-100', border: 'border-blue-200' },
      green: { bg: 'bg-green-50', text: 'text-green-700', hover: 'hover:bg-green-100', border: 'border-green-200' },
      purple: { bg: 'bg-purple-50', text: 'text-purple-700', hover: 'hover:bg-purple-100', border: 'border-purple-200' },
      yellow: { bg: 'bg-yellow-50', text: 'text-yellow-700', hover: 'hover:bg-yellow-100', border: 'border-yellow-200' },
      orange: { bg: 'bg-orange-50', text: 'text-orange-700', hover: 'hover:bg-orange-100', border: 'border-orange-200' },
      indigo: { bg: 'bg-indigo-50', text: 'text-indigo-700', hover: 'hover:bg-indigo-100', border: 'border-indigo-200' },
      red: { bg: 'bg-red-50', text: 'text-red-700', hover: 'hover:bg-red-100', border: 'border-red-200' },
    };
    return colors[color] || colors.blue;
  };

  return (
    <div className="space-y-6">
      {/* Templates de Permissões */}
      <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl p-6 border border-blue-100">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Copy className="w-5 h-5 text-blue-600" />
            <h3 className="text-lg font-semibold text-gray-900">Templates Rápidos</h3>
          </div>
          <button
            onClick={() => setShowTemplates(!showTemplates)}
            className="text-sm text-blue-600 hover:text-blue-700 font-medium"
          >
            {showTemplates ? 'Ocultar' : 'Ver templates'}
          </button>
        </div>

        {showTemplates && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {Object.entries(TEMPLATES).map(([key, template]) => {
              const Icon = template.icon;
              const colors = getColorClasses(template.color);
              
              return (
                <button
                  key={key}
                  onClick={() => applyTemplate(key as keyof typeof TEMPLATES)}
                  className={`${colors.bg} ${colors.border} border-2 rounded-lg p-4 text-left ${colors.hover} transition-all hover:shadow-md`}
                >
                  <div className="flex items-center gap-3 mb-2">
                    <div className={`p-2 ${colors.bg} rounded-lg`}>
                      <Icon className={`w-5 h-5 ${colors.text}`} />
                    </div>
                    <div>
                      <h4 className={`font-semibold ${colors.text}`}>{template.nome}</h4>
                    </div>
                  </div>
                  <p className="text-xs text-gray-600">{template.descricao}</p>
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Categorias de Permissões */}
      <div className="space-y-4">
        {PERMISSION_CATEGORIES.map(category => {
          const Icon = category.icon;
          const colors = getColorClasses(category.color);
          const isExpanded = expandedCategories.includes(category.id);
          const moduloAtivo = category.modulo ? permissoes[category.modulo as keyof FuncionarioPermissoes] : true;

          return (
            <div key={category.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden">
              {/* Header da Categoria */}
              <div className={`${colors.bg} border-b ${colors.border} p-4`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`p-2 bg-white rounded-lg shadow-sm`}>
                      <Icon className={`w-5 h-5 ${colors.text}`} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{category.nome}</h3>
                      <p className="text-xs text-gray-500">
                        {category.permissoes.filter(p => permissoes[p.key as keyof FuncionarioPermissoes]).length} de {category.permissoes.length} ativas
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    {/* Toggle do Módulo */}
                    {category.modulo && (
                      <label className="flex items-center gap-2 cursor-pointer">
                        <span className="text-sm font-medium text-gray-700">Acessar</span>
                        <div className="relative">
                          <input
                            type="checkbox"
                            checked={moduloAtivo as boolean}
                            onChange={() => toggleModulo(category.modulo as keyof FuncionarioPermissoes)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </div>
                      </label>
                    )}

                    {/* Botão Expandir/Recolher */}
                    <button
                      onClick={() => toggleCategory(category.id)}
                      className={`p-2 rounded-lg ${colors.hover} transition-colors`}
                    >
                      {isExpanded ? (
                        <ChevronUp className={`w-5 h-5 ${colors.text}`} />
                      ) : (
                        <ChevronDown className={`w-5 h-5 ${colors.text}`} />
                      )}
                    </button>
                  </div>
                </div>
              </div>

              {/* Permissões Específicas */}
              {isExpanded && (
                <div className="p-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {category.permissoes.map(perm => {
                      const PermIcon = perm.icon;
                      const isAtivo = permissoes[perm.key as keyof FuncionarioPermissoes];

                      return (
                        <label
                          key={perm.key}
                          className={`flex items-center justify-between p-3 rounded-lg border-2 cursor-pointer transition-all ${
                            isAtivo
                              ? `${colors.bg} ${colors.border}`
                              : 'bg-gray-50 border-gray-200 hover:bg-gray-100'
                          }`}
                        >
                          <div className="flex items-center gap-3">
                            <PermIcon className={`w-4 h-4 ${isAtivo ? colors.text : 'text-gray-400'}`} />
                            <span className={`text-sm font-medium ${isAtivo ? 'text-gray-900' : 'text-gray-600'}`}>
                              {perm.label}
                            </span>
                          </div>
                          <div className="relative">
                            <input
                              type="checkbox"
                              checked={isAtivo as boolean}
                              onChange={(e) => updatePermissao(perm.key as keyof FuncionarioPermissoes, e.target.checked)}
                              disabled={!isAdmin}
                              className="sr-only peer"
                            />
                            <div className="w-11 h-6 bg-gray-200 peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                          </div>
                        </label>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Resumo de Permissões */}
      <div className="bg-gray-50 rounded-xl p-6 border border-gray-200">
        <h4 className="font-semibold text-gray-900 mb-3">Resumo de Acesso</h4>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {PERMISSION_CATEGORIES.map(cat => {
            const Icon = cat.icon;
            const colors = getColorClasses(cat.color);
            const moduloAtivo = cat.modulo ? permissoes[cat.modulo as keyof FuncionarioPermissoes] : true;
            const permissoesAtivas = cat.permissoes.filter(p => permissoes[p.key as keyof FuncionarioPermissoes]).length;

            return (
              <div key={cat.id} className={`${colors.bg} rounded-lg p-3 border ${colors.border}`}>
                <div className="flex items-center gap-2 mb-2">
                  <Icon className={`w-4 h-4 ${colors.text}`} />
                  <span className="text-xs font-medium text-gray-700">{cat.nome}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-lg font-bold text-gray-900">{permissoesAtivas}</span>
                  <span className="text-xs text-gray-500">/ {cat.permissoes.length}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default PermissionsManager;
