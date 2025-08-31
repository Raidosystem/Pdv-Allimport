# 📋 Guia de Importação de Backup - Ordens de Serviço

## ✅ PROBLEMA RESOLVIDO
O erro `"Could not find the 'cliente_email' column"` foi corrigido! O sistema agora mapeia corretamente os campos do backup para as colunas reais da base de dados.

## 🔧 Correções Implementadas

### 1. **Mapeamento Correto das Colunas**
- ❌ Antigo: Tentava inserir `cliente_email`, `cliente_nome`, etc. (colunas inexistentes)
- ✅ Novo: Mapeia para `cliente_id`, `descricao_problema`, `equipamento`, etc. (colunas reais)

### 2. **Gestão Automática de Clientes**
- 🔍 **Busca automática**: Procura clientes existentes por nome/telefone/email
- 🆕 **Criação automática**: Cria novos clientes se não encontrar
- 🔗 **Associação**: Liga automaticamente a OS ao cliente correto

### 3. **Estrutura de Dados Suportada**
```json
{
  "equipamento": "Samsung Galaxy S21",     // Gerado automaticamente: marca + modelo
  "marca": "Samsung",                      // Campo separado 
  "modelo": "Galaxy S21",                  // Campo separado
  "numero_serie": "SN123456",             // Número de série
  "descricao_problema": "Tela quebrada",   // Ex: defeito_relatado → descricao_problema
  "observacoes": "Observações gerais",     // Campo de anotações
  "status": "Em análise",                  // Status traduzido
  "data_entrada": "2025-08-25",           // Data de entrada
  "data_finalizacao": null,               // Data de conclusão (opcional)
  "valor": 250.00,                        // Valor total
  "garantia_meses": 3,                    // Garantia em meses
  "usuario_id": "uuid-do-usuario",        // Preenchido automaticamente
  "cliente_id": "uuid-do-cliente"         // Associado ou criado automaticamente
}
```

## 📝 Formatos de Arquivo Aceitos

### Formato 1: Array Direto
```json
[
  {
    "numero_os": "OS001",
    "cliente_nome": "João Silva",
    "marca": "Samsung",
    "modelo": "Galaxy",
    "defeito_relatado": "Tela quebrada",
    "status": "Orçamento",
    "valor_orcado": "250.00"
  }
]
```

### Formato 2: Objeto Encapsulado
```json
{
  "ordens": [
    {
      "numero_os": "OS001",
      "cliente_nome": "João Silva",
      "marca": "Samsung",
      "defeito": "Tela quebrada"
    }
  ]
}
```

### Formato 3: Nomes Alternativos
```json
[
  {
    "numeroOS": "OS001",
    "clienteNome": "João Silva", 
    "brand": "Samsung",
    "model": "Galaxy",
    "problema": "Tela quebrada",
    "situacao": "Orçamento",
    "price": "250.00"
  }
]
```

## 🎯 Mapeamento de Campos Flexível

| Campo no Backup | Aliases Aceitos | Campo Final |
|-----------------|----------------|-------------|
| `cliente_nome` | `clienteNome`, `cliente`, `nome`, `name` | → Cria/encontra cliente |
| `defeito_relatado` | `defeitoRelatado`, `defeito`, `problema`, `issue` | → `descricao_problema` |
| `valor_orcado` | `valorOrcado`, `orcamento`, `price`, `valor` | → `valor` |
| `numero_os` | `numeroOS`, `os`, `numero` | → `numero_os` |
| `status` | `situacao`, `state` | → `status` (traduzido) |

## 🔄 Tradução de Status
- `"Orçamento"` → `"Em análise"`
- `"Em andamento"` → `"Em conserto"`
- `"Concluído"` → `"Pronto"`
- `"Entregue"` → `"Entregue"`
- `"Cancelado"` → `"Cancelado"`

## 🚀 Como Usar

1. **Acesse com a conta autorizada**: `assistenciaallimport10@gmail.com`
2. **Vá para Ordens de Serviço**
3. **Clique no botão verde "Importar Backup"**
4. **Selecione seu arquivo JSON**
5. **O sistema irá**:
   - ✅ Detectar automaticamente o formato
   - ✅ Criar/encontrar clientes
   - ✅ Mapear todos os campos
   - ✅ Inserir as ordens de serviço
   - ✅ Recarregar a página com os novos dados

## 📁 Arquivos de Exemplo
- `exemplo-backup-ordens.json` - Array direto com diferentes formatos
- `exemplo-backup-objeto.json` - Objeto encapsulado com metadados

## ✨ Funcionalidades Avançadas
- 🔍 **Auto-detecção de formato**: Não precisa se preocupar com a estrutura
- 🎯 **Mapeamento inteligente**: Aceita dezenas de nomes diferentes para o mesmo campo
- 👥 **Gestão de clientes**: Cria automaticamente clientes que não existem
- 🔒 **Segurança**: Restrito apenas ao usuário autorizado
- 📊 **Feedback visual**: Mostra quantas ordens foram importadas
- 🔄 **Atualização automática**: Recarrega a lista após importação

🎉 **Agora a importação de backup de ordens de serviço está 100% funcional!**
