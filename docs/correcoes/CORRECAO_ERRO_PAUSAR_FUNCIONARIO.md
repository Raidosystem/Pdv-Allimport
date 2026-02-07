# 🔧 CORREÇÃO: Erro ao Atualizar Funcionário (Pausar)

## 🐛 PROBLEMA IDENTIFICADO

Ao tentar pausar um funcionário na seção "Ativar Funcionários", o sistema apresentava erro.

### Causa Raiz
O sistema tinha **duas abordagens conflitantes** para gerenciar o status de funcionários:

1. **Código legado**: Usa coluna `ativo` (boolean)
   - `ativo = true` → Funcionário ativo
   - `ativo = false` → Funcionário inativo

2. **Código novo**: Usa coluna `status` (varchar)
   - `status = 'ativo'` → Funcionário ativo
   - `status = 'pausado'` → Funcionário pausado temporariamente
   - `status = 'inativo'` → Funcionário inativo permanentemente

### Arquivos Afetados
- ✅ `src/modules/admin/pages/ActivateUsersPage.tsx` - Usa `status`
- ❌ `src/hooks/useEmpresa.ts` - Usava apenas `ativo`
- ❌ `src/types/empresa.ts` - Não tinha campo `status`
- ✅ `src/types/admin.ts` - Já tinha `status`

## ✅ SOLUÇÃO IMPLEMENTADA

### 1. Atualizado Hook `useEmpresa.ts`
```typescript
// ANTES (apenas ativo)
const toggleFuncionario = async (funcionarioId: string, ativo: boolean) => {
  const { error } = await supabase
    .from('funcionarios')
    .update({ ativo })
    .eq('id', funcionarioId);
}

// DEPOIS (sincroniza status e ativo)
const toggleFuncionario = async (funcionarioId: string, ativo: boolean) => {
  const novoStatus = ativo ? 'ativo' : 'pausado';
  
  // Atualizar status
  const { error } = await supabase
    .from('funcionarios')
    .update({ status: novoStatus })
    .eq('id', funcionarioId);
  
  // Atualizar login_funcionarios também
  const { error: loginError } = await supabase
    .from('login_funcionarios')
    .update({ ativo })
    .eq('funcionario_id', funcionarioId);
}
```

### 2. Atualizado Tipo `Funcionario` em `empresa.ts`
```typescript
export interface Funcionario {
  id: string;
  empresa_id: string;
  nome: string;
  email: string;
  telefone?: string;
  cargo: string;
  ativo: boolean; // Mantido para compatibilidade
  status?: 'ativo' | 'pausado' | 'inativo'; // Adicionado
  permissoes: FuncionarioPermissoes;
  created_at: string;
  updated_at: string;
}
```

### 3. Criado Script SQL de Sincronização
**Arquivo:** `CORRIGIR_STATUS_FUNCIONARIOS.sql`

O script:
- ✅ Cria coluna `status` se não existir
- ✅ Sincroniza dados existentes
- ✅ Cria triggers automáticos:
  - Quando `status` mudar → `ativo` é atualizado
  - Quando `ativo` mudar → `status` é atualizado

### 4. Criado Script de Diagnóstico
**Arquivo:** `VERIFICAR_ESTRUTURA_FUNCIONARIOS.sql`

Para verificar:
- Estrutura da tabela
- Políticas RLS
- Valores atuais de status
- Constraints

## 📋 COMO EXECUTAR A CORREÇÃO

### Passo 1: Executar SQL no Supabase
```bash
1. Abra o SQL Editor do Supabase
2. Cole o conteúdo de CORRIGIR_STATUS_FUNCIONARIOS.sql
3. Execute o script
4. Verifique os resultados
```

### Passo 2: Rebuild do Frontend
```bash
# Parar servidor se estiver rodando
Ctrl+C

# Limpar cache
npm run build

# Reiniciar
npm run dev
```

### Passo 3: Testar
```bash
1. Acesse: Admin → Ativar Usuários
2. Encontre um funcionário ativo
3. Clique no botão "⏸️ Pausar"
4. Verifique se o status muda para "Pausado"
5. Clique em "▶️ Ativar" novamente
6. Verifique se volta para "Ativo"
```

## 🎯 COMPORTAMENTO ESPERADO

### Após a Correção:
1. **Pausar Funcionário:**
   - `status` → `'pausado'`
   - `ativo` → `false` (automático via trigger)
   - `login_funcionarios.ativo` → `false`
   - Funcionário **NÃO consegue** fazer login

2. **Ativar Funcionário:**
   - `status` → `'ativo'`
   - `ativo` → `true` (automático via trigger)
   - `login_funcionarios.ativo` → `true`
   - Funcionário **consegue** fazer login

3. **Compatibilidade:**
   - Código antigo usando `ativo` → Continua funcionando
   - Código novo usando `status` → Funciona perfeitamente
   - Triggers mantêm tudo sincronizado

## 🔍 VERIFICAÇÃO

### Verificar no Banco de Dados:
```sql
-- Ver funcionários e seus status
SELECT 
  id,
  nome,
  ativo,
  status,
  CASE 
    WHEN (ativo = true AND status = 'ativo') THEN '✅ OK'
    WHEN (ativo = false AND status IN ('pausado', 'inativo')) THEN '✅ OK'
    ELSE '⚠️ Problema'
  END as sincronia
FROM funcionarios
ORDER BY nome;
```

### Verificar no Console do Navegador:
```javascript
// Deve aparecer os logs:
// ✅ Funcionário atualizado
// ✅ Login atualizado
// ✅ Lista recarregada
```

## 📚 ARQUIVOS CRIADOS/MODIFICADOS

### Criados:
- ✅ `CORRIGIR_STATUS_FUNCIONARIOS.sql` - Script de correção
- ✅ `VERIFICAR_ESTRUTURA_FUNCIONARIOS.sql` - Script de diagnóstico
- ✅ `CORRECAO_ERRO_PAUSAR_FUNCIONARIO.md` - Esta documentação

### Modificados:
- ✅ `src/hooks/useEmpresa.ts` - Função `toggleFuncionario()`
- ✅ `src/types/empresa.ts` - Interface `Funcionario`

## 🚨 ATENÇÃO

### ANTES de usar em produção:
1. ✅ Execute `VERIFICAR_ESTRUTURA_FUNCIONARIOS.sql` primeiro
2. ✅ Faça backup da tabela `funcionarios`
3. ✅ Execute `CORRIGIR_STATUS_FUNCIONARIOS.sql`
4. ✅ Teste em ambiente de desenvolvimento
5. ✅ Verifique logs do console

### Problemas Conhecidos:
- Se os triggers não forem criados, `ativo` e `status` podem ficar dessincronizados
- Execute o script SQL **obrigatoriamente** antes de usar o novo código

## ✅ CONCLUSÃO

O erro foi causado por **conflito entre duas abordagens de gerenciamento de status**. A solução implementada:

1. ✅ Mantém compatibilidade com código legado (`ativo`)
2. ✅ Adiciona suporte para novo sistema (`status`)
3. ✅ Sincronização automática via triggers SQL
4. ✅ Funcionários podem ser pausados/ativados sem erros

**Status:** 🎉 Corrigido e pronto para uso!
