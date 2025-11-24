# 🔧 SOLUÇÃO: CORS no Backend API

## ❌ Problema Identificado

O erro persiste porque o **backend está em outro domínio**:
- Frontend: `pdv.gruporaval.com.br` ✅
- Backend API: `pdv.crmvsystem.com` ❌ (precisa configurar CORS)

## 📍 Onde Configurar

O backend em `pdv.crmvsystem.com` é um **projeto separado na Vercel**.

### Opção 1: Se você tem acesso ao repositório do backend

Localize o arquivo que contém as rotas da API (geralmente em `/api/pix` e `/api/preference`) e adicione:

```typescript
// api/pix/route.ts (ou similar)

export async function OPTIONS(request: Request) {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': 'https://pdv.gruporaval.com.br',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Credentials': 'true',
    },
  });
}

export async function POST(request: Request) {
  try {
    // ... lógica do PIX ...
    
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': 'https://pdv.gruporaval.com.br',
        'Access-Control-Allow-Credentials': 'true',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': 'https://pdv.gruporaval.com.br',
        'Access-Control-Allow-Credentials': 'true',
      },
    });
  }
}
```

### Opção 2: Configurar no vercel.json do backend

Crie/edite o `vercel.json` no **projeto do backend** (`pdv.crmvsystem.com`):

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

## 🎯 Solução Alternativa (Sem Modificar Backend)

Se você **não tem acesso ao backend**, a melhor opção é **usar um proxy**:

### Criar rota proxy no frontend

Crie `/api/pix.ts` no **frontend**:

```typescript
// api/pix.ts
export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const response = await fetch('https://pdv.crmvsystem.com/api/pix', {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Erro ao processar pagamento' });
  }
}
```

E alterar o código do frontend para chamar `/api/pix` ao invés de `https://pdv.crmvsystem.com/api/pix`.

---

## ⚡ Solução Mais Rápida (Temporária)

Remover `credentials: 'include'` das requisições fetch no frontend:

```typescript
// Antes:
fetch(url, {
  method: 'POST',
  credentials: 'include', // ← REMOVER
  headers: { ... }
})

// Depois:
fetch(url, {
  method: 'POST',
  headers: { ... }
})
```

Isso permite usar `Access-Control-Allow-Origin: *`, mas **não é recomendado** se você precisa de cookies/autenticação.

---

## 📋 Checklist

- [ ] Identificar se você tem acesso ao repositório do backend (`pdv.crmvsystem.com`)
- [ ] Aplicar a correção no backend (Opção 1 ou 2)
- [ ] OU criar proxy no frontend (Alternativa)
- [ ] Fazer deploy das alterações
- [ ] Testar geração de PIX novamente

---

## 🔍 Como Identificar o Repositório do Backend?

1. Acesse: https://vercel.com/
2. Procure por projeto chamado `pdv-crmvsystem` ou similar
3. Veja o repositório GitHub vinculado
4. Clone o repositório e aplique as correções

**Me diga se você tem acesso ao backend ou se prefere usar o proxy!**
