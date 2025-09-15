# 🧹 PLANO DE LIMPEZA DE CÓDIGO - PDV ALLIMPORT

## 🚨 PROBLEMAS CRÍTICOS ENCONTRADOS:

### 1. **ARQUIVOS DUPLICADOS** (REMOVER IMEDIATAMENTE)

#### Services Duplicados:
```
❌ REMOVER:
- src/services/ExportServiceNew.ts (usar exportService.ts)
- src/services/salesNew.ts (usar sales.ts)
- src/services/salesOriginal.ts 
- src/services/sales_CLEAN.ts
- src/services/sales_OLD.ts
- src/services/salesEmbedded.ts
- src/services/clienteService-new.ts (usar clienteService.ts)
- src/utils/importador-privado-backup.ts
```

#### Backups desnecessários:
```
❌ REMOVER:
- src/services/ordemServicoService.ts.backup
```

#### Arquivos de teste na raiz:
```
❌ REMOVER:
- test-import.js (arquivo na raiz do projeto)
```

### 2. **COMPONENTES DE DEBUG EM PRODUÇÃO** (MOVER OU REMOVER)

```
🔧 MOVER para pasta /admin ou REMOVER:
- src/components/BackupDebugger.tsx
- src/components/AuthDiagnostic.tsx
- src/components/SystemCheck.tsx
- src/components/QuickFix.tsx
```

### 3. **CÓDIGO DUPLICADO** (REFATORAR)

#### ExportService duplicado:
```typescript
// ❌ PROBLEMA: Duas classes idênticas
// src/services/exportService.ts
// src/services/ExportServiceNew.ts
export class ExportService {
  static async exportSalesToPDF(data: SalesReport, filters: any) { ... }
  static async exportSalesToExcel(data: SalesReport) { ... }
}
```

#### Hooks com funcionalidades repetidas:
```typescript
// ❌ PROBLEMA: Múltiplas implementações similares
// src/hooks/useSales.ts - useCart, useSaleCalculation
// src/hooks/useProducts.ts - checkCodeExists duplicado
```

### 4. **IMPORTS DESNECESSÁRIOS**

```typescript
// ❌ PROBLEMA: Imports comentados e não utilizados
// src/modules/products/ProductsPageSimple.tsx linha 9
// import { useAuth } from '../auth'  // REMOVER
```

### 5. **DADOS DE TESTE NO BANCO** (LIMPAR)

Execute o SQL de auditoria para encontrar e remover:
- Ordens com prefixo "TEST-"
- Clientes com nomes de teste
- Produtos com códigos duplicados

## 🎯 PLANO DE AÇÃO:

### **FASE 1: LIMPEZA IMEDIATA** (AGORA)
1. Execute `AUDITORIA_CODIGO.sql` para identificar dados de teste
2. Remova ordens TEST-FIXED e TEST-QUICK que aparecem nos logs
3. Verifique clientes duplicados

### **FASE 2: LIMPEZA DE ARQUIVOS** (PRÓXIMA)
1. Remover arquivos duplicados listados acima
2. Mover componentes de debug para pasta admin
3. Consolidar services duplicados

### **FASE 3: REFATORAÇÃO** (FUTURO)
1. Unificar ExportService
2. Consolidar hooks duplicados
3. Limpar imports não utilizados

## 🔧 COMANDOS PARA EXECUTAR:

### SQL (Execute primeiro):
```sql
-- Remover ordens de teste
DELETE FROM ordens_servico 
WHERE numero_os LIKE 'TEST-%' 
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;
```

### Arquivos para deletar:
```bash
# ❌ DELETAR ESTES ARQUIVOS:
rm src/services/ExportServiceNew.ts
rm src/services/sales*.ts (exceto sales.ts)
rm src/services/clienteService-new.ts
rm src/utils/importador-privado-backup.ts
rm test-import.js
```

## ✅ PRIORIDADE: 
**EXECUTAR AUDITORIA_CODIGO.SQL PRIMEIRO** para limpar dados de teste!