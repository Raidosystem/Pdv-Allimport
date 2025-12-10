-- 🔐 MARCAR CONTA SUPER ADMIN DO SISTEMA

-- ⚠️ IMPORTANTE:
-- novaradiosystem@outlook.com = SUPER ADMIN (desenvolvedor/dono do sistema)
-- assistenciaallimport10@gmail.com = Cliente com assinatura ativa

-- ====================================
-- 1. ADICIONAR COLUNA is_super_admin
-- ====================================
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS is_super_admin BOOLEAN DEFAULT false;

-- ====================================
-- 2. MARCAR SUPER ADMIN
-- ====================================
UPDATE empresas
SET 
  is_super_admin = true,
  tipo_conta = 'super_admin'
WHERE email = 'novaradiosystem@outlook.com';

-- ====================================
-- 3. ADICIONAR COMENTÁRIO PARA DOCUMENTAÇÃO
-- ====================================
COMMENT ON COLUMN empresas.is_super_admin IS 
'Super Admin do sistema - acesso total, nunca pode ser excluído. Desenvolvedor/Dono do sistema.';

-- ====================================
-- 4. CRIAR CONSTRAINT PARA PROTEGER
-- ====================================
-- Criar função que impede exclusão do super admin
CREATE OR REPLACE FUNCTION proteger_super_admin()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.is_super_admin = true THEN
    RAISE EXCEPTION 'Não é possível excluir a conta Super Admin do sistema!';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para proteção
DROP TRIGGER IF EXISTS trigger_proteger_super_admin ON empresas;
CREATE TRIGGER trigger_proteger_super_admin
BEFORE DELETE ON empresas
FOR EACH ROW
EXECUTE FUNCTION proteger_super_admin();

-- ====================================
-- 5. ATUALIZAR tipo_conta VALORES
-- ====================================
-- Agora temos 4 tipos:
-- 'super_admin' = Desenvolvedor/Dono do sistema (acesso total, não pode ser excluído)
-- 'assinatura_ativa' = Cliente com mensalidade paga
-- 'teste_ativo' = Período de teste (30 dias)
-- 'funcionarios' = Contas de funcionários

-- ====================================
-- 6. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ SUPER ADMIN CONFIGURADO' as status,
  id,
  nome,
  email,
  cnpj,
  tipo_conta,
  is_super_admin,
  '🔒 PROTEGIDO - NÃO PODE SER EXCLUÍDO' as protecao
FROM empresas
WHERE is_super_admin = true;

-- Ver todas as empresas organizadas
SELECT 
  '📊 TODAS AS EMPRESAS' as titulo,
  CASE 
    WHEN e.is_super_admin = true THEN '🔐 SUPER ADMIN'
    WHEN e.tipo_conta = 'assinatura_ativa' THEN '💰 CLIENTE PAGO'
    WHEN e.tipo_conta = 'teste_ativo' THEN '🆓 TESTE'
    ELSE '👥 OUTROS'
  END as tipo,
  e.nome,
  e.email,
  e.cnpj,
  COUNT(f.id) as funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.is_super_admin, e.tipo_conta, e.nome, e.email, e.cnpj
ORDER BY 
  CASE 
    WHEN e.is_super_admin = true THEN 1
    WHEN e.tipo_conta = 'assinatura_ativa' THEN 2
    WHEN e.tipo_conta = 'teste_ativo' THEN 3
    ELSE 4
  END;

-- ====================================
-- 7. TESTAR PROTEÇÃO (deve dar erro)
-- ====================================
-- Descomente a linha abaixo para testar se a proteção funciona
-- DELETE FROM empresas WHERE is_super_admin = true;
-- ❌ Esperado: "Não é possível excluir a conta Super Admin do sistema!"
