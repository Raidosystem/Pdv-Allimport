-- ============================================
-- ATUALIZAR TABELA CONFIGURACOES_IMPRESSAO 
-- Para suportar sistema atual de rodapé com 4 linhas
-- ============================================

-- Garantir que a tabela exista (criar se necessário)
CREATE TABLE IF NOT EXISTS public.configuracoes_impressao (
    user_id UUID PRIMARY KEY,
    cabecalho TEXT,
    cabecalho_personalizado TEXT,
    rodape TEXT,
    rodape_linha1 TEXT,
    rodape_linha2 TEXT,
    rodape_linha3 TEXT,
    rodape_linha4 TEXT,
    criado_em TIMESTAMP DEFAULT NOW(),
    atualizado_em TIMESTAMP
);

-- Adicionar colunas para as 4 linhas do rodapé
DO $$ 
BEGIN
    -- Adicionar coluna cabecalho_personalizado se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'cabecalho_personalizado'
    ) THEN
        ALTER TABLE public.configuracoes_impressao 
        ADD COLUMN cabecalho_personalizado TEXT DEFAULT '';
    END IF;

    -- Adicionar colunas para as 4 linhas do rodapé se não existirem
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'rodape_linha1'
    ) THEN
        ALTER TABLE public.configuracoes_impressao 
        ADD COLUMN rodape_linha1 TEXT DEFAULT '';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'rodape_linha2'
    ) THEN
        ALTER TABLE public.configuracoes_impressao 
        ADD COLUMN rodape_linha2 TEXT DEFAULT '';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'rodape_linha3'
    ) THEN
        ALTER TABLE public.configuracoes_impressao 
        ADD COLUMN rodape_linha3 TEXT DEFAULT '';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' 
        AND column_name = 'rodape_linha4'
    ) THEN
        ALTER TABLE public.configuracoes_impressao 
        ADD COLUMN rodape_linha4 TEXT DEFAULT '';
    END IF;
END $$;

-- Migrar dados existentes do campo 'rodape' para 'rodape_linha1' se necessário
UPDATE public.configuracoes_impressao 
SET rodape_linha1 = COALESCE(rodape, ''),
    cabecalho_personalizado = COALESCE(cabecalho, '')
WHERE (rodape_linha1 IS NULL OR rodape_linha1 = '') 
   AND (cabecalho_personalizado IS NULL OR cabecalho_personalizado = '');

-- Verificar estrutura atualizada
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'configuracoes_impressao' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar dados existentes
SELECT 
    user_id,
    cabecalho,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    criado_em
FROM public.configuracoes_impressao 
ORDER BY criado_em DESC
LIMIT 5;

-- ============================================
-- FUNÇÃO PARA MIGRAR CONFIGURAÇÕES DO LOCALSTORAGE
-- ============================================

-- Esta função pode ser chamada via JavaScript para migrar dados do localStorage
CREATE OR REPLACE FUNCTION public.migrar_configuracoes_impressao_usuario(
    p_user_id UUID,
    p_cabecalho_personalizado TEXT DEFAULT '',
    p_rodape_linha1 TEXT DEFAULT '',
    p_rodape_linha2 TEXT DEFAULT '',
    p_rodape_linha3 TEXT DEFAULT '',
    p_rodape_linha4 TEXT DEFAULT ''
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Inserir ou atualizar configurações
    INSERT INTO public.configuracoes_impressao (
        user_id,
        cabecalho_personalizado,
        rodape_linha1,
        rodape_linha2,
        rodape_linha3,
        rodape_linha4,
        atualizado_em
    ) VALUES (
        p_user_id,
        p_cabecalho_personalizado,
        p_rodape_linha1,
        p_rodape_linha2,
        p_rodape_linha3,
        p_rodape_linha4,
        NOW()
    )
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
        rodape_linha1 = EXCLUDED.rodape_linha1,
        rodape_linha2 = EXCLUDED.rodape_linha2,
        rodape_linha3 = EXCLUDED.rodape_linha3,
        rodape_linha4 = EXCLUDED.rodape_linha4,
        atualizado_em = NOW();
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÃO PARA BUSCAR CONFIGURAÇÕES
-- ============================================

CREATE OR REPLACE FUNCTION public.buscar_configuracoes_impressao_usuario(p_user_id UUID)
RETURNS TABLE (
    cabecalho_personalizado TEXT,
    rodape_linha1 TEXT,
    rodape_linha2 TEXT,
    rodape_linha3 TEXT,
    rodape_linha4 TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(ci.cabecalho_personalizado, '') as cabecalho_personalizado,
        COALESCE(ci.rodape_linha1, '') as rodape_linha1,
        COALESCE(ci.rodape_linha2, '') as rodape_linha2,
        COALESCE(ci.rodape_linha3, '') as rodape_linha3,
        COALESCE(ci.rodape_linha4, '') as rodape_linha4
    FROM public.configuracoes_impressao ci
    WHERE ci.user_id = p_user_id;
    
    -- Se não encontrar, retornar configurações padrão
    IF NOT FOUND THEN
        RETURN QUERY SELECT ''::TEXT, ''::TEXT, ''::TEXT, ''::TEXT, ''::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;