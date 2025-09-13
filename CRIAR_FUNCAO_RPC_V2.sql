-- 1) Tabela de idempotência
create table if not exists public.payments_processed (
  payment_id   bigint primary key,     -- ID do pagamento no Mercado Pago
  company_id   uuid,                   -- empresa beneficiada
  order_id     uuid,                   -- pedido (se houver)
  processed_at timestamptz default now()
);

comment on table public.payments_processed is
  'Pagamentos do MP já processados (idempotência).';

-- 2) Helper para checar se tabela existe
create or replace function public.table_exists(t_schema text, t_name text)
returns boolean language sql stable as $$
  select to_regclass(format('%I.%I', t_schema, t_name)) is not null
$$;

-- 3) RPC principal para processar pagamentos de assinatura
create or replace function public.extend_company_paid_until_v2(
  p_mp_payment_id bigint,
  p_company_id text default null,  -- Mudado para TEXT para aceitar emails
  p_order_id uuid default null
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_company_id text := p_company_id;  -- Mudado para TEXT
  v_order_id   uuid := p_order_id;
  v_rows       int;
  v_payment_data jsonb;
  v_payer_email text;
  v_subscription_id uuid;
begin
  -- Idempotência: reserva o payment_id; se já existe, sai.
  insert into public.payments_processed(payment_id)
  values (p_mp_payment_id)
  on conflict do nothing;

  get diagnostics v_rows = row_count;
  if v_rows = 0 then
    raise notice 'extend_company_paid_until_v2: payment_id=% já foi processado.', p_mp_payment_id;
    return;
  end if;

  raise notice 'extend_company_paid_until_v2: processando payment_id=%', p_mp_payment_id;

  -- Buscar dados do pagamento no Mercado Pago via metadados (company_id como identificador)
  if v_company_id is not null then
    -- Tentar encontrar assinatura pelo company_id (que agora é sempre email)
    -- O company_id nos metadados agora é sempre o email completo
    
    -- Buscar por email (agora é o caso principal)
    if v_company_id like '%@%' then
      select id into v_subscription_id
      from public.subscriptions 
      where email = v_company_id
      limit 1;
      
      if v_subscription_id is not null then
        raise notice 'extend_company_paid_until_v2: encontrada assinatura por email: %', v_company_id;
        
        -- Estender assinatura por 30 dias
        update public.subscriptions 
        set subscription_end_date = greatest(
              coalesce(subscription_end_date, now()), 
              now()
            ) + interval '30 days',
            status = 'active',
            payment_id = p_mp_payment_id::text,
            payment_status = 'paid',
            updated_at = now()
        where id = v_subscription_id;
        
        raise notice 'extend_company_paid_until_v2: assinatura % estendida por 30 dias', v_subscription_id;
      else
        raise notice 'extend_company_paid_until_v2: nenhuma assinatura encontrada para email: %', v_company_id;
      end if;
    else
      -- Fallback: tentar buscar por user_id se company_id for um UUID (compatibilidade)
      begin
        select s.id into v_subscription_id
        from public.subscriptions s
        join auth.users u on u.id = s.user_id
        where s.user_id = v_company_id::uuid
        limit 1;
        
        if v_subscription_id is not null then
          raise notice 'extend_company_paid_until_v2: encontrada assinatura por user_id: %', v_company_id;
          
          -- Estender assinatura por 30 dias
          update public.subscriptions 
          set subscription_end_date = greatest(
                coalesce(subscription_end_date, now()), 
                now()
              ) + interval '30 days',
              status = 'active',
              payment_id = p_mp_payment_id::text,
              payment_status = 'paid',
              updated_at = now()
          where id = v_subscription_id;
          
          raise notice 'extend_company_paid_until_v2: assinatura % estendida por 30 dias', v_subscription_id;
        end if;
      exception when others then
        raise notice 'extend_company_paid_until_v2: company_id não é um UUID válido: %', v_company_id;
      end;
    end if;
  end if;

  -- Se não encontrou assinatura, apenas registrar o processamento
  if v_subscription_id is null then
    raise notice 'extend_company_paid_until_v2: nenhuma assinatura encontrada para company_id=%. Pagamento registrado apenas.', v_company_id;
  end if;

  -- Compatibilidade: tentar estender via tabela companies (se existir)
  if v_company_id is not null and public.table_exists('public','companies') then
    -- Tentar converter para UUID se possível (compatibilidade)
    begin
      update public.companies c
         set paid_until = greatest(coalesce(c.paid_until, now()), now()) + interval '30 days',
             updated_at = now()
       where c.id = v_company_id::uuid;
    exception when others then
      raise notice 'extend_company_paid_until_v2: company_id não é UUID para tabela companies: %', v_company_id;
    end;
  end if;

  -- Se existir orders e tivermos order_id, marca como paid
  if v_order_id is not null and public.table_exists('public','orders') then
    update public.orders
       set status = 'paid',
           paid_at = coalesce(paid_at, now()),
           updated_at = now()
     where id = v_order_id
       and (status is distinct from 'paid');
  end if;

  -- Finaliza o registro de idempotência
  update public.payments_processed
     set order_id   = v_order_id,
         processed_at = now()
   where payment_id = p_mp_payment_id;

  raise notice 'extend_company_paid_until_v2: processamento concluído para payment_id=%', p_mp_payment_id;
end
$$;

comment on function public.extend_company_paid_until_v2(bigint, text, uuid) is
  'Processa pagamentos MP e estende assinaturas na tabela subscriptions por 30 dias.';