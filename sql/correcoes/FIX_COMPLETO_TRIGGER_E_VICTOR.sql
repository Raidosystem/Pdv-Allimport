-- =============================================
-- CORREÇÃO COMPLETA: Trigger + Victor existente
-- =============================================

-- 1️⃣ CORRIGIR VICTOR (já criado mas com flags erradas)
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  primeiro_acesso = TRUE
WHERE nome = 'Victor'
  AND usuario_ativo = FALSE
  AND senha_definida = FALSE;

SELECT '✅ Victor corrigido!' as passo_1;

-- 2️⃣ VERIFICAR VICTOR APÓS CORREÇÃO
SELECT 
  '✅ VICTOR APÓS CORREÇÃO' as info,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status
FROM funcionarios
WHERE nome = 'Victor';

-- 3️⃣ REMOVER TRIGGER ANTIGO
DROP TRIGGER IF EXISTS trigger_auto_criar_login ON funcionarios;

-- 4️⃣ RECRIAR FUNÇÃO (corrigida com UPDATE nas flags)
CREATE OR REPLACE FUNCTION auto_criar_login_funcionario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_usuario TEXT;
  v_usuario_base TEXT;
  v_contador INTEGER := 1;
  v_usuario_existe BOOLEAN;
  v_senha_padrao TEXT := '123456';
BEGIN
  -- Gerar username base (remove espaços e caracteres especiais)
  v_usuario_base := lower(regexp_replace(NEW.nome, '[^a-zA-Z0-9]', '', 'g'));
  v_usuario := v_usuario_base;
  
  -- Verificar se usuário já existe e incrementar se necessário
  LOOP
    SELECT EXISTS (
      SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario
    ) INTO v_usuario_existe;
    
    IF NOT v_usuario_existe THEN
      EXIT;
    END IF;
    
    v_usuario := v_usuario_base || v_contador::TEXT;
    v_contador := v_contador + 1;
  END LOOP;
  
  -- ✅ Criar o login
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha_hash,
    senha,
    ativo,
    precisa_trocar_senha,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    v_usuario,
    crypt(v_senha_padrao, gen_salt('bf')),
    crypt(v_senha_padrao, gen_salt('bf')),
    TRUE,
    TRUE,
    NOW(),
    NOW()
  )
  ON CONFLICT (funcionario_id) DO UPDATE
  SET 
    usuario = EXCLUDED.usuario,
    ativo = TRUE,
    updated_at = NOW();
  
  -- ✅ ATUALIZAR flags na tabela funcionarios para aparecer no login
  UPDATE funcionarios
  SET 
    usuario_ativo = TRUE,
    senha_definida = TRUE,
    primeiro_acesso = TRUE
  WHERE id = NEW.id;
  
  RAISE NOTICE '✅ Login automático criado para: % (usuario: %)', NEW.nome, v_usuario;
  
  RETURN NEW;
END;
$$;

-- 5️⃣ CRIAR TRIGGER CORRETO
CREATE TRIGGER trigger_auto_criar_login
  AFTER INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_criar_login_funcionario();

-- 6️⃣ VERIFICAR TRIGGER
SELECT 
  '✅ TRIGGER CONFIGURADO' as info,
  tgname as trigger_name,
  tgenabled as enabled,
  CASE tgenabled
    WHEN 'O' THEN '✅ ATIVO'
    WHEN 'D' THEN '❌ DESABILITADO'
    WHEN 'R' THEN '⚠️ REPLICA ONLY'
    WHEN 'A' THEN '⚠️ ALWAYS'
  END as status,
  CASE 
    WHEN tgtype & 2 = 2 THEN 'BEFORE'
    WHEN tgtype & 4 = 4 THEN 'INSTEAD OF'
    ELSE 'AFTER'
  END as timing
FROM pg_trigger
WHERE tgrelid = 'funcionarios'::regclass
AND tgname = 'trigger_auto_criar_login';

-- 7️⃣ VERIFICAR SE VICTOR APARECE NA RPC
SELECT 
  '✅ TESTANDO RPC listar_usuarios_ativos' as info,
  id,
  nome,
  usuario,
  senha_definida,
  primeiro_acesso
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE nome = 'Victor' LIMIT 1)
)
WHERE nome = 'Victor';

SELECT '🎉 Correção completa! Victor deve aparecer no login agora.' as resultado;

-- =============================================
-- 📝 RESUMO DO PROBLEMA
-- =============================================
/*
PROBLEMA:
- Trigger criava login_funcionarios OK ✅
- MAS não atualizava flags em funcionarios ❌
- RPC listar_usuarios_ativos filtra por senha_definida = TRUE
- Victor tinha senha_definida = FALSE
- Resultado: Victor não aparecia no login

SOLUÇÃO:
1. Corrigir Victor existente (UPDATE manual)
2. Adicionar UPDATE no trigger para flags
3. Próximos funcionários já virão com flags corretas
*/
