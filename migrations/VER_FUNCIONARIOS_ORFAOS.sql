-- 🔍 VER FUNCIONÁRIOS ÓRFÃOS (sem empresa)

-- Ver quem são os 9 funcionários sem empresa
SELECT 
  '⚠️ FUNCIONÁRIOS ÓRFÃOS (sem empresa)' as problema,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id as empresa_id_invalido
FROM funcionarios f
WHERE NOT EXISTS (
  SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
)
ORDER BY f.nome;

-- Ver quantos logins esses órfãos têm
SELECT 
  '🔑 Logins de órfãos' as tipo,
  COUNT(*) as total_logins
FROM login_funcionarios lf
WHERE lf.funcionario_id IN (
  SELECT f.id FROM funcionarios f
  WHERE NOT EXISTS (
    SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
  )
);
