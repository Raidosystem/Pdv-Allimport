-- ========================================
-- UPGRADE PROFISSIONAL - SISTEMA ADMINISTRATIVO
-- PDV Allimport - SQL CORRIGIDO para Supabase
-- ========================================

-- 1. CONVITES DE USUÁRIO
-- ========================================
create table if not exists public.convites (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  email text not null,
  funcao_nome text default 'funcionario',
  status text not null default 'pendente',
  token text not null unique,
  expires_at timestamptz not null,
  created_by uuid references public.funcionarios(id),
  created_at timestamptz not null default now()
);

-- 2. BACKUPS (METADADOS)
-- ========================================
create table if not exists public.backups (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  status text not null default 'pendente',
  arquivo_url text,
  tamanho_bytes bigint,
  mensagem text,
  created_by uuid references public.funcionarios(id),
  created_at timestamptz not null default now()
);

-- 3. INTEGRAÇÕES
-- ========================================
create table if not exists public.integracoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  tipo text not null,
  status text not null default 'nao_configurado',
  config jsonb not null default '{}'::jsonb,
  teste_realizado_at timestamptz,
  ultimo_erro text,
  updated_at timestamptz not null default now(),
  unique (empresa_id, tipo)
);

-- 4. POLÍTICAS RLS (SIMPLIFICADAS)
-- ========================================
alter table public.convites enable row level security;
alter table public.backups enable row level security;
alter table public.integracoes enable row level security;

-- Convites: acesso por empresa
create policy p_convites_empresa on public.convites
  using (empresa_id = auth.empresa_do_usuario());

-- Backups: acesso por empresa  
create policy p_backups_empresa on public.backups
  using (empresa_id = auth.empresa_do_usuario());

-- Integrações: acesso por empresa
create policy p_integracoes_empresa on public.integracoes
  using (empresa_id = auth.empresa_do_usuario());

-- 5. NOVAS PERMISSÕES (CRIAR TABELA SE NÃO EXISTIR)
-- ========================================
create table if not exists public.permissoes (
  id uuid primary key default gen_random_uuid(),
  recurso text not null,
  acao text not null,
  descricao text not null,
  categoria text not null default 'geral',
  created_at timestamptz default now(),
  unique (recurso, acao)
);

insert into public.permissoes (recurso, acao, descricao, categoria) values
  ('convites', 'read', 'Visualizar convites de usuários', 'admin'),
  ('convites', 'create', 'Criar convites de usuários', 'admin'),
  ('convites', 'delete', 'Cancelar convites de usuários', 'admin'),
  ('backups', 'read', 'Visualizar histórico de backups', 'sistema'),
  ('backups', 'create', 'Executar backup do sistema', 'sistema'),
  ('backups', 'download', 'Baixar arquivos de backup', 'sistema'),
  ('integracoes', 'read', 'Visualizar status das integrações', 'integracao'),
  ('integracoes', 'write', 'Configurar integrações externas', 'integracao'),
  ('integracoes', 'test', 'Testar integrações configuradas', 'integracao'),
  ('dashboard.admin', 'read', 'Acessar dashboard administrativo', 'admin'),
  ('auditoria', 'read', 'Visualizar logs de auditoria', 'admin')
  on conflict (recurso, acao) do nothing;

-- 6. FUNÇÕES PARA DASHBOARD
-- ========================================
create or replace function dash_users_stats() returns json language sql stable as $$
  with stats as (
    select 
      count(*) filter (where status = 'ativo') as ativos,
      count(*) filter (where status = 'bloqueado') as bloqueados,
      count(*) filter (where status = 'pendente') as pendentes,
      count(*) as total
    from funcionarios 
    where empresa_id = auth.empresa_do_usuario()
  )
  select json_build_object(
    'total', total, 
    'ativos', ativos, 
    'bloqueados', bloqueados,
    'pendentes', pendentes
  ) from stats;
$$;

create or replace function dash_integracoes_status() returns json language sql stable as $$
  select coalesce(
    json_agg(
      json_build_object(
        'tipo', tipo, 
        'status', status,
        'ultimo_teste', teste_realizado_at,
        'ultimo_erro', ultimo_erro
      ) order by tipo
    ), 
    '[]'::json
  )
  from integracoes 
  where empresa_id = auth.empresa_do_usuario();
$$;

create or replace function dash_backups_recentes() returns json language sql stable as $$
  select coalesce(
    json_agg(
      json_build_object(
        'id', id,
        'status', status,
        'created_at', created_at,
        'tamanho_mb', round(tamanho_bytes / 1024.0 / 1024.0, 2)
      ) order by created_at desc
    ), 
    '[]'::json
  )
  from backups 
  where empresa_id = auth.empresa_do_usuario()
  limit 5;
$$;

-- 7. DADOS INICIAIS
-- ========================================
insert into public.integracoes (empresa_id, tipo, status, config)
select 
  e.id,
  unnest(array['mercadopago', 'smtp', 'whatsapp']) as tipo,
  'nao_configurado' as status,
  '{}'::jsonb as config
from public.empresas e
on conflict (empresa_id, tipo) do nothing;

-- 8. ÍNDICES PARA PERFORMANCE
-- ========================================
create index if not exists idx_convites_empresa_status on public.convites(empresa_id, status);
create index if not exists idx_backups_empresa_created on public.backups(empresa_id, created_at desc);
create index if not exists idx_integracoes_empresa_tipo on public.integracoes(empresa_id, tipo);

-- ========================================
-- ✅ UPGRADE COMPLETO - SISTEMA PROFISSIONAL! 
-- ========================================