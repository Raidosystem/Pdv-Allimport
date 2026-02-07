# 🚀 GUIA DE EXECUÇÃO - Sistema de Permissões Automático

## 📋 Status Atual

Você tem **6 funcionários** no banco de dados:
- **5 Proprietários** (precisam de ADMIN): Administrador Principal, assistenciaallimport10, cris-ramos30, Cristiano Ramos Mendes, novaradiosystem
- **1 Funcionária** (Jennifer Sousa): Receberá permissões específicas

**❌ PROBLEMA ATUAL**: Todos têm apenas permissões básicas (sem ADMIN)

**✅ SOLUÇÃO**: Executar o script SQL completo para ativar o sistema automático

---

## 🎯 O que o Script Faz

1. **Cria função de trigger** que detecta automaticamente se usuário é proprietário ou funcionário
2. **Aplica ADMIN aos 5 proprietários existentes** (UPDATE automático via JOIN)
3. **Configura triggers** para futuros usuários (novos proprietários = ADMIN, novos funcionários = padrão)
4. **Cria função auxiliar** para aplicar templates manualmente quando necessário

---

## 📝 PASSO A PASSO - Execução no Supabase

### **PASSO 1: Abrir SQL Editor no Supabase**

1. Acesse: https://supabase.com/dashboard/project/YOUR_PROJECT_ID
2. No menu lateral, clique em **SQL Editor**
3. Clique em **New Query** (Nova Consulta)

---

### **PASSO 2: Copiar o Script Completo**

Abra o arquivo: `MELHORAR_SISTEMA_PERMISSOES.sql`

**IMPORTANTE**: Copie **TODO O CONTEÚDO** do arquivo (646 linhas)

---

### **PASSO 3: Colar e Executar**

1. Cole todo o script na janela do SQL Editor
2. Clique no botão **RUN** (Executar) ou pressione `Ctrl+Enter`
3. Aguarde a execução completa (pode levar alguns segundos)

---

### **PASSO 4: Verificar Resultado**

Após a execução, você verá mensagens de sucesso. Execute esta query para verificar:

```sql
SELECT 
  f.nome,
  f.cargo,
  CASE 
    WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN '🔴 PROPRIETÁRIO (ADMIN)'
    ELSE '👤 FUNCIONÁRIO'
  END as tipo,
  CASE 
    WHEN f.permissoes->>'configuracoes' = 'true' THEN '✅ ADMIN'
    WHEN f.permissoes->>'ordens_servico' = 'true' AND f.permissoes->>'vendas' = 'false' THEN '🟢 TÉCNICO'
    WHEN f.permissoes->>'caixa' = 'true' THEN '🟡 CAIXA'
    WHEN f.permissoes->>'vendas' = 'true' THEN '🔵 VENDEDOR'
    ELSE '⚪ PADRÃO'
  END as perfil,
  f.permissoes->>'configuracoes' as "Config",
  f.permissoes->>'funcionarios' as "Func",
  f.permissoes->>'backup' as "Backup",
  f.permissoes->>'pode_deletar_clientes' as "Deletar_Clientes"
FROM funcionarios f
ORDER BY 
  CASE WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN 1 ELSE 2 END,
  f.nome;
```

---

## ✅ RESULTADO ESPERADO

Após a execução bem-sucedida, você deve ver:

| nome                    | tipo                      | perfil   | Config | Func  | Backup | Deletar_Clientes |
|------------------------|---------------------------|----------|--------|-------|--------|------------------|
| Administrador Principal | 🔴 PROPRIETÁRIO (ADMIN)   | ✅ ADMIN | true   | true  | true   | true             |
| assistenciaallimport10  | 🔴 PROPRIETÁRIO (ADMIN)   | ✅ ADMIN | true   | true  | true   | true             |
| cris-ramos30           | 🔴 PROPRIETÁRIO (ADMIN)   | ✅ ADMIN | true   | true  | true   | true             |
| Cristiano Ramos Mendes | 🔴 PROPRIETÁRIO (ADMIN)   | ✅ ADMIN | true   | true  | true   | true             |
| novaradiosystem        | 🔴 PROPRIETÁRIO (ADMIN)   | ✅ ADMIN | true   | true  | true   | true             |
| Jennifer Sousa         | 👤 FUNCIONÁRIO            | ⚪ PADRÃO | false  | false | false  | false            |

**✅ Todos os proprietários devem ter:**
- `Config = true`
- `Func = true`
- `Backup = true`
- `Deletar_Clientes = true`
- Perfil: **✅ ADMIN**

---

## 🔧 PASSO 5 (OPCIONAL): Aplicar Template Específico para Jennifer

Se quiser aplicar o template "Técnico" para Jennifer:

```sql
SELECT aplicar_template_permissoes('9d9fe570-7c09-4ee4-8c52-11b7969c00f3', 'tecnico');
```

Depois verifique:

```sql
SELECT nome, 
  permissoes->>'ordens_servico' as "OS",
  permissoes->>'vendas' as "Vendas",
  permissoes->>'configuracoes' as "Config"
FROM funcionarios 
WHERE nome = 'Jennifer Sousa';
```

**Resultado Esperado:**
- OS = `true`
- Vendas = `false`
- Config = `false`

---

## 🧪 PASSO 6: Testar Sistema Automático

Teste se novos funcionários recebem permissões automaticamente:

```sql
-- Criar funcionário de teste
INSERT INTO funcionarios (nome, email, cargo, empresa_id, ativo)
VALUES ('Teste Auto', 'teste@auto.com', 'Teste', 
  (SELECT id FROM empresas LIMIT 1), 
  true);

-- Verificar permissões aplicadas automaticamente
SELECT nome, 
  permissoes->>'vendas' as vendas,
  permissoes->>'configuracoes' as config,
  jsonb_pretty(permissoes) as permissoes_completas
FROM funcionarios 
WHERE nome = 'Teste Auto';

-- Limpar teste
DELETE FROM funcionarios WHERE nome = 'Teste Auto';
```

**Resultado Esperado:**
- `vendas = true`
- `config = false` (não é proprietário)
- Permissões padrão aplicadas automaticamente

---

## ❌ TROUBLESHOOTING (Problemas Comuns)

### **Erro: "relation empresas does not exist"**
**Solução**: Verifique se a tabela `empresas` existe:
```sql
SELECT * FROM empresas LIMIT 1;
```

### **Erro: "column user_id does not exist"**
**Solução**: Ajuste a query da trigger para usar apenas `empresa_id`:
```sql
-- Na função auto_aplicar_permissoes(), alterar linha:
SELECT EXISTS(
  SELECT 1 FROM empresas 
  WHERE id = NEW.empresa_id  -- Usar apenas empresa_id
) INTO v_is_proprietario;
```

### **Proprietários ainda sem ADMIN após execução**
**Solução**: Execute manualmente o UPDATE da Seção 7️⃣:
```sql
UPDATE funcionarios
SET permissoes = jsonb_build_object(
    'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
    'ordens_servico', true, 'funcionarios', true, 'relatorios', true,
    'configuracoes', true, 'backup', true,
    'pode_criar_vendas', true, 'pode_editar_vendas', true,
    'pode_cancelar_vendas', true, 'pode_aplicar_desconto', true,
    'pode_criar_produtos', true, 'pode_editar_produtos', true,
    'pode_deletar_produtos', true, 'pode_gerenciar_estoque', true,
    'pode_criar_clientes', true, 'pode_editar_clientes', true,
    'pode_deletar_clientes', true, 'pode_abrir_caixa', true,
    'pode_fechar_caixa', true, 'pode_gerenciar_movimentacoes', true,
    'pode_criar_os', true, 'pode_editar_os', true, 'pode_finalizar_os', true,
    'pode_ver_todos_relatorios', true, 'pode_exportar_dados', true,
    'pode_alterar_configuracoes', true, 'pode_gerenciar_funcionarios', true,
    'pode_fazer_backup', true
),
updated_at = NOW()
WHERE id IN (
  '09dc2c9d-8cae-4e25-a889-6e98b03d1bf5',
  'ccdad2bc-3cc1-48a5-b447-be962b2956eb',
  '229271ef-567c-44c7-a996-dd738d3dd476',
  '23f89969-3c78-4b1e-8131-d98c4b81facb',
  '0e72a56a-d826-4731-bc82-59d9a28acba5'
);
```

---

## 📊 CHECKLIST DE VALIDAÇÃO

Após executar o script, confirme:

- [ ] Script executado sem erros
- [ ] 5 proprietários com `configuracoes = true`
- [ ] 5 proprietários com `funcionarios = true`
- [ ] 5 proprietários com `backup = true`
- [ ] Jennifer com permissões básicas (ou template aplicado)
- [ ] Trigger criada com sucesso
- [ ] Função `aplicar_template_permissoes()` disponível
- [ ] Teste de funcionário automático funcionou

---

## 🎉 PRÓXIMOS PASSOS

Após validação bem-sucedida:

1. **Frontend**: Usar o componente `PermissionsManager` para gerenciar permissões visualmente
2. **Novos Funcionários**: Sistema aplicará permissões automaticamente
3. **Novos Proprietários**: Receberão ADMIN automaticamente ao comprar o sistema
4. **Templates**: Usar função `aplicar_template_permissoes()` quando necessário

---

## 📞 SUPORTE

Se encontrar problemas:
1. Copie a mensagem de erro completa
2. Execute a query de verificação (Passo 4)
3. Compartilhe os resultados para análise

---

**✅ Sistema Pronto para Produção!**
