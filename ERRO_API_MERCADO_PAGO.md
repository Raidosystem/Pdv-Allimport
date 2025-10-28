# 🐛 ERRO CRÍTICO: API do Mercado Pago - Pagamento com Cartão

## ❌ Problema Encontrado

Ao clicar em "Pagar com Cartão", o checkout do Mercado Pago **não abre** porque o token de acesso está incorreto.

### 📍 Localização do Erro

**Arquivo**: `src/services/mercadoPagoApiService.ts`  
**Linha**: 47-48

### 🔍 Código Atual (ERRADO)

```typescript
// Credenciais de produção do Mercado Pago
private readonly PRODUCTION_ACCESS_TOKEN = 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';
private readonly PRODUCTION_PUBLIC_KEY = 'APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022';
```

### ⚠️ O Problema

O valor está sendo tratado como **string literal** em vez de **acessar a variável de ambiente**:

- ❌ Valor atual: `"process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN"` (texto)
- ✅ Valor esperado: O token real do Mercado Pago (ex: `"APP_USR-123abc..."`)

Isso faz com que a API do Mercado Pago **rejeite** a requisição por autenticação inválida.

### ✅ Correção Necessária

```typescript
// Credenciais de produção do Mercado Pago
private readonly PRODUCTION_ACCESS_TOKEN = import.meta.env.VITE_MP_ACCESS_TOKEN || '';
private readonly PRODUCTION_PUBLIC_KEY = import.meta.env.VITE_MP_PUBLIC_KEY || 'APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022';
```

### 📋 Passos para Corrigir

1. **Editar o arquivo** `src/services/mercadoPagoApiService.ts`
2. **Substituir a linha 47** pela correção acima
3. **Verificar** se o arquivo `.env` tem as variáveis corretas:
   ```env
   VITE_MP_ACCESS_TOKEN=APP_USR-seu-token-aqui
   VITE_MP_PUBLIC_KEY=APP_USR-sua-chave-publica-aqui
   ```
4. **Reiniciar** o servidor de desenvolvimento

### 🔍 Como Testar

Após a correção, abra o console do navegador (F12) e verifique:

1. Clique em "Pagar com Cartão"
2. Observe os logs no console:
   - ✅ Deve mostrar: `🚀 Iniciando createPaymentPreference com dados: {...}`
   - ✅ Deve mostrar: `✅ Resposta da API Preference: {...}`
   - ✅ Deve abrir o checkout do Mercado Pago em nova aba

### 🎯 Impacto

**Antes da correção:**
- ❌ Checkout não abre
- ❌ Erro 401 (Unauthorized) na API do Mercado Pago
- ❌ Pagamentos com cartão não funcionam

**Depois da correção:**
- ✅ Checkout abre corretamente
- ✅ API autentica com sucesso
- ✅ Pagamentos com cartão funcionam normalmente

---

## 📝 Detalhes Técnicos

### Fluxo de Pagamento com Cartão

1. Usuário clica em "Pagar com Cartão"
2. Frontend chama `mercadoPagoApiService.createPaymentPreference()`
3. Serviço faz requisição para `https://pdv.crmvsystem.com/api/preference`
4. API Vercel cria preferência no Mercado Pago usando o **ACCESS_TOKEN**
5. Mercado Pago retorna URL do checkout
6. Frontend abre URL em nova aba com `window.open()`

### Por que o erro ocorre?

No passo **4**, a API Vercel tenta autenticar com o Mercado Pago usando o token.  
Como o token está errado (é uma string literal), o Mercado Pago rejeita com **401 Unauthorized**.

### Logs de Erro Esperados

```
❌ API Error 401: Unauthorized
❌ Erro na API (/api/preference): API Error: 401 - Unauthorized
❌ Erro ao criar preferência: Erro ao processar pagamento. Verifique sua conexão e tente novamente.
```

---

## 🚀 Próximos Passos

1. Aplicar a correção no código
2. Verificar variáveis de ambiente
3. Testar pagamento com cartão
4. Commit e deploy da correção
