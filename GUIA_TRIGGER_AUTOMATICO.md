# 🤖 CRIAÇÃO AUTOMÁTICA DE EMPRESA E SUBSCRIPTION

## 🎯 O que este script faz?

Cria um **TRIGGER** no Supabase que **automaticamente**:

1. ✅ Cria uma empresa para **CADA NOVO USUÁRIO** que se cadastrar
2. ✅ Cria uma subscription ativa (1 ano) para o usuário
3. ✅ Cria empresa e subscription para **usuários existentes** que não têm

## 📋 Como Funcionar

### **PASSO 1: Executar o script**

Abra o **Supabase SQL Editor** e execute o arquivo:
```
CRIAR_TRIGGER_EMPRESA_AUTOMATICA.sql
```

### **PASSO 2: O que acontece**

**Para usuários existentes:**
- ✅ Busca todos os usuários na tabela `auth.users`
- ✅ Cria empresa para quem não tem
- ✅ Cria subscription para quem não tem

**Para novos usuários (automático):**
- 👤 Usuário se cadastra
- 🤖 **TRIGGER** detecta automaticamente
- ✅ Cria empresa com dados do usuário
- ✅ Cria subscription ativa (1 ano)
- ✨ **TUDO AUTOMÁTICO!**

### **PASSO 3: Verificar**

O script mostra uma tabela com todos os usuários:

```
| usuario_email          | empresa_nome  | plano  | status        |
|------------------------|---------------|--------|---------------|
| cris-ramos30@...       | Minha Empresa | yearly | ✅ OK         |
| outro@email.com        | Minha Empresa | yearly | ✅ OK         |
```

## 🔧 Dados Criados Automaticamente

### **Empresa:**
- `user_id`: ID do usuário
- `nome`: Nome do perfil do usuário OU "Minha Empresa"
- `email`: Email do usuário
- `telefone`: Telefone do usuário OU "(00) 00000-0000"
- Outros campos: Valores padrão (podem ser editados depois)

### **Subscription:**
- `plan_type`: "yearly" (anual)
- `status`: "active" (ativa)
- `subscription_end_date`: Hoje + 1 ano

## ⚙️ Como Funciona o Trigger

```sql
USUÁRIO SE CADASTRA
       ↓
auth.users (INSERT)
       ↓
TRIGGER detecta
       ↓
Função create_empresa_for_new_user()
       ↓
Cria empresa + subscription
       ↓
✅ PRONTO!
```

## 🧪 Testar

1. **Cadastre um novo usuário** no sistema
2. **Verifique no SQL Editor:**
   ```sql
   SELECT 
     e.nome,
     u.email,
     s.plan_type
   FROM empresas e
   JOIN auth.users u ON u.id = e.user_id
   JOIN subscriptions s ON s.user_id = e.user_id
   WHERE u.email = 'email-do-novo-usuario@teste.com';
   ```
3. Deve retornar a empresa e subscription criadas automaticamente!

## ✅ Vantagens

- 🤖 **100% Automático** - Não precisa criar manualmente
- 🔄 **Retroativo** - Cria para usuários existentes
- 🎯 **Consistente** - Todos os usuários terão empresa e subscription
- 🚀 **Rápido** - Executa no momento do cadastro

## ⚠️ Importante

- O trigger funciona apenas para **novos cadastros** depois de executar o script
- Usuários existentes são processados na primeira execução do script
- Você pode editar os dados da empresa depois no painel Admin

## 🎨 Personalizar

Para mudar os valores padrão, edite a função:

```sql
-- Mudar plano padrão (linha 34)
'yearly' → 'monthly' ou 'free'

-- Mudar duração (linha 38)
NOW() + INTERVAL '1 year' → '6 months', '3 months', etc

-- Mudar nome padrão (linha 15)
'Minha Empresa' → 'Nome personalizado'
```

---

## 🎯 Resultado Final

Após executar o script:
- ✅ Todos os usuários terão empresa
- ✅ Todos os usuários terão subscription
- ✅ Novos usuários receberão automaticamente
- ✅ Erro 406 no Admin Dashboard será resolvido
- ✅ Sistema funcionará para todos os usuários!
