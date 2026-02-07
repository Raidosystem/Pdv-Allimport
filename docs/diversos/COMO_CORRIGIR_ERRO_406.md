# 🔧 Como Corrigir os Erros 406 - Guia Rápido

## ❌ Problema
Erros 406 (Not Acceptable) aparecem no console do navegador:
- `GET .../rest/v1/caixa?... 406 (Not Acceptable)`
- `GET .../rest/v1/lojas_online?... 406 (Not Acceptable)`

## ✅ Solução

### Passo 1: Acessar o Supabase SQL Editor

1. Abra o dashboard do Supabase: https://supabase.com/dashboard
2. Selecione seu projeto: **kmcaaqetxtwkdcczdomw**
3. Clique em **SQL Editor** no menu lateral esquerdo

### Passo 2: Executar o Script

1. Clique em **+ New query** para criar nova query
2. Abra o arquivo `CORRIGIR_ERRO_406_TABELAS.sql` deste projeto
3. **Copie TODO o conteúdo** do arquivo
4. **Cole** no SQL Editor do Supabase
5. Clique em **Run** (ou pressione Ctrl+Enter)

### Passo 3: Verificar Resultado

O script vai:
- ✅ Criar tabela `caixa` e `movimentacoes_caixa` (se não existirem)
- ✅ Criar tabela `lojas_online` (se não existir)
- ✅ Configurar RLS (Row Level Security) corretamente
- ✅ Criar índices para performance
- ✅ Mostrar mensagens de verificação no final

**Mensagens esperadas:**
```
✅ Tabela caixa existe
✅ Tabela movimentacoes_caixa existe
✅ Tabela lojas_online existe
```

### Passo 4: Testar no Sistema

1. Volte para o sistema PDV (`http://localhost:5174`)
2. Pressione **Ctrl + Shift + R** para recarregar completamente a página
3. Abra o **Console do navegador** (F12)
4. Navegue pelos menus:
   - Clique em "Caixa"
   - Clique em "Produtos"
   - Clique em "Ordens de Serviço"

**Resultado esperado:** ✅ Nenhum erro 406 deve aparecer no console

---

## 🔍 Se ainda aparecer erro 406

### Diagnóstico:

Execute este script SQL no Supabase para verificar o estado das tabelas:

```sql
-- Verificar se as tabelas existem
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('caixa', 'movimentacoes_caixa', 'lojas_online');

-- Verificar RLS
SELECT 
  schemaname, 
  tablename, 
  rowsecurity as "RLS Habilitado"
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
  AND schemaname = 'public';

-- Verificar políticas RLS
SELECT 
  tablename,
  policyname,
  cmd as "Operação"
FROM pg_policies
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
ORDER BY tablename, policyname;
```

### Possíveis problemas:

1. **Tabela não foi criada** → Execute o script novamente
2. **RLS está desabilitado** → Execute: `ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;`
3. **Políticas não foram criadas** → Execute o script novamente
4. **Permissões insuficientes** → Verifique se está usando a role `postgres` ou `service_role`

---

## 📊 O que o script faz?

### Tabela `caixa`
- Armazena aberturas e fechamentos de caixa
- Políticas RLS: usuário só vê seus próprios caixas
- Campos: valor_inicial, valor_final, status (aberto/fechado), datas

### Tabela `movimentacoes_caixa`
- Armazena entradas e saídas do caixa
- Políticas RLS: usuário só vê movimentações de seus caixas
- Campos: tipo (entrada/saida), descricao, valor, venda_id

### Tabela `lojas_online`
- Configurações de loja online/catálogo
- Políticas RLS: 
  - Leitura pública para lojas ativas
  - Donos podem gerenciar suas lojas
- Campos: slug, nome, whatsapp, cores, configurações

---

## ✅ Checklist Pós-Execução

- [ ] Script executado sem erros no Supabase SQL Editor
- [ ] Mensagens "✅ Tabela existe" apareceram
- [ ] Sistema recarregado com Ctrl+Shift+R
- [ ] Console sem erros 406 ao navegar nos menus
- [ ] Funcionalidade do caixa testada
- [ ] Funcionalidade de produtos testada

---

## 🆘 Suporte

Se ainda tiver problemas após executar o script:

1. Copie as mensagens de erro do Supabase SQL Editor
2. Copie as mensagens de erro do console do navegador (F12)
3. Tire prints das queries que estão dando erro
4. Compartilhe para análise
