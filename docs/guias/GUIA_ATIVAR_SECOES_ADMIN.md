# 🔓 ATIVAR SEÇÕES DE ADMINISTRAÇÃO

## 🎯 Objetivo

Habilitar com segurança as 3 seções:
- ✅ **Usuários** - Gerenciar usuários do sistema
- ✅ **Convites** - Convidar novos usuários  
- ✅ **Funções & Permissões** - Configurar roles e permissões

## 📋 Passo a Passo

### **PASSO 1: Executar script SQL**

Abra o **Supabase SQL Editor** e execute o arquivo:
```
ATIVAR_PERMISSOES_ADMIN.sql
```

Este script irá:
1. ✅ Verificar se você tem registro como funcionário
2. ✅ Criar registro de funcionário se não existir
3. ✅ Criar função "Administrador" se não existir
4. ✅ Atribuir função Administrador a você
5. ✅ Criar TODAS as permissões necessárias
6. ✅ Mostrar resultado final

### **PASSO 2: Verificar resultado**

Após executar, você verá:

```
| funcionario_nome | email                    | status | funcao        | nivel | total_permissoes |
|------------------|--------------------------|--------|---------------|-------|------------------|
| Administrador    | cris-ramos30@hotmail.com | ativo  | Administrador | 1     | 35               |
```

E uma lista com todas as 35 permissões:
- `administracao.usuarios:create`
- `administracao.usuarios:read`
- `administracao.usuarios:update`
- `administracao.usuarios:delete`
- `administracao.usuarios:invite`
- `administracao.funcoes:create`
- `administracao.funcoes:read`
- `administracao.funcoes:update`
- `administracao.funcoes:delete`
- E mais 26 permissões...

### **PASSO 3: Recarregar a aplicação**

1. **Feche e abra** o navegador (ou pressione Ctrl + Shift + R)
2. **Faça login novamente** se necessário
3. Acesse **Administração do Sistema**

### **PASSO 4: Verificar funcionamento**

Agora as 3 seções devem estar **totalmente funcionais**:

#### 📊 **Usuários**
- ✅ Listagem de todos os usuários
- ✅ Busca e filtros
- ✅ Edição de usuários
- ✅ Ativação/Desativação
- ✅ Exclusão de usuários
- ✅ Reenvio de convites

#### ✉️ **Convites**
- ✅ Formulário para convidar novos usuários
- ✅ Seleção de funções
- ✅ Envio de e-mail de convite
- ✅ Validação de dados

#### 🛡️ **Funções & Permissões**
- ✅ Matriz visual de permissões
- ✅ Criação de novas funções
- ✅ Edição de funções existentes
- ✅ Atribuição de permissões
- ✅ Controle granular de acesso

## 🔍 Diagnóstico de Problemas

Se alguma seção não funcionar:

### **Problema 1: "Você não tem permissão"**

**Solução:**
```sql
-- Verificar permissões do usuário
SELECT 
  fp.recurso,
  fp.acao,
  'SIM' as tem_permissao
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN funcionario_funcoes ff ON ff.funcao_id = func.id
JOIN funcionarios f ON f.id = ff.funcionario_id
WHERE f.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com')
ORDER BY fp.recurso, fp.acao;
```

Se não retornar nada, execute novamente o PASSO 1.

### **Problema 2: "Erro ao carregar dados"**

**Solução:**
```sql
-- Verificar políticas RLS
SELECT tablename, policyname
FROM pg_policies 
WHERE tablename IN ('funcionarios', 'funcoes', 'funcao_permissoes', 'funcionario_funcoes')
ORDER BY tablename;
```

### **Problema 3: Seção aparece vazia**

**Solução:**
1. Abra o **Console do navegador** (F12)
2. Procure por erros em vermelho
3. Verifique os logs com 🔍 (emoji de busca)

## ✅ Checklist de Verificação

Após executar tudo:

- [ ] Script SQL executado sem erros
- [ ] Resultado mostra 35 permissões
- [ ] Navegador recarregado (Ctrl + Shift + R)
- [ ] Console sem erros em vermelho
- [ ] Seção "Usuários" abre e mostra dados
- [ ] Seção "Convites" abre formulário
- [ ] Seção "Funções & Permissões" mostra matriz

## 🎯 Resultado Esperado

Após seguir todos os passos, você terá:

✅ **Acesso total** às 3 seções administrativas
✅ **Permissões completas** para gerenciar o sistema
✅ **Função Administrador** atribuída
✅ **Sistema funcionando** sem erros

## 🆘 Suporte

Se algo não funcionar:
1. Verifique o console do navegador
2. Execute o script SQL de diagnóstico
3. Compartilhe os erros específicos

---

**Importante:** Este script é seguro e **não quebra** nada no código. Ele apenas:
- Cria dados necessários no banco
- Atribui permissões
- Não modifica código TypeScript/React
