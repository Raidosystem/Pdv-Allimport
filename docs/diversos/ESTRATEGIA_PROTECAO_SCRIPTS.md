# 🛡️ ESTRATÉGIA DE PROTEÇÃO - EVITAR QUEBRAR O SISTEMA

## 🎯 OBJETIVO
Criar uma metodologia segura para executar scripts SQL sem quebrar funcionalidades existentes.

## 📋 FUNÇÕES CRÍTICAS QUE NUNCA DEVEM SER REMOVIDAS

### 🔑 FUNÇÕES DE LOGIN (ESSENCIAIS)
```sql
-- ⚠️ NUNCA REMOVER ESTAS FUNÇÕES:
- listar_usuarios_ativos(UUID)     -- Lista funcionários para login
- validar_senha_local(UUID, TEXT)  -- Valida senhas dos funcionários
```

### 🏢 FUNÇÕES DE EMPRESAS (IMPORTANTES)
```sql
-- ⚠️ MANTER SEMPRE:
- generate_verification_code()     -- Códigos de verificação
- verify_whatsapp_code()          -- Verificação WhatsApp
```

## 🔒 REGRAS DE OURO PARA SCRIPTS SQL

### ❌ NUNCA FAZER:
1. **`DROP FUNCTION` sem verificar dependências**
2. **`TRUNCATE` ou `DELETE` em tabelas críticas**
3. **`DROP TABLE` sem backup**
4. **Alterar estrutura de tabelas em uso**
5. **Remover colunas sem verificar código**

### ✅ SEMPRE FAZER:
1. **Testar em ambiente isolado primeiro**
2. **Fazer backup antes de mudanças críticas**
3. **Usar `IF EXISTS` em comandos DROP**
4. **Verificar dependências antes de remover**
5. **Documentar o que cada script faz**

## 📝 TEMPLATE SEGURO PARA NOVOS SCRIPTS

```sql
-- 🔧 NOME_DO_SCRIPT.sql
-- OBJETIVO: [Descrever o que faz]
-- IMPACTO: [Alto/Médio/Baixo]
-- FUNCIONALIDADES AFETADAS: [Listar]

-- ====================================
-- 1. VERIFICAÇÕES DE SEGURANÇA
-- ====================================
-- Verificar se funções críticas existem
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'listar_usuarios_ativos') THEN
    RAISE EXCEPTION '❌ FUNÇÃO CRÍTICA listar_usuarios_ativos NÃO EXISTE! PARE IMEDIATAMENTE!';
  END IF;
  
  IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'validar_senha_local') THEN
    RAISE EXCEPTION '❌ FUNÇÃO CRÍTICA validar_senha_local NÃO EXISTE! PARE IMEDIATAMENTE!';
  END IF;
  
  RAISE NOTICE '✅ Funções críticas verificadas - PODE CONTINUAR';
END $$;

-- ====================================
-- 2. BACKUP DE SEGURANÇA (SE NECESSÁRIO)
-- ====================================
-- Exemplo: CREATE TABLE funcionarios_backup AS SELECT * FROM funcionarios;

-- ====================================
-- 3. SUAS ALTERAÇÕES AQUI
-- ====================================
-- Seus comandos SQL...

-- ====================================
-- 4. VERIFICAÇÃO FINAL
-- ====================================
-- Testar se sistema ainda funciona
SELECT 'Sistema OK' as status WHERE EXISTS (
  SELECT FROM pg_proc WHERE proname = 'listar_usuarios_ativos'
) AND EXISTS (
  SELECT FROM pg_proc WHERE proname = 'validar_senha_local'
);
```

## 🚨 SISTEMA DE ALERTA

### 🔔 ANTES DE EXECUTAR QUALQUER SCRIPT:
1. **Ler o script completamente**
2. **Verificar se contém DROP, TRUNCATE, DELETE**
3. **Confirmar se não afeta funções críticas**
4. **Testar em ambiente separado se possível**

### 📊 CATEGORIZAÇÃO DE SCRIPTS:

#### 🟢 BAIXO RISCO
- SELECT para consultas
- INSERT de novos dados
- UPDATE específicos
- CREATE de novas tabelas/funções

#### 🟡 MÉDIO RISCO
- ALTER TABLE para adicionar colunas
- CREATE OR REPLACE de funções não-críticas
- UPDATE em massa com WHERE específico

#### 🔴 ALTO RISCO
- DROP TABLE/FUNCTION
- TRUNCATE
- DELETE sem WHERE
- ALTER TABLE para remover colunas
- Mudanças em tabelas: funcionarios, empresas, login_funcionarios

## 🛠️ FERRAMENTAS DE PROTEÇÃO

### 1. SCRIPT DE VERIFICAÇÃO PRÉ-EXECUÇÃO
```sql
-- EXECUTE ANTES DE QUALQUER SCRIPT CRÍTICO
SELECT 
  'VERIFICAÇÃO DE SISTEMA' as teste,
  CASE 
    WHEN EXISTS (SELECT FROM pg_proc WHERE proname = 'listar_usuarios_ativos') 
    THEN '✅ listar_usuarios_ativos OK'
    ELSE '❌ listar_usuarios_ativos MISSING'
  END as funcao1,
  CASE 
    WHEN EXISTS (SELECT FROM pg_proc WHERE proname = 'validar_senha_local') 
    THEN '✅ validar_senha_local OK'
    ELSE '❌ validar_senha_local MISSING'
  END as funcao2;
```

### 2. SCRIPT DE RESTAURAÇÃO RÁPIDA
```sql
-- EM CASO DE EMERGÊNCIA, EXECUTE:
\i CORRECAO_RAPIDA_LOGIN.sql
```

## 📚 BOAS PRÁTICAS

### 🎯 DESENVOLVIMENTO SEGURO:
1. **Um script = uma funcionalidade**
2. **Testar localmente primeiro**
3. **Documentar dependências**
4. **Usar transações quando possível**
5. **Manter backups atualizados**

### 🔄 PROCESSO RECOMENDADO:
1. **Análise** - O que o script faz?
2. **Verificação** - Afeta sistema crítico?
3. **Backup** - Necessário backup?
4. **Teste** - Funciona sem quebrar?
5. **Execução** - Aplicar em produção
6. **Validação** - Sistema ainda funciona?

## 🎉 RESULTADO
Com esta metodologia, evitamos quebrar o sistema e mantemos a estabilidade do PDV!