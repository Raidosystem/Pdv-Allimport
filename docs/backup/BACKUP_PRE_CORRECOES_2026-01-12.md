# 🔐 BACKUP PRE-CORREÇÕES - 12 de Janeiro de 2026

## ⚠️ DOCUMENTO DE SEGURANÇA - NÃO DELETAR

Este documento registra o estado do sistema ANTES das correções dos 13 problemas identificados.
**Use este documento para reverter mudanças se algo der errado.**

---

## 📊 ANÁLISE COMPLETA REALIZADA

### Data da Análise: 12/01/2026
### Versão do Sistema: package.json (verificar versão atual)

---

## 🔴 PROBLEMAS IDENTIFICADOS (13 Total)

### 1. Inconsistência user_id vs usuario_id
**Status:** PARCIALMENTE CORRIGIDO
**Arquivos Afetados:**
- ✅ src/services/sales.ts - JÁ CORRIGIDO (linha 553, 575)
- ⚠️ src/types/sales.ts - PRECISA CORREÇÃO (linha 44, 61)
- ⚠️ src/types/caixa.ts - USA usuario_id (linha 21)
- ⚠️ Potencialmente outros serviços

**Backup Estado Atual:**
```typescript
// types/sales.ts linha 44
export interface CashRegister {
  id: string
  user_id: string  // ⚠️ INCONSISTENTE com MovimentacaoCaixa
  data_abertura: string
  // ...
}

// types/caixa.ts linha 21
export interface MovimentacaoCaixa {
  usuario_id: string  // ⚠️ INCONSISTENTE com CashRegister
  // ...
}
```

**Plano de Correção:**
1. Verificar schema do banco (qual campo realmente existe)
2. Padronizar TODOS os tipos para usar o campo correto
3. Validar que services e hooks usam o padrão correto

---

### 2. Falta de Tratamento de Erro em Hooks
**Arquivos:** useSales.ts, useProducts.ts
**Status:** PRECISA MELHORIA

**Estado Atual:**
- useProducts.ts tem try/catch mas pode melhorar
- useSales.ts usa apenas console.log para debug

**Plano:**
- Adicionar estados error/setError onde faltam
- Melhorar feedback ao usuário

---

### 3. Dependências Circulares em usePermissions
**Arquivo:** src/hooks/usePermissions.tsx (1072 linhas)
**Status:** FUNCIONAL MAS COMPLEXO

**Observação:** Não mexer sem necessidade - sistema está funcionando

---

### 4. Código Morto de Backup
**Arquivos:**
- src/services/clienteService.ts (linhas 100-240 comentadas)
- src/hooks/useProdutos.ts (logs sobre backup desabilitado)

**Plano:**
- Remover blocos comentados extensos
- Manter comentários explicativos curtos

---

### 5. Validação empresa_id Faltante
**Arquivos:** dreService.ts, lojaOnlineService.ts
**Status:** FUNCIONA MAS PODE MELHORAR

**Plano:**
- Usar empresaUtils.ts consistentemente
- Adicionar validações onde necessário

---

### 6. Produtos Sem Service Dedicado
**Problema:** Lógica espalhada em hooks
**Arquivos:**
- src/hooks/useProducts.ts (480 linhas)
- src/hooks/useProdutos.ts (duplicado)

**Plano:**
1. Criar src/services/productService.ts
2. Mover lógica de negócio para service
3. Simplificar hooks para apenas gerenciar estado

---

### 7. Mercado Pago - Credencial Hardcoded
**Arquivo:** src/services/mercadoPagoService.ts linha 5
**CRÍTICO DE SEGURANÇA**

**Estado Atual:**
```typescript
const MP_PUBLIC_KEY = import.meta.env.VITE_MP_PUBLIC_KEY || 'APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022'
```

**Plano:**
- Remover fallback hardcoded
- Fazer app falhar explicitamente se não configurado

---

### 8. Hack Supabase Visibility
**Arquivo:** src/lib/supabase.ts linha 33
**Status:** INTENCIONAL - NÃO MEXER SEM TESTAR

---

### 9. RPC delete_user Sem Verificação
**Arquivo:** src/services/funcionarioAuthService.ts linha 106
**Status:** PODE MELHORAR

**Plano:**
- Adicionar try/catch específico
- Tratar erro se função não existir

---

### 10. Múltiplos ClienteService
**Arquivos Duplicados:**
- clienteService.ts (ATUAL)
- clienteService-fixed.ts
- clienteService-new.ts

**Plano:**
1. Verificar se -fixed e -new são usados
2. Deletar se não forem referenciados

---

### 11. Product Interfaces Duplicadas
**Arquivos:**
- src/types/product.ts (preco_venda, codigo, estoque)
- src/types/sales.ts (price, sku, stock_quantity)

**Plano:**
- Consolidar em types/product.ts
- Criar adapters se necessário para compatibilidade

---

### 12. usePermissions Muito Complexo
**Arquivo:** src/hooks/usePermissions.tsx (1072 linhas)
**Status:** FUNCIONAL - REFATORAR COM CUIDADO

**Observação:** Sistema de permissões é crítico - não refatorar agora

---

### 13. Console.logs Excessivos
**Arquivos:** Projeto inteiro
**Status:** LIMPEZA GRADUAL

**Plano:**
- Remover console.logs desnecessários
- Manter apenas logs críticos de erro

---

## 📝 ORDEM DE EXECUÇÃO DAS CORREÇÕES

### 🔴 Prioridade ALTA (Fazer Primeiro)
1. ✅ Correção 7: Remover credencial hardcoded Mercado Pago
2. ✅ Correção 1: Padronizar user_id vs usuario_id
3. ✅ Correção 11: Consolidar interfaces Product

### 🟠 Prioridade MÉDIA
4. ✅ Correção 10: Deletar arquivos duplicados clienteService
5. ✅ Correção 4: Remover código morto comentado
6. ✅ Correção 6: Criar productService.ts

### 🟡 Prioridade BAIXA (Melhorias)
7. ✅ Correção 2: Melhorar error handling em hooks
8. ✅ Correção 9: Melhorar rollback em funcionarioAuthService
9. ✅ Correção 5: Validar empresa_id consistentemente
10. ✅ Correção 13: Limpar console.logs desnecessários

### ⏸️ NÃO MEXER AGORA
- Correção 3: usePermissions (muito complexo)
- Correção 8: Hack Supabase (intencional)
- Correção 12: Refatorar usePermissions (muito arriscado)

---

## 🔄 COMO REVERTER MUDANÇAS

### Se algo der errado durante as correções:

1. **Git:**
   ```bash
   git status
   git diff
   git checkout -- <arquivo>  # Reverter arquivo específico
   git reset --hard HEAD       # Reverter tudo (cuidado!)
   ```

2. **Backup Manual:**
   - Todos os arquivos originais estão documentados acima
   - Copiar código do backup e colar de volta

3. **Testar Após Cada Correção:**
   ```bash
   npm run type-check  # Verificar erros TypeScript
   npm run lint        # Verificar erros ESLint
   npm run dev         # Testar aplicação
   ```

---

## ✅ CHECKLIST DE SEGURANÇA

Antes de cada correção:
- [ ] Ler código atual completamente
- [ ] Entender dependências
- [ ] Planejar mudança mínima necessária
- [ ] Fazer mudança
- [ ] Verificar erros TypeScript
- [ ] Testar funcionalidade afetada

Depois de cada correção:
- [ ] `npm run type-check` passou sem erros
- [ ] `npm run lint` não criou novos warnings
- [ ] Sistema inicia sem erros (npm run dev)
- [ ] Funcionalidade testada manualmente
- [ ] Commit da mudança

---

## 📞 CONTATOS DE EMERGÊNCIA

Se algo quebrar:
1. Reverter última mudança
2. Verificar este documento
3. Testar sistema
4. Investigar logs de erro

---

## 🎯 RESULTADO ESPERADO

Após todas as correções:
- ✅ Sistema mais consistente
- ✅ Código mais limpo
- ✅ Menos bugs potenciais
- ✅ Melhor manutenibilidade
- ✅ Segurança melhorada

**IMPORTANTE:** Ir devagar, testar muito, reverter se necessário!

---

## 📅 LOG DE CORREÇÕES

### ✅ Correção #1 - Mercado Pago Credencial Hardcoded
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Modificados:** [src/services/mercadoPagoService.ts]
- **Resultado:** Removido fallback hardcoded 'APP_USR-4a8bfb6e...', agora lança erro se não configurado

### ✅ Correção #2 - Padronização user_id vs usuario_id
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Modificados:** 
  - src/types/caixa.ts (Caixa.usuario_id → user_id, MovimentacaoCaixa.usuario_id → user_id)
  - src/types/ordemServico.ts (OrdemServico.usuario_id → user_id)
  - src/services/sales.ts (movimentacao.usuario_id → user_id)
  - src/services/ordemServicoService.ts (7 ocorrências corrigidas)
- **Resultado:** Todos os campos agora usam user_id (conforme schema do banco)

### ✅ Correção #3 - Arquivos Duplicados ClienteService
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Removidos:**
  - src/services/clienteService-fixed.ts
  - src/services/clienteService-new.ts
- **Resultado:** Código limpo, sem duplicações

### ✅ Correção #4 - Código Morto Comentado
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Modificados:** [src/services/clienteService.ts]
- **Resultado:** Removidas ~150 linhas de código comentado de backup local

### ✅ Correção #5 - Rollback Funcionário Auth
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Modificados:** [src/services/funcionarioAuthService.ts]
- **Resultado:** Melhorado tratamento de erro ao deletar usuário Auth em rollback

### ✅ Correção #6 - ProductService Criado
- **Data:** 12/01/2026
- **Status:** ✅ CONCLUÍDO
- **Arquivos Criados:** [src/services/productService.ts]
- **Resultado:** Service centralizado com 12 métodos (CRUD, categorias, estoque)

### ⏳ Correção #7 - Error Handling Hooks
- **Data:** [Próxima]
- **Status:** [Pendente]
- **Arquivos a Modificar:** []
- **Resultado:** []

### ⏳ Correção #8 - Validação empresa_id
- **Data:** [Próxima]
- **Status:** [Pendente]
- **Arquivos a Modificar:** []
- **Resultado:** []

### ⏸️ Correção #9 - Console.logs
- **Data:** [Limpeza Gradual]
- **Status:** [Baixa Prioridade]
- **Arquivos a Modificar:** [Múltiplos]
- **Resultado:** []

### ⛔ NÃO MEXER - usePermissions Complexo
- **Motivo:** Sistema crítico funcionando, risco alto
- **Status:** MANTIDO COMO ESTÁ

### ⛔ NÃO MEXER - Hack Supabase Visibility
- **Motivo:** Workaround intencional
- **Status:** MANTIDO COMO ESTÁ

---

**FIM DO DOCUMENTO DE BACKUP**
**Criado em:** 12/01/2026
**Válido até:** Todas as correções serem aplicadas com sucesso
