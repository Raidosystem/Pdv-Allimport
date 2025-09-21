-- ========================================
-- UPGRADE MINIMALISTA - SISTEMA PROFISSIONAL
-- PDV Allimport - Versão Ultra Simples
-- ========================================

-- 1. CONVITES (VERSÃO SIMPLIFICADA)
-- ========================================
create table if not exists public.convites (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null,
  email text not null,
  funcao text default 'funcionario',
  status text not null default 'pendente',
  token text not null unique default gen_random_uuid()::text,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_by uuid,
  created_at timestamptz not null default now()
);

-- 2. BACKUPS (VERSÃO SIMPLIFICADA)
-- ========================================
create table if not exists public.backups (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null,
  status text not null default 'pendente',
  arquivo_url text,
  tamanho_bytes bigint default 0,
  mensagem text,
  created_by uuid,
  created_at timestamptz not null default now()
);

-- 3. INTEGRAÇÕES (VERSÃO SIMPLIFICADA)
-- ========================================
create table if not exists public.integracoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null,
  tipo text not null,
  status text not null default 'nao_configurado',
  config jsonb not null default '{}'::jsonb,
  teste_realizado_at timestamptz,
  ultimo_erro text,
  updated_at timestamptz not null default now()
);

-- 4. FUNÇÕES E FUNCIONÁRIOS (SISTEMA USUÁRIOS)
-- ========================================
create table if not exists public.funcoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null,
  nome text not null,
  descricao text,
  created_at timestamptz not null default now()
);

create table if not exists public.funcionarios (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null,
  email text not null,
  nome text,
  telefone text,
  status text not null default 'pendente',
  convite_token text,
  convite_expires_at timestamptz,
  last_login_at timestamptz,
  created_at timestamptz not null default now()
);

-- Adicionar colunas se não existirem (para tabelas já criadas)
alter table public.funcionarios 
add column if not exists convite_token text;

alter table public.funcionarios 
add column if not exists convite_expires_at timestamptz;

create table if not exists public.funcionario_funcoes (
  funcionario_id uuid not null references public.funcionarios(id) on delete cascade,
  funcao_id uuid not null references public.funcoes(id) on delete cascade,
  empresa_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (funcionario_id, funcao_id)
);

-- 5. ÍNDICES BÁSICOS
-- ========================================
create unique index if not exists idx_integracoes_empresa_tipo_unique 
on public.integracoes(empresa_id, tipo);

create unique index if not exists idx_funcoes_empresa_nome_unique 
on public.funcoes(empresa_id, nome);

create unique index if not exists idx_funcionarios_empresa_email_unique 
on public.funcionarios(empresa_id, email);

-- ========================================
-- ✅ UPGRADE MINIMALISTA COMPLETO!
-- Apenas tabelas básicas sem complexidades
-- ========================================