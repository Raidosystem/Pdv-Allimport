-- Correção das políticas que falharam

-- Políticas para clientes
CREATE POLICY "Usuários podem ver seus próprios clientes" ON public.clientes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar clientes" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios clientes" ON public.clientes
    FOR UPDATE USING (auth.uid() = user_id);

-- Inserir categorias sem ON CONFLICT
INSERT INTO public.categories (name, description) 
VALUES 
    ('Eletrônicos', 'Produtos eletrônicos e tecnológicos'),
    ('Roupas', 'Vestuário e acessórios'),
    ('Casa e Jardim', 'Produtos para casa e jardim'),
    ('Esportes', 'Artigos esportivos e fitness'),
    ('Livros', 'Livros e material educativo'),
    ('Alimentação', 'Produtos alimentícios'),
    ('Saúde e Beleza', 'Produtos de saúde e cosméticos'),
    ('Automotivo', 'Peças e acessórios automotivos'),
    ('Informática', 'Equipamentos de informática'),
    ('Ferramentas', 'Ferramentas e equipamentos');

-- Verificação final
SELECT '🎉 CORREÇÕES APLICADAS COM SUCESSO!' as resultado;
