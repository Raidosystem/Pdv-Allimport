-- ========================================
-- CORREÇÃO: Adicionar empresa_id automaticamente
-- ========================================
-- Este script adiciona empresa_id aos registros existentes em funcionario_funcoes

-- 1. ATUALIZAR registros existentes sem empresa_id
UPDATE funcionario_funcoes ff
SET empresa_id = f.empresa_id
FROM funcionarios f
WHERE ff.funcionario_id = f.id
AND ff.empresa_id IS NULL;

-- 2. VERIFICAR se ainda há registros sem empresa_id
SELECT 
  ff.funcionario_id,
  ff.funcao_id,
  ff.empresa_id,
  f.nome as funcionario,
  f.empresa_id as empresa_do_funcionario
FROM funcionario_funcoes ff
LEFT JOIN funcionarios f ON ff.funcionario_id = f.id
WHERE ff.empresa_id IS NULL;

-- 3. (OPCIONAL) Criar trigger para adicionar empresa_id automaticamente
CREATE OR REPLACE FUNCTION auto_add_empresa_id()
RETURNS TRIGGER AS $$
BEGIN
  -- Se empresa_id não foi fornecido, buscar do funcionário
  IF NEW.empresa_id IS NULL THEN
    SELECT empresa_id INTO NEW.empresa_id
    FROM funcionarios
    WHERE id = NEW.funcionario_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger (se não existir)
DROP TRIGGER IF EXISTS trigger_auto_empresa_id ON funcionario_funcoes;

CREATE TRIGGER trigger_auto_empresa_id
  BEFORE INSERT OR UPDATE ON funcionario_funcoes
  FOR EACH ROW
  EXECUTE FUNCTION auto_add_empresa_id();

-- 4. TESTE: Verificar se o trigger funciona
-- (Comente as linhas abaixo após o teste)
/*
INSERT INTO funcionario_funcoes (funcionario_id, funcao_id)
SELECT 
  (SELECT id FROM funcionarios LIMIT 1),
  (SELECT id FROM funcoes LIMIT 1)
WHERE EXISTS (SELECT 1 FROM funcionarios LIMIT 1)
AND EXISTS (SELECT 1 FROM funcoes LIMIT 1);

-- Verificar se empresa_id foi adicionado automaticamente
SELECT * FROM funcionario_funcoes ORDER BY created_at DESC LIMIT 1;

-- Deletar registro de teste (usando funcionario_id e funcao_id como chave)
DELETE FROM funcionario_funcoes 
WHERE funcionario_id = (SELECT funcionario_id FROM funcionario_funcoes ORDER BY created_at DESC LIMIT 1)
AND funcao_id = (SELECT funcao_id FROM funcionario_funcoes ORDER BY created_at DESC LIMIT 1);
*/

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Todos os registros existentes agora têm empresa_id
-- ✅ Novos registros receberão empresa_id automaticamente
-- ✅ O erro "null value in column empresa_id" não acontecerá mais
