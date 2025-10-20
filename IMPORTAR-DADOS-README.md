# 📊 IMPORTAÇÃO MANUAL DE DADOS PARA O SUPABASE

## ✅ Arquivo Gerado com Sucesso!

- **Arquivo**: `importar-dados.sql`
- **Tamanho**: 341 KB
- **Linhas**: 17,748
- **Dados**: 141 clientes + 813 produtos + 160 ordens de serviço

---

## 🚀 Como Importar os Dados

### 1️⃣ Acesse o Supabase SQL Editor

1. Abra o Supabase: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. Faça login na sua conta
3. Vá em **SQL Editor** (no menu lateral esquerdo)

### 2️⃣ Execute o Script SQL

**Opção A - Arquivo Completo (Recomendado para primeira importação)**
1. Clique em **New Query** (Nova Consulta)
2. Abra o arquivo `importar-dados.sql` em um editor de texto
3. Copie TODO o conteúdo
4. Cole no SQL Editor do Supabase
5. Clique em **Run** (ou pressione Ctrl+Enter)

**Opção B - Por Seções (Se houver timeout)**
Se o arquivo for muito grande e der timeout, execute em partes:

1. **Primeiro: Clientes**
   ```sql
   -- Copie apenas a seção de CLIENTES do arquivo
   -- (linhas 13 até aproximadamente 2500)
   ```

2. **Segundo: Produtos**
   ```sql
   -- Copie apenas a seção de PRODUTOS
   -- (dividida em vários lotes de 100)
   ```

3. **Terceiro: Ordens de Serviço**
   ```sql
   -- Copie apenas a seção de ORDENS DE SERVIÇO
   ```

### 3️⃣ Verificar Importação

Após executar o script, ele automaticamente mostrará um resumo:

```sql
SELECT 'clientes' as tabela, COUNT(*) as total FROM clientes WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
UNION ALL
SELECT 'produtos', COUNT(*) FROM produtos WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
UNION ALL
SELECT 'ordens_servico', COUNT(*) FROM ordens_servico WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';
```

**Resultado Esperado:**
| tabela | total |
|--------|-------|
| clientes | 141 |
| produtos | 813 |
| ordens_servico | 160 |

---

## ⚠️ IMPORTANTE

### Antes de Importar

1. **Faça um backup** dos dados existentes (se houver)
2. **Verifique o ID da empresa** no arquivo SQL:
   - Linha 19: `EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00'`
   - Se precisar mudar, use Find & Replace no arquivo

### Durante a Importação

- ⏱️ **Tempo estimado**: 30 segundos a 2 minutos
- 🔄 **Progresso**: O Supabase mostrará o andamento
- ⚠️ **Timeout**: Se der timeout, execute por seções

### Após a Importação

1. ✅ Verifique se os totais batem
2. 🔍 Abra o sistema e confira alguns registros
3. 📊 Confirme que telefones e CPF/CNPJ estão aparecendo
4. 🗑️ Pode deletar o arquivo `importar-dados.sql` após confirmação

---

## 🔧 Solução de Problemas

### Erro: "permission denied"
**Causa**: Você não está autenticado ou não tem permissão
**Solução**: 
1. Faça login no Supabase
2. Certifique-se de ser admin do projeto

### Erro: "duplicate key value"
**Causa**: Dados já existem no banco
**Solução**: 
1. Os dados serão ignorados (script usa INSERT, não UPSERT)
2. Se quiser substituir, delete os dados antes:
   ```sql
   DELETE FROM ordens_servico WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';
   DELETE FROM produtos WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';
   DELETE FROM clientes WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';
   ```

### Erro: "timeout" ou "query too large"
**Causa**: Script muito grande
**Solução**: Execute por seções (veja Opção B acima)

### Dados não aparecem no sistema
**Causa**: Cache do navegador
**Solução**: 
1. Pressione Ctrl+Shift+R para recarregar
2. Ou limpe o cache do navegador

---

## 📝 Estrutura do Arquivo SQL

```
├── Configurações iniciais
│   └── Desabilitar triggers (performance)
├── CLIENTES (141 registros)
│   └── INSERT com todos os campos
├── PRODUTOS (813 registros)
│   └── Dividido em lotes de 100
├── ORDENS DE SERVIÇO (160 registros)
│   └── INSERT com relacionamentos
├── Finalização
│   ├── Reabilitar triggers
│   ├── Atualizar sequences
│   └── Query de verificação
```

---

## ✅ Checklist de Importação

- [ ] Backup dos dados existentes feito
- [ ] ID da empresa verificado no SQL
- [ ] Supabase SQL Editor aberto
- [ ] Arquivo `importar-dados.sql` copiado
- [ ] Script executado com sucesso
- [ ] Verificação de totais OK
- [ ] Dados aparecendo no sistema
- [ ] Telefones e CPF/CNPJ visíveis
- [ ] Arquivo SQL pode ser deletado

---

## 🎯 Próximos Passos

Após importar com sucesso:

1. ✅ Os dados do backup não serão mais necessários
2. 🔄 O sistema usará apenas o Supabase
3. 📱 Telefones e documentos estarão visíveis
4. 🚀 Sistema funcionará normalmente

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique o console do navegador (F12)
2. Veja os logs do Supabase SQL Editor
3. Confirme que está logado como administrador
4. Tente executar uma seção menor primeiro

**Gerado em**: 19/10/2025 às 23:27
**Versão**: 1.0.0
