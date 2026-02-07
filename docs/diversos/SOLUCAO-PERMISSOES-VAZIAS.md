# 🐛 SOLUÇÃO: Permissões Vazias no Sistema

## ❌ Problema Identificado

```
🔥 [loadPermissoes] Carregou 0 permissões
```

A tabela `permissoes` está **vazia**, impedindo o sistema de:
- Criar novas funções
- Gerenciar permissões
- Exibir o modal de permissões corretamente

## ✅ Solução

### Opção 1: SQL Manual (RECOMENDADO)

1. Acesse o Supabase Dashboard
2. Vá em **SQL Editor**
3. Cole e execute o conteúdo do arquivo:
   ```
   EXECUTAR-POPULAR-PERMISSOES.sql
   ```

### Opção 2: Script Node.js

```bash
# Usar service role key no .env
node popular-permissoes.cjs
```

## 📊 O que será criado

- **49 permissões** distribuídas em 7 módulos:
  - ✅ Vendas (6 permissões)
  - ✅ Produtos (7 permissões)
  - ✅ Clientes (6 permissões)
  - ✅ Financeiro (7 permissões)
  - ✅ Relatórios (6 permissões)
  - ✅ Configurações (6 permissões)
  - ✅ Administração (11 permissões)

## 🔒 RLS Corrigido

O script também configura as políticas RLS corretas:
- ✅ Leitura pública de permissões (necessário para menus)
- ✅ Apenas admins podem gerenciar

## 🎯 Resultado Esperado

Após executar o script, você deve ver:
```
📊 RESUMO POR MÓDULO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  administracao                  → 11 permissões
  administracao.funcoes          → 4 permissões
  clientes                       → 6 permissões
  configuracoes                  → 6 permissões
  financeiro                     → 7 permissões
  produtos                       → 7 permissões
  relatorios                     → 6 permissões
  vendas                         → 6 permissões
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TOTAL: 49 permissões
```

## ✅ Verificação

Após executar, teste no console do navegador:
```javascript
// Deve retornar 49 permissões
const { data } = await supabase.from('permissoes').select('*');
console.log('Total:', data?.length);
```

## 🚀 Próximos Passos

1. Execute o SQL
2. Recarregue a página no navegador
3. Acesse Admin > Funções e Permissões
4. O modal deve abrir com todas as permissões categorizadas
