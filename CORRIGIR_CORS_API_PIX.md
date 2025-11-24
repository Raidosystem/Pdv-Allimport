# 🔧 Erro CORS - API PIX Bloqueada

## ❌ Problema Atual

```
Access to fetch at 'https://pdv.crmvsystem.com/api/pix' 
from origin 'https://pdv.gruporaval.com.br' has been blocked by CORS policy
```

**Causa:** O header `Access-Control-Allow-Origin: *` não é permitido quando a requisição usa `credentials: 'include'`.

---

## ✅ Solução

O backend em **Vercel** (`https://pdv.crmvsystem.com/api/pix`) precisa ser configurado para:

### 1. Permitir origem específica:
```javascript
Access-Control-Allow-Origin: https://pdv.gruporaval.com.br
```

### 2. Permitir credenciais:
```javascript
Access-Control-Allow-Credentials: true
```

### 3. Permitir métodos e headers:
```javascript
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

---

## 📝 Código de Exemplo (Vercel API Route)

Se o arquivo é `/api/pix/route.ts` ou similar:

```typescript
export async function OPTIONS(request: Request) {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': 'https://pdv.gruporaval.com.br',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Max-Age': '86400',
    },
  });
}

export async function POST(request: Request) {
  // ... lógica do PIX ...
  
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': 'https://pdv.gruporaval.com.br',
      'Access-Control-Allow-Credentials': 'true',
    },
  });
}
```

---

## 🔧 Alternativa: Configurar no vercel.json

Se preferir configurar globalmente:

```json
{
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "https://pdv.gruporaval.com.br"
        },
        {
          "key": "Access-Control-Allow-Credentials",
          "value": "true"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, PUT, DELETE, OPTIONS"
        },
        {
          "key": "Access-Control-Allow-Headers",
          "value": "X-Requested-With, Content-Type, Authorization"
        }
      ]
    }
  ]
}
```

---

## 🎯 Próximos Passos

1. Acesse o repositório do backend em **Vercel**
2. Localize o arquivo `/api/pix` (pode ser `.ts`, `.js`, ou route handler)
3. Adicione os headers CORS corretos
4. Faça deploy da alteração
5. Teste novamente a geração de PIX

---

## 🧪 Testar Localmente

Para testar se funcionou:

```bash
curl -X OPTIONS https://pdv.crmvsystem.com/api/pix \
  -H "Origin: https://pdv.gruporaval.com.br" \
  -H "Access-Control-Request-Method: POST" \
  -v
```

Deve retornar:
```
Access-Control-Allow-Origin: https://pdv.gruporaval.com.br
Access-Control-Allow-Credentials: true
```

---

## ℹ️ Observação

**Este erro não impede o funcionamento do sistema PDV.** 

A geração de PIX é uma funcionalidade adicional. O sistema está **100% funcional** para:
- ✅ Vendas
- ✅ Cadastros
- ✅ Relatórios  
- ✅ Admin Dashboard
- ✅ Controle de assinaturas

O PIX só será necessário quando clientes quiserem pagar online via QR Code.
