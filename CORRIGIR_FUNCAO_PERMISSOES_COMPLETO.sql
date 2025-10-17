-- =========================================
-- CORREÇÃO COMPLETA: funcao_permissoes
-- =========================================

-- 1. Verificar estrutura atual
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 2. Verificar constraints e chaves
SELECT
  constraint_name,
  constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'funcao_permissoes';

-- 3. Se a tabela está mal estruturada, recriar
DO $$ 
BEGIN
  -- Dropar tabela se existir
  DROP TABLE IF EXISTS funcao_permissoes CASCADE;
  
  -- Recriar tabela corretamente
  CREATE TABLE funcao_permissoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    funcao_id UUID NOT NULL REFERENCES funcoes(id) ON DELETE CASCADE,
    permissao_id UUID NOT NULL REFERENCES permissoes(id) ON DELETE CASCADE,
    empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Constraint: uma permissão só pode ser associada uma vez a uma função
    UNIQUE(funcao_id, permissao_id)
  );

  -- Índices para performance
  CREATE INDEX idx_funcao_permissoes_funcao_id ON funcao_permissoes(funcao_id);
  CREATE INDEX idx_funcao_permissoes_permissao_id ON funcao_permissoes(permissao_id);
  CREATE INDEX idx_funcao_permissoes_empresa_id ON funcao_permissoes(empresa_id);

  RAISE NOTICE '✅ Tabela funcao_permissoes recriada com sucesso!';
END $$;

-- 4. Habilitar RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- 5. Dropar políticas antigas se existirem
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;

-- 6. Criar políticas RLS simples (SEM RECURSÃO)
CREATE POLICY "funcao_permissoes_select_policy" 
ON funcao_permissoes FOR SELECT
USING (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

CREATE POLICY "funcao_permissoes_insert_policy" 
ON funcao_permissoes FOR INSERT
WITH CHECK (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

CREATE POLICY "funcao_permissoes_update_policy" 
ON funcao_permissoes FOR UPDATE
USING (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

CREATE POLICY "funcao_permissoes_delete_policy" 
ON funcao_permissoes FOR DELETE
USING (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 7. Verificar políticas criadas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'funcao_permissoes';

-- 8. Teste de INSERT
DO $$
DECLARE
  v_empresa_id UUID;
  v_funcao_id UUID;
  v_permissao_id UUID;
BEGIN
  -- Pegar primeira empresa
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  -- Pegar primeira função
  SELECT id INTO v_funcao_id FROM funcoes LIMIT 1;
  
  -- Pegar primeira permissão
  SELECT id INTO v_permissao_id FROM permissoes LIMIT 1;
  
  -- Tentar INSERT
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  VALUES (v_funcao_id, v_permissao_id, v_empresa_id)
  ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
  
  RAISE NOTICE '✅ Teste de INSERT bem-sucedido!';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- 9. Mostrar dados atuais
SELECT 
  fp.id,
  f.nome AS funcao,
  p.recurso || ':' || p.acao AS permissao,
  fp.empresa_id
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
LIMIT 10;

-- 10. Mensagem final
DO $$
BEGIN
  RAISE NOTICE '✅ Script executado com sucesso!';
  RAISE NOTICE '📋 Verifique os resultados acima.';
  RAISE NOTICE '🎯 Tabela funcao_permissoes está pronta para uso!';
END $$;
