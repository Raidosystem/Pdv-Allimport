-- 🎯 CRIAR SISTEMA DE FUNÇÕES - VERSÃO CORRIGIDA

-- 1. Criar tabela funcoes
CREATE TABLE IF NOT EXISTS funcoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  ativo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(empresa_id, nome)
);

-- 2. Adicionar coluna funcao_id em funcionarios
ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS funcao_id UUID REFERENCES funcoes(id) ON DELETE SET NULL;

-- 3. Criar índices
CREATE INDEX IF NOT EXISTS idx_funcoes_empresa_id ON funcoes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_funcao_id ON funcionarios(funcao_id);

-- 4. Habilitar RLS
ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;

-- 5. Remover políticas antigas se existirem
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes;

-- 6. Criar políticas RLS
CREATE POLICY "funcoes_select_policy"
ON funcoes FOR SELECT TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() LIMIT 1)
);

CREATE POLICY "funcoes_insert_policy"
ON funcoes FOR INSERT TO authenticated
WITH CHECK (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
);

CREATE POLICY "funcoes_update_policy"
ON funcoes FOR UPDATE TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
)
WITH CHECK (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
);

CREATE POLICY "funcoes_delete_policy"
ON funcoes FOR DELETE TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
);

-- 7. Inserir funções padrão (SEM coluna permissoes)
INSERT INTO funcoes (empresa_id, nome, descricao)
SELECT e.id, 'Vendedor', 'Pode realizar vendas e atender clientes'
FROM empresas e
WHERE NOT EXISTS (SELECT 1 FROM funcoes f WHERE f.empresa_id = e.id AND f.nome = 'Vendedor');

INSERT INTO funcoes (empresa_id, nome, descricao)
SELECT e.id, 'Caixa', 'Pode operar o caixa, abrir e fechar'
FROM empresas e
WHERE NOT EXISTS (SELECT 1 FROM funcoes f WHERE f.empresa_id = e.id AND f.nome = 'Caixa');

INSERT INTO funcoes (empresa_id, nome, descricao)
SELECT e.id, 'Gerente', 'Pode gerenciar funcionários, estoque e vendas'
FROM empresas e
WHERE NOT EXISTS (SELECT 1 FROM funcoes f WHERE f.empresa_id = e.id AND f.nome = 'Gerente');

INSERT INTO funcoes (empresa_id, nome, descricao)
SELECT e.id, 'Técnico', 'Pode criar e gerenciar ordens de serviço'
FROM empresas e
WHERE NOT EXISTS (SELECT 1 FROM funcoes f WHERE f.empresa_id = e.id AND f.nome = 'Técnico');

-- 8. Verificar funções criadas
SELECT 
  '✅ FUNÇÕES CRIADAS' as status,
  e.nome as empresa,
  f.nome as funcao,
  f.descricao
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
ORDER BY e.nome, f.nome;

-- 9. Verificar coluna funcao_id
SELECT 
  '✅ COLUNA ADICIONADA' as status,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'funcionarios' AND column_name = 'funcao_id';

-- 10. Resumo
SELECT 
  '📊 COMPLETO' as titulo,
  COUNT(*) as total_funcoes_criadas
FROM funcoes;
