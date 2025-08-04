# 🚨 SOLUÇÃO DO ERRO - Sistema de Aprovação

## ❌ Erro Encontrado
```
ERROR: 42601: syntax error at or near "NOT"
LINE 32: CREATE POLICY IF NOT EXISTS "Users can view own approval status"
```

## ✅ PROBLEMA RESOLVIDO

O PostgreSQL do Supabase não suporta `IF NOT EXISTS` para políticas RLS. 

## 🔧 SOLUÇÃO: Execute Passo a Passo

### Opção 1: Script Corrigido Completo
Execute o arquivo `SETUP_APROVACAO_COMPLETO.sql` atualizado (já corrigido)

### Opção 2: Execute Passo a Passo (Recomendado)

1. **PASSO 1:** Execute `SETUP_PASSO_1.sql` (Criar tabela)
2. **PASSO 2:** Execute `SETUP_PASSO_2.sql` (Índices e RLS)
3. **PASSO 3:** Execute `SETUP_PASSO_3.sql` (Políticas)
4. **PASSO 4:** Execute `SETUP_PASSO_4.sql` (Trigger)
5. **PASSO 5:** Execute `SETUP_PASSO_5.sql` (Funções)
6. **PASSO 6:** Execute `SETUP_PASSO_6.sql` (Verificação)

## 📋 Conteúdo dos Passos:

### PASSO 1: Criar Tabela
```sql
CREATE TABLE IF NOT EXISTS public.user_approvals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  -- ... resto da estrutura
);
```

### PASSO 2: Índices e RLS
```sql
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;
```

### PASSO 3: Políticas (SEM IF NOT EXISTS)
```sql
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
CREATE POLICY "Users can view own approval status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);
```

## 🧪 Verificar se Funcionou

Após executar todos os passos:
```bash
node verificar-sistema-aprovacao.mjs
```

## 📍 Links Importantes

- **SQL Editor:** https://supabase.com/dashboard/project/hkbrcnacgcxqkjjgdpsq/sql
- **Aplicação:** https://pdv-allimport-rfyw3ybg5-radiosystem.vercel.app

## 🎯 Arquivos Disponíveis

- `SETUP_APROVACAO_COMPLETO.sql` - Script completo corrigido
- `SETUP_PASSO_1.sql` até `SETUP_PASSO_6.sql` - Execução passo a passo
- `verificar-sistema-aprovacao.mjs` - Script de teste

**Execute qualquer uma das opções para configurar o sistema!** 🚀
