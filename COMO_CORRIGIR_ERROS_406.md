# 🔧 CORREÇÃO DOS ERROS 406 DO SUPABASE

## ❌ Problema Identificado

Os erros 406 no console indicam que as tabelas necessárias não existem no Supabase:

```
Failed to load resource: the server responded with a status of 406 ()
- /rest/v1/subscriptions
- /rest/v1/empresas
```

## ✅ Solução

Execute o arquivo SQL `EXECUTAR_NO_SUPABASE_AGORA.sql` no SQL Editor do Supabase.

### Passo a Passo:

1. **Acesse o Supabase Dashboard**
   - URL: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
   - Faça login

2. **Abra o SQL Editor**
   - No menu lateral, clique em "SQL Editor"
   - Ou acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql

3. **Execute o Script**
   - Clique em "+ New Query"
   - Copie TODO o conteúdo do arquivo `EXECUTAR_NO_SUPABASE_AGORA.sql`
   - Cole no editor
   - Clique em "Run" (ou Ctrl+Enter)

4. **Verifique o Resultado**
   - Você deve ver: "Tabelas criadas com sucesso!"
   - E a lista das tabelas: empresas, subscriptions

## 📋 O que será criado:

### Tabela `empresas`
Armazena dados da empresa do usuário:
- nome, razao_social, cnpj
- telefone, email, site
- endereco, cidade, cep
- logo (URL)

### Tabela `subscriptions`
Controla assinaturas e período de teste:
- status (trial, active, expired, cancelled)
- plan_type (free, basic, premium, enterprise)
- trial_start_date, trial_end_date
- Datas de pagamento e renovação

### Políticas RLS
- ✅ Cada usuário só vê seus próprios dados
- ✅ Proteção total contra acesso não autorizado
- ✅ Políticas para SELECT, INSERT, UPDATE, DELETE

## 🧪 Teste Após Execução

1. Recarregue a página do sistema (F5)
2. Os erros 406 devem desaparecer do console
3. A seção "Dados da Empresa" deve funcionar normalmente
4. A seção "Assinatura" deve mostrar os dados do trial

## ⚠️ Importante

Se você já tem usuários cadastrados, eles ainda não terão registros nas tabelas novas. O sistema criará automaticamente quando:
- Acessarem "Configurações do Sistema" → "Dados da Empresa" (primeira vez)
- O sistema verificar a assinatura (automático no login)

## 🐛 Sobre o Bug de Foco nos Inputs

O bug de perda de foco nos inputs já foi corrigido nos últimos commits:
- Commit: `94bf3d6` - Adicionadas key props e melhorado useEffect
- Commit: `3e76e6c` - Removido useEffect duplicado
- Commit: `c3708f7` - Simplificados handlers

**Após executar o SQL, o sistema deve funcionar 100% sem erros!** 🎉
