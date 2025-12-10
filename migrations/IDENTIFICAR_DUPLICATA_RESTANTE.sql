-- 🔍 IDENTIFICAR A EMPRESA DUPLICADA RESTANTE

-- Ver qual empresa ainda está duplicada
SELECT 
  '⚠️ EMPRESA DUPLICADA' as problema,
  nome,
  COUNT(*) as total_duplicatas,
  STRING_AGG(id::text, ', ') as ids,
  STRING_AGG(email, ', ') as emails,
  STRING_AGG(tipo_conta, ', ') as tipos_conta
FROM empresas
GROUP BY nome
HAVING COUNT(*) > 1;

-- Ver detalhes completos das duplicatas
SELECT 
  '📋 DETALHES DAS DUPLICATAS' as info,
  e.id,
  e.nome,
  e.email,
  e.cnpj,
  e.tipo_conta,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
WHERE e.nome IN (
  SELECT nome 
  FROM empresas 
  GROUP BY nome 
  HAVING COUNT(*) > 1
)
GROUP BY e.id, e.nome, e.email, e.cnpj, e.tipo_conta
ORDER BY e.nome, e.tipo_conta DESC, admins DESC;
