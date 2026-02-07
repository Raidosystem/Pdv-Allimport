# ?? GUIA DE INSTALAÇÃO - SCRIPT CONSOLIDADO FINAL

## ? **ÚNICO ARQUIVO A EXECUTAR**

```
?? INSTALACAO_COMPLETA_FINAL.sql
```

**Este arquivo faz TUDO em 1 execução!**

---

## ?? **O QUE ESTE SCRIPT FAZ**

```
???????????????????????????????????????????????????
?  1. ? Instala extension pgcrypto               ?
???????????????????????????????????????????????????
?  2. ? Corrige 5 RPCs:                          ?
?     - listar_usuarios_ativos                    ?
?     - validar_senha_local                       ?
?     - atualizar_senha_funcionario               ?
?     - trocar_senha_propria                      ?
?     - Permissões corretas                       ?
???????????????????????????????????????????????????
?  3. ? Ativa TODOS os funcionários:             ?
?     - usuario_ativo = TRUE                      ?
?     - senha_definida = TRUE                     ?
?     - status = 'ativo'                          ?
?     - ativo = TRUE                              ?
???????????????????????????????????????????????????
?  4. ? Cria login para TODOS:                   ?
?     - Cristiano ? cristiano / senha dele       ?
?     - Jennifer  ? jennifer / 123456            ?
?     - Outros    ? username / 123456            ?
???????????????????????????????????????????????????
?  5. ? Instala 2 TRIGGERS:                      ?
?     - auto_criar_login (INSERT)                 ?
?     - auto_atualizar_login (UPDATE)             ?
???????????????????????????????????????????????????
?  6. ? Testa tudo:                              ?
?     - Verifica RPCs                             ?
?     - Verifica triggers                         ?
?     - Lista usuários                            ?
?     - Mostra estatísticas                       ?
???????????????????????????????????????????????????
```

---

## ? **COMO EXECUTAR (3 minutos)**

### **1?? Abrir Supabase SQL Editor**

```
1. Acesse: https://supabase.com
2. Selecione seu projeto
3. Clique em "SQL Editor" (menu lateral)
4. Clique em "New Query"
```

---

### **2?? Copiar e Colar**

```
1. Abra o arquivo: INSTALACAO_COMPLETA_FINAL.sql
2. Selecione TODO o conteúdo (Ctrl+A)
3. Copie (Ctrl+C)
4. Cole no SQL Editor do Supabase (Ctrl+V)
```

---

### **3?? Executar**

```
1. Clique no botão "Run" (ou pressione Ctrl+Enter)
2. Aguarde 30-60 segundos
3. ? Veja os resultados aparecerem
```

---

## ?? **RESULTADOS ESPERADOS**

Você verá várias tabelas com resultados:

### **1. Status de Cada Etapa**

```
| status                                              |
|----------------------------------------------------|
| ? PASSO 1: Extension pgcrypto garantida           |
| ? PASSO 2: RPC listar_usuarios_ativos corrigida   |
| ? PASSO 3: RPC validar_senha_local corrigida      |
| ? PASSO 4: RPC atualizar_senha_funcionario corr.  |
| ? PASSO 5: RPC trocar_senha_propria criada        |
| ? PASSO 6: Todos os funcionários ativados         |
| ? PASSO 7: Logins criados/atualizados para todos  |
| ? PASSO 8: Triggers instalados                    |
```

---

### **2. Verificação de RPCs**

```
| secao                      | pgcrypto | rpc_listar | rpc_validar | ... |
|----------------------------|----------|------------|-------------|-----|
| ?? VERIFICAÇÃO FINAL - RPCs | ?       | ?         | ?          | ?  |
```

---

### **3. Usuários que Aparecerão no Login**

```
| nome                   | email                      | tipo_admin    | usuario   |
|------------------------|----------------------------|---------------|-----------|
| Cristiano Ramos Mendes | cris-ramos30@hotmail.com   | admin_empresa | cristiano |
| Jennifer               | (email)                    | funcionario   | jennifer  |
```

---

### **4. Estatísticas**

```
| secao        | total_func | ativos | com_senha | logins | aparecendo |
|--------------|------------|--------|-----------|--------|------------|
| ?? ESTATÍSTICAS | 2       | 2      | 2         | 2      | 2          |
```

---

### **5. Estado Final Detalhado**

```
| nome       | tipo_admin    | usuario_ativo | senha_def | username  | status_login_local |
|------------|---------------|---------------|-----------|-----------|-------------------|
| Cristiano  | admin_empresa | true          | true      | cristiano | ? VAI APARECER   |
| Jennifer   | funcionario   | true          | true      | jennifer  | ? VAI APARECER   |
```

---

### **6. Mensagem Final**

```
| resultado                    | rpcs                      | funcionarios                 | triggers                     | senha                      | proximo_passo                          |
|------------------------------|---------------------------|------------------------------|------------------------------|----------------------------|----------------------------------------|
| ?? INSTALAÇÃO COMPLETA!       | ? Todas as RPCs corrigidas | ? Todos os funcionários ativos | ? Triggers instalados        | ? Senha padrão: 123456    | Acesse: http://localhost:5173/login-local |
```

---

## ? **APÓS A EXECUÇÃO**

### **1?? Testar no Frontend**

```bash
# Acesse:
http://localhost:5173/login-local
```

**Você DEVE ver:**
```
??????????????????????  ??????????????????????
?  ?? Cristiano      ?  ?  ?? Jennifer       ?
?                    ?  ?                    ?
?  Administrador     ?  ?  Vendedor          ?
??????????????????????  ??????????????????????
```

---

### **2?? Fazer Login**

```
1. Clique em qualquer card
2. Digite a senha:
   - Cristiano: (sua senha atual)
   - Jennifer: 123456
   - Outros: 123456
3. ? Deve logar com sucesso
4. Sistema pode pedir troca de senha (normal)
```

---

### **3?? Testar Novo Funcionário**

```
1. Vá em: Administração > Funcionários
2. Clique em "Novo Funcionário"
3. Preencha: Nome, Email, CPF, etc.
4. Clique em "Salvar"
5. ? Trigger cria login automaticamente
6. Volte para /login-local
7. ? Novo funcionário aparece imediatamente
8. Senha: 123456
```

---

## ?? **TROUBLESHOOTING**

### **Problema 1: Erro ao executar**

```sql
-- Verifique se a extensão está instalada:
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

-- Se não estiver, execute:
CREATE EXTENSION pgcrypto;
```

---

### **Problema 2: Funcionários não aparecem**

```sql
-- Execute este diagnóstico:
SELECT 
  f.nome,
  f.usuario_ativo,
  f.senha_definida,
  f.ativo,
  f.status,
  lf.usuario,
  lf.ativo as login_ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Se algum campo estiver NULL ou FALSE, execute novamente a PARTE 6 e 7
```

---

### **Problema 3: RPC não existe**

```sql
-- Liste as RPCs instaladas:
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name LIKE '%usuario%' OR routine_name LIKE '%senha%';

-- Se estiver vazio, execute novamente as PARTES 2-5
```

---

### **Problema 4: Trigger não funciona**

```sql
-- Verifique se os triggers existem:
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name LIKE '%auto%';

-- Se não existir, execute novamente a PARTE 8
```

---

## ?? **CHECKLIST FINAL**

Após executar o script, marque cada item:

- [ ] ? Script executado sem erros
- [ ] ? Verificação de RPCs: todos com ?
- [ ] ? Verificação de Triggers: todos com ?
- [ ] ? Lista de usuários mostra 2+ pessoas
- [ ] ? Estatísticas: aparecendo = total_funcionarios
- [ ] ? Estado final: todos com "? VAI APARECER"
- [ ] ? Frontend `/login-local` mostra todos os cards
- [ ] ? Login funciona com senha 123456
- [ ] ? Novo funcionário aparece automaticamente

---

## ?? **RESUMO ULTRA-RÁPIDO**

```
1. Abra Supabase SQL Editor
2. Cole INSTALACAO_COMPLETA_FINAL.sql
3. Clique em "Run"
4. Aguarde 1 minuto
5. ? Acesse http://localhost:5173/login-local
6. ? Veja todos os funcionários
7. ? Senha: 123456
```

---

## ?? **PRÓXIMOS PASSOS**

1. ? Execute o script
2. ? Teste no frontend
3. ? Cadastre funcionário de teste
4. ? Delete funcionário de teste
5. ? Documente senha padrão para equipe
6. ? Deploy em produção

---

## ?? **SUPORTE**

Se algo der errado, execute este SQL e me mostre o resultado:

```sql
SELECT 
  'RPCs' as tipo,
  COUNT(*) as total
FROM information_schema.routines 
WHERE routine_name IN (
  'listar_usuarios_ativos',
  'validar_senha_local',
  'atualizar_senha_funcionario',
  'trocar_senha_propria'
)
UNION ALL
SELECT 
  'Triggers' as tipo,
  COUNT(*) as total
FROM information_schema.triggers 
WHERE trigger_name LIKE '%auto%'
UNION ALL
SELECT 
  'Funcionários' as tipo,
  COUNT(*) as total
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
UNION ALL
SELECT 
  'Logins' as tipo,
  COUNT(*) as total
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
```

**Resultado esperado:**
```
| tipo         | total |
|--------------|-------|
| RPCs         | 4     |
| Triggers     | 2     |
| Funcionários | 2+    |
| Logins       | 2+    |
```

---

**?? TUDO PRONTO! Sistema 100% funcional e automatizado!**
