-- ========================================
-- SISTEMA DE ADMINISTRAÇÃO MULTI-TENANT
-- Sistema PDV Allimport - Estrutura Completa
-- ========================================

-- 1. TABELA DE EMPRESAS (TENANTS)
-- ========================================

create table if not exists public.empresas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cnpj text,
  email text,
  telefone text,
  endereco text,
  logo_url text,
  plano text not null default 'basic',
  status text not null default 'ativo', -- ativo|suspenso|cancelado
  max_usuarios integer not null default 5,
  max_lojas integer not null default 1,
  features jsonb default '{}',
  assinatura_id text, -- ID do Mercado Pago ou outro gateway
  assinatura_expires_at timestamptz,
  tema jsonb default '{"primaryColor": "#3B82F6", "mode": "light"}',
  configuracoes jsonb default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. FUNCIONÁRIOS (USUÁRIOS DO SISTEMA)
-- ========================================

create table if not exists public.funcionarios (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  email text not null,
  telefone text,
  documento text,
  cargo text,
  status text not null default 'ativo', -- ativo|bloqueado|pendente
  lojas text[] default '{}'::text[], -- IDs/códigos de lojas se multi-loja
  limite_desconto_pct numeric(5,2) default 0,
  limite_cancelamentos_dia integer default 0,
  permite_estorno boolean default false,
  two_factor_enabled boolean default false,
  last_login_at timestamptz,
  session_expires_at timestamptz,
  convite_token text,
  convite_expires_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (empresa_id, email),
  unique (convite_token)
);

-- 3. FUNÇÕES/ROLES (DEFINIDAS POR EMPRESA)
-- ========================================

create table if not exists public.funcoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  descricao text,
  is_system boolean default false, -- impede edição/exclusão
  escopo_lojas text[] default '{}'::text[], -- vazio = todas as lojas
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (empresa_id, nome)
);

-- 4. PERMISSÕES (CATÁLOGO GLOBAL)
-- ========================================

create table if not exists public.permissoes (
  id uuid primary key default gen_random_uuid(),
  recurso text not null, -- ex: 'vendas', 'relatorios.overview'
  acao text not null,    -- ex: 'read', 'create', 'update', 'delete', 'export'
  descricao text,
  categoria text not null default 'geral',
  created_at timestamptz default now(),
  unique (recurso, acao)
);

-- 5. RELAÇÃO FUNÇÃO X PERMISSÃO
-- ========================================

create table if not exists public.funcao_permissoes (
  funcao_id uuid not null references public.funcoes(id) on delete cascade,
  permissao_id uuid not null references public.permissoes(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (funcao_id, permissao_id)
);

-- 6. RELAÇÃO FUNCIONÁRIO X FUNÇÃO
-- ========================================

create table if not exists public.funcionario_funcoes (
  funcionario_id uuid not null references public.funcionarios(id) on delete cascade,
  funcao_id uuid not null references public.funcoes(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (funcionario_id, funcao_id)
);

-- 7. LOG DE AUDITORIA
-- ========================================

create table if not exists public.audit_logs (
  id bigserial primary key,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  funcionario_id uuid references public.funcionarios(id) on delete set null,
  recurso text not null,
  acao text not null,
  entidade_tipo text, -- ex: 'venda', 'cliente', 'produto'
  entidade_id text,   -- ID da entidade afetada
  dados_anteriores jsonb,
  dados_novos jsonb,
  ip_address text,
  user_agent text,
  sucesso boolean default true,
  erro_message text,
  created_at timestamptz default now()
);

-- 8. SESSÕES ATIVAS
-- ========================================

create table if not exists public.user_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  funcionario_id uuid references public.funcionarios(id) on delete cascade,
  jwt_jti text,
  ip_address text,
  user_agent text,
  is_active boolean default true,
  last_activity_at timestamptz default now(),
  expires_at timestamptz,
  created_at timestamptz default now()
);

-- ========================================
-- INSERIR PERMISSÕES PADRÃO
-- ========================================

insert into public.permissoes (recurso, acao, descricao, categoria) values 
-- Vendas
('vendas', 'read', 'Visualizar vendas', 'vendas'),
('vendas', 'create', 'Criar vendas', 'vendas'),
('vendas', 'update', 'Editar vendas', 'vendas'),
('vendas', 'delete', 'Excluir vendas', 'vendas'),
('vendas', 'cancel', 'Cancelar vendas', 'vendas'),
('vendas', 'refund', 'Estornar vendas', 'vendas'),
('vendas', 'discount', 'Aplicar descontos', 'vendas'),

-- Caixa
('caixa', 'read', 'Visualizar caixa', 'caixa'),
('caixa', 'open', 'Abrir caixa', 'caixa'),
('caixa', 'close', 'Fechar caixa', 'caixa'),
('caixa', 'supply', 'Fazer suprimento', 'caixa'),
('caixa', 'withdraw', 'Fazer sangria', 'caixa'),
('caixa', 'manage', 'Gerenciar caixa', 'caixa'),

-- Clientes
('clientes', 'read', 'Visualizar clientes', 'clientes'),
('clientes', 'create', 'Criar clientes', 'clientes'),
('clientes', 'update', 'Editar clientes', 'clientes'),
('clientes', 'delete', 'Excluir clientes', 'clientes'),
('clientes', 'export', 'Exportar clientes', 'clientes'),

-- Produtos
('produtos', 'read', 'Visualizar produtos', 'produtos'),
('produtos', 'create', 'Criar produtos', 'produtos'),
('produtos', 'update', 'Editar produtos', 'produtos'),
('produtos', 'delete', 'Excluir produtos', 'produtos'),
('produtos', 'manage_stock', 'Gerenciar estoque', 'produtos'),
('produtos', 'adjust_price', 'Ajustar preços', 'produtos'),
('produtos', 'export', 'Exportar produtos', 'produtos'),

-- Ordens de Serviço
('ordens_servico', 'read', 'Visualizar OS', 'ordens_servico'),
('ordens_servico', 'create', 'Criar OS', 'ordens_servico'),
('ordens_servico', 'update', 'Editar OS', 'ordens_servico'),
('ordens_servico', 'delete', 'Excluir OS', 'ordens_servico'),
('ordens_servico', 'approve', 'Aprovar OS', 'ordens_servico'),
('ordens_servico', 'complete', 'Finalizar OS', 'ordens_servico'),
('ordens_servico', 'export', 'Exportar OS', 'ordens_servico'),

-- Relatórios
('relatorios.overview', 'read', 'Ver relatórios gerais', 'relatorios'),
('relatorios.detalhado', 'read', 'Ver relatórios detalhados', 'relatorios'),
('relatorios.ranking', 'read', 'Ver rankings', 'relatorios'),
('relatorios.graficos', 'read', 'Ver gráficos', 'relatorios'),
('relatorios.analytics', 'read', 'Ver analytics/IA', 'relatorios'),
('relatorios.exportacoes', 'read', 'Fazer exportações', 'relatorios'),
('relatorios', 'export', 'Exportar relatórios', 'relatorios'),

-- Administração
('administracao.usuarios', 'read', 'Ver usuários', 'administracao'),
('administracao.usuarios', 'create', 'Criar usuários', 'administracao'),
('administracao.usuarios', 'update', 'Editar usuários', 'administracao'),
('administracao.usuarios', 'delete', 'Excluir usuários', 'administracao'),
('administracao.usuarios', 'invite', 'Convidar usuários', 'administracao'),
('administracao.usuarios', 'impersonate', 'Impersonar usuários', 'administracao'),

('administracao.funcoes', 'read', 'Ver funções', 'administracao'),
('administracao.funcoes', 'create', 'Criar funções', 'administracao'),
('administracao.funcoes', 'update', 'Editar funções', 'administracao'),
('administracao.funcoes', 'delete', 'Excluir funções', 'administracao'),

('administracao.sistema', 'read', 'Ver configurações', 'administracao'),
('administracao.sistema', 'update', 'Editar configurações', 'administracao'),

('administracao.backups', 'read', 'Ver backups', 'administracao'),
('administracao.backups', 'create', 'Criar backups', 'administracao'),
('administracao.backups', 'restore', 'Restaurar backups', 'administracao'),

('administracao.logs', 'read', 'Ver logs de auditoria', 'administracao')

on conflict (recurso, acao) do nothing;

-- ========================================
-- FUNÇÕES DE APOIO
-- ========================================

-- Extrai empresa_id do JWT
create or replace function public.jwt_empresa_id()
returns uuid language plpgsql stable security definer as $$
declare 
  claims jsonb;
  empresa_uuid uuid;
begin
  claims := current_setting('request.jwt.claims', true)::jsonb;
  empresa_uuid := nullif(coalesce(claims->>'empresa_id',''), '')::uuid;
  return empresa_uuid;
exception when others then
  return null;
end $$;

-- Extrai user_id do JWT
create or replace function public.jwt_user_id()
returns uuid language plpgsql stable security definer as $$
declare 
  claims jsonb;
  user_uuid uuid;
begin
  claims := current_setting('request.jwt.claims', true)::jsonb;
  user_uuid := nullif(coalesce(claims->>'sub',''), '')::uuid;
  return user_uuid;
exception when others then
  return null;
end $$;

-- Verifica se o usuário atual tem uma permissão específica
create or replace function public.has_permission(p_recurso text, p_acao text)
returns boolean language sql stable security definer as $$
  with user_context as (
    select 
      public.jwt_user_id() as user_id,
      public.jwt_empresa_id() as empresa_id
  ),
  funcionario_info as (
    select f.id as funcionario_id, f.status, f.empresa_id
    from public.funcionarios f
    join user_context uc on uc.user_id = f.user_id
    where f.empresa_id = (select empresa_id from user_context)
      and f.status = 'ativo'
  ),
  user_roles as (
    select ff.funcao_id, func.empresa_id
    from public.funcionario_funcoes ff
    join funcionario_info fi on fi.funcionario_id = ff.funcionario_id
    join public.funcoes func on func.id = ff.funcao_id
    where func.empresa_id = (select empresa_id from user_context)
  )
  select exists (
    select 1
    from public.funcao_permissoes fp
    join public.permissoes p on p.id = fp.permissao_id
    join user_roles ur on ur.funcao_id = fp.funcao_id
    join public.funcoes f on f.id = fp.funcao_id
    where f.empresa_id = (select empresa_id from user_context)
      and p.recurso = p_recurso
      and p.acao = p_acao
  );
$$;

-- Verifica se o usuário é owner/admin da empresa
create or replace function public.is_admin()
returns boolean language sql stable security definer as $$
  select public.has_permission('administracao.usuarios', 'create');
$$;

-- Função para registrar log de auditoria
create or replace function public.log_audit(
  p_recurso text,
  p_acao text,
  p_entidade_tipo text default null,
  p_entidade_id text default null,
  p_dados_anteriores jsonb default null,
  p_dados_novos jsonb default null
) returns void language plpgsql security definer as $$
declare
  v_empresa_id uuid;
  v_user_id uuid;
  v_funcionario_id uuid;
begin
  v_empresa_id := public.jwt_empresa_id();
  v_user_id := public.jwt_user_id();
  
  -- Busca funcionario_id
  select f.id into v_funcionario_id
  from public.funcionarios f
  where f.user_id = v_user_id 
    and f.empresa_id = v_empresa_id;

  insert into public.audit_logs (
    empresa_id, user_id, funcionario_id, recurso, acao,
    entidade_tipo, entidade_id, dados_anteriores, dados_novos
  ) values (
    v_empresa_id, v_user_id, v_funcionario_id, p_recurso, p_acao,
    p_entidade_tipo, p_entidade_id, p_dados_anteriores, p_dados_novos
  );
end $$;

-- ========================================
-- TRIGGERS PARA UPDATED_AT
-- ========================================

create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger empresas_updated_at before update on public.empresas
  for each row execute function update_updated_at_column();

create trigger funcionarios_updated_at before update on public.funcionarios
  for each row execute function update_updated_at_column();

create trigger funcoes_updated_at before update on public.funcoes
  for each row execute function update_updated_at_column();

-- ========================================
-- ATIVAR RLS EM TODAS AS TABELAS
-- ========================================

alter table public.empresas enable row level security;
alter table public.funcionarios enable row level security;
alter table public.funcoes enable row level security;
alter table public.permissoes enable row level security;
alter table public.funcao_permissoes enable row level security;
alter table public.funcionario_funcoes enable row level security;
alter table public.audit_logs enable row level security;
alter table public.user_sessions enable row level security;

-- ========================================
-- POLÍTICAS RLS PARA ADMINISTRAÇÃO
-- ========================================

-- EMPRESAS: Só vê a própria empresa
create policy empresas_select on public.empresas
  for select using (id = public.jwt_empresa_id());

create policy empresas_update on public.empresas
  for update using (
    id = public.jwt_empresa_id() 
    and public.has_permission('administracao.sistema', 'update')
  );

-- FUNCIONÁRIOS: Só da própria empresa
create policy funcionarios_select on public.funcionarios
  for select using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'read')
  );

create policy funcionarios_insert on public.funcionarios
  for insert with check (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'create')
  );

create policy funcionarios_update on public.funcionarios
  for update using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'update')
  );

create policy funcionarios_delete on public.funcionarios
  for delete using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'delete')
  );

-- FUNÇÕES: Só da própria empresa
create policy funcoes_select on public.funcoes
  for select using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.funcoes', 'read')
  );

create policy funcoes_insert on public.funcoes
  for insert with check (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.funcoes', 'create')
  );

create policy funcoes_update on public.funcoes
  for update using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.funcoes', 'update')
    and not is_system  -- Não permite editar funções de sistema
  );

create policy funcoes_delete on public.funcoes
  for delete using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.funcoes', 'delete')
    and not is_system  -- Não permite excluir funções de sistema
  );

-- PERMISSÕES: Todos podem ler (para montar a matriz)
create policy permissoes_select on public.permissoes
  for select using (true);

-- FUNÇÃO_PERMISSÕES: Só da própria empresa
create policy funcao_permissoes_all on public.funcao_permissoes
  for all using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.funcoes', 'read')
  );

-- FUNCIONÁRIO_FUNÇÕES: Só da própria empresa
create policy funcionario_funcoes_all on public.funcionario_funcoes
  for all using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'read')
  );

-- AUDIT_LOGS: Só da própria empresa
create policy audit_logs_select on public.audit_logs
  for select using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.logs', 'read')
  );

create policy audit_logs_insert on public.audit_logs
  for insert with check (
    empresa_id = public.jwt_empresa_id()
  );

-- USER_SESSIONS: Só da própria empresa
create policy user_sessions_all on public.user_sessions
  for all using (
    empresa_id = public.jwt_empresa_id()
    and public.has_permission('administracao.usuarios', 'read')
  );

-- ========================================
-- EXEMPLO: ADAPTAR TABELAS EXISTENTES
-- ========================================

-- Adicione empresa_id às suas tabelas existentes:
-- alter table public.vendas add column empresa_id uuid references public.empresas(id);
-- alter table public.clientes add column empresa_id uuid references public.empresas(id);
-- alter table public.produtos add column empresa_id uuid references public.empresas(id);
-- alter table public.ordens_servico add column empresa_id uuid references public.empresas(id);

-- E aplique RLS:
-- create policy vendas_tenant on public.vendas for all using (empresa_id = public.jwt_empresa_id());
-- create policy clientes_tenant on public.clientes for all using (empresa_id = public.jwt_empresa_id());
-- create policy produtos_tenant on public.produtos for all using (empresa_id = public.jwt_empresa_id());
-- create policy ordens_servico_tenant on public.ordens_servico for all using (empresa_id = public.jwt_empresa_id());

-- ========================================
-- INSERIR FUNÇÕES PADRÃO (EXECUTAR APÓS CRIAR EMPRESA)
-- ========================================

-- Esta função será chamada quando uma nova empresa for criada
create or replace function public.create_default_roles(p_empresa_id uuid)
returns void language plpgsql security definer as $$
declare
  v_admin_role_id uuid;
  v_manager_role_id uuid;
  v_seller_role_id uuid;
  v_cashier_role_id uuid;
  v_tech_role_id uuid;
  v_financial_role_id uuid;
  v_readonly_role_id uuid;
begin
  -- Criar funções padrão
  insert into public.funcoes (empresa_id, nome, descricao, is_system) values
    (p_empresa_id, 'Administrador', 'Acesso total ao sistema', true),
    (p_empresa_id, 'Gerente', 'Acesso gerencial completo', true),
    (p_empresa_id, 'Vendedor', 'Acesso a vendas e clientes', true),
    (p_empresa_id, 'Caixa', 'Acesso ao caixa e vendas', true),
    (p_empresa_id, 'Técnico OS', 'Acesso a ordens de serviço', true),
    (p_empresa_id, 'Financeiro', 'Acesso a relatórios financeiros', true),
    (p_empresa_id, 'Somente Leitura', 'Apenas visualização', true)
  returning id into v_readonly_role_id;

  -- Buscar IDs das funções criadas
  select id into v_admin_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Administrador';
  select id into v_manager_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Gerente';
  select id into v_seller_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Vendedor';
  select id into v_cashier_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Caixa';
  select id into v_tech_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Técnico OS';
  select id into v_financial_role_id from public.funcoes 
    where empresa_id = p_empresa_id and nome = 'Financeiro';

  -- Atribuir TODAS as permissões ao Administrador
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_admin_role_id, p.id, p_empresa_id
  from public.permissoes p;

  -- Atribuir permissões ao Gerente (quase tudo, exceto algumas de admin)
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_manager_role_id, p.id, p_empresa_id
  from public.permissoes p
  where p.recurso not in ('administracao.usuarios', 'administracao.funcoes', 'administracao.sistema')
     or (p.recurso in ('administracao.usuarios', 'administracao.funcoes') and p.acao = 'read');

  -- Vendedor: vendas, clientes, produtos (read), relatórios básicos
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_seller_role_id, p.id, p_empresa_id
  from public.permissoes p
  where (p.recurso = 'vendas')
     or (p.recurso = 'clientes')
     or (p.recurso = 'produtos' and p.acao in ('read'))
     or (p.recurso in ('relatorios.overview', 'relatorios.detalhado') and p.acao = 'read');

  -- Caixa: caixa, vendas, clientes básico
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_cashier_role_id, p.id, p_empresa_id
  from public.permissoes p
  where (p.recurso = 'caixa')
     or (p.recurso = 'vendas' and p.acao in ('read', 'create'))
     or (p.recurso = 'clientes' and p.acao in ('read', 'create', 'update'));

  -- Técnico OS: ordens de serviço, clientes
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_tech_role_id, p.id, p_empresa_id
  from public.permissoes p
  where (p.recurso = 'ordens_servico')
     or (p.recurso = 'clientes' and p.acao in ('read', 'create', 'update'))
     or (p.recurso = 'produtos' and p.acao = 'read');

  -- Financeiro: relatórios e leitura de dados
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_financial_role_id, p.id, p_empresa_id
  from public.permissoes p
  where (p.recurso like 'relatorios%')
     or (p.recurso in ('vendas', 'clientes', 'produtos', 'ordens_servico', 'caixa') and p.acao = 'read');

  -- Somente Leitura: apenas read em tudo
  insert into public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
  select v_readonly_role_id, p.id, p_empresa_id
  from public.permissoes p
  where p.acao = 'read';

end $$;

-- ========================================
-- FUNÇÃO PARA SETUP INICIAL DE EMPRESA
-- ========================================

create or replace function public.setup_empresa(
  p_nome text,
  p_email text,
  p_cnpj text default null,
  p_admin_nome text default null,
  p_admin_email text default null
) returns uuid language plpgsql security definer as $$
declare
  v_empresa_id uuid;
  v_user_id uuid;
  v_funcionario_id uuid;
  v_admin_role_id uuid;
begin
  -- Criar empresa
  insert into public.empresas (nome, email, cnpj)
  values (p_nome, coalesce(p_email, p_admin_email), p_cnpj)
  returning id into v_empresa_id;

  -- Criar funções padrão
  perform public.create_default_roles(v_empresa_id);

  -- Se fornecido admin, criar o usuário
  if p_admin_email is not null then
    -- Buscar ou criar usuário no auth
    select id into v_user_id from auth.users where email = p_admin_email;
    
    if v_user_id is null then
      -- Usuário será criado pelo convite/signup
      -- Por enquanto, apenas reservar o slot
      v_user_id := gen_random_uuid();
    end if;

    -- Criar funcionário admin
    insert into public.funcionarios (
      user_id, empresa_id, nome, email, status, limite_desconto_pct
    ) values (
      v_user_id, v_empresa_id, 
      coalesce(p_admin_nome, split_part(p_admin_email, '@', 1)), 
      p_admin_email, 'ativo', 100
    ) returning id into v_funcionario_id;

    -- Atribuir role de Administrador
    select id into v_admin_role_id 
    from public.funcoes 
    where empresa_id = v_empresa_id and nome = 'Administrador';

    insert into public.funcionario_funcoes (funcionario_id, funcao_id, empresa_id)
    values (v_funcionario_id, v_admin_role_id, v_empresa_id);
  end if;

  return v_empresa_id;
end $$;

-- ========================================
-- EXEMPLO DE USO PARA CRIAR UMA EMPRESA
-- ========================================

-- select public.setup_empresa(
--   'Allimport Tecnologia', 
--   'contato@allimport.com.br',
--   '12.345.678/0001-90',
--   'Administrador',
--   'admin@allimport.com.br'
-- );

-- ========================================
-- COMENTÁRIOS FINAIS
-- ========================================

-- Este script cria toda a estrutura necessária para o sistema multi-tenant.
-- Próximos passos:
-- 1. Executar este script no Supabase
-- 2. Adaptar suas tabelas existentes com empresa_id
-- 3. Criar os componentes React de administração
-- 4. Implementar o fluxo de convites
-- 5. Adicionar middleware de JWT para incluir empresa_id no token