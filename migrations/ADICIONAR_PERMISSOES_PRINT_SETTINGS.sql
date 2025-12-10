-- ============================================
-- ADICIONAR PERMISSÕES PARA CONFIGURAÇÕES DE IMPRESSÃO
-- Garantir que usuários autenticados possam usar as funções
-- ============================================

-- Dar permissões para a tabela configuracoes_impressao
GRANT SELECT, INSERT, UPDATE, DELETE ON public.configuracoes_impressao TO authenticated;

-- Dar permissões para as funções RPC
GRANT EXECUTE ON FUNCTION public.migrar_configuracoes_impressao_usuario(UUID, TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_configuracoes_impressao_usuario(UUID) TO authenticated;

-- Habilitar RLS na tabela se ainda não estiver habilitado
ALTER TABLE public.configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- Criar política para que usuários só vejam suas próprias configurações
DROP POLICY IF EXISTS "Usuários podem ver suas próprias configurações de impressão" ON public.configuracoes_impressao;

CREATE POLICY "Usuários podem ver suas próprias configurações de impressão"
ON public.configuracoes_impressao
FOR ALL 
TO authenticated
USING (user_id = auth.uid());

-- Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'configuracoes_impressao';

-- Verificar permissões das funções
SELECT 
    routine_name,
    routine_type,
    data_type,
    security_type
FROM information_schema.routines 
WHERE routine_name LIKE '%configuracoes_impressao%'
  AND routine_schema = 'public';

COMMIT;