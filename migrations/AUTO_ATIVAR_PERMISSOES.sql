-- ============================================
-- AUTO-ATIVAR PERMISSÕES AO CRIAR FUNCIONÁRIOS
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR ESTRUTURA ATUAL DA TABELA
-- ============================================
SELECT 
  column_name,
  data_type,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- ============================================
-- 2️⃣ DEFINIR VALORES PADRÃO PARA PERMISSÕES
-- ============================================

-- Garantir que pode_visualizar seja TRUE por padrão para todas as permissões existentes
UPDATE funcao_permissoes
SET pode_visualizar = COALESCE(pode_visualizar, true)
WHERE pode_visualizar IS NULL OR pode_visualizar = false;

-- Garantir que pode_criar seja FALSE por padrão (segurança)
UPDATE funcao_permissoes
SET pode_criar = COALESCE(pode_criar, false)
WHERE pode_criar IS NULL;

-- Garantir que pode_editar seja FALSE por padrão (segurança)
UPDATE funcao_permissoes
SET pode_editar = COALESCE(pode_editar, false)
WHERE pode_editar IS NULL;

-- Garantir que pode_excluir seja FALSE por padrão (segurança)
UPDATE funcao_permissoes
SET pode_excluir = COALESCE(pode_excluir, false)
WHERE pode_excluir IS NULL;

-- ============================================
-- 3️⃣ VERIFICAR PERMISSÕES POR FUNÇÃO
-- ============================================
SELECT 
  fn.nome as funcao,
  COUNT(*) as total_permissoes,
  COUNT(CASE WHEN fp.pode_visualizar = true THEN 1 END) as pode_ver,
  COUNT(CASE WHEN fp.pode_criar = true THEN 1 END) as pode_criar,
  COUNT(CASE WHEN fp.pode_editar = true THEN 1 END) as pode_editar,
  COUNT(CASE WHEN fp.pode_excluir = true THEN 1 END) as pode_excluir
FROM funcoes fn
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = fn.id
GROUP BY fn.id, fn.nome
ORDER BY fn.nome;

-- ============================================
-- 4️⃣ DEFINIR VALORES PADRÃO PARA NOVOS REGISTROS
-- ============================================

-- Alterar a coluna 'pode_visualizar' para ter valor padrão TRUE
ALTER TABLE funcao_permissoes 
ALTER COLUMN pode_visualizar SET DEFAULT true;

-- Alterar a coluna 'pode_criar' para ter valor padrão FALSE (apenas se necessário)
ALTER TABLE funcao_permissoes 
ALTER COLUMN pode_criar SET DEFAULT false;

-- Alterar a coluna 'pode_editar' para ter valor padrão FALSE (apenas se necessário)
ALTER TABLE funcao_permissoes 
ALTER COLUMN pode_editar SET DEFAULT false;

-- Alterar a coluna 'pode_excluir' para ter valor padrão FALSE
ALTER TABLE funcao_permissoes 
ALTER COLUMN pode_excluir SET DEFAULT false;

-- ============================================
-- 4️⃣ CRIAR TRIGGER PARA AUTO-ATIVAR
-- ============================================

-- Função que garante que permissões sempre venham ativas por padrão
CREATE OR REPLACE FUNCTION auto_ativar_permissao()
RETURNS TRIGGER AS $$
BEGIN
  -- Se ativo não foi especificado, define como true
  IF NEW.ativo IS NULL THEN
    NEW.ativo := true;
  END IF;
  
  -- Se pode_visualizar não foi especificado, define como true
  IF NEW.pode_visualizar IS NULL THEN
    NEW.pode_visualizar := true;
  END IF;
  
  -- Se pode_criar não foi especificado, define como false (por segurança)
  IF NEW.pode_criar IS NULL THEN
    NEW.pode_criar := false;
  END IF;
  
  -- Se pode_editar não foi especificado, define como false (por segurança)
  IF NEW.pode_editar IS NULL THEN
    NEW.pode_editar := false;
  END IF;
  
  -- Se pode_excluir não foi especificado, define como false (por segurança)
  IF NEW.pode_excluir IS NULL THEN
    NEW.pode_excluir := false;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger BEFORE INSERT
DROP TRIGGER IF EXISTS trigger_auto_ativar_permissao ON funcao_permissoes;

CREATE TRIGGER trigger_auto_ativar_permissao
  BEFORE INSERT ON funcao_permissoes
  FOR EACH ROW
  EXECUTE FUNCTION auto_ativar_permissao();

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Ver todas as permissões com seus status
SELECT 
  fn.nome as funcao,
  p.modulo,
  p.recurso,
  p.acao,
  fp.ativo,
  fp.pode_visualizar,
  fp.pode_criar,
  fp.pode_editar,
  fp.pode_excluir
FROM funcao_permissoes fp
JOIN funcoes fn ON fp.funcao_id = fn.id
JOIN permissoes p ON fp.permissao_id = p.id
ORDER BY fn.nome, p.modulo, p.recurso, p.acao;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- 1. Todas as permissões existentes ficam ativas
-- 2. Novas permissões virão ativas por padrão
-- 3. Trigger garante ativação automática
-- 4. Sistema pronto para criar funcionários com permissões ativas
