-- 🔍 DIAGNÓSTICO: Qual campo está REALMENTE na tabela movimentacoes_caixa?
-- Execute este SQL no Supabase SQL Editor para descobrir

-- 1. Ver TODAS as colunas da tabela movimentacoes_caixa
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'movimentacoes_caixa'
ORDER BY ordinal_position;

-- 2. Ver especificamente se existe 'usuario_id' ou 'user_id'
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND table_name = 'movimentacoes_caixa' 
              AND column_name = 'usuario_id'
        ) THEN '✅ Existe coluna usuario_id'
        ELSE '❌ NÃO existe coluna usuario_id'
    END as campo_usuario_id,
    
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND table_name = 'movimentacoes_caixa' 
              AND column_name = 'user_id'
        ) THEN '✅ Existe coluna user_id'
        ELSE '❌ NÃO existe coluna user_id'
    END as campo_user_id;

-- 3. Ver políticas RLS ativas
SELECT 
    policyname as nome_politica,
    tablename as tabela,
    cmd as comando,
    SUBSTRING(qual::text, 1, 100) as condicao_usando,
    SUBSTRING(with_check::text, 1, 100) as condicao_check
FROM pg_policies
WHERE tablename = 'movimentacoes_caixa';

-- 4. Ver se RLS está habilitado
SELECT 
    tablename as tabela,
    rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename IN ('movimentacoes_caixa', 'caixa');
