-- 🔧 CORRIGIR CNPJ DO SUPER ADMIN

-- Atualizar CNPJ da conta Super Admin
UPDATE empresas
SET cnpj = '55306730000107'
WHERE email = 'novaradiosystem@outlook.com'
AND is_super_admin = true;

-- Verificar resultado
SELECT 
  '✅ CNPJ ATUALIZADO' as status,
  nome,
  email,
  cnpj,
  tipo_conta,
  is_super_admin
FROM empresas
WHERE is_super_admin = true;
