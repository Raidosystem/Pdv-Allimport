-- ============================================
-- VERIFICAÇÃO ESPECÍFICA: PROBLEMA DO CAIXA
-- Sistema com 5 usuários - Caixa fechando sozinho
-- NÃO ALTERA NADA - APENAS ANALISA
-- ============================================

-- 1. LISTAR OS 5 USUÁRIOS DO SISTEMA
SELECT 
    '👥 OS 5 USUÁRIOS DO SISTEMA' as secao,
    id as user_id,
    email,
    created_at as data_criacao,
    CASE 
        WHEN id = auth.uid() THEN '👈 VOCÊ ESTÁ LOGADO'
        ELSE '👤 Outro usuário'
    END as status_login
FROM auth.users
ORDER BY created_at;

-- 2. VERIFICAR STATUS RLS DA TABELA CAIXA
SELECT 
    '🔒 STATUS RLS - TABELA CAIXA' as secao,
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ RLS ESTÁ ATIVO' 
        ELSE '❌ RLS ESTÁ DESATIVADO - PROBLEMA!' 
    END as status_rls
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'caixa';

-- 3. LISTAR TODAS AS POLÍTICAS DA TABELA CAIXA
SELECT 
    '📋 POLÍTICAS DA TABELA CAIXA' as secao,
    policyname as nome_politica,
    cmd as comando,
    CASE 
        WHEN qual = 'ALL' THEN '🔄 Todas operações'
        WHEN qual = 'SELECT' THEN '👁️ SELECT (leitura)'
        WHEN qual = 'INSERT' THEN '➕ INSERT (criar)'
        WHEN qual = 'UPDATE' THEN '✏️ UPDATE (editar)'
        WHEN qual = 'DELETE' THEN '🗑️ DELETE (excluir)'
    END as tipo_operacao
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename = 'caixa'
ORDER BY policyname;

-- 4. VER AS CONDIÇÕES EXATAS DAS POLÍTICAS (MAIS IMPORTANTE)
SELECT 
    '🔍 CONDIÇÕES DAS POLÍTICAS - TABELA CAIXA' as secao,
    pol.polname as politica,
    pol.polcmd as comando,
    CASE 
        WHEN pg_get_expr(pol.polqual, pol.polrelid) LIKE '%auth.uid()%' THEN '✅ USA auth.uid()'
        WHEN pg_get_expr(pol.polqual, pol.polrelid) LIKE '%usuario_id%' THEN '✅ USA usuario_id'
        WHEN pg_get_expr(pol.polqual, pol.polrelid) LIKE '%user_id%' THEN '⚠️ USA user_id (verificar se coluna existe)'
        ELSE '❓ Outro filtro'
    END as tipo_filtro,
    pg_get_expr(pol.polqual, pol.polrelid) as condicao_completa_using,
    pg_get_expr(pol.polwithcheck, pol.polrelid) as condicao_completa_with_check
FROM pg_policy pol
JOIN pg_class cls ON pol.polrelid = cls.oid
WHERE cls.relname = 'caixa';

-- 5. VERIFICAR QUAL COLUNA A TABELA CAIXA REALMENTE USA
SELECT 
    '🔑 COLUNAS DA TABELA CAIXA' as secao,
    column_name as coluna,
    data_type as tipo,
    is_nullable as permite_null,
    CASE 
        WHEN column_name = 'usuario_id' THEN '✅ CORRETO - Coluna de isolamento'
        WHEN column_name = 'user_id' THEN '✅ CORRETO - Coluna de isolamento'
        ELSE ''
    END as observacao
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'caixa'
AND (column_name LIKE '%id%' OR column_name LIKE 'status')
ORDER BY ordinal_position;

-- 6. DISTRIBUIÇÃO DE CAIXAS POR USUÁRIO
SELECT 
    '📊 CAIXAS POR USUÁRIO' as secao,
    c.usuario_id,
    u.email as email_usuario,
    COUNT(*) as total_caixas,
    COUNT(CASE WHEN c.status = 'aberto' THEN 1 END) as caixas_abertos,
    COUNT(CASE WHEN c.status = 'fechado' THEN 1 END) as caixas_fechados,
    MAX(c.data_abertura) as ultimo_caixa_aberto
FROM public.caixa c
LEFT JOIN auth.users u ON c.usuario_id = u.id
GROUP BY c.usuario_id, u.email
ORDER BY total_caixas DESC;

-- 7. VERIFICAR SE HÁ CAIXAS ÓRFÃOS (sem usuario_id)
SELECT 
    '⚠️ CAIXAS ÓRFÃOS (SEM USUÁRIO)' as secao,
    COUNT(*) as total_orfaos,
    CASE 
        WHEN COUNT(*) > 0 THEN '❌ PROBLEMA! Caixas sem usuario_id'
        ELSE '✅ OK - Todos os caixas têm usuário'
    END as diagnostico
FROM public.caixa
WHERE usuario_id IS NULL;

-- 8. VERIFICAR CAIXAS VISÍVEIS PARA O USUÁRIO ATUAL
SELECT 
    '👁️ CAIXAS QUE VOCÊ VÊ ATUALMENTE' as secao,
    id as caixa_id,
    usuario_id,
    status,
    valor_inicial,
    data_abertura,
    data_fechamento,
    CASE 
        WHEN usuario_id = auth.uid() THEN '✅ É SEU CAIXA'
        ELSE '❌ NÃO É SEU - VAZAMENTO DE DADOS!'
    END as pertence_a_voce
FROM public.caixa
ORDER BY data_abertura DESC
LIMIT 10;

-- 9. ANÁLISE DO PROBLEMA RELATADO
SELECT 
    '🐛 ANÁLISE DO PROBLEMA' as secao,
    '
    ═══════════════════════════════════════════════════════
    PROBLEMA RELATADO:
    "o caixa estava aberto e agora esta fechado, 
     e esta que tem 5 usuarios, 
     deve estar puxando de algum usuario 
     que tem que ser protegido de cada usuario"
    ═══════════════════════════════════════════════════════
    
    POSSÍVEIS CAUSAS:
    
    1️⃣ RLS NÃO ESTÁ FUNCIONANDO:
       - Tabela caixa tem RLS desabilitado
       - Políticas estão incorretas
       - Campo usuario_id está NULL em alguns registros
    
    2️⃣ POLÍTICA USA CAMPO ERRADO:
       - Tabela usa: usuario_id
       - Política usa: user_id (campo inexistente)
       - Resultado: Política não filtra nada
    
    3️⃣ CÓDIGO DO FRONTEND BUSCA ERRADO:
       - caixaService.ts busca: .eq("usuario_id", user.id)
       - Mas RLS não está filtrando
       - Pode retornar caixa de outro usuário
    
    ═══════════════════════════════════════════════════════
    
    COMO CONFIRMAR O PROBLEMA:
    
    ✅ Query 2: Verificar se RLS está ATIVO
    ✅ Query 4: Verificar se política usa "usuario_id"
    ✅ Query 5: Confirmar que coluna é "usuario_id" (não "user_id")
    ✅ Query 6: Ver quantos usuários têm caixas
    ✅ Query 8: Ver se você está vendo caixas de outros
    
    ═══════════════════════════════════════════════════════
    
    O QUE DEVE ESTAR CORRETO:
    
    ✅ RLS ATIVO na tabela caixa
    ✅ Política: auth.uid() = usuario_id
    ✅ Coluna: usuario_id (não user_id)
    ✅ Query 8: Deve mostrar APENAS seus caixas
    
    ═══════════════════════════════════════════════════════
    ' as diagnostico;

-- 10. VERIFICAR POLÍTICAS DE OUTRAS TABELAS RELACIONADAS
SELECT 
    '🔗 POLÍTICAS DE TABELAS RELACIONADAS' as secao,
    tablename,
    COUNT(*) as total_politicas,
    STRING_AGG(policyname, ', ') as nomes_politicas
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN (
    'caixa',
    'movimentacoes_caixa',
    'vendas',
    'produtos',
    'clientes',
    'configuracoes_impressao'
)
GROUP BY tablename
ORDER BY tablename;

-- 11. RESUMO EXECUTIVO
SELECT 
    '🎯 RESUMO EXECUTIVO' as titulo,
    '
    ═══════════════════════════════════════════════════════
    VERIFICAÇÕES CONCLUÍDAS
    ═══════════════════════════════════════════════════════
    
    ✅ Query 1: Listar os 5 usuários
    ✅ Query 2: Status RLS da tabela caixa
    ✅ Query 3: Lista de políticas ativas
    ✅ Query 4: Condições exatas das políticas (MAIS IMPORTANTE)
    ✅ Query 5: Verificar nome da coluna (usuario_id ou user_id)
    ✅ Query 6: Distribuição de caixas por usuário
    ✅ Query 7: Caixas órfãos
    ✅ Query 8: Caixas visíveis para você (teste de vazamento)
    
    ═══════════════════════════════════════════════════════
    PRÓXIMOS PASSOS:
    ═══════════════════════════════════════════════════════
    
    1. Analise o resultado da Query 4 (condições das políticas)
    2. Verifique a Query 8 - você está vendo caixas de outros?
    3. Se sim, há vazamento de dados
    4. Se não, o problema pode ser no código do frontend
    
    ⚠️ AGUARDAR RESULTADOS antes de fazer alterações
    
    ═══════════════════════════════════════════════════════
    ' as instrucoes;
