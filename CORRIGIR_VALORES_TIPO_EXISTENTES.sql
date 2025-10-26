-- =============================================
-- CORRIGIR VALORES DE TIPO + CONSTRAINT
-- =============================================

-- PASSO 1: Ver quais valores de 'tipo' existem atualmente
SELECT 
    tipo,
    COUNT(*) as total
FROM clientes
GROUP BY tipo
ORDER BY total DESC;

-- PASSO 2: Atualizar valores nulos ou inválidos para 'fisica'
UPDATE clientes 
SET tipo = 'fisica' 
WHERE tipo IS NULL OR tipo NOT IN ('fisica', 'juridica');

SELECT '✅ Valores de tipo corrigidos!' as status;

-- PASSO 3: Remover constraint antigo
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_tipo_check;

-- PASSO 4: Criar novo constraint
ALTER TABLE clientes 
ADD CONSTRAINT clientes_tipo_check 
CHECK (tipo IN ('fisica', 'juridica'));

SELECT '✅ Constraint criado com sucesso!' as status;

-- PASSO 5: Verificar resultado
SELECT 
    tipo,
    COUNT(*) as total
FROM clientes
GROUP BY tipo;

-- PASSO 6: Testar inserção
INSERT INTO clientes (
    nome,
    cpf_cnpj,
    cpf_digits,
    telefone,
    empresa_id,
    tipo,
    ativo
) VALUES (
    'TESTE FINAL',
    '111.111.111-11',
    '11111111111',
    '11999999999',
    (SELECT id FROM empresas LIMIT 1),
    'fisica',
    true
) RETURNING id, nome;

-- PASSO 7: Limpar teste
DELETE FROM clientes WHERE nome = 'TESTE FINAL';

SELECT '🎉 TUDO FUNCIONANDO PERFEITAMENTE!' as resultado;
