-- =====================================================
-- POLÍTICAS DE SEGURANÇA MULTI-TENANT (MULTI-EMPRESA)
-- =====================================================
-- Este script implementa isolamento completo de dados
-- entre diferentes empresas/clientes do sistema
-- =====================================================

-- ⚠️ IMPORTANTE: Cada usuário deve ter empresa_id configurado!
-- Verifique na tabela 'usuarios' ou 'profiles' se existe coluna empresa_id

-- =====================================================
-- 1. VERIFICAR ESTRUTURA DAS TABELAS
-- =====================================================

-- Verificar se vendas tem empresa_id
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'vendas' AND column_name IN ('empresa_id', 'user_id');

-- Verificar se usuarios/profiles tem empresa_id
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('usuarios', 'profiles', 'auth.users') 
AND column_name = 'empresa_id';

-- =====================================================
-- 2. ADICIONAR empresa_id NAS TABELAS (se não existir)
-- =====================================================

-- Adicionar empresa_id em vendas (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN empresa_id UUID REFERENCES empresas(id);
        
        -- Atualizar vendas existentes com empresa do usuário
        UPDATE vendas v
        SET empresa_id = u.empresa_id
        FROM usuarios u
        WHERE v.user_id = u.id;
        
        -- Criar índice para performance
        CREATE INDEX idx_vendas_empresa_id ON vendas(empresa_id);
    END IF;
END $$;

-- Adicionar empresa_id em produtos (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE produtos ADD COLUMN empresa_id UUID REFERENCES empresas(id);
        
        -- Atualizar produtos existentes
        UPDATE produtos p
        SET empresa_id = (
            SELECT empresa_id FROM usuarios WHERE id = p.user_id LIMIT 1
        );
        
        CREATE INDEX idx_produtos_empresa_id ON produtos(empresa_id);
    END IF;
END $$;

-- Adicionar empresa_id em clientes (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE clientes ADD COLUMN empresa_id UUID REFERENCES empresas(id);
        
        UPDATE clientes c
        SET empresa_id = (
            SELECT empresa_id FROM usuarios WHERE id = auth.uid() LIMIT 1
        );
        
        CREATE INDEX idx_clientes_empresa_id ON clientes(empresa_id);
    END IF;
END $$;

-- =====================================================
-- 3. CRIAR FUNÇÃO PARA PEGAR empresa_id DO USUÁRIO
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT empresa_id 
        FROM usuarios 
        WHERE id = auth.uid()
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. REMOVER POLÍTICAS ANTIGAS PERMISSIVAS
-- =====================================================

-- Vendas
DROP POLICY IF EXISTS "Usuários autenticados podem criar vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar vendas" ON vendas;

-- Vendas Itens
DROP POLICY IF EXISTS "Usuários autenticados podem criar itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários autenticados podem ver itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar itens de venda" ON vendas_itens;

-- Produtos
DROP POLICY IF EXISTS "Usuários autenticados podem criar produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar produtos" ON produtos;

-- Clientes
DROP POLICY IF EXISTS "Usuários autenticados podem criar clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar clientes" ON clientes;

-- =====================================================
-- 5. CRIAR POLÍTICAS SEGURAS POR EMPRESA - VENDAS
-- =====================================================

-- INSERT: Só pode criar venda com empresa_id do usuário
CREATE POLICY "Usuários só podem criar vendas da própria empresa"
ON vendas
FOR INSERT
TO authenticated
WITH CHECK (empresa_id = get_user_empresa_id());

-- SELECT: Só vê vendas da própria empresa
CREATE POLICY "Usuários só veem vendas da própria empresa"
ON vendas
FOR SELECT
TO authenticated
USING (empresa_id = get_user_empresa_id());

-- UPDATE: Só atualiza vendas da própria empresa
CREATE POLICY "Usuários só atualizam vendas da própria empresa"
ON vendas
FOR UPDATE
TO authenticated
USING (empresa_id = get_user_empresa_id())
WITH CHECK (empresa_id = get_user_empresa_id());

-- DELETE: Só deleta vendas da própria empresa
CREATE POLICY "Usuários só deletam vendas da própria empresa"
ON vendas
FOR DELETE
TO authenticated
USING (empresa_id = get_user_empresa_id());

-- =====================================================
-- 6. POLÍTICAS SEGURAS - VENDAS_ITENS
-- =====================================================

-- INSERT: Só pode criar item se a venda for da empresa do usuário
CREATE POLICY "Usuários só criam itens de vendas da própria empresa"
ON vendas_itens
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE id = venda_id 
        AND empresa_id = get_user_empresa_id()
    )
);

-- SELECT: Só vê itens de vendas da própria empresa
CREATE POLICY "Usuários só veem itens de vendas da própria empresa"
ON vendas_itens
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE id = venda_id 
        AND empresa_id = get_user_empresa_id()
    )
);

-- UPDATE: Só atualiza itens de vendas da própria empresa
CREATE POLICY "Usuários só atualizam itens de vendas da própria empresa"
ON vendas_itens
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE id = venda_id 
        AND empresa_id = get_user_empresa_id()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE id = venda_id 
        AND empresa_id = get_user_empresa_id()
    )
);

-- =====================================================
-- 7. POLÍTICAS SEGURAS - PRODUTOS
-- =====================================================

CREATE POLICY "Usuários só criam produtos da própria empresa"
ON produtos FOR INSERT TO authenticated
WITH CHECK (empresa_id = get_user_empresa_id());

CREATE POLICY "Usuários só veem produtos da própria empresa"
ON produtos FOR SELECT TO authenticated
USING (empresa_id = get_user_empresa_id());

CREATE POLICY "Usuários só atualizam produtos da própria empresa"
ON produtos FOR UPDATE TO authenticated
USING (empresa_id = get_user_empresa_id())
WITH CHECK (empresa_id = get_user_empresa_id());

-- =====================================================
-- 8. POLÍTICAS SEGURAS - CLIENTES
-- =====================================================

CREATE POLICY "Usuários só criam clientes da própria empresa"
ON clientes FOR INSERT TO authenticated
WITH CHECK (empresa_id = get_user_empresa_id());

CREATE POLICY "Usuários só veem clientes da própria empresa"
ON clientes FOR SELECT TO authenticated
USING (empresa_id = get_user_empresa_id());

CREATE POLICY "Usuários só atualizam clientes da própria empresa"
ON clientes FOR UPDATE TO authenticated
USING (empresa_id = get_user_empresa_id())
WITH CHECK (empresa_id = get_user_empresa_id());

-- =====================================================
-- 9. VERIFICAR POLÍTICAS CRIADAS
-- =====================================================

SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename IN ('vendas', 'vendas_itens', 'produtos', 'clientes')
ORDER BY tablename, cmd;

-- =====================================================
-- 10. TESTE DE ISOLAMENTO
-- =====================================================

-- Verificar quantas empresas existem
SELECT id, nome FROM empresas;

-- Verificar empresa_id dos usuários
SELECT id, email, empresa_id FROM usuarios;

-- Verificar se vendas têm empresa_id
SELECT id, empresa_id, user_id FROM vendas LIMIT 5;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ Cada tabela tem coluna empresa_id
-- ✅ Políticas verificam empresa_id do usuário
-- ✅ Usuário da Empresa A NÃO vê dados da Empresa B
-- ✅ Total isolamento entre clientes do sistema
-- =====================================================

-- ⚠️ IMPORTANTE APÓS EXECUTAR:
-- 1. Faça logout e login novamente
-- 2. Teste criar uma venda
-- 3. Verifique se só vê suas próprias vendas
-- 4. Crie um usuário de teste em outra empresa
-- 5. Confirme que não vê dados da primeira empresa
-- =====================================================
