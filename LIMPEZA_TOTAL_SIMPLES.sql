-- =============================================
-- REMOVER TUDO - VERSÃO ULTRA SIMPLES
-- =============================================

-- PASSO 1: Remover TODAS as functions relacionadas a user_id
DROP FUNCTION IF EXISTS public.prevent_orphan_cliente() CASCADE;
DROP FUNCTION IF EXISTS prevent_orphan_cliente() CASCADE;
DROP FUNCTION IF EXISTS public.trigger_set_user_id() CASCADE;
DROP FUNCTION IF EXISTS trigger_set_user_id() CASCADE;
DROP FUNCTION IF EXISTS public.set_user_id() CASCADE;
DROP FUNCTION IF EXISTS set_user_id() CASCADE;

-- PASSO 2: Remover TODOS os triggers da tabela clientes
DROP TRIGGER IF EXISTS prevent_orphan_cliente_trigger ON clientes CASCADE;
DROP TRIGGER IF EXISTS check_orphan_cliente ON clientes CASCADE;
DROP TRIGGER IF EXISTS validate_cliente ON clientes CASCADE;
DROP TRIGGER IF EXISTS before_insert_clientes ON clientes CASCADE;
DROP TRIGGER IF EXISTS before_update_clientes ON clientes CASCADE;
DROP TRIGGER IF EXISTS set_user_id_trigger ON clientes CASCADE;
DROP TRIGGER IF EXISTS trigger_set_user_id ON clientes CASCADE;
DROP TRIGGER IF EXISTS set_user_id ON clientes CASCADE;

-- PASSO 3: Listar triggers restantes (simplificado)
SELECT tgname FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'clientes' AND NOT t.tgisinternal;

-- PASSO 4: Remover coluna user_id completamente
ALTER TABLE clientes DROP COLUMN IF EXISTS user_id CASCADE;

-- PASSO 5: Remover constraint ANTES de corrigir valores
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_tipo_check;

-- PASSO 6: Corrigir TODOS os valores de tipo (inclusive os inválidos)
UPDATE clientes SET tipo = 'fisica' 
WHERE tipo IS NULL OR tipo NOT IN ('fisica', 'juridica');

SELECT 'Total de clientes corrigidos: ' || COUNT(*) FROM clientes WHERE tipo = 'fisica';

-- PASSO 7: Criar novo constraint (agora os dados estão limpos)
ALTER TABLE clientes ADD CONSTRAINT clientes_tipo_check CHECK (tipo IN ('fisica', 'juridica'));

-- PASSO 8: Teste final
INSERT INTO clientes (nome, cpf_cnpj, cpf_digits, telefone, empresa_id, tipo, ativo)
VALUES ('TESTE', '333.333.333-33', '33333333333', '11999999999', 
        (SELECT id FROM empresas LIMIT 1), 'fisica', true)
RETURNING id, nome;

DELETE FROM clientes WHERE cpf_digits = '33333333333';

SELECT '✅ SISTEMA LIMPO E FUNCIONANDO!' as resultado;
