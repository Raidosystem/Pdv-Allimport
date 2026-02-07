# 🔒 CONFIGURAÇÃO RLS PARA SISTEMA DE BACKUP COMPLETO

## 📋 CHECKLIST DE CONFIGURAÇÃO

Para o sistema de backup funcionar completamente, você precisa executar os seguintes passos no Supabase:

### 1. **VERIFICAR E CRIAR TABELAS** ⚙️
Execute primeiro: `CRIAR_TABELAS_BACKUP.sql`
- ✅ Verifica se todas as tabelas existem
- ✅ Adiciona coluna `user_id` se necessário
- ✅ Cria tabelas básicas se não existirem

### 2. **CONFIGURAR RLS COMPLETO** 🔒
Execute depois: `RLS_BACKUP_COMPLETO.sql`
- ✅ Cria todas as funções RPC necessárias
- ✅ Cria tabela `user_backups`
- ✅ Ativa RLS em todas as tabelas
- ✅ Cria políticas de segurança
- ✅ Adiciona triggers automáticos

## 🎯 FUNÇÕES RPC CRIADAS

### `export_user_data_json()`
- Exporta todos os dados do usuário em formato JSON
- Inclui: clientes, produtos, categorias, vendas, etc.
- Retorna backup completo formatado

### `import_user_data_json(backup_json, clear_existing)`
- Importa dados de backup JSON
- `backup_json`: dados do backup
- `clear_existing`: limpar dados existentes (padrão: true)
- Retorna resultado da operação

### `save_backup_to_database()`
- Cria backup manual e salva no banco
- Usa tabela `user_backups`
- Retorna confirmação

### `list_user_backups()`
- Lista todos os backups do usuário
- Mostra data, tamanho, etc.
- Ordenado por data (mais recente primeiro)

### `restore_from_database_backup(backup_id, clear_existing)`
- Restaura backup específico do banco
- `backup_id`: ID do backup a restaurar
- `clear_existing`: limpar dados atuais

## 🛡️ POLÍTICAS RLS CONFIGURADAS

Para cada tabela principal:
- ✅ **SELECT**: usuário só vê próprios dados
- ✅ **INSERT**: usuário só insere com seu user_id
- ✅ **UPDATE**: usuário só atualiza próprios dados  
- ✅ **DELETE**: usuário só deleta próprios dados

**Tabelas protegidas:**
- `clientes` - dados de clientes
- `categorias` - categorias de produtos
- `produtos` - estoque de produtos
- `vendas` - histórico de vendas
- `itens_venda` - itens das vendas
- `caixa` - sessões de caixa
- `movimentacoes_caixa` - movimentações
- `configuracoes` - configurações do sistema
- `user_backups` - backups salvos

## ⚡ TRIGGERS AUTOMÁTICOS

Todas as tabelas têm triggers que:
- ✅ Inserem `user_id` automaticamente
- ✅ Garantem isolamento por usuário
- ✅ Não permitem dados órfãos

## 🧪 COMO TESTAR

### No Sistema Web:
1. Acesse: Dashboard → Administração → Backup
2. Use o **Debug do Sistema de Backup**
3. Clique em "Criar Backup de Teste"
4. Baixe e importe o arquivo
5. Verifique o log de debug

### No SQL Editor:
```sql
-- Testar export
SELECT export_user_data_json();

-- Testar backup manual
SELECT save_backup_to_database();

-- Listar backups
SELECT list_user_backups();

-- Verificar políticas
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

## 🔧 TROUBLESHOOTING

### ❌ **Erro: "Função não encontrada"**
- Execute `RLS_BACKUP_COMPLETO.sql` completamente
- Verifique se todas as funções foram criadas

### ❌ **Erro: "Tabela não existe"**
- Execute primeiro `CRIAR_TABELAS_BACKUP.sql`
- Verifique se todas as tabelas têm `user_id`

### ❌ **Erro: "Usuário não autenticado"**
- Verifique se está logado no sistema
- Confirme se `auth.uid()` retorna valor

### ❌ **Erro: "Permissão negada"**
- Verifique se RLS está ativo: `SHOW row_security;`
- Confirme se políticas foram criadas

## 📊 VERIFICAÇÕES DE SEGURANÇA

```sql
-- 1. Verificar RLS ativo
SELECT schemaname, tablename, rowsecurity
FROM pg_tables 
WHERE schemaname = 'public';

-- 2. Verificar políticas criadas
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 3. Verificar triggers
SELECT trigger_name, table_name, action_timing, event
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY table_name;

-- 4. Testar isolamento
SELECT COUNT(*) FROM produtos; -- Deve mostrar apenas produtos do usuário logado
```

## 🎉 RESULTADO FINAL

Após executar a configuração completa, você terá:

- ✅ **Sistema de Backup Universal** funcionando
- ✅ **Isolamento total** entre usuários
- ✅ **Funções RPC** para import/export
- ✅ **Segurança máxima** com RLS
- ✅ **Backup automático** configurável
- ✅ **Debug completo** para testes

**🔒 Privacidade e segurança total garantidas!**

---

## 📞 SUPORTE

Se encontrar problemas:
1. Verifique logs do console do navegador
2. Execute queries de verificação
3. Confira se usuário está autenticado
4. Use o componente de debug integrado
