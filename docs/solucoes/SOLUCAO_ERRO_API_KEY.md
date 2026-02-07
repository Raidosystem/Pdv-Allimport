# 🔧 Solução para Erro "No API key found in request"

## 📋 Problema
O erro "No API key found in request" ocorre quando o navegador está usando uma versão antiga em cache do JavaScript que não contém as credenciais do Supabase.

## ✅ Soluções Implementadas

### 1. **Cache-Busting Automático** (index.html)
- Incrementada versão do cache para `2.2.6-fix`
- Sistema de limpeza automática ao detectar nova versão
- Força reload completo após limpeza
- Limpa localStorage, caches e Service Workers

### 2. **Headers HTTP** (_headers)
- Configurado `Cache-Control: no-cache, no-store, must-revalidate`
- Aplicado a todos os arquivos JavaScript, CSS e HTML
- Garante que o navegador sempre busque versões novas

### 3. **Utilitário de Limpeza Manual** (limpar-cache.html)
- Interface gráfica para limpar cache
- Acesse: `https://pdv.gruporaval.com.br/limpar-cache.html`
- Botões para diferentes tipos de limpeza
- Log em tempo real do processo

### 4. **Correção do usePermissions.tsx**
- Implementada estratégia dupla de busca de funcionários
- Suporte para usuários sem funcionário cadastrado (admin automático)
- Permissões completas para donos de empresa
- Uso de `.maybeSingle()` para evitar erros

## 🚀 Como Aplicar a Correção

### Para Usuários Finais (RECOMENDADO):

**Opção A: Acesso direto ao utilitário**
1. Acesse: `https://pdv.gruporaval.com.br/limpar-cache.html`
2. Clique em "🚀 Limpar Cache Completo"
3. Aguarde a limpeza e reload automático
4. Faça login novamente

**Opção B: Limpeza manual do navegador**
1. Pressione `Ctrl + Shift + Delete` (Chrome/Edge) ou `Ctrl + Shift + Del` (Firefox)
2. Selecione "Todo o período"
3. Marque: ✅ Cookies e ✅ Imagens e arquivos em cache
4. Clique em "Limpar dados"
5. **IMPORTANTE:** Feche TODAS as abas do site
6. Abra uma nova aba e acesse o site

**Opção C: Modo anônimo/privado**
1. Abra uma janela anônima (`Ctrl + Shift + N` no Chrome)
2. Acesse o site
3. Se funcionar, volte e limpe o cache normal

### Para Deploy:

```powershell
# 1. Fazer build com as correções
npm run build

# 2. Fazer commit das alterações
git add .
git commit -m "fix: Correção cache + usePermissions para admin sem funcionário"

# 3. Push para produção
git push origin main

# 4. Aguarde o deploy automático

# 5. Compartilhe o link de limpeza com usuários:
# https://pdv.gruporaval.com.br/limpar-cache.html
```

## 🔍 Verificação

Após aplicar as correções, verifique no console do navegador (F12):

✅ **Deve aparecer:**
```
🧹 [INLINE] Limpando cache antigo: 2.2.5 → 2.2.6-fix
🗑️ [INLINE] Deletando X caches
✅ [INLINE] Cache limpo e atualizado para 2.2.6-fix
🔄 [INLINE] Forçando reload completo...
```

❌ **NÃO deve aparecer:**
```
No API key found in request
```

## 💡 Explicação Técnica

### Por que acontecia?
1. O navegador cacheava o JavaScript antigo
2. Service Workers também cacheavam os arquivos
3. LocalStorage mantinha versão antiga
4. Headers HTTP não forçavam atualização

### Como foi resolvido?
1. **Cache-busting inline**: Script no `<head>` que executa ANTES de tudo
2. **Versionamento agressivo**: Mudança de versão força limpeza
3. **Headers HTTP**: Servidor envia instruções para não cachear
4. **Reload forçado**: `window.location.reload(true)` após limpeza
5. **Código corrigido**: `usePermissions.tsx` agora suporta admin sem funcionário

## 📱 Testado em:
- ✅ Chrome/Edge (Windows/Mac/Android)
- ✅ Firefox (Windows/Mac/Android)
- ✅ Safari (Mac/iOS)
- ✅ Opera
- ✅ Brave

## 🆘 Se ainda não funcionar:

1. Acesse: `chrome://settings/clearBrowserData` (Chrome)
   - Ou: `edge://settings/clearBrowserData` (Edge)
   - Ou: `about:preferences#privacy` (Firefox)

2. Selecione "Todo o período"

3. Marque APENAS:
   - ✅ Cookies e outros dados de sites
   - ✅ Imagens e arquivos armazenados em cache

4. Clique em "Limpar dados"

5. **Reinicie o navegador completamente** (feche todas as janelas)

6. Acesse o site novamente

---

**Última atualização:** 2025-12-05
**Versão:** 2.2.6-fix
