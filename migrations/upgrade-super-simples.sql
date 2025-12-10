-- ========================================
-- UPGRADE SUPER-SIMPLES - SISTEMA PROFISSIONAL
-- PDV Allimport - Zero dependências, funciona sempre
-- ========================================

-- 1. CONVITES (SUPER SIMPLES)
-- ========================================
create table if not exists public.convites (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null default gen_random_uuid(),
  email text not null,
  funcao text default 'funcionario',
  status text not null default 'pendente',
  token text not null unique default gen_random_uuid()::text,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_by uuid,
  created_at timestamptz not null default now()
);

-- 2. BACKUPS (SUPER SIMPLES)
-- ========================================
create table if not exists public.backups (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null default gen_random_uuid(),
  status text not null default 'pendente',
  arquivo_url text,
  tamanho_bytes bigint default 0,
  mensagem text,
  created_by uuid,
  created_at timestamptz not null default now()
);

-- 3. INTEGRAÇÕES (SUPER SIMPLES)
-- ========================================
create table if not exists public.integracoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null default gen_random_uuid(),
  tipo text not null,
  status text not null default 'nao_configurado',
  config jsonb not null default '{}'::jsonb,
  teste_realizado_at timestamptz,
  ultimo_erro text,
  updated_at timestamptz not null default now()
);

-- Garantir que não há duplicatas por empresa+tipo
create unique index if not exists idx_integracoes_empresa_tipo_unique 
on public.integracoes(empresa_id, tipo);

-- 4. POLÍTICAS RLS ABERTAS (PARA TESTAR)
-- ========================================
alter table public.convites enable row level security;
alter table public.backups enable row level security;
alter table public.integracoes enable row level security;

-- Políticas abertas: qualquer usuário autenticado pode ver tudo (simplificado)
drop policy if exists p_convites_open on public.convites;
create policy p_convites_open on public.convites
  for all using (auth.uid() is not null);

drop policy if exists p_backups_open on public.backups;
create policy p_backups_open on public.backups
  for all using (auth.uid() is not null);

drop policy if exists p_integracoes_open on public.integracoes;
create policy p_integracoes_open on public.integracoes
  for all using (auth.uid() is not null);

-- 5. FUNÇÕES PARA DASHBOARD (DADOS MOCK)
-- ========================================
create or replace function dash_users_stats() returns json language sql stable as $$
  select json_build_object(
    'total', 1,
    'ativos', 1,
    'bloqueados', 0,
    'pendentes', 0
  );
$$;

create or replace function dash_integracoes_status() returns json language sql stable as $$
  select '[
    {"tipo": "mercadopago", "status": "nao_configurado", "ultimo_teste": null, "ultimo_erro": null},
    {"tipo": "smtp", "status": "nao_configurado", "ultimo_teste": null, "ultimo_erro": null},
    {"tipo": "whatsapp", "status": "nao_configurado", "ultimo_teste": null, "ultimo_erro": null}
  ]'::json;
$$;

create or replace function dash_backups_recentes() returns json language sql stable as $$
  select '[]'::json;
$$;

-- 6. INSERIR DADOS DE EXEMPLO
-- ========================================
insert into public.integracoes (empresa_id, tipo, status, config) values
  (gen_random_uuid(), 'mercadopago', 'nao_configurado', '{}'::jsonb),
  (gen_random_uuid(), 'smtp', 'nao_configurado', '{}'::jsonb),
  (gen_random_uuid(), 'whatsapp', 'nao_configurado', '{}'::jsonb)
on conflict do nothing;

-- 7. ÍNDICES PARA PERFORMANCE
-- ========================================
create index if not exists idx_convites_empresa_status 
on public.convites(empresa_id, status);

create index if not exists idx_backups_empresa_created 
on public.backups(empresa_id, created_at desc);

create index if not exists idx_integracoes_empresa 
on public.integracoes(empresa_id);

-- ========================================
-- ✅ UPGRADE SUPER-SIMPLES COMPLETO!
-- Funciona sempre, sem erros, dados mock prontos
-- ========================================