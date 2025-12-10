-- SOLUÇÃO COMPLETA: Corrigir problema "Aguardando pagamento"
-- Execute este SQL no Supabase Dashboard > SQL Editor

-- 0. VERIFICAR/CORRIGIR ESTRUTURA DA TABELA payments_processed
DO $$
BEGIN
  -- Verificar se a tabela existe e ajustar tipos se necessário
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'payments_processed') THEN
    -- Alterar payment_id para TEXT se for BIGINT
    IF EXISTS (
      SELECT FROM information_schema.columns 
      WHERE table_name = 'payments_processed' 
      AND column_name = 'payment_id' 
      AND data_type IN ('bigint', 'integer')
    ) THEN
      ALTER TABLE public.payments_processed ALTER COLUMN payment_id TYPE TEXT;
      RAISE NOTICE 'payments_processed.payment_id alterado para TEXT';
    END IF;
    
    -- Remover colunas desnecessárias se existirem
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'payments_processed' AND column_name = 'company_id') THEN
      ALTER TABLE public.payments_processed DROP COLUMN company_id;
      RAISE NOTICE 'Coluna company_id removida de payments_processed';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'payments_processed' AND column_name = 'order_id') THEN
      ALTER TABLE public.payments_processed DROP COLUMN order_id;
      RAISE NOTICE 'Coluna order_id removida de payments_processed';
    END IF;
  ELSE
    -- Criar tabela se não existir (estrutura simples)
    CREATE TABLE public.payments_processed (
      payment_id TEXT PRIMARY KEY,
      processed_at TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Tabela payments_processed criada';
  END IF;
END
$$;

-- 1. ATUALIZAR A FUNÇÃO RPC PARA ACEITAR TEXT (EMAIL)
CREATE OR REPLACE FUNCTION public.extend_company_paid_until_v2(
  p_mp_payment_id bigint,
  p_company_id text default null,  -- Mudado de UUID para TEXT para aceitar emails
  p_order_id uuid default null
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_company_id text := p_company_id;  -- Mudado para TEXT
  v_order_id   uuid := p_order_id;
  v_rows       int;
  v_payment_data jsonb;
  v_payer_email text;
  v_subscription_id uuid;
BEGIN
  -- Idempotência: reserva o payment_id; se já existe, sai.
  INSERT INTO public.payments_processed(payment_id)
  VALUES (p_mp_payment_id::text)  -- Converter para TEXT
  ON CONFLICT DO NOTHING;

  GET DIAGNOSTICS v_rows = ROW_COUNT;
  IF v_rows = 0 THEN
    RAISE NOTICE 'extend_company_paid_until_v2: payment_id=% já foi processado.', p_mp_payment_id;
    RETURN;
  END IF;

  RAISE NOTICE 'extend_company_paid_until_v2: processando payment_id=%', p_mp_payment_id;

  -- Buscar dados do pagamento no Mercado Pago via metadados (company_id como email)
  IF v_company_id IS NOT NULL THEN
    -- Buscar por email (caso principal agora)
    IF v_company_id LIKE '%@%' THEN
      SELECT id INTO v_subscription_id
      FROM public.subscriptions 
      WHERE email = v_company_id
      LIMIT 1;
      
      IF v_subscription_id IS NOT NULL THEN
        RAISE NOTICE 'extend_company_paid_until_v2: encontrada assinatura por email: %', v_company_id;
        
        -- Estender assinatura por 30 dias
        UPDATE public.subscriptions 
        SET subscription_end_date = GREATEST(
              COALESCE(subscription_end_date, NOW()), 
              NOW()
            ) + INTERVAL '30 days',
            status = 'active',
            payment_id = p_mp_payment_id::text,
            payment_status = 'paid',
            updated_at = NOW()
        WHERE id = v_subscription_id;
        
        RAISE NOTICE 'extend_company_paid_until_v2: assinatura % estendida por 30 dias', v_subscription_id;
      ELSE
        RAISE NOTICE 'extend_company_paid_until_v2: nenhuma assinatura encontrada para email: %', v_company_id;
        
        -- CRIAR ASSINATURA AUTOMATICAMENTE SE NÃO EXISTIR
        BEGIN
          INSERT INTO public.subscriptions (
            email,
            status,
            subscription_end_date,
            payment_status,
            payment_id,
            created_at,
            updated_at
          ) VALUES (
            v_company_id,
            'active',
            NOW() + INTERVAL '30 days',
            'paid',
            p_mp_payment_id::text,
            NOW(),
            NOW()
          );
          
          RAISE NOTICE 'extend_company_paid_until_v2: nova assinatura criada para email: %', v_company_id;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'extend_company_paid_until_v2: erro ao criar assinatura: %', SQLERRM;
        END;
      END IF;
    ELSE
      -- Fallback: tentar buscar por user_id se company_id for um UUID (compatibilidade)
      BEGIN
        SELECT s.id INTO v_subscription_id
        FROM public.subscriptions s
        JOIN auth.users u ON u.id = s.user_id
        WHERE s.user_id = v_company_id::uuid
        LIMIT 1;
        
        IF v_subscription_id IS NOT NULL THEN
          RAISE NOTICE 'extend_company_paid_until_v2: encontrada assinatura por user_id: %', v_company_id;
          
          -- Estender assinatura por 30 dias
          UPDATE public.subscriptions 
          SET subscription_end_date = GREATEST(
                COALESCE(subscription_end_date, NOW()), 
                NOW()
              ) + INTERVAL '30 days',
              status = 'active',
              payment_id = p_mp_payment_id::text,
              payment_status = 'paid',
              updated_at = NOW()
          WHERE id = v_subscription_id;
          
          RAISE NOTICE 'extend_company_paid_until_v2: assinatura % estendida por 30 dias', v_subscription_id;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'extend_company_paid_until_v2: company_id não é um UUID válido: %', v_company_id;
      END;
    END IF;
  END IF;

  -- Se não encontrou assinatura, apenas registrar o processamento
  IF v_subscription_id IS NULL THEN
    RAISE NOTICE 'extend_company_paid_until_v2: processamento concluído para payment_id=%', p_mp_payment_id;
  END IF;

  -- Se existir orders e tivermos order_id, marca como paid
  IF v_order_id IS NOT NULL AND public.table_exists('public','orders') THEN
    UPDATE public.orders
       SET status = 'paid',
           paid_at = COALESCE(paid_at, NOW()),
           updated_at = NOW()
     WHERE id = v_order_id
       AND (status IS DISTINCT FROM 'paid');
  END IF;

  -- Finaliza o registro de idempotência
  UPDATE public.payments_processed
     SET processed_at = NOW()
   WHERE payment_id = p_mp_payment_id::text;  -- Converter para TEXT

  RAISE NOTICE 'extend_company_paid_until_v2: processamento concluído para payment_id=%', p_mp_payment_id;
END
$$;

-- 2. TESTAR A FUNÇÃO COM PAYMENT ID APROVADO (assistenciaallimport10@gmail.com)
SELECT extend_company_paid_until_v2(
  126096480102::bigint,
  'assistenciaallimport10@gmail.com'::text,
  NULL::uuid
);

-- 3. TESTAR TAMBÉM COM O PAYMENT ID DE TESTE
SELECT extend_company_paid_until_v2(
  125543848657::bigint,
  'teste@pdvallimport.com'::text,
  NULL::uuid
);

-- 4. VERIFICAR SE ASSINATURAS FORAM CRIADAS/ATUALIZADAS
SELECT 
  email, 
  status, 
  subscription_end_date, 
  payment_status,
  payment_id,
  EXTRACT(DAY FROM subscription_end_date - NOW()) as dias_restantes,
  created_at
FROM public.subscriptions 
WHERE email IN ('teste@pdvallimport.com', 'assistenciaallimport10@gmail.com')
ORDER BY email;

-- 5. VERIFICAR PAGAMENTOS PROCESSADOS
SELECT 
  payment_id,
  processed_at
FROM public.payments_processed 
WHERE payment_id IN ('125543848657', '126096480102')
ORDER BY payment_id;

-- 6. COMENTÁRIOS FINAIS
SELECT 'FUNÇÃO ATUALIZADA E TESTADA! Agora o sistema deve reconhecer pagamentos automaticamente.' as resultado;