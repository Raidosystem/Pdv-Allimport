# ✅ Implementação: Editar Senha de Funcionários

## 🎯 Objetivo
Permitir que administradores **resetem senhas esquecidas** de funcionários através do painel de gestão de usuários.

---

## 📝 Alterações Realizadas

### 1️⃣ Frontend: AdminUsersPage.tsx
✅ **Adicionado ao EditUserModal**:
- ✅ Checkbox "Alterar senha" para ativar/desativar edição
- ✅ Campo "Nova Senha" com validação mínima de 6 caracteres
- ✅ Botão para mostrar/ocultar senha (ícone de olho)
- ✅ Validação antes de submeter
- ✅ Chamada para RPC `atualizar_senha_funcionario`
- ✅ Importação dos ícones `Eye` e `EyeOff` do lucide-react

**Estados adicionados**:
```typescript
const [novaSenha, setNovaSenha] = useState('');
const [mostrarSenha, setMostrarSenha] = useState(false);
const [alterarSenha, setAlterarSenha] = useState(false);
```

**Fluxo de validação**:
1. Usuário marca checkbox "Alterar senha"
2. Campo de senha aparece
3. Ao submeter, valida se senha tem 6+ caracteres
4. Chama RPC para atualizar com bcrypt
5. Mostra mensagem de sucesso

---

## 🔧 Passo a Passo para Finalizar

### ⚠️ IMPORTANTE: Execute no Supabase SQL Editor

1. **Abra o Dashboard do Supabase**: https://supabase.com/dashboard
2. **Vá em**: SQL Editor
3. **Execute o arquivo**: `CRIAR_RPC_ATUALIZAR_SENHA.sql`

```sql
-- Este SQL cria a função atualizar_senha_funcionario
-- que usa bcrypt para hash seguro da nova senha
```

4. **Verifique a criação**:
```sql
-- Listar funções RPC criadas
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'atualizar_senha_funcionario';
```

Deve retornar:
```
routine_name                  | routine_type
------------------------------|-------------
atualizar_senha_funcionario   | FUNCTION
```

---

## 🧪 Como Testar

### 1. Testar a RPC no SQL Editor (opcional)
```sql
-- Primeiro, pegue um ID de funcionário
SELECT id, nome FROM funcionarios LIMIT 1;

-- Depois teste a função
SELECT atualizar_senha_funcionario(
    'ID_DO_FUNCIONARIO_AQUI'::uuid,
    'senhaTestE123'
);

-- Verificar se atualizou
SELECT funcionario_id, senha_hash, updated_at 
FROM login_funcionarios 
WHERE funcionario_id = 'ID_DO_FUNCIONARIO_AQUI'::uuid;
```

### 2. Testar no Frontend

#### Passo a Passo:
1. **Acesse**: Painel Admin → Usuários
2. **Clique em**: Botão "Editar" (ícone lápis) de um funcionário
3. **Marque**: Checkbox "Alterar senha"
4. **Digite**: Uma nova senha (mínimo 6 caracteres)
5. **Clique**: Botão de mostrar/ocultar senha para verificar
6. **Clique**: "Salvar Alterações"
7. **Verifique**: Mensagem "✅ Usuário e senha atualizados com sucesso!"

#### Validar Login com Nova Senha:
1. **Faça logout** do sistema
2. **Acesse**: Tela de Login de Funcionários (`/funcionarios/login`)
3. **Digite**: Email do funcionário + nova senha
4. **Clique**: "Entrar"
5. **Deve**: Logar com sucesso ✅

---

## 🔐 Segurança Implementada

✅ **Bcrypt**: Senha criptografada com salt automático (`gen_salt('bf')`)  
✅ **Validação**: Mínimo 6 caracteres obrigatório  
✅ **RLS**: Função `SECURITY DEFINER` garante permissões corretas  
✅ **Frontend**: Senha não é exibida no input por padrão  
✅ **Log**: Console.log apenas informa sucesso, não loga senha  

---

## 📊 Estrutura de Banco

### Tabela: `login_funcionarios`
```sql
CREATE TABLE login_funcionarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### RPC: `atualizar_senha_funcionario`
- **Entrada**: `p_funcionario_id` (UUID), `p_nova_senha` (TEXT)
- **Saída**: `void` (sem retorno, lança exceção em erro)
- **Segurança**: `SECURITY DEFINER` + Grant para `authenticated`

---

## 🚨 Troubleshooting

### Erro: "function atualizar_senha_funcionario does not exist"
**Solução**: Execute o SQL `CRIAR_RPC_ATUALIZAR_SENHA.sql` no Supabase

### Erro: "Funcionário não encontrado na tabela de login"
**Causa**: O funcionário não tem registro em `login_funcionarios`  
**Solução**: 
1. Verifique se foi criado via `criar_funcionario_com_senha`
2. Ou crie manualmente:
```sql
INSERT INTO login_funcionarios (funcionario_id, email, senha_hash)
VALUES (
    'ID_DO_FUNCIONARIO',
    'email@example.com',
    crypt('senhaInicial123', gen_salt('bf'))
);
```

### Erro: "A senha deve ter pelo menos 6 caracteres"
**Causa**: Validação bloqueando senha curta  
**Solução**: Digite senha com 6+ caracteres

### Senha atualizada mas não consegue logar
**Verificar**:
1. Email está correto na tabela `login_funcionarios`?
2. `funcionario_id` corresponde ao ID correto?
3. Teste login com senha antiga para confirmar que mudou

---

## ✅ Checklist Final

- [ ] SQL `CRIAR_RPC_ATUALIZAR_SENHA.sql` executado no Supabase
- [ ] Função RPC aparece no SQL Editor (query de verificação)
- [ ] Frontend compila sem erros (`npm run dev`)
- [ ] Modal de edição abre corretamente
- [ ] Checkbox "Alterar senha" funciona
- [ ] Campo de senha aparece quando marcado
- [ ] Botão de mostrar/ocultar senha funciona
- [ ] Validação de 6 caracteres funciona
- [ ] Ao salvar, mostra mensagem de sucesso
- [ ] Login com nova senha funciona ✅

---

## 📚 Arquivos Modificados

1. ✅ `src/pages/admin/AdminUsersPage.tsx` - Adicionado campo de senha no EditUserModal
2. ✅ `CRIAR_RPC_ATUALIZAR_SENHA.sql` - RPC para atualizar senha com bcrypt

---

## 🎉 Próximos Passos

Após implementar, você pode adicionar:
- [ ] Botão "Gerar senha aleatória" para facilitar reset
- [ ] Campo "Confirmar senha" para dupla verificação
- [ ] Histórico de alterações de senha
- [ ] Notificação por email quando senha é alterada
- [ ] Expiração de senha após X dias
- [ ] Requisitos de senha forte (letras, números, símbolos)

---

**Dúvidas?** Verifique os logs do console (`console.log('🔑 Atualizando senha...')`) para debug.
