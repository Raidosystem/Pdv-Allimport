# 🗄️ DEPLOY SUPABASE - INSTRUÇÕES DE EXECUÇÃO

## 📋 **Como executar o deploy no Supabase:**

### 1. **Acesse o Supabase Dashboard:**
   - URL: https://supabase.com/dashboard
   - Projeto: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw

### 2. **Vá para SQL Editor:**
   - Clique em "SQL Editor" no menu lateral
   - Ou acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql

### 3. **Execute o script:**
   - Copie TODO o conteúdo do arquivo `DEPLOY_BASICO.sql`
   - Cole no SQL Editor
   - Clique em "RUN" (▶️)

### 4. **Verificar execução:**
   - Deve mostrar: "DEPLOY CONCLUÍDO!" 
   - Verificar se price foi atualizado para R$ 59,90
   - Confirmar criação da tabela `payments`

## 🎯 **O que o script faz:**

✅ **Atualiza preços:** R$ 29,90 → R$ 59,90
✅ **Cria tabela payments:** Para Mercado Pago
✅ **Configura RLS:** Políticas de segurança
✅ **Função SQL:** activate_subscription_after_payment
✅ **Índices:** Para performance

## ⚠️ **IMPORTANTE:**
- Execute apenas o arquivo `DEPLOY_BASICO.sql`
- NÃO execute arquivos .md (Markdown)
- Aguarde a confirmação de sucesso

---
**Status:** ✅ Script pronto para execução
**Arquivo:** `DEPLOY_BASICO.sql` (63 linhas)
