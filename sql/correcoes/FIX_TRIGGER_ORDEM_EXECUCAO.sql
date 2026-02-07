-- =============================================
-- FIX: Trigger executando antes do INSERT
-- =============================================
-- Erro: "violates foreign key constraint login_funcionarios_funcionario_id_fkey"
-- Causa: Trigger BEFORE INSERT tenta criar login ANTES do funcionário existir
-- Solução: Mudar para AFTER INSERT
-- =============================================

-- 1️⃣ REMOVER TRIGGER ANTIGO
DROP TRIGGER IF EXISTS trigger_auto_criar_login ON funcionarios;

-- 2️⃣ RECRIAR FUNÇÃO (corrigida para AFTER INSERT)
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
  
  -- ✅ AGORA o funcionário já existe em funcionarios, pode criar o login
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
    NEW.id,  -- ✅ Este ID já existe porque trigger é AFTER INSERT
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

-- 3️⃣ CRIAR TRIGGER CORRETO (AFTER INSERT em vez de BEFORE)
CREATE TRIGGER trigger_auto_criar_login
  AFTER INSERT ON funcionarios  -- ✅ AFTER garante que funcionario.id já existe
  FOR EACH ROW
  EXECUTE FUNCTION auto_criar_login_funcionario();

-- 4️⃣ VERIFICAR SE TRIGGER FOI CRIADO
SELECT 
  '✅ TRIGGER CONFIGURADO' as info,
  tgname as trigger_name,
  tgtype as trigger_type,
  CASE 
    WHEN tgtype & 2 = 2 THEN 'BEFORE'
    WHEN tgtype & 4 = 4 THEN 'INSTEAD OF'
    ELSE 'AFTER'
  END as timing,
  CASE 
    WHEN tgtype & 16 = 16 THEN 'INSERT'
    WHEN tgtype & 32 = 32 THEN 'DELETE'
    WHEN tgtype & 64 = 64 THEN 'UPDATE'
  END as event
FROM pg_trigger
WHERE tgrelid = 'funcionarios'::regclass
AND tgname = 'trigger_auto_criar_login';

-- 5️⃣ COMENTÁRIO
COMMENT ON TRIGGER trigger_auto_criar_login ON funcionarios IS 
'Cria login automático APÓS inserção do funcionário (AFTER INSERT garante que FK existe)';

SELECT '🎉 Trigger corrigido! Agora funcionários podem ser criados sem erro de FK.' as resultado;

-- =============================================
-- 📝 EXPLICAÇÃO DO PROBLEMA
-- =============================================
/*
ANTES (ERRADO):
1. INSERT INTO funcionarios (...) 
2. BEFORE INSERT trigger dispara
3. Tenta INSERT INTO login_funcionarios (funcionario_id = NEW.id) ❌ ERRO: NEW.id ainda não existe!
4. Funcionário não é criado

DEPOIS (CORRETO):
1. INSERT INTO funcionarios (...)
2. Funcionário é criado com sucesso (id gerado)
3. AFTER INSERT trigger dispara
4. INSERT INTO login_funcionarios (funcionario_id = NEW.id) ✅ NEW.id já existe!
5. Login criado com sucesso
*/
