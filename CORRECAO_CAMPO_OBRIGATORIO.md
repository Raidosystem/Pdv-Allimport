# 🔧 Correção - Campo Obrigatório "descricao_problema"

## ❌ **ERRO CORRIGIDO:**
```
Erro ao importar backup: null value in column "descricao_problema" of relation "ordens_servico" violates not-null constraint
```

## 🔍 **CAUSA DO PROBLEMA:**
- A coluna `descricao_problema` na tabela `ordens_servico` é **obrigatória** (NOT NULL)
- O código estava mapeando para o nome da interface TypeScript (`defeito_relatado`) 
- Mas precisava mapear para o **nome real da coluna no banco** (`descricao_problema`)

## ✅ **CORREÇÃO APLICADA:**

### Antes (❌ Errado):
```typescript
// Mapeava para interface TypeScript (não existe no banco)
defeito_relatado: getField(...) || 'Não informado'
```

### Depois (✅ Correto):
```typescript  
// Mapeia para coluna real do banco com valor garantido
descricao_problema: getField(ordem, 'defeito_relatado', 'defeitoRelatado', 'defeito', 'problema', 'issue') || 'Problema não informado'
```

## 🎯 **CAMPOS OBRIGATÓRIOS IDENTIFICADOS:**

| Campo | Tipo | Valor Padrão | Status |
|-------|------|--------------|--------|
| `numero_os` | string | `OS001`, `OS002`... | ✅ |
| `descricao_problema` | string | `"Problema não informado"` | ✅ |

## 📝 **MAPEAMENTO COMPLETO ATUALIZADO:**

```typescript
{
  // OBRIGATÓRIOS
  numero_os: "OS001",                          // ✅ Sempre preenchido
  descricao_problema: "Tela quebrada",         // ✅ Nunca null

  // OPCIONAIS (podem ser null)  
  cliente_id: "uuid..." || null,
  equipamento: "Samsung Galaxy S21",
  marca: "Samsung" || null,
  modelo: "Galaxy S21" || null,
  status: "Em análise",                        // ✅ Valor padrão
  data_entrada: "2025-08-31",                 // ✅ Data atual
  valor: 250.00 || null,
  usuario_id: "current_user_id"               // ✅ Usuário logado
}
```

## 🔄 **ALIAS DE CAMPOS SUPORTADOS:**

Para `descricao_problema`:
- `defeito_relatado` ✅
- `defeitoRelatado` ✅  
- `defeito` ✅
- `problema` ✅
- `issue` ✅

## 📁 **ARQUIVO DE TESTE CRIADO:**
`teste-backup-campos-obrigatorios.json` - Testa diferentes combinações de campos incluindo casos sem defeito especificado.

## 🎉 **RESULTADO:**
- ✅ **Build**: Bem-sucedido
- ✅ **Campos obrigatórios**: Todos com valores garantidos  
- ✅ **Import funcionando**: Sem erros de constraint

**Agora o backup deve funcionar sem o erro de "null value in column"!**
