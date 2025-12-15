-- 🎛️ ADICIONAR CONTROLE DE MÓDULOS POR EMPRESA
-- Permite ocultar seções (como Ordens de Serviço) sem quebrar código ou dados

-- 1. Adicionar coluna para controle de módulos
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS modulos_habilitados JSONB 
DEFAULT '{"ordens_servico": true, "vendas": true, "estoque": true, "relatorios": true}'::jsonb;

-- 2. Atualizar empresas existentes com valores padrão (todos habilitados)
UPDATE empresas 
SET modulos_habilitados = '{"ordens_servico": true, "vendas": true, "estoque": true, "relatorios": true}'::jsonb
WHERE modulos_habilitados IS NULL;

-- 3. Verificar coluna criada
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'empresas'
AND column_name = 'modulos_habilitados';

-- 4. Testar: Ver configuração de módulos das empresas
SELECT 
    id,
    nome,
    modulos_habilitados,
    modulos_habilitados->>'ordens_servico' as os_habilitado,
    modulos_habilitados->>'vendas' as vendas_habilitado
FROM empresas
LIMIT 5;

-- 5. Exemplo: Desabilitar Ordens de Serviço para uma empresa específica
-- UPDATE empresas 
-- SET modulos_habilitados = jsonb_set(
--     modulos_habilitados, 
--     '{ordens_servico}', 
--     'false'::jsonb
-- )
-- WHERE id = 'UUID_DA_EMPRESA';

-- 6. Exemplo: Reabilitar Ordens de Serviço
-- UPDATE empresas 
-- SET modulos_habilitados = jsonb_set(
--     modulos_habilitados, 
--     '{ordens_servico}', 
--     'true'::jsonb
-- )
-- WHERE id = 'UUID_DA_EMPRESA';
