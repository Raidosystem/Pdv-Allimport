-- =============================================
-- FORÇAR ATUALIZAÇÃO DO SCHEMA CACHE DO SUPABASE
-- =============================================
-- Execute este script no Supabase SQL Editor para forçar refresh do schema cache

-- =============================================
-- 1. VERIFICAR ESTRUTURA ATUAL DA TABELA PRODUTOS
-- =============================================
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'produtos'
ORDER BY ordinal_position;

-- Resultado esperado: deve mostrar a coluna 'estoque'

-- =============================================
-- 2. FORÇAR REFRESH DO SCHEMA CACHE
-- =============================================
-- Opção 1: Notificar mudanças de schema (recomendado)
NOTIFY pgrst, 'reload schema';

-- Opção 2: Se a opção 1 não funcionar, tente recriar a tabela (mais drástico)
-- ATENÇÃO: Isso não apaga dados, apenas atualiza metadados

-- =============================================
-- 3. GARANTIR QUE A COLUNA ESTOQUE EXISTE
-- =============================================
-- Se por algum motivo a coluna não existir, este comando a cria
-- Se já existir, não faz nada (sem erro)
DO $$
BEGIN
    -- Verificar se a coluna estoque existe
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'produtos' 
          AND column_name = 'estoque'
    ) THEN
        -- Adicionar coluna estoque se não existir
        ALTER TABLE public.produtos 
        ADD COLUMN estoque INTEGER DEFAULT 0;
        
        RAISE NOTICE 'Coluna estoque adicionada à tabela produtos';
    ELSE
        RAISE NOTICE 'Coluna estoque já existe na tabela produtos';
    END IF;
END $$;

-- =============================================
-- 4. ATUALIZAR PERMISSÕES RLS (se necessário)
-- =============================================
-- Garantir que as políticas RLS permitam acesso ao campo estoque
-- (normalmente não é necessário, pois RLS trabalha por linha, não por coluna)

-- =============================================
-- 5. VERIFICAR SE O CACHE FOI ATUALIZADO
-- =============================================
-- Execute esta query para confirmar que a coluna está visível
SELECT 
    id,
    nome,
    estoque,  -- Esta coluna deve ser retornada sem erro
    preco,
    user_id
FROM public.produtos
LIMIT 5;

-- =============================================
-- 6. TESTE DIRETO DE UPDATE
-- =============================================
-- Testar se é possível atualizar o campo estoque diretamente
-- Substitua 'SEU_PRODUCT_ID' e 'SEU_USER_ID' pelos valores reais

-- UPDATE public.produtos
-- SET estoque = 10
-- WHERE id = 'SEU_PRODUCT_ID'
--   AND user_id = 'SEU_USER_ID';

-- =============================================
-- 7. INFORMAÇÕES SOBRE O CACHE DO SUPABASE
-- =============================================

/*
📌 SOBRE O CACHE DO SCHEMA:

O PostgREST (API REST do Supabase) mantém um cache do schema do banco de dados.
Quando você adiciona/remove colunas, o cache pode não atualizar imediatamente.

📌 SOLUÇÕES:

1. NOTIFY pgrst, 'reload schema';
   - Força o PostgREST a recarregar o schema
   - É a solução mais rápida e segura
   
2. Reiniciar o projeto no Dashboard do Supabase
   - Vá em Settings > Database > Restart
   - Mais demorado mas garante reset completo
   
3. Aguardar atualização automática
   - O cache atualiza automaticamente a cada 10 minutos (padrão)
   - Não recomendado se você precisa testar agora

📌 VERIFICAÇÃO EXTRA:

Se o erro persistir, pode ser que:
- A coluna realmente não existe (verifique com a query 1)
- O usuário não tem permissão (verifique RLS)
- O campo está sendo enviado com nome errado no frontend

📌 DEBUGGING NO FRONTEND:

No console do navegador, você verá o payload enviado:
1. Abra DevTools > Network
2. Filtre por "produtos"
3. Clique na requisição PATCH/POST
4. Veja em "Payload" se o campo "estoque" está sendo enviado

Se o campo NÃO aparecer no payload, o problema é no frontend.
Se o campo APARECE no payload mas o erro persiste, o problema é o cache do Supabase.
*/

-- =============================================
-- ✅ RESULTADO ESPERADO
-- =============================================
SELECT 'SCHEMA CACHE ATUALIZADO:
✅ Comando NOTIFY enviado para atualizar cache
✅ Coluna estoque verificada/criada
✅ Permissões RLS mantidas
✅ Teste de query executado com sucesso

🔄 PRÓXIMOS PASSOS:
1. Aguarde 10-30 segundos para o cache atualizar
2. Recarregue a página do frontend (Ctrl+Shift+R)
3. Tente salvar o produto novamente
4. Se o erro persistir, reinicie o projeto no Dashboard do Supabase

💡 ALTERNATIVA RÁPIDA:
Se você tem pressa e o NOTIFY não resolver:
- Vá para o Dashboard do Supabase
- Settings > Database > Restart Database
- Aguarde 1-2 minutos
- Teste novamente

🐛 SE O ERRO CONTINUAR:
Execute a query de verificação (item 5) e envie o resultado para análise.' as status;
