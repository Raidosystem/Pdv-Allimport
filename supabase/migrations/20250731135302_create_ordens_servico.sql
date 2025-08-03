-- Migration: Create ordens_servico table
-- Date: 2025-08-02
-- Description: Create ordens_servico table (Portuguese version) for service orders management

-- Create ordens_servico table if not exists
CREATE TABLE IF NOT EXISTS public.ordens_servico (
  id uuid default gen_random_uuid() primary key,
  cliente_id uuid references public.clientes(id),
  usuario_id uuid references auth.users(id),
  numero_os text unique not null,
  descricao_problema text not null,
  descricao_servico text,
  observacoes text,
  valor decimal(10,2) default 0,
  status text not null default 'Aberta' check (status in ('Aberta', 'Em Andamento', 'Pronto', 'Entregue', 'Cancelada')),
  data_entrada timestamp with time zone default now(),
  data_previsao timestamp with time zone,
  data_finalizacao timestamp with time zone,
  equipamento text,
  marca text,
  modelo text,
  numero_serie text,
  acessorios text,
  defeitos_encontrados text,
  pecas_utilizadas jsonb,
  tempo_gasto interval,
  criado_em timestamp with time zone default now(),
  atualizado_em timestamp with time zone default now()
);

-- Enable RLS on ordens_servico table
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for ordens_servico table
CREATE POLICY "Users can view all ordens_servico" 
ON public.ordens_servico FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert ordens_servico" 
ON public.ordens_servico FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update ordens_servico" 
ON public.ordens_servico FOR UPDATE 
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can delete ordens_servico" 
ON public.ordens_servico FOR DELETE 
USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_usuario_id ON public.ordens_servico(usuario_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_status ON public.ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_data_entrada ON public.ordens_servico(data_entrada);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_numero_os ON public.ordens_servico(numero_os);

-- Create trigger for updating the updated_at column
CREATE OR REPLACE FUNCTION public.handle_updated_at_ordens_servico()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_updated_at_ordens_servico
    BEFORE UPDATE ON public.ordens_servico
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at_ordens_servico();
