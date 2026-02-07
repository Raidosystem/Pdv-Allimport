# ✅ INSTRUÇÕES: Como Executar SQL no Supabase

## 📋 Passos para executar o SQL

### 1. Acesse o Supabase Dashboard
- Vá para: https://supabase.com/dashboard
- Faça login na sua conta
- Selecione o projeto **Pdv-Allimport**

### 2. Abra o SQL Editor
- No menu lateral esquerdo, clique em **"SQL Editor"**
- Ou clique no ícone `< >` (código)

### 3. Cole e Execute o SQL
- Clique em **"New Query"** (Nova Consulta)
- Cole o código SQL do arquivo `ATUALIZAR_TABELA_EMPRESAS_ENDERECO.sql`
- Clique no botão **"Run"** (▶️) ou pressione `Ctrl + Enter`

### 4. Verifique o Resultado
Você deve ver uma mensagem de sucesso e a lista de colunas da tabela empresas, incluindo:
- ✅ logradouro
- ✅ numero
- ✅ complemento
- ✅ bairro
- ✅ cidade
- ✅ estado
- ✅ uf
- ✅ cep

---

## 🔧 SQL a ser Executado

```sql
-- ============================================
-- ATUALIZAR TABELA EMPRESAS COM CAMPOS DE ENDEREÇO SEPARADOS
-- ============================================

-- Adicionar colunas de endereço separadas
ALTER TABLE empresas
  ADD COLUMN IF NOT EXISTS logradouro TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS numero TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS complemento TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bairro TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS estado TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS uf TEXT DEFAULT '';

-- Renomear coluna logo para logo_url (padronizar nomenclatura)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'empresas' AND column_name = 'logo'
  ) THEN
    ALTER TABLE empresas RENAME COLUMN logo TO logo_url;
  END IF;
END $$;

-- Comentários nas colunas para documentação
COMMENT ON COLUMN empresas.logradouro IS 'Rua, Avenida, etc.';
COMMENT ON COLUMN empresas.numero IS 'Número do endereço';
COMMENT ON COLUMN empresas.complemento IS 'Apartamento, Sala, Bloco, etc.';
COMMENT ON COLUMN empresas.bairro IS 'Bairro';
COMMENT ON COLUMN empresas.cidade IS 'Cidade';
COMMENT ON COLUMN empresas.estado IS 'Cidade - UF (ex: São Paulo - SP)';
COMMENT ON COLUMN empresas.uf IS 'Sigla do estado (SP, RJ, MG, etc.)';
COMMENT ON COLUMN empresas.cep IS 'CEP no formato 00000-000';

-- Atualizar timestamp de modificação
CREATE OR REPLACE FUNCTION update_empresas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar trigger se já existir
DROP TRIGGER IF EXISTS trigger_update_empresas_timestamp ON empresas;
CREATE TRIGGER trigger_update_empresas_timestamp
  BEFORE UPDATE ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION update_empresas_updated_at();

-- Verificar estrutura atualizada
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'empresas'
ORDER BY ordinal_position;
```

---

## ✅ O que foi corrigido/implementado:

### 1. **Serviço de Busca de CEP** ✅
- Arquivo: `src/services/cepService.ts`
- Função `fetchAddressByCep()` usando API ViaCEP
- Validação e formatação automática de CEP
- Tratamento de erros

### 2. **Componente de Formulário de Endereço** ✅
- Arquivo: `src/components/EnderecoForm.tsx`
- Campos separados: CEP, Logradouro, Número, Complemento, Bairro, Cidade, Estado
- Busca automática ao digitar CEP (via ViaCEP API)
- Feedback visual durante busca
- Validação de CEP em tempo real
- Foco automático no campo "Número" após busca

### 3. **Atualização da Estrutura do Banco** ✅
- Arquivo SQL: `ATUALIZAR_TABELA_EMPRESAS_ENDERECO.sql`
- Adicionadas colunas: `logradouro`, `numero`, `complemento`, `bairro`, `estado`, `uf`
- Renomeação: `logo` → `logo_url` (padronização)
- Trigger para `updated_at` automático
- Comentários nas colunas para documentação

### 4. **Atualização dos Hooks e Componentes** ✅
- `src/hooks/useEmpresaSettings.ts`: Interface atualizada com campos de endereço
- `src/components/EmpresaView.tsx`: Substituição do textarea por EnderecoForm
- `src/pages/ConfiguracoesPageNew.tsx`: Interface atualizada e integração completa

---

## 🚀 Como Testar

### Após executar o SQL acima:

1. **Acesse Configurações do Sistema**
   - No sistema PDV, vá em "Configurações do Sistema"
   - Clique na aba "Empresa"

2. **Teste a Busca de CEP**
   - Digite um CEP válido (ex: `01310-100`)
   - Pressione TAB ou clique na lupa 🔍
   - Os campos devem ser preenchidos automaticamente

3. **Preencha os Dados**
   - Complete o número do endereço
   - Adicione complemento (opcional)
   - Clique em "Salvar"

4. **Verifique o Salvamento**
   - Deve aparecer mensagem: **"Dados da empresa salvos com sucesso!"**
   - Recarregue a página e verifique se os dados persistiram

---

## 🐛 Possíveis Erros Corrigidos

### ❌ "Erro ao salvar dados da empresa"
**Causa**: Estrutura da tabela desatualizada (faltavam colunas)
**Solução**: Execute o SQL acima para adicionar as colunas necessárias

### ❌ Campos de endereço não aparecendo
**Causa**: Componentes desatualizados
**Solução**: Código já atualizado nos arquivos TypeScript

### ❌ CEP não busca automaticamente
**Causa**: Serviço de CEP não implementado
**Solução**: Implementado em `cepService.ts` com API ViaCEP

---

## 📝 Observações Importantes

- ✅ O CEP deve ter 8 dígitos (formato: 00000-000)
- ✅ A busca funciona mesmo se o CEP for digitado sem hífen
- ✅ Campos obrigatórios: CEP, Logradouro, Número, Bairro, Cidade, Estado
- ✅ Complemento é opcional
- ✅ A API ViaCEP é gratuita e não requer autenticação
- ✅ Após salvar, os dados ficam armazenados no Supabase
- ✅ Cada usuário tem seus próprios dados de empresa (multi-tenant)

---

## 🎯 Próximos Passos

1. **Execute o SQL no Supabase** ⬅️ FAÇA ISSO AGORA!
2. Teste o formulário de endereço com CEP real
3. Verifique se o salvamento funciona corretamente
4. Reporte qualquer erro encontrado

---

**Dúvidas?** Entre em contato ou abra uma issue! 🚀
