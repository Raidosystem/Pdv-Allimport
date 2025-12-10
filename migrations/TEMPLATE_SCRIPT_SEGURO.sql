-- 🛡️ TEMPLATE SEGURO PARA NOVOS SCRIPTS SQL
-- Copie este template quando for criar um novo script para evitar quebrar o sistema

-- ====================================
-- INFORMAÇÕES DO SCRIPT
-- ====================================
-- NOME: [NOME_DO_SEU_SCRIPT]
-- OBJETIVO: [O que este script faz]
-- IMPACTO: [Alto/Médio/Baixo]
-- FUNCIONALIDADES AFETADAS: [Listar quais partes do sistema podem ser afetadas]
-- DATA: [Data de criação]

-- ====================================
-- 1. VERIFICAÇÕES DE SEGURANÇA OBRIGATÓRIAS
-- ====================================
DO $$
BEGIN
  -- Verificar se funções críticas de login existem
  IF NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') THEN
    RAISE EXCEPTION '🚨 PARE! Função crítica listar_usuarios_ativos não existe. Execute CORRECAO_RAPIDA_LOGIN.sql primeiro!';
  END IF;
  
  IF NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local') THEN
    RAISE EXCEPTION '🚨 PARE! Função crítica validar_senha_local não existe. Execute CORRECAO_RAPIDA_LOGIN.sql primeiro!';
  END IF;
  
  -- Verificar se tabelas críticas existem
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionarios') THEN
    RAISE EXCEPTION '🚨 PARE! Tabela funcionarios não existe!';
  END IF;
  
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'empresas') THEN
    RAISE EXCEPTION '🚨 PARE! Tabela empresas não existe!';
  END IF;
  
  RAISE NOTICE '✅ Verificações de segurança APROVADAS - PODE CONTINUAR';
END $$;

-- ====================================
-- 2. BACKUP DE SEGURANÇA (SE NECESSÁRIO)
-- ====================================
-- Descomente e ajuste se seu script modificar dados importantes:

-- CREATE TABLE funcionarios_backup_$(date) AS SELECT * FROM funcionarios;
-- CREATE TABLE empresas_backup_$(date) AS SELECT * FROM empresas;

-- RAISE NOTICE '💾 Backup criado com sucesso';

-- ====================================
-- 3. INÍCIO DAS SUAS ALTERAÇÕES
-- ====================================
-- ⚠️ REGRAS IMPORTANTES:
-- 1. NUNCA use DROP sem IF EXISTS
-- 2. NUNCA use TRUNCATE em tabelas críticas
-- 3. SEMPRE use WHERE em DELETE/UPDATE
-- 4. Teste cada comando individualmente
-- 5. Use BEGIN/COMMIT para transações

-- Exemplo seguro de CREATE:
-- CREATE TABLE IF NOT EXISTS nova_tabela (...);

-- Exemplo seguro de ALTER:
-- ALTER TABLE tabela ADD COLUMN IF NOT EXISTS nova_coluna TEXT;

-- Exemplo seguro de UPDATE:
-- UPDATE tabela SET campo = 'valor' WHERE condicao_especifica;

-- ========================================
-- SUAS ALTERAÇÕES AQUI:
-- ========================================

-- [Cole seus comandos SQL aqui]

-- ====================================
-- 4. VERIFICAÇÃO PÓS-EXECUÇÃO
-- ====================================
DO $$
BEGIN
  -- Verificar se sistema ainda funciona após as alterações
  IF NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') THEN
    RAISE EXCEPTION '💥 SISTEMA QUEBRADO! Função listar_usuarios_ativos foi removida!';
  END IF;
  
  IF NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local') THEN
    RAISE EXCEPTION '💥 SISTEMA QUEBRADO! Função validar_senha_local foi removida!';
  END IF;
  
  -- Verificar se ainda existem funcionários ativos
  IF NOT EXISTS (SELECT FROM funcionarios WHERE usuario_ativo = true AND senha_definida = true) THEN
    RAISE WARNING '⚠️ ATENÇÃO! Nenhum funcionário ativo encontrado. Verifique se não desativou usuários sem querer.';
  END IF;
  
  RAISE NOTICE '✅ Verificação pós-execução APROVADA - Sistema funcionando';
END $$;

-- ====================================
-- 5. TESTE RÁPIDO DE FUNCIONALIDADE
-- ====================================
SELECT 
  '🧪 TESTE FINAL' as teste,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos')
         AND EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local')
         AND EXISTS (SELECT FROM funcionarios WHERE usuario_ativo = true)
    THEN '✅ SISTEMA OK - SCRIPT EXECUTADO COM SUCESSO'
    ELSE '❌ SISTEMA COM PROBLEMAS - VERIFICAR IMEDIATAMENTE'
  END as resultado;

-- ====================================
-- 6. LOG DE EXECUÇÃO (OPCIONAL)
-- ====================================
-- Criar tabela de log se não existir (opcional)
CREATE TABLE IF NOT EXISTS log_scripts (
  id SERIAL PRIMARY KEY,
  nome_script TEXT NOT NULL,
  data_execucao TIMESTAMP DEFAULT NOW(),
  status TEXT DEFAULT 'EXECUTADO',
  observacoes TEXT
);

-- Registrar execução do script
INSERT INTO log_scripts (
  nome_script,
  data_execucao,
  status,
  observacoes
) VALUES (
  '[NOME_DO_SEU_SCRIPT]',
  NOW(),
  'EXECUTADO COM SUCESSO',
  'Script executado via template seguro'
);

SELECT 
  '📝 CONCLUSÃO' as info,
  'Script executado com segurança. Sistema PDV mantido estável.' as mensagem;

-- ====================================
-- CHECKLIST FINAL:
-- ====================================
-- □ Funções críticas preservadas
-- □ Dados importantes mantidos
-- □ Sistema de login funcionando
-- □ Backup criado (se necessário)
-- □ Testes passaram
-- □ Log registrado