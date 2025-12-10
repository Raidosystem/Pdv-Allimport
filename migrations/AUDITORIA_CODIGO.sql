-- 🔍 AUDITORIA DE CÓDIGO - Verificar problemas no sistema
-- Execute este SQL para encontrar problemas de integridade de dados

-- 1. ARQUIVOS DUPLICADOS IDENTIFICADOS (via análise de código)
/*
PROBLEMAS ENCONTRADOS NA ANÁLISE:

📁 ARQUIVOS DUPLICADOS:
✅ src/services/exportService.ts 
✅ src/services/ExportServiceNew.ts 
   → MESMO CONTEÚDO, CLASSES IDÊNTICAS

📁 SERVICES DUPLICADOS:
✅ src/services/sales.ts
✅ src/services/salesNew.ts  
✅ src/services/salesOriginal.ts
✅ src/services/sales_CLEAN.ts
✅ src/services/sales_OLD.ts
✅ src/services/salesEmbedded.ts
   → MUITAS VERSÕES DO MESMO SERVIÇO

📁 CLIENTE SERVICES DUPLICADOS:
✅ src/services/clienteService.ts
✅ src/services/clienteService-new.ts
   → FUNCIONALIDADE DUPLICADA

📁 IMPORTADORES DUPLICADOS:
✅ src/utils/importador-privado.ts
✅ src/utils/importador-privado-backup.ts
   → BACKUP DESNECESSÁRIO

📁 COMPONENTES DE DEBUG EM PRODUÇÃO:
✅ src/components/BackupDebugger.tsx
✅ src/components/AuthDiagnostic.tsx  
✅ src/components/SystemCheck.tsx
✅ src/components/QuickFix.tsx
✅ test-import.js (arquivo raiz)
   → DEVEM SER REMOVIDOS OU MOVIDOS

📁 HOOKS DUPLICADOS:
✅ src/hooks/useProducts.ts (função checkCodeExists duplicada)
✅ src/hooks/useSales.ts (múltiplas funções similares)

📁 PAGES DUPLICADAS:
✅ src/pages/RelatoriosExportacoesPage.tsx (código repetitivo)
*/

-- 2. VERIFICAÇÃO DE DADOS - Possíveis problemas de duplicação
SELECT 
  'POSSÍVEL DUPLICAÇÃO NO CÓDIGO' as problema,
  'Encontrados múltiplos arquivos com mesmo propósito' as detalhes;

-- 3. ORDENS COM PREFIXES DE TESTE (devem ser removidas)
SELECT 
  'ORDENS DE TESTE/DEBUG' as problema,
  numero_os,
  marca,
  modelo,
  status,
  created_at
FROM ordens_servico 
WHERE (numero_os LIKE 'TEST-%' 
       OR numero_os LIKE '%test%' 
       OR numero_os LIKE '%debug%'
       OR numero_os LIKE '%quick%'
       OR numero_os LIKE '%fixed%')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC;

-- 4. CLIENTES COM NOMES DE TESTE/DEBUG
SELECT 
  'CLIENTES DE TESTE/DEBUG' as problema,
  nome,
  telefone,
  created_at
FROM clientes 
WHERE (nome ILIKE '%test%' 
       OR nome ILIKE '%debug%' 
       OR nome ILIKE '%quick%'
       OR nome = 'Cliente Teste')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC;

-- 5. VERIFICAR ESTRUTURA DA TABELA PRODUTOS
SELECT 
  'ESTRUTURA TABELA PRODUTOS' as problema,
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'produtos' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6. PRODUTOS DUPLICADOS (por nome - sem filtro de usuario_id)
SELECT 
  'PRODUTOS COM NOMES DUPLICADOS' as problema,
  nome,
  count(*) as quantidade,
  string_agg(id::text, ' | ') as ids
FROM produtos 
WHERE nome IS NOT NULL 
  AND nome != ''
GROUP BY nome 
HAVING count(*) > 1
ORDER BY quantidade DESC;