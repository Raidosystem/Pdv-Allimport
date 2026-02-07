-- 🔧 ATUALIZAR empresas existentes com dados do cadastro (auth.users)
-- Este SQL preenche os dados de empresas que já existem mas estão vazias

-- 0. Primeiro, ver quais colunas existem na tabela
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'empresas' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 1. Adicionar coluna endereco se não existir
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS endereco text;

-- 2. Ver o estado atual
SELECT 
  e.id,
  e.user_id,
  e.nome as nome_atual,
  e.cnpj as cnpj_atual,
  e.telefone as tel_atual,
  au.email,
  au.raw_user_meta_data->>'fullName' as nome_cadastro,
  au.raw_user_meta_data->>'companyName' as empresa_cadastro,
  au.raw_user_meta_data->>'document' as doc_cadastro,
  au.raw_user_meta_data->>'whatsapp' as whatsapp_cadastro,
  au.raw_user_meta_data->>'city' as cidade_cadastro,
  au.raw_user_meta_data->>'state' as estado_cadastro
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
ORDER BY e.created_at DESC;

-- 3. ATUALIZAR empresas com dados do cadastro (só atualiza campos vazios/nulos)
UPDATE empresas e
SET 
  nome = COALESCE(
    NULLIF(e.nome, ''),
    au.raw_user_meta_data->>'companyName',
    au.raw_user_meta_data->>'fullName',
    e.nome
  ),
  cnpj = COALESCE(
    NULLIF(e.cnpj, ''),
    au.raw_user_meta_data->>'document',
    e.cnpj
  ),
  telefone = COALESCE(
    NULLIF(e.telefone, ''),
    au.raw_user_meta_data->>'whatsapp',
    e.telefone
  ),
  email = COALESCE(
    NULLIF(e.email, ''),
    au.email,
    e.email
  ),
  cidade = COALESCE(
    NULLIF(e.cidade, ''),
    au.raw_user_meta_data->>'city',
    e.cidade
  ),
  estado = COALESCE(
    NULLIF(e.estado, ''),
    au.raw_user_meta_data->>'state',
    e.estado
  ),
  cep = COALESCE(
    NULLIF(e.cep, ''),
    au.raw_user_meta_data->>'cep',
    e.cep
  ),
  endereco = COALESCE(
    NULLIF(e.endereco, ''),
    CASE 
      WHEN au.raw_user_meta_data->>'street' IS NOT NULL THEN
        CONCAT(
          au.raw_user_meta_data->>'street',
          CASE WHEN au.raw_user_meta_data->>'number' IS NOT NULL 
            THEN ', ' || (au.raw_user_meta_data->>'number')
            ELSE '' END,
          CASE WHEN au.raw_user_meta_data->>'neighborhood' IS NOT NULL 
            THEN ' - ' || (au.raw_user_meta_data->>'neighborhood')
            ELSE '' END
        )
      ELSE e.endereco
    END
  ),
  updated_at = NOW()
FROM auth.users au
WHERE au.id = e.user_id
  AND au.raw_user_meta_data IS NOT NULL
  AND (
    e.nome IS NULL OR e.nome = '' OR
    e.cnpj IS NULL OR e.cnpj = '' OR
    e.telefone IS NULL OR e.telefone = '' OR
    e.email IS NULL OR e.email = ''
  );

-- 4. Para usuários que NÃO TÊM registro em empresas, INSERIR
INSERT INTO empresas (user_id, nome, cnpj, telefone, email, cidade, estado, cep, endereco, created_at, updated_at)
SELECT 
  au.id as user_id,
  COALESCE(au.raw_user_meta_data->>'companyName', au.raw_user_meta_data->>'fullName', 'Minha Empresa') as nome,
  au.raw_user_meta_data->>'document' as cnpj,
  au.raw_user_meta_data->>'whatsapp' as telefone,
  au.email,
  au.raw_user_meta_data->>'city' as cidade,
  au.raw_user_meta_data->>'state' as estado,
  au.raw_user_meta_data->>'cep' as cep,
  CASE 
    WHEN au.raw_user_meta_data->>'street' IS NOT NULL THEN
      CONCAT(
        au.raw_user_meta_data->>'street',
        CASE WHEN au.raw_user_meta_data->>'number' IS NOT NULL 
          THEN ', ' || (au.raw_user_meta_data->>'number')
          ELSE '' END,
        CASE WHEN au.raw_user_meta_data->>'neighborhood' IS NOT NULL 
          THEN ' - ' || (au.raw_user_meta_data->>'neighborhood')
          ELSE '' END
      )
    ELSE NULL
  END as endereco,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
WHERE e.id IS NULL
  AND au.raw_user_meta_data IS NOT NULL;

-- 5. Verificar resultado final
SELECT 
  '✅ RESULTADO FINAL' as info,
  e.id,
  e.nome,
  e.cnpj,
  e.telefone,
  e.email,
  e.cidade,
  e.estado,
  e.endereco,
  au.email as email_auth
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
ORDER BY e.updated_at DESC;
