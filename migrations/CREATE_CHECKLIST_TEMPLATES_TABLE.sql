-- Criar tabela para templates de checklist personalizados por usuário
CREATE TABLE IF NOT EXISTS checklist_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(usuario_id)
);

-- Habilitar RLS
ALTER TABLE checklist_templates ENABLE ROW LEVEL SECURITY;

-- Política: Usuário pode ver apenas seu próprio template
CREATE POLICY "Usuários podem ver seu próprio checklist template"
  ON checklist_templates
  FOR SELECT
  USING (auth.uid() = usuario_id OR auth.uid() = empresa_id);

-- Política: Usuário pode inserir seu próprio template
CREATE POLICY "Usuários podem criar seu próprio checklist template"
  ON checklist_templates
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Política: Usuário pode atualizar seu próprio template
CREATE POLICY "Usuários podem atualizar seu próprio checklist template"
  ON checklist_templates
  FOR UPDATE
  USING (auth.uid() = usuario_id OR auth.uid() = empresa_id)
  WITH CHECK (auth.uid() = usuario_id OR auth.uid() = empresa_id);

-- Política: Usuário pode deletar seu próprio template
CREATE POLICY "Usuários podem deletar seu próprio checklist template"
  ON checklist_templates
  FOR DELETE
  USING (auth.uid() = usuario_id OR auth.uid() = empresa_id);

-- Índices para melhor performance
CREATE INDEX idx_checklist_templates_usuario ON checklist_templates(usuario_id);
CREATE INDEX idx_checklist_templates_empresa ON checklist_templates(empresa_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_checklist_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
CREATE TRIGGER update_checklist_templates_timestamp
  BEFORE UPDATE ON checklist_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_checklist_templates_updated_at();

COMMENT ON TABLE checklist_templates IS 'Templates personalizados de checklist por usuário';
COMMENT ON COLUMN checklist_templates.items IS 'Array de itens do checklist [{id: string, label: string, ordem: number}]';
