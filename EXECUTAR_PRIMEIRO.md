# 🚀 GUIA RÁPIDO - EXECUTAR NO SUPABASE

## ⚠️ IMPORTANTE: Execute este script primeiro!

### 📋 Arquivo a Executar
**Nome:** `ESTRUTURA_COMPLETA_FUNCIONARIOS.sql`

Este script é **mais completo** e **seguro** que o `ADICIONAR_STATUS_FUNCIONARIOS.sql`

## 🎯 O QUE O SCRIPT FAZ

### 1. ✅ Adiciona Colunas Faltantes
- `status` - VARCHAR(20) - 'ativo', 'pausado', 'inativo'
- `ultimo_acesso` - TIMESTAMP - Data do último login
- `tipo_admin` - VARCHAR(50) - 'admin_empresa' ou 'funcionario'

### 2. ✅ Torna Email Opcional
- Remove obrigatoriedade da coluna `email`
- Permite criar funcionários sem email

### 3. ✅ Atualiza Dados Existentes
- Define status 'ativo' para funcionários sem status
- Define tipo_admin 'funcionario' para não-admins

### 4. ✅ Cria Índices
- `idx_funcionarios_status`
- `idx_funcionarios_ultimo_acesso`
- `idx_funcionarios_tipo_admin`
- `idx_funcionarios_empresa_id`

### 5. ✅ Atualiza Função de Login
- Verifica status antes de permitir login
- Bloqueia funcionários pausados
- Atualiza ultimo_acesso automaticamente

## 📝 COMO EXECUTAR

### Passo 1: Abrir Supabase
```
1. Acesse https://supabase.com
2. Faça login
3. Selecione seu projeto PDV Allimport
```

### Passo 2: SQL Editor
```
1. Clique em "SQL Editor" no menu lateral
2. Clique em "New Query"
```

### Passo 3: Copiar e Colar
```
1. Abra o arquivo: ESTRUTURA_COMPLETA_FUNCIONARIOS.sql
2. Selecione TODO o conteúdo (Ctrl+A)
3. Copie (Ctrl+C)
4. Cole no SQL Editor do Supabase (Ctrl+V)
```

### Passo 4: Executar
```
1. Clique no botão "Run" (ou pressione Ctrl+Enter)
2. Aguarde a execução (leva ~5 segundos)
```

### Passo 5: Verificar Resultados
```
Você verá mensagens como:

NOTICE:  ✅ Coluna status adicionada com sucesso!
NOTICE:  ✅ Coluna ultimo_acesso adicionada com sucesso!
NOTICE:  ✅ Coluna email agora aceita NULL!

E duas tabelas de resultado:
1. Estrutura da tabela funcionarios
2. Contagem de funcionários por status
```

## ✅ VERIFICAÇÃO DE SUCESSO

### O script executou corretamente se você ver:

**Tabela 1 - Estrutura:**
```
column_name       | data_type | is_nullable
------------------|-----------|------------
id                | uuid      | NO
empresa_id        | uuid      | NO
nome              | text      | NO
email             | text      | YES ✅ (aceita NULL)
status            | varchar   | YES ✅ (nova coluna)
tipo_admin        | varchar   | YES ✅
usuario_id        | uuid      | YES
ultimo_acesso     | timestamp | YES ✅ (nova coluna)
```

**Tabela 2 - Contagem:**
```
total | ativos | pausados | inativos | admins | funcionarios_normais | sem_email
------|--------|----------|----------|--------|---------------------|----------
  3   |   3    |    0     |    0     |   1    |         2           |    0
```

## 🔧 SE DER ERRO

### Erro: "column already exists"
```
✅ Não é problema! O script detecta e pula colunas existentes
```

### Erro: "constraint already exists"
```
✅ Não é problema! Significa que a constraint já foi criada
```

### Erro: "permission denied"
```
❌ Você precisa estar logado como owner do projeto
Solução: Verifique se está na conta correta
```

### Erro: "syntax error"
```
❌ Cópia incompleta do script
Solução: Copie TODO o conteúdo do arquivo novamente
```

## 🎉 APÓS EXECUTAR COM SUCESSO

### Pode:
✅ Criar funcionários sem email
✅ Pausar funcionários
✅ Ativar funcionários
✅ Excluir funcionários
✅ Sistema rastreia último acesso

### Teste:
1. Acesse a página "Ativar Usuários"
2. Crie um funcionário (apenas nome + senha)
3. Veja o usuário gerado automaticamente
4. Teste pausar/ativar
5. Teste excluir

## 📞 SUPORTE

Se ainda tiver problemas:
1. Copie a mensagem de erro completa
2. Tire um print da tela
3. Informe qual linha do script deu erro

---

**Status:** ✅ Pronto para executar
**Tempo:** ~5 segundos
**Risco:** Baixo (script usa IF NOT EXISTS)
