# 🚨 CORREÇÃO URGENTE - Erros de Banco de Dados

## Problemas Identificados

### 1. ❌ Função `criar_backup_automatico_diario()` não existe
- **Erro**: `function public.criar_backup_automatico_diario() does not exist`
- **Causa**: Triggers foram criados mas a função foi removida
- **Impacto**: Impossível salvar/atualizar clientes e produtos

### 2. ❌ RPC `atualizar_cliente_seguro` não encontrada
- **Erro**: `POST /rest/v1/rpc/atualizar_cliente_seguro 404 (Not Found)`
- **Causa**: Função SQL não foi criada no banco
- **Impacto**: Impossível atualizar clientes pelo formulário

### 3. ❌ Queries com `user_id` errado para funcionários
- **Erro**: `empresas?select=nome&user_id=eq.866ae21a... (406)`
- **Causa**: Funcionários locais têm `user_id` próprio, mas devem usar `empresa_id` do metadata
- **Impacto**: Funcionários não conseguem acessar dados da empresa

---

## 📋 SOLUÇÃO - Passo a Passo

### PASSO 1: Executar Script SQL (⏱️ ~30 segundos)

1. **Abra o Supabase Dashboard**
   - Acesse: https://supabase.com/dashboard
   - Entre no projeto: `kmcaaqetxtwkdcczdomw`
   - Vá em: **SQL Editor** (menu lateral)

2. **Execute o script de correção**
   - Abra o arquivo: `CORRIGIR_FUNCOES_FALTANDO_URGENTE.sql`
   - Copie TODO o conteúdo
   - Cole no SQL Editor
   - Clique em **RUN** (ou pressione Ctrl+Enter)

3. **Verifique o resultado**
   - Deve aparecer no final:
     ```
     🗑️  Triggers de backup restantes: 0
     ✅ RPC atualizar_cliente_seguro
     ✅ RPC atualizar_produto_seguro
     🎉 CORREÇÃO COMPLETA!
     ```

---

### PASSO 2: Atualizar Arquivos Frontend (⏱️ ~5 minutos)

Agora você tem um utilitário novo: `src/utils/empresaUtils.ts`

**Arquivos que DEVEM ser atualizados:**

#### 2.1. `src/modules/dashboard/DashboardPageNew.tsx`

**Antes (linha 89-94):**
```typescript
const { data, error } = await supabase
  .from('empresas')
  .select('nome')
  .eq('user_id', user.id)  // ❌ ERRADO para funcionários
  .single()
```

**Depois:**
```typescript
import { getEmpresaId } from '../../utils/empresaUtils'

// No início da função
const { empresaId } = await getEmpresaId(user)
if (!empresaId) {
  setNomeEmpresa('Empresa')
  return
}

const { data, error } = await supabase
  .from('empresas')
  .select('nome')
  .eq('id', empresaId)  // ✅ CORRETO
  .single()
```

---

#### 2.2. `src/hooks/useEmpresaId.ts`

**Adicione no início:**
```typescript
import { getEmpresaId as getEmpresaIdUtil } from '../utils/empresaUtils'
```

**Atualize a função `getEmpresaIdFromUser`:**
```typescript
async function getEmpresaIdFromUser(user: User): Promise<string | null> {
  const { empresaId } = await getEmpresaIdUtil(user)
  return empresaId
}
```

---

#### 2.3. `src/hooks/useEmpresa.ts`

**Adicione import:**
```typescript
import { getEmpresaId } from '../utils/empresaUtils'
```

**Atualize `carregarEmpresa` (linha 17-22):**
```typescript
const carregarEmpresa = useCallback(async () => {
  if (!user?.id) return

  setLoading(true)
  setError(null)

  try {
    const { empresaId } = await getEmpresaId(user)
    if (!empresaId) {
      setError('Empresa não encontrada')
      return
    }

    const { data, error } = await supabase
      .from('empresas')
      .select('*')
      .eq('id', empresaId)
      .single()

    if (error) throw error
    setEmpresa(data)
  } catch (err: any) {
    setError(err.message)
  } finally {
    setLoading(false)
  }
}, [user])
```

---

### PASSO 3: Testar (⏱️ ~2 minutos)

1. **Limpe o cache do navegador**
   - Pressione: `Ctrl + Shift + Delete`
   - Selecione: "Cache" e "Cookies"
   - Período: "Última hora"
   - Clique: "Limpar dados"

2. **Faça login como funcionário**
   - Vá para `/login-local`
   - Selecione: Jennifer (ou outro funcionário)
   - Digite a senha

3. **Teste as funcionalidades**
   - ✅ **Editar Cliente**: Deve salvar sem erro 404
   - ✅ **Editar Produto**: Deve salvar sem erro 404
   - ✅ **Dashboard**: Deve mostrar nome da empresa correto
   - ✅ **Console**: Não deve ter erros 406 de `empresas`

---

## 🔍 Diagnóstico de Problemas

### Se ainda houver erro 404 em `atualizar_cliente_seguro`:

1. Verifique se o script SQL foi executado com sucesso
2. Execute novamente apenas a parte da função:
   ```sql
   -- Copie apenas o bloco "PARTE 2: CRIAR RPC atualizar_cliente_seguro"
   -- do arquivo CORRIGIR_FUNCOES_FALTANDO_URGENTE.sql
   ```

### Se ainda houver erro 406 em `empresas`:

1. Verifique se os arquivos frontend foram atualizados
2. Limpe o cache novamente (hard refresh: `Ctrl+Shift+R`)
3. Verifique o console: deve mostrar logs `[getEmpresaId]`

### Se funcionários não conseguem acessar dados:

1. Verifique o RLS da tabela `empresas`:
   ```sql
   -- Execute no SQL Editor
   SELECT * FROM pg_policies WHERE tablename = 'empresas';
   ```
2. Deve ter policy permitindo acesso via `empresa_id`

---

## 📊 Resumo Técnico

### O que foi corrigido:

1. **Triggers removidos**: 
   - Removidos triggers que chamavam `criar_backup_automatico_diario()`
   - Função foi deletada (era redundante)

2. **RPCs criadas**:
   - `atualizar_cliente_seguro`: Atualiza clientes com RLS correto
   - `atualizar_produto_seguro`: Atualiza produtos com RLS correto

3. **Utilitário criado**:
   - `empresaUtils.ts`: Helper para obter `empresa_id` correto
   - Suporta funcionários (metadata) e admins (query)

### Arquivos criados:
- ✅ `CORRIGIR_FUNCOES_FALTANDO_URGENTE.sql` (script SQL)
- ✅ `src/utils/empresaUtils.ts` (utilitário frontend)
- ✅ `GUIA_CORRECAO_ERROS_BD.md` (este arquivo)

---

## 🎯 Próximos Passos

Após executar as correções acima, você deve:

1. **Atualizar outros arquivos** que usam `.eq('user_id', user.id)` para buscar empresas
   - Lista completa: 44 arquivos identificados
   - Priorize: hooks, services, páginas principais

2. **Testar com múltiplos usuários**:
   - Admin principal
   - Funcionário com permissões limitadas
   - Funcionário com permissões amplas

3. **Monitorar logs**:
   - Console do navegador (F12)
   - Supabase Dashboard > Logs

---

## ❓ Dúvidas?

Se algo não funcionar:
1. Capture os logs completos do console
2. Verifique os logs do Supabase
3. Compartilhe o erro completo

---

**Data**: 2025-12-09  
**Versão**: 1.0  
**Status**: ✅ Pronto para execução
