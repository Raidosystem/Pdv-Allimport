# ?? GUIA VISUAL - EXECUTAR AGORA

## ?? PASSO A PASSO COM IMAGENS MENTAIS

### **?? PASSO 1: Acessar Supabase (5 segundos)**

```
1. Abra seu navegador
2. Vá para: https://supabase.com/dashboard
3. Faça login (se necessário)
4. Selecione seu projeto "Pdv-Allimport"
```

---

### **?? PASSO 2: Abrir SQL Editor (5 segundos)**

```
1. No menu lateral esquerdo, clique em "SQL Editor"
2. Clique em "New query" (botão verde no canto superior direito)
3. Você verá uma tela em branco para colar o SQL
```

---

### **?? PASSO 3: Copiar e Colar SQL (10 segundos)**

```
1. Abra o arquivo: CORRECAO_COMPLETA_EXECUTAR_AGORA.sql
2. Pressione Ctrl+A (selecionar tudo)
3. Pressione Ctrl+C (copiar)
4. Volte para o Supabase SQL Editor
5. Clique na área de texto
6. Pressione Ctrl+V (colar)
```

**Você deve ver algo assim:**
```sql
-- =============================================
-- ?? CORREÇÃO COMPLETA - EXECUTAR TUDO DE UMA VEZ
-- =============================================
-- Este script consolida todas as correções necessárias
...
```

---

### **?? PASSO 4: Executar o SQL (2 segundos)**

```
1. Clique no botão "RUN" (ou pressione Ctrl+Enter)
2. Aguarde alguns segundos
3. Você verá mensagens de sucesso aparecendo:
```

**Mensagens esperadas:**
```
? PASSO 1: Extension pgcrypto garantida
? PASSO 2: RPC listar_usuarios_ativos corrigida (com campo usuario)
? PASSO 3: RPC validar_senha_local corrigida (compatível senha + senha_hash)
? PASSO 4: RPC atualizar_senha_funcionario corrigida
? PASSO 5: RPC trocar_senha_propria criada
?? VERIFICAÇÃO FINAL (todos com ?)
?? ESTATÍSTICAS (mostra contagem de funcionários)
?? CORREÇÃO COMPLETA!
```

---

### **?? PASSO 5: Verificar Resultado (5 segundos)**

Na parte inferior da tela, você verá:

**Tabela 1: VERIFICAÇÃO FINAL**
```
| secao            | pgcrypto | rpc_listar_usuarios | rpc_validar_senha | ... |
|------------------|----------|---------------------|-------------------|-----|
| ?? VERIFICAÇÃO   | ?       | ?                  | ?                | ... |
```

**Tabela 2: ESTATÍSTICAS**
```
| secao          | total_funcionarios | funcionarios_ativos | ... |
|----------------|-------------------|---------------------|-----|
| ?? ESTATÍSTICAS | 3                 | 2                   | ... |
```

**Tabela 3: CONCLUSÃO**
```
| resultado           | mensagem                               | proximo_passo                          |
|---------------------|----------------------------------------|----------------------------------------|
| ?? CORREÇÃO COMPLETA| Todas as RPCs foram corrigidas...      | Agora teste o login em: http://...    |
```

**? Se você vir essas 3 tabelas com ?, está PRONTO!**

---

### **?? PASSO 6: Testar no Sistema (30 segundos)**

```
1. Abra um novo terminal (VSCode: Ctrl+`)
2. Se o servidor não estiver rodando, execute: npm run dev
3. Abra o navegador em: http://localhost:5173/login-local
```

**O que você DEVE ver:**

```
???????????????????????????????????????????????????????????
?               ?? RaVal pdv                              ?
?          Sistema de Ponto de Venda                      ?
???????????????????????????????????????????????????????????

         Selecione seu usuário para fazer login

   ????????????????  ????????????????  ????????????????
   ? Admin        ?  ? Jennifer     ?  ? Carlos       ?
   ?              ?  ?              ?  ?              ?
   ?    ?????     ?  ?    ?????     ?  ?    ?????     ?
   ?    ? AD ?     ?  ?    ? JS ?     ?  ?    ? CS ?     ?
   ?    ?????     ?  ?    ?????     ?  ?    ?????     ?
   ?              ?  ?              ?  ?              ?
   ? Administrador?  ? Funcionário  ?  ? Funcionário  ?
   ????????????????  ????????????????  ????????????????
```

**? Se aparecer cards como acima, FUNCIONOU!**

---

### **?? PASSO 7: Fazer Login (10 segundos)**

```
1. Clique em um dos cards (ex: Jennifer)
2. Aparecerá tela pedindo senha
3. Digite a senha (ex: 123456)
4. Clique em "Entrar no Sistema"
5. Deve logar e ir para o dashboard
```

**Tela de senha esperada:**
```
?????????????????????????????????????????????????????????????
?                    ? Voltar                               ?
?                                                           ?
?                     ?????                                 ?
?                     ? JS ?                                ?
?                     ?????                                 ?
?                                                           ?
?              Bem-vindo, Jennifer!                         ?
?          Digite sua senha para continuar                  ?
?                                                           ?
?   Senha: [???????] ??                                     ?
?                                                           ?
?          [ ?? Entrar no Sistema ]                         ?
?????????????????????????????????????????????????????????????
```

---

## ? CHECKLIST DE SUCESSO

Marque conforme vai executando:

```
[ ] 1. Acessei Supabase
[ ] 2. Abri SQL Editor
[ ] 3. Copiei CORRECAO_COMPLETA_EXECUTAR_AGORA.sql
[ ] 4. Colei no editor
[ ] 5. Cliquei em RUN
[ ] 6. Vi mensagens de sucesso (?)
[ ] 7. Vi tabelas de verificação (todas com ?)
[ ] 8. Acessei http://localhost:5173/login-local
[ ] 9. Vi cards de usuários
[ ] 10. Cliquei em um card
[ ] 11. Digitei a senha
[ ] 12. Logou com sucesso! ??
```

---

## ?? TROUBLESHOOTING RÁPIDO

### **? Não vejo cards de usuários**

**Causa**: Nenhum funcionário ativo
**Solução**:
```sql
-- Execute no Supabase SQL Editor:
UPDATE funcionarios
SET usuario_ativo = true,
    senha_definida = true
WHERE empresa_id = (SELECT id FROM empresas LIMIT 1);
```

---

### **? Senha não valida (sempre incorreta)**

**Causa**: Senha não foi setada corretamente
**Solução**:
```sql
-- Resetar senha do usuário (substitua 'usuario_aqui'):
SELECT atualizar_senha_funcionario(
  (SELECT funcionario_id FROM login_funcionarios WHERE usuario = 'usuario_aqui'),
  'nova_senha_123'
);
```

---

### **? Erro "Cannot read property 'usuario'"**

**Causa**: RPC não foi atualizada
**Solução**:
```sql
-- Reexecutar CORRECAO_COMPLETA_EXECUTAR_AGORA.sql
-- OU executar apenas FIX_LISTAR_USUARIOS_ATIVOS.sql
```

---

### **? Erro "Extension pgcrypto not found"**

**Causa**: Extensão não instalada
**Solução**:
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

---

## ?? DIAGNÓSTICO COMPLETO

Se nada funcionar, execute este SQL para diagnóstico:

```sql
-- Copie e cole no Supabase SQL Editor:
-- Arquivo: DIAGNOSTICO_LOGIN_FUNCIONARIOS.sql
```

Procure por linhas com ? e corrija conforme indicado acima.

---

## ?? RESULTADO FINAL ESPERADO

Ao completar todos os passos:

```
? SQL executado sem erros
? Todas as RPCs corrigidas
? Cards aparecem na tela
? Login funciona perfeitamente
? Dashboard carrega
? Permissões aplicadas
? Sistema 100% funcional!
```

---

## ?? TEMPO TOTAL ESTIMADO

```
?? Preparação:    2 min
??? Executar SQL: 30 seg
?? Testar:        2 min
?????????????????????
?? TOTAL:        ~5 min
```

---

## ?? PRECISA DE AJUDA?

**Logs do navegador:**
1. Pressione F12
2. Vá na aba "Console"
3. Procure por erros em vermelho
4. Copie e analise

**Logs do Supabase:**
1. Vá em "Logs" no menu lateral
2. Selecione "Postgres Logs"
3. Procure por erros recentes

**Arquivos de suporte:**
- `CORRECAO_RAPIDA_LOGIN.md` - Guia completo
- `DIAGNOSTICO_LOGIN_FUNCIONARIOS.sql` - Diagnóstico
- `CORRECAO_COMPLETA_EXECUTAR_AGORA.sql` - Script de correção

---

**?? Você consegue! É mais fácil do que parece!**

**?? Foco:** Execute o `CORRECAO_COMPLETA_EXECUTAR_AGORA.sql` e teste!

**?? Em 5 minutos está tudo funcionando!**

---

**Criado para facilitar sua vida! ??**
