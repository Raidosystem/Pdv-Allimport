-- Corrigir o funcionário admin Cristiano Ramos
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true
WHERE id = '197904bb-6ec2-42ca-9127-0a43b9f99924';

-- Verificar a correção
SELECT 
  nome,
  email,
  status,
  ativo,
  usuario_ativo,
  senha_definida,
  funcao_id
FROM funcionarios
WHERE id = '197904bb-6ec2-42ca-9127-0a43b9f99924';
