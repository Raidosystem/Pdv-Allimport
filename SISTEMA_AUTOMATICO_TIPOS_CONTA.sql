-- 🔄 SISTEMA AUTOMÁTICO DE TIPOS DE CONTA

-- ====================================
-- PARTE 1: CONFIGURAR NOVOS CADASTROS
-- ====================================

-- Função para definir tipo_conta ao criar empresa
CREATE OR REPLACE FUNCTION set_tipo_conta_on_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Se não especificou tipo_conta, define como teste_ativo
  IF NEW.tipo_conta IS NULL THEN
    NEW.tipo_conta := 'teste_ativo';
    NEW.data_fim_teste := NOW() + INTERVAL '15 days';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para novos cadastros
DROP TRIGGER IF EXISTS trigger_set_tipo_conta ON empresas;
CREATE TRIGGER trigger_set_tipo_conta
BEFORE INSERT ON empresas
FOR EACH ROW
EXECUTE FUNCTION set_tipo_conta_on_insert();

-- ====================================
-- PARTE 2: FUNÇÃO PARA ATIVAR ASSINATURA
-- ====================================

-- Função para ativar assinatura após pagamento
CREATE OR REPLACE FUNCTION ativar_assinatura(p_empresa_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE empresas
  SET 
    tipo_conta = 'assinatura_ativa',
    data_fim_teste = NULL -- Limpa data de teste
  WHERE id = p_empresa_id
  AND tipo_conta = 'teste_ativo';
  
  -- Log de auditoria (opcional)
  RAISE NOTICE 'Assinatura ativada para empresa %', p_empresa_id;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- PARTE 3: FUNÇÃO PARA VERIFICAR TESTES EXPIRADOS
-- ====================================

-- Função para verificar e expirar testes (rodar diariamente via cron/scheduled)
CREATE OR REPLACE FUNCTION expirar_testes_vencidos()
RETURNS TABLE(empresa_id UUID, empresa_nome TEXT, email TEXT) AS $$
BEGIN
  RETURN QUERY
  UPDATE empresas e
  SET tipo_conta = 'teste_expirado'
  WHERE e.tipo_conta = 'teste_ativo'
  AND e.data_fim_teste < NOW()
  RETURNING e.id, e.nome, e.email;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- PARTE 4: ATUALIZAR VALORES POSSÍVEIS
-- ====================================

-- Agora temos 5 tipos de conta:
-- 'super_admin' = Desenvolvedor/Dono do sistema (você)
-- 'assinatura_ativa' = Cliente pagante com mensalidade ativa
-- 'teste_ativo' = Período de teste (15 dias)
-- 'teste_expirado' = Teste vencido, não pagou
-- 'funcionarios' = Contas de funcionários/colaboradores

-- ====================================
-- PARTE 5: EXEMPLOS DE USO
-- ====================================

-- EXEMPLO 1: Novo cadastro (automático via trigger)
-- INSERT INTO empresas (nome, email, cnpj) 
-- VALUES ('Nova Empresa', 'empresa@exemplo.com', '12345678000100');
-- Resultado: tipo_conta = 'teste_ativo', data_fim_teste = NOW() + 15 dias

-- EXEMPLO 2: Cliente pagou (chamar após confirmação de pagamento)
-- SELECT ativar_assinatura('uuid-da-empresa');
-- Resultado: tipo_conta = 'assinatura_ativa'

-- EXEMPLO 3: Verificar testes expirados (rodar diariamente)
-- SELECT * FROM expirar_testes_vencidos();
-- Resultado: Atualiza empresas vencidas para 'teste_expirado'

-- ====================================
-- PARTE 6: VERIFICAR INSTALAÇÃO
-- ====================================

SELECT 
  '✅ SISTEMA AUTOMÁTICO CONFIGURADO' as status,
  'Triggers e funções criadas com sucesso' as mensagem;

-- Ver funções criadas
SELECT 
  '📋 FUNÇÕES DISPONÍVEIS' as tipo,
  routine_name as nome_funcao,
  routine_type as tipo
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
  'set_tipo_conta_on_insert',
  'ativar_assinatura',
  'expirar_testes_vencidos',
  'proteger_super_admin'
)
ORDER BY routine_name;

-- Ver triggers ativos
SELECT 
  '🔄 TRIGGERS ATIVOS' as tipo,
  trigger_name,
  event_manipulation as evento,
  event_object_table as tabela
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table = 'empresas'
ORDER BY trigger_name;
