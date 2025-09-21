-- ========================================
-- UPGRADE PROFISSIONAL - ADMINISTRAÇÃO DO SISTEMA
-- PDV Allimport - Novas funcionalidades do blueprint
-- ========================================
-- ATENÇÃO: Este script APENAS ADICIONA funcionalidades, não modifica o existente

-- 1. CONVITES DE USUÁRIO (NOVO)
-- ========================================

create table if not exists public.convites (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  email text not null,
  funcao_id uuid references public.funcoes(id),
  status text not null default 'pendente', -- pendente | aceito | expirado | cancelado
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
  status text not null default 'pendente', -- pendente | ok | erro
  arquivo_url text, -- storage signed url
  tamanho_bytes bigint,
  mensagem text,
  created_by uuid references public.funcionarios(id),
  created_at timestamptz not null default now()
);

-- 3. INTEGRAÇÕES (NOVO)
-- ========================================

create table if not exists public.integracoes (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  tipo text not null, -- 'mercadopago' | 'smtp' | 'whatsapp'
  status text not null default 'nao_configurado', -- nao_configurado | configurado | ativo | erro
  config jsonb not null default '{}'::jsonb,
  teste_realizado_at timestamptz,
  ultimo_erro text,
  updated_at timestamptz not null default now(),
  unique (empresa_id, tipo)
);

-- 4. POLÍTICAS RLS PARA NOVAS TABELAS
-- ========================================

alter table public.convites enable row level security;
alter table public.backups enable row level security;
alter table public.integracoes enable row level security;

-- Helper: empresa do usuário logado (já existe)
-- create or replace function auth.empresa_do_usuario() returns uuid language sql stable as $$
--   select empresa_id from funcionarios where user_id = auth.uid();
-- $$;

-- Convites: apenas admins da empresa podem gerenciar
create policy p_convites_admin on public.convites for all
  using (empresa_id = auth.empresa_do_usuario() and exists (
    select 1 from funcionario_funcoes ff
    join funcoes f on f.id = ff.funcao_id
    join funcionarios func on func.id = ff.funcionario_id
    where func.user_id = auth.uid() and f.nome in ('admin', 'administrador')
  ));

-- Backups: visível por empresa, gerenciamento por admin/gerente
create policy p_backups_select on public.backups for select
  using (empresa_id = auth.empresa_do_usuario());

create policy p_backups_admin on public.backups for insert, update, delete
  using (empresa_id = auth.empresa_do_usuario() and exists (
    select 1 from funcionario_funcoes ff
    join funcoes f on f.id = ff.funcao_id
    join funcionarios func on func.id = ff.funcionario_id
    where func.user_id = auth.uid() and f.nome in ('admin', 'administrador', 'gerente')
  ));

-- Integrações: visível por empresa, gerenciamento por admin
create policy p_integracoes_select on public.integracoes for select
  using (empresa_id = auth.empresa_do_usuario());

create policy p_integracoes_admin on public.integracoes for insert, update, delete
  using (empresa_id = auth.empresa_do_usuario() and exists (
    select 1 from funcionario_funcoes ff
    join funcoes f on f.id = ff.funcao_id
    join funcionarios func on func.id = ff.funcionario_id
    where func.user_id = auth.uid() and f.nome in ('admin', 'administrador')
  ));

-- 5. NOVAS PERMISSÕES PROFISSIONAIS
-- ========================================

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

-- 6. VIEWS ÚTEIS PARA DASHBOARD
-- ========================================

-- Permissões efetivas do usuário logado
create or replace view v_user_permissions as
select distinct f.user_id, p.recurso, p.acao
from funcionarios f
join funcionario_funcoes ff on ff.funcionario_id = f.id
join funcao_permissoes fp on fp.funcao_id = ff.funcao_id
join permissoes p on p.id = fp.permissao_id
where f.user_id = auth.uid();

-- Estatísticas do dashboard
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

-- Status das integrações
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

-- Últimos backups
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

-- 7. TRIGGERS PARA AUDITORIA (MELHORIA)
-- ========================================

-- Função para registrar ações administrativas
create or replace function log_admin_action()
returns trigger language plpgsql security definer as $$
begin
  if TG_OP = 'INSERT' then
    insert into audit_logs (empresa_id, funcionario_id, acao, detalhes, created_at)
    values (
      coalesce(NEW.empresa_id, auth.empresa_do_usuario()),
      (select id from funcionarios where user_id = auth.uid()),
      TG_TABLE_NAME || '.' || lower(TG_OP),
      json_build_object('id', NEW.id, 'data', to_jsonb(NEW)),
      now()
    );
    return NEW;
  elsif TG_OP = 'UPDATE' then
    insert into audit_logs (empresa_id, funcionario_id, acao, detalhes, created_at)
    values (
      coalesce(NEW.empresa_id, auth.empresa_do_usuario()),
      (select id from funcionarios where user_id = auth.uid()),
      TG_TABLE_NAME || '.' || lower(TG_OP),
      json_build_object('id', NEW.id, 'old', to_jsonb(OLD), 'new', to_jsonb(NEW)),
      now()
    );
    return NEW;
  elsif TG_OP = 'DELETE' then
    insert into audit_logs (empresa_id, funcionario_id, acao, detalhes, created_at)
    values (
      coalesce(OLD.empresa_id, auth.empresa_do_usuario()),
      (select id from funcionarios where user_id = auth.uid()),
      TG_TABLE_NAME || '.' || lower(TG_OP),
      json_build_object('id', OLD.id, 'data', to_jsonb(OLD)),
      now()
    );
    return OLD;
  end if;
  return null;
end;$$;

-- Aplicar triggers nas tabelas administrativas
drop trigger if exists tr_convites_audit on public.convites;
create trigger tr_convites_audit
  after insert or update or delete on public.convites
  for each row execute function log_admin_action();

drop trigger if exists tr_backups_audit on public.backups;
create trigger tr_backups_audit
  after insert or update or delete on public.backups
  for each row execute function log_admin_action();

drop trigger if exists tr_integracoes_audit on public.integracoes;
create trigger tr_integracoes_audit
  after insert or update or delete on public.integracoes
  for each row execute function log_admin_action();

-- 8. DADOS INICIAIS PARA INTEGRAÇÕES
-- ========================================

-- Criar registros de integrações padrão para empresas existentes
insert into public.integracoes (empresa_id, tipo, status, config)
select 
  e.id,
  unnest(array['mercadopago', 'smtp', 'whatsapp']) as tipo,
  'nao_configurado' as status,
  '{}'::jsonb as config
from public.empresas e
on conflict (empresa_id, tipo) do nothing;

-- 9. ÍNDICES PARA PERFORMANCE
-- ========================================

create index if not exists idx_convites_empresa_status on public.convites(empresa_id, status);
create index if not exists idx_backups_empresa_created on public.backups(empresa_id, created_at desc);
create index if not exists idx_integracoes_empresa_tipo on public.integracoes(empresa_id, tipo);
create index if not exists idx_audit_logs_empresa_created on public.audit_logs(empresa_id, created_at desc);

-- ========================================
-- UPGRADE COMPLETO! 
-- Sistema administrativo profissional implementado
-- ========================================