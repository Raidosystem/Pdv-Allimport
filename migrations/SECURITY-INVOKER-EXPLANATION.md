# 🔒 Segurança das Funções - SECURITY INVOKER

## ⚠️ Mudança Importante

As funções foram alteradas de `SECURITY DEFINER` para `SECURITY INVOKER` para permitir chamadas diretas do frontend de forma segura.

---

## 📋 O que mudou?

### **ANTES** (SECURITY DEFINER):
```sql
CREATE OR REPLACE FUNCTION public.generate_verification_code(...)
RETURNS TABLE(...) 
LANGUAGE plpgsql
SECURITY DEFINER  -- ❌ Executa com permissões do dono da função
```

**Problema**: Requer Edge Functions ou Service Role Key para chamar.

---

### **DEPOIS** (SECURITY INVOKER):
```sql
CREATE OR REPLACE FUNCTION public.generate_verification_code(...)
RETURNS TABLE(...) 
LANGUAGE plpgsql
SECURITY INVOKER  -- ✅ Executa com permissões do usuário autenticado
```

**Vantagem**: Pode ser chamada diretamente do frontend com segurança.

---

## 🛡️ Proteções Implementadas

### 1️⃣ **Verificação de Autenticação**
```sql
IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
END IF;
```

### 2️⃣ **Verificação de Propriedade**
```sql
IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Você só pode gerar códigos para sua própria conta';
END IF;
```

### 3️⃣ **RLS (Row Level Security)**
Apenas o próprio usuário pode:
- ✅ Ver seus códigos
- ✅ Inserir códigos
- ✅ Atualizar tentativas
- ✅ Deletar códigos antigos

---

## ✅ Funções Atualizadas

### 1. `generate_verification_code()`
- **Antes**: SECURITY DEFINER
- **Depois**: SECURITY INVOKER
- **Proteção**: Verifica se `auth.uid() = p_user_id`

### 2. `verify_whatsapp_code()`
- **Antes**: SECURITY DEFINER
- **Depois**: SECURITY INVOKER
- **Proteção**: Verifica se `auth.uid() = p_user_id`

### 3. `cleanup_expired_verification_codes()`
- **Mantido**: SECURITY DEFINER (apenas admin pode executar)

---

## 🚀 Como Usar

### Frontend pode chamar diretamente:

```typescript
// Gerar código
const { data, error } = await supabase.rpc('generate_verification_code', {
  p_user_id: user.id,
  p_phone: '+5511999999999'
})

// Verificar código
const { data: isValid, error } = await supabase.rpc('verify_whatsapp_code', {
  p_user_id: user.id,
  p_code: '123456'
})
```

---

## 🔐 Por que é seguro?

1. **RLS Ativo**: Usuário só acessa seus próprios dados
2. **Validação de Propriedade**: Função verifica `auth.uid()`
3. **Sem Escalação de Privilégios**: Executa com permissões do usuário

---

## ⚙️ Alternativa: SECURITY DEFINER + Edge Functions

Se preferir usar `SECURITY DEFINER`, você precisaria:

### Criar Edge Function:

```typescript
// supabase/functions/verify-whatsapp/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { userId, code } = await req.json()
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // SERVICE_ROLE
  )
  
  const { data, error } = await supabase.rpc('verify_whatsapp_code', {
    p_user_id: userId,
    p_code: code
  })
  
  return new Response(JSON.stringify({ data, error }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Frontend chamaria a Edge Function:

```typescript
const { data, error } = await supabase.functions.invoke('verify-whatsapp', {
  body: { userId: user.id, code: '123456' }
})
```

**Vantagem**: Mais controle e segurança adicional
**Desvantagem**: Mais complexo de configurar

---

## 📝 Recomendação

Para o seu caso (sistema PDV com usuários controlados):

✅ **Use SECURITY INVOKER** (implementação atual)
- Mais simples
- Seguro com RLS
- Sem necessidade de Edge Functions

❌ **Não use SECURITY DEFINER** a menos que:
- Precise de lógica complexa no backend
- Tenha muitos usuários não confiáveis
- Precise de auditoria avançada

---

## 🧪 Como Testar

1. **Execute o SQL atualizado** no Supabase
2. **Teste** chamar as funções do frontend
3. **Verifique** que funciona sem Edge Functions
4. **Confirme** que RLS está protegendo os dados

---

**Atualizado em**: 10/10/2025
**Versão**: 2.0.0 (SECURITY INVOKER)
