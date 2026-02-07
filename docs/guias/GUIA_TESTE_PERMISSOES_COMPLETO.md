# ✅ GUIA DE TESTE - Sistema de Permissões Automáticas

## 🎯 O QUE FOI IMPLEMENTADO

Um sistema **COMPLETO e AUTOMÁTICO** que funciona para:

1. ✅ **Jennifer e funcionários existentes** → Corrigidos automaticamente
2. ✅ **Novos funcionários** criados pelo admin → Permissões automáticas via TRIGGER
3. ✅ **Novos usuários** que comprarem o sistema → Sistema pronto automaticamente

---

## 📝 PASSO A PASSO DE TESTE

### **1️⃣ Executar o Script Principal**

No SQL Editor do Supabase, execute:

```sql
\i SISTEMA_PERMISSOES_AUTOMATICAS_COMPLETO.sql
```

**Resultado esperado:**
```
✅ TRIGGER CRIADO - Novos funcionários receberão permissões automáticas
✅ FUNÇÃO CRIADA - Pode atualizar permissões em massa
🔄 Corrigindo permissões de funcionários existentes...
  ✅ Jennifer (Técnico): true
  ✅ Cristiano (Administrador): true
🎉 Total de funcionários corrigidos: 2
```

---

### **2️⃣ TESTAR JENNIFER (Funcionário Existente)**

#### No SQL Editor:
```sql
SELECT 
  nome,
  permissoes->>'ordens_servico' as os_ativo,
  ativo,
  usuario_ativo,
  senha_definida
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%';
```

**Resultado esperado:**
```
nome     | os_ativo | ativo | usuario_ativo | senha_definida
Jennifer | true     | true  | true          | true
```

#### No Frontend:
1. Faça **logout completo**
2. Login com: `assistenciaallimport10@gmail.com`
3. Na tela de login local, **Jennifer deve aparecer na lista**
4. Selecione Jennifer e faça login
5. No dashboard, **deve aparecer o card "Ordens de Serviço"** ✅
6. No menu lateral, **deve aparecer "OS"** ✅

---

### **3️⃣ TESTAR NOVO FUNCIONÁRIO (Via Interface Admin)**

#### Passo a passo:
1. Login como admin: `assistenciaallimport10@gmail.com`
2. Ir em **Administração** → **Gerenciar Funcionários**
3. Clicar em **"Adicionar Funcionário"**
4. Preencher:
   - Nome: `Teste Vendedor`
   - Email: `teste@email.com`
   - Função: **Vendedor**
5. Salvar

#### Verificar no SQL:
```sql
SELECT 
  nome,
  permissoes,
  usuario_ativo,
  senha_definida
FROM funcionarios
WHERE nome = 'Teste Vendedor';
```

**Resultado esperado:**
```json
{
  "nome": "Teste Vendedor",
  "permissoes": {
    "vendas": true,
    "produtos": true,
    "clientes": true,
    "caixa": false,
    "ordens_servico": false,  // Vendedor não tem OS
    "relatorios": false,
    "configuracoes": false,
    "backup": false
  },
  "usuario_ativo": true,
  "senha_definida": true
}
```

#### Criar outro com função Técnico:
- Nome: `Teste Técnico`
- Função: **Técnico**

**Resultado esperado para Técnico:**
```json
{
  "ordens_servico": true,  // ✅ Técnico TEM OS
  "vendas": false,
  "produtos": true,
  "clientes": true
}
```

---

### **4️⃣ TESTAR NOVO USUÁRIO (Simulação de Compra)**

#### No SQL Editor, simular novo usuário:
```sql
BEGIN;

-- 1. Criar empresa (simula novo cliente comprando)
INSERT INTO empresas (nome, email, user_id)
VALUES (
  'Empresa Teste Ltda',
  'teste@empresateste.com',
  gen_random_uuid()
)
RETURNING id;

-- Copie o ID retornado e use nas próximas queries
-- Exemplo: '12345678-1234-1234-1234-123456789012'

-- 2. Verificar se funções foram criadas automaticamente
SELECT 
  '🎭 FUNÇÕES CRIADAS AUTOMATICAMENTE' as titulo,
  nome,
  descricao
FROM funcoes
WHERE empresa_id = '12345678-1234-1234-1234-123456789012'  -- Use o ID real
ORDER BY nome;

-- 3. Criar funcionário para essa empresa
INSERT INTO funcionarios (
  empresa_id,
  funcao_id,
  nome,
  email,
  ativo,
  status
) VALUES (
  '12345678-1234-1234-1234-123456789012',  -- Use o ID real
  (SELECT id FROM funcoes WHERE empresa_id = '12345678-1234-1234-1234-123456789012' AND nome = 'Técnico' LIMIT 1),
  'Funcionário Novo Sistema',
  'novo@sistema.com',
  true,
  'ativo'
);

-- 4. Verificar permissões aplicadas automaticamente
SELECT 
  '✅ PERMISSÕES APLICADAS AUTOMATICAMENTE' as titulo,
  nome,
  permissoes
FROM funcionarios
WHERE email = 'novo@sistema.com';

ROLLBACK;  -- Desfazer teste (ou COMMIT para manter)
```

**Resultado esperado:**
```sql
-- Funções criadas automaticamente:
Administrador
Gerente
Vendedor
Caixa
Técnico

-- Permissões do novo funcionário:
{
  "vendas": false,
  "produtos": true,
  "clientes": true,
  "caixa": false,
  "ordens_servico": true,  // ✅ AUTOMÁTICO!
  "relatorios": false,
  "configuracoes": false,
  "backup": false
}
```

---

## 🔧 SOLUÇÃO DE PROBLEMAS

### ❌ Jennifer ainda não aparece no login

**Verificar:**
```sql
-- 1. Status de Jennifer
SELECT nome, ativo, status, usuario_ativo, senha_definida
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%';

-- 2. Se aparecer na RPC
SELECT * FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com')
);
```

**Correção:**
```sql
UPDATE funcionarios
SET 
  ativo = true,
  status = 'ativo',
  usuario_ativo = true,
  senha_definida = true
WHERE LOWER(nome) LIKE '%jennifer%';
```

### ❌ Novo funcionário criado SEM permissões

**Verificar se trigger existe:**
```sql
SELECT 
  trigger_name, 
  event_manipulation, 
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'before_insert_funcionario_permissoes';
```

**Se não existir, recriar:**
```sql
\i SISTEMA_PERMISSOES_AUTOMATICAS_COMPLETO.sql
```

### ❌ Módulo OS não aparece mesmo com permissão `true`

**Causas possíveis:**
1. Cache do navegador
2. LocalStorage antigo
3. Sessão antiga

**Solução:**
```javascript
// No console do navegador (F12):
localStorage.clear();
location.reload();

// Ou faça logout/login completo
```

---

## 📊 QUERIES DE VERIFICAÇÃO RÁPIDA

### Ver todas as permissões por função:
```sql
SELECT 
  func.nome as funcao,
  STRING_AGG(DISTINCT 
    CASE 
      WHEN f.permissoes->>'vendas' = 'true' THEN 'vendas'
      WHEN f.permissoes->>'produtos' = 'true' THEN 'produtos'
      WHEN f.permissoes->>'clientes' = 'true' THEN 'clientes'
      WHEN f.permissoes->>'caixa' = 'true' THEN 'caixa'
      WHEN f.permissoes->>'ordens_servico' = 'true' THEN 'OS'
      WHEN f.permissoes->>'relatorios' = 'true' THEN 'relatorios'
    END, ', '
  ) as modulos_ativos
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
GROUP BY func.nome
ORDER BY func.nome;
```

### Ver funcionários que aparecem no login:
```sql
SELECT 
  nome,
  permissoes->>'ordens_servico' as tem_os,
  usuario_ativo,
  senha_definida,
  status
FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com')
);
```

### Forçar recalculo de permissões para uma função:
```sql
-- Exemplo: Atualizar todos os Técnicos
SELECT * FROM atualizar_permissoes_funcionarios_por_funcao(
  (SELECT id FROM funcoes WHERE nome = 'Técnico' LIMIT 1)
);
```

---

## ✅ CHECKLIST FINAL

Após executar o script, verifique:

- [ ] **Jennifer aparece no login local**
- [ ] **Jennifer vê card "Ordens de Serviço" no dashboard**
- [ ] **Criar novo funcionário Vendedor → não tem OS**
- [ ] **Criar novo funcionário Técnico → TEM OS** ✅
- [ ] **Criar novo funcionário Admin → tem TUDO**
- [ ] **Todos os funcionários têm `usuario_ativo = true`**
- [ ] **Trigger `before_insert_funcionario_permissoes` existe**
- [ ] **Função `atualizar_permissoes_funcionarios_por_funcao` existe**

---

## 📞 SUPORTE

Se algum teste falhar:

1. ✅ Copie o resultado da query de verificação
2. ✅ Copie os logs do console do navegador (F12)
3. ✅ Execute `\i DIAGNOSTICO_JENNIFER_OS.sql` para debug adicional
4. ✅ Verifique se o script foi executado completamente (sem erros)

---

## 🎉 RESULTADO ESPERADO

Após executar tudo:

✅ **Jennifer** → Módulo OS aparece  
✅ **Novos funcionários** → Permissões automáticas baseadas na função  
✅ **Novos clientes** → Sistema completo pronto ao comprar  
✅ **Sem trabalho manual** → Tudo automático via triggers!

**Sistema 100% funcional e escalável!** 🚀
