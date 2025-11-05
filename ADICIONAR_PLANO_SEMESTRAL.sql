-- =============================================
-- ADICIONAR PLANO SEMESTRAL AO SISTEMA
-- =============================================

-- Verificar se a tabela subscription_plans existe
DO $$
BEGIN
  -- Se a tabela existe, adicionar o plano semestral
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscription_plans') THEN
    
    -- Atualizar os preços dos planos existentes para ficar consistente
    UPDATE subscription_plans 
    SET price_brl = 59.90 
    WHERE name = 'Mensal';
    
    -- Inserir plano semestral
    INSERT INTO subscription_plans (name, description, price_brl, days_duration, mp_preference_title, sort_order) 
    VALUES 
    ('Semestral', 'Acesso completo por 6 meses - R$ 52,00/mês', 312.00, 180, 'PDV Allimport - Plano Semestral', 2)
    ON CONFLICT DO NOTHING;
    
    -- Reordenar os planos
    UPDATE subscription_plans SET sort_order = 1 WHERE name = 'Mensal';
    UPDATE subscription_plans SET sort_order = 2 WHERE name = 'Semestral';
    UPDATE subscription_plans SET sort_order = 3 WHERE name = 'Trimestral';
    UPDATE subscription_plans SET sort_order = 4 WHERE name = 'Anual';
    
    -- Atualizar preço do anual para ser mais atrativo
    UPDATE subscription_plans 
    SET 
      price_brl = 550.00,
      description = 'Acesso completo por 12 meses - R$ 45,83/mês (Mais Econômico)'
    WHERE name = 'Anual';
    
    RAISE NOTICE '✅ Plano Semestral adicionado com sucesso!';
    RAISE NOTICE '💰 Preços atualizados: Mensal R$ 59,90 | Semestral R$ 312,00 | Anual R$ 550,00';
    
  ELSE
    RAISE NOTICE '⚠️ Tabela subscription_plans não encontrada - planos apenas no frontend';
  END IF;
END $$;

-- Verificar resultado
SELECT 
  name,
  description,
  price_brl,
  days_duration,
  ROUND(price_brl / (days_duration / 30.0), 2) as preco_mensal_equivalente,
  sort_order
FROM subscription_plans 
WHERE is_active = true
ORDER BY sort_order;

-- Calcular economias
WITH precos AS (
  SELECT 
    name,
    price_brl,
    days_duration,
    ROUND(price_brl / (days_duration / 30.0), 2) as mensal_equiv
  FROM subscription_plans 
  WHERE is_active = true
),
economia AS (
  SELECT 
    p.*,
    (SELECT mensal_equiv FROM precos WHERE name = 'Mensal') as preco_mensal_base,
    (SELECT mensal_equiv FROM precos WHERE name = 'Mensal') * (days_duration / 30.0) as preco_sem_desconto,
    ((SELECT mensal_equiv FROM precos WHERE name = 'Mensal') * (days_duration / 30.0)) - price_brl as economia_total
  FROM precos p
)
SELECT 
  name as plano,
  CONCAT('R$ ', price_brl) as preco_total,
  CONCAT('R$ ', mensal_equiv) as preco_mensal,
  CASE 
    WHEN economia_total > 0 THEN CONCAT('R$ ', ROUND(economia_total, 2), ' (', ROUND((economia_total / preco_sem_desconto) * 100, 1), '%)')
    ELSE 'Base'
  END as economia
FROM economia
ORDER BY days_duration;

-- =============================================
-- 📊 RESUMO DOS PLANOS ATUALIZADOS
-- =============================================
-- Mensal: R$ 59,90 (R$ 59,90/mês)
-- Semestral: R$ 312,00 (R$ 52,00/mês) - Economia: R$ 47,40 (13%)
-- Anual: R$ 550,00 (R$ 45,83/mês) - Economia: R$ 168,80 (23%)
-- =============================================