-- 🎯 CRIAR SISTEMA DE FUNÇÕES E PERMISSÕES

-- ✅ 1. Criar tabela de FUNÇÕES (cargos/posições)
CREATE TABLE IF NOT EXISTS funcoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  permissoes JSONB DEFAULT '[]'::jsonb, -- Array de IDs de permissões
  ativo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(empresa_id, nome)
);

-- ✅ 2. Adicionar coluna funcao_id na tabela funcionarios
ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS funcao_id UUID REFERENCES funcoes(id) ON DELETE SET NULL;

-- ✅ 3. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_funcoes_empresa_id ON funcoes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_funcao_id ON funcionarios(funcao_id);

-- ✅ 4. Habilitar RLS na tabela funcoes
ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;

-- ✅ 5. Criar políticas RLS para funcoes

-- SELECT: Ver funções da minha empresa
CREATE POLICY "funcoes_select_policy"
ON funcoes FOR SELECT TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() LIMIT 1)
);

-- INSERT: Criar funções na minha empresa (apenas admin)
CREATE POLICY "funcoes_insert_policy"
ON funcoes FOR INSERT TO authenticated
WITH CHECK (
  empresa_id = auth.uid()
  OR empresa_id = (
    SELECT empresa_id FROM funcionarios 
    WHERE user_id = auth.uid() 
    AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
    LIMIT 1
  )
);

-- UPDATE: Atualizar funções da minha empresa (apenas admin)
CREATE POLICY "funcoes_update_policy"
ON funcoes FOR UPDATE TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (
    SELECT empresa_id FROM funcionarios 
    WHERE user_id = auth.uid() 
    AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
    LIMIT 1
  )
)
WITH CHECK (
  empresa_id = auth.uid()
  OR empresa_id = (
    SELECT empresa_id FROM funcionarios 
    WHERE user_id = auth.uid() 
    AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
    LIMIT 1
  )
);

-- DELETE: Deletar funções da minha empresa (apenas admin)
CREATE POLICY "funcoes_delete_policy"
ON funcoes FOR DELETE TO authenticated
USING (
  empresa_id = auth.uid()
  OR empresa_id = (
    SELECT empresa_id FROM funcionarios 
    WHERE user_id = auth.uid() 
    AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
    LIMIT 1
  )
);

-- ✅ 6. Inserir funções padrão para cada empresa existente
INSERT INTO funcoes (empresa_id, nome, descricao, permissoes)
SELECT 
  e.id as empresa_id,
  'Vendedor',
  'Pode realizar vendas e atender clientes',
  '[]'::jsonb
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes f 
  WHERE f.empresa_id = e.id AND f.nome = 'Vendedor'
);

INSERT INTO funcoes (empresa_id, nome, descricao, permissoes)
SELECT 
  e.id as empresa_id,
  'Caixa',
  'Pode operar o caixa, abrir e fechar',
  '[]'::jsonb
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes f 
  WHERE f.empresa_id = e.id AND f.nome = 'Caixa'
);

INSERT INTO funcoes (empresa_id, nome, descricao, permissoes)
SELECT 
  e.id as empresa_id,
  'Gerente',
  'Pode gerenciar funcionários, estoque e vendas',
  '[]'::jsonb
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes f 
  WHERE f.empresa_id = e.id AND f.nome = 'Gerente'
);

INSERT INTO funcoes (empresa_id, nome, descricao, permissoes)
SELECT 
  e.id as empresa_id,
  'Técnico',
  'Pode criar e gerenciar ordens de serviço',
  '[]'::jsonb
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes f 
  WHERE f.empresa_id = e.id AND f.nome = 'Técnico'
);

-- ✅ 7. Verificar funções criadas
SELECT 
  '✅ FUNÇÕES CRIADAS' as status,
  e.nome as empresa,
  f.nome as funcao,
  f.descricao
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
ORDER BY e.nome, f.nome;

-- ✅ 8. Verificar estrutura da tabela funcionarios
SELECT 
  '✅ COLUNA funcao_id ADICIONADA' as status,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcionarios' AND column_name = 'funcao_id';

-- 📊 9. Resumo final
SELECT 
  '📊 SISTEMA DE FUNÇÕES INSTALADO' as titulo,
  COUNT(DISTINCT empresa_id) as total_empresas,
  COUNT(*) as total_funcoes
FROM funcoes;

SELECT 
  '🎯 PRÓXIMO PASSO' as titulo,
  'Recarregue o frontend e teste criar um funcionário' as acao,
  'Agora aparecerá o campo "Função" no formulário' as resultado;
