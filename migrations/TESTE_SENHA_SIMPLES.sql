-- Teste super simples para encontrar o problema

-- 1. Testar crypt diretamente
SELECT 
  'Teste 1: crypt direto' as teste,
  crypt('senha123', gen_salt('bf')) as resultado,
  CASE 
    WHEN crypt('senha123', gen_salt('bf')) IS NULL THEN '❌ RETORNA NULL'
    ELSE '✅ OK'
  END as status;

-- 2. Testar dentro de uma função
CREATE OR REPLACE FUNCTION teste_insert_senha()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_senha_hash text;
  v_funcionario_id uuid := gen_random_uuid();
BEGIN
  -- Gerar hash
  v_senha_hash := crypt('senha123', gen_salt('bf'));
  
  -- Verificar se é NULL
  IF v_senha_hash IS NULL THEN
    RETURN '❌ Hash é NULL';
  END IF;
  
  -- Tentar inserir
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha,
    ativo
  ) VALUES (
    v_funcionario_id,
    'teste_' || floor(random() * 10000)::text,
    v_senha_hash,
    true
  );
  
  RETURN '✅ INSERT funcionou! Hash: ' || left(v_senha_hash, 20) || '...';
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN '❌ Erro: ' || SQLERRM;
END;
$$;

-- Executar teste
SELECT teste_insert_senha();

-- 3. Limpar teste
DELETE FROM login_funcionarios WHERE usuario LIKE 'teste_%';
