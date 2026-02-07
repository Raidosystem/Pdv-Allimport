# 🧹 PLANO DE LIMPEZA - PDV ALLIMPORT

## ARQUIVOS PARA REMOVER IMEDIATAMENTE:

### 1. Scripts SQL Duplicados (Raiz do Projeto):
- DEPLOY_BASICO.sql
- DEPLOY_COMPLETO.md
- DEPLOY_ERROR_FIXED.md
- DEPLOY_FINAL_FIX.sql
- DEPLOY_FINAL_INSTRUCOES.md
- DEPLOY_FINAL.sql
- DEPLOY_FIX_RLS.sql
- DEPLOY_GUIDE.md
- DEPLOY_INSTRUCTIONS.md
- DEPLOY_PRICE_UPDATE_MANUAL.md
- DEPLOY_PRODUCAO_FINAL.md
- DEPLOY_PRODUCTION_FINAL.md
- DEPLOY_SEGURO.sql
- DEPLOY_STATUS_FINAL.md
- DEPLOY_STATUS_OLD.md
- DEPLOY_SUCCESS_FINAL.md
- DEPLOY_SUCCESS_OLD.md
- DEPLOY_SUCCESS.md
- DEPLOY_SUPABASE_COMPLETO.sql
- DEPLOY_SUPABASE_FINAL.sql
- DEPLOY_SUPABASE_FIX.sql
- DEPLOY_SUPABASE_INSTRUCOES.md
- DEPLOY_SUPABASE_INSTRUCTIONS.md
- DEPLOY_SUPABASE_SIMPLES.sql
- DEPLOY_SUPABASE_SUMMARY.md
- DEPLOY_SUPABASE.sql
- DEPLOY_VERCEL.md
- DEPLOY.md

### 2. Scripts Node/JavaScript Duplicados:
- deploy-approval-system.mjs
- deploy-backup-system.sh
- deploy-caixa-supabase.cjs
- deploy-complete.sh
- deploy-email-config.mjs
- deploy-final-supabase.mjs
- deploy-final.sh
- deploy-hierarchy-system.sql
- deploy-instrucoes.js
- deploy-instructions.mjs
- deploy-manual-check.mjs
- deploy-price-update.mjs
- deploy-simples.sh
- deploy-summary.sh
- deploy-supabase-config.mjs
- deploy-supabase-final.mjs
- deploy-supabase-final.sql
- deploy-supabase-manual.sh
- deploy-supabase-manual.sql
- deploy-supabase-now.mjs
- deploy-supabase-simples.mjs
- deploy-supabase-status.sh
- deploy-supabase.mjs
- deploy-ultra-seguro.mjs
- deploy-ultra-seguro.sql
- deploy-via-api.mjs
- deploy-without-docker.sh

### 3. Scripts de Teste:
- test-api-direct.html
- test-approval-system.mjs
- test-auth.cjs
- test-caixa-frontend.cjs
- test-checklist.js
- test-data-sharing.cjs
- test-data-sharing.js
- test-database-connection.mjs
- test-db.js
- test-deploy-final.sh
- test-email-clean.mjs
- test-email-confirmation.mjs
- test-login-caixa.cjs
- test-numero-os.js
- test-payment.html
- test-pix-direct.js
- test-pix-produção.html
- test-production-ready.js
- test-supabase.js
- test-supabase.mjs
- test-subscription-status.mjs
- test-system.js

### 4. Arquivos de Correção/Diagnóstico:
- aplicar-correcao-direta.mjs
- check-clientes-structure.cjs
- clear-email-data.sql
- clear-email-summary.sh
- clear-test-session.js
- clear-user-data.mjs
- correcao-definitiva.mjs
- correcao-final.sql
- correcao-urgente.mjs
- corrigir-entrega-os.sql
- corrigir-entrega-rapido.mjs
- corrigir-erro-entrega-final.mjs
- corrigir-ordens-servico.sql
- corrigir-os-final.mjs
- corrigir-os-problema.mjs
- CORRECAO_CRITICA_RLS_CLIENTES.sql
- CORRECAO_FINAL_SIMPLES.sql
- CORRECAO_SEGURA.sql
- CORRECAO_SIMPLES_SUPABASE.sql
- CORRECAO_STATUS_SQL.sql
- CORRECAO_USUARIO_ID.sql

### 5. Diagnósticos/Debug:
- debug-entrega.mjs
- debug-pix.html
- debug-subscription.mjs
- diagnostico-entrega-completo.mjs
- diagnostico-frontend.js
- diagnostico-ordens-servico.sql
- diagnostico-simples.mjs
- diagnostico-status-completo.mjs
- diagnostico-tabelas-caixa.cjs
- DIAGNOSTICO_SUPABASE.sql

### 6. Arquivos de Verificação:
- verificar-estrutura-produtos.sql
- verificar-inconsistencia.mjs
- verificar-sistema-aprovacao.mjs
- verify-caixa-tables.cjs
- verify-caixa-tables.js
- verify-caixa-tables.mjs
- VERIFICAR_ADMIN_PERMISSIONS.sql
- VERIFICAR_ESTADO.sql

### 7. Scripts Shell:
- apply-caixa-fix.sh
- apply-days-fix.sh
- apply-email-config.sh
- build.sh
- clear-email-summary.sh
- connect-supabase.sh
- conectar-psql.sh
- deploy.sh
- execute-supabase-scripts.sh

## CÓDIGO PARA LIMPAR:

### 1. Imports Comentados:
```tsx
// src/modules/products/ProductsPageSimple.tsx linha 9
// import { useAuth } from '../auth'  // REMOVER
```

### 2. Componentes Duplicados:
- src/modules/products/ProductsPageOld.tsx (REMOVER - usar ProductsPage.tsx)
- api/preference-old.js (REMOVER - usar preference.js)
- api/preference-new.js (REMOVER - usar preference.js)
- api/pix-old.js (REMOVER - usar pix.js)

### 3. Componentes de Debug (Produção):
- src/components/DebugComponent.tsx (REMOVER)
- src/components/AuthDiagnostic.tsx (MOVER para pasta admin)
- src/components/SystemCheck.tsx (MOVER para pasta admin)
- src/components/QuickFix.tsx (MOVER para pasta admin)

### 4. Reorganizar:
- src/examples/SalesWithProductForm.tsx → src/components/examples/
- Componentes de admin já estão em src/components/admin/ ✅

## AÇÃO RECOMENDADA:

1. **Manter apenas:**
   - 1 script SQL principal para deploy
   - 1 arquivo de cada tipo (preference.js, pix.js)
   - Componentes ativos e necessários

2. **Organizar:**
   - Componentes de debug em /admin
   - Exemplos em /components/examples

3. **Resultado:**
   - Projeto 70% menor
   - Estrutura mais limpa
   - Mais fácil manutenção
