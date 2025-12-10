-- =============================================
-- VERIFICAR E CORRIGIR FUNÇÃO DE BACKUP AUTOMÁTICO
-- =============================================

-- Ver se a função existe
SELECT 
    '🔍 VERIFICANDO FUNÇÃO DE BACKUP' as secao;

SELECT 
    proname as nome_funcao,
    pg_get_functiondef(oid) as definicao
FROM pg_proc
WHERE proname = 'criar_backup_automatico_diario';

-- Ver permissões da função
SELECT 
    '🔐 PERMISSÕES DA FUNÇÃO' as secao;

SELECT 
    proname,
    proacl
FROM pg_proc
WHERE proname = 'criar_backup_automatico_diario';

-- Verificar se a função está acessível via RPC
SELECT 
    '🌐 TESTE DE EXECUÇÃO' as secao;

-- Tentar executar a função (isso irá criar um backup de teste)
SELECT criar_backup_automatico_diario();

-- Ver último backup criado
SELECT 
    '📦 ÚLTIMO BACKUP CRIADO' as secao;

SELECT 
    id,
    empresa_id,
    tipo,
    status,
    descricao,
    total_clientes,
    total_produtos,
    total_vendas,
    tamanho_bytes,
    created_at
FROM public.backups
ORDER BY created_at DESC
LIMIT 1;
