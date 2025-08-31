-- SQL para criar tabela de metas no Supabase
-- Execute este SQL no Supabase SQL Editor

-- Criar tabela de metas
CREATE TABLE metas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL CHECK (tipo IN ('vendas_diaria', 'vendas_mensal', 'receita_diaria', 'receita_mensal', 'clientes_novos', 'ticket_medio')),
  nome TEXT NOT NULL,
  valor_meta DECIMAL(10,2) NOT NULL DEFAULT 0,
  periodo TEXT NOT NULL CHECK (periodo IN ('diario', 'mensal', 'anual')),
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar RLS
ALTER TABLE metas ENABLE ROW LEVEL SECURITY;

-- Política para SELECT - usuário só vê suas próprias metas
CREATE POLICY "Users can view own goals" ON metas
  FOR SELECT USING (auth.uid() = user_id);

-- Política para INSERT - usuário só pode criar suas próprias metas
CREATE POLICY "Users can insert own goals" ON metas
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para UPDATE - usuário só pode atualizar suas próprias metas
CREATE POLICY "Users can update own goals" ON metas
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para DELETE - usuário só pode deletar suas próprias metas
CREATE POLICY "Users can delete own goals" ON metas
  FOR DELETE USING (auth.uid() = user_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Trigger para atualizar updated_at
CREATE TRIGGER update_metas_updated_at BEFORE UPDATE ON metas
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Inserir algumas metas de exemplo para o usuário principal
INSERT INTO metas (user_id, tipo, nome, valor_meta, periodo, ativo) VALUES
  ('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 'receita_diaria', 'Meta de Receita Diária', 1000.00, 'diario', true),
  ('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 'vendas_diaria', 'Meta de Vendas por Dia', 10, 'diario', true),
  ('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 'receita_mensal', 'Meta de Receita Mensal', 30000.00, 'mensal', true),
  ('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 'clientes_novos', 'Meta de Novos Clientes', 5, 'mensal', true),
  ('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 'ticket_medio', 'Meta de Ticket Médio', 150.00, 'diario', true);

-- Comentários para documentação
COMMENT ON TABLE metas IS 'Tabela para armazenar metas personalizáveis dos usuários';
COMMENT ON COLUMN metas.tipo IS 'Tipo da meta: vendas_diaria, vendas_mensal, receita_diaria, receita_mensal, clientes_novos, ticket_medio';
COMMENT ON COLUMN metas.nome IS 'Nome descritivo da meta definido pelo usuário';
COMMENT ON COLUMN metas.valor_meta IS 'Valor objetivo da meta (quantidade ou valor monetário)';
COMMENT ON COLUMN metas.periodo IS 'Período de avaliação da meta: diario, mensal, anual';
COMMENT ON COLUMN metas.ativo IS 'Se a meta está ativa para acompanhamento';
