# 🔄 SISTEMA UNIVERSAL DE BACKUP - PDV ALLIMPORT

## 🚀 VISÃO GERAL

O PDV Allimport agora possui um **Sistema Universal de Backup** que aceita qualquer arquivo JSON de outros sistemas e transforma automaticamente para funcionar no nosso sistema.

### ✨ PRINCIPAIS RECURSOS

- 🔍 **Detecção Automática**: Identifica automaticamente a estrutura do backup
- 🧠 **Mapeamento Inteligente**: Mapeia campos de outros sistemas para nossos campos
- 🔄 **Transformação Automática**: Converte dados de qualquer formato para PDV Allimport
- 📊 **Relatório Completo**: Mostra detalhes da transformação realizada
- 🛡️ **Validação Rigorosa**: Verifica integridade dos dados antes da importação

## 📁 ESTRUTURA DO SISTEMA

### Arquivos Principais:
- **`src/utils/backupTransformer.ts`** - Engine de transformação universal
- **`src/pages/ConfiguracoesBackup.tsx`** - Interface completa de configurações
- **`src/components/BackupManager.tsx`** - Componente de gerenciamento melhorado
- **`src/hooks/useBackup.ts`** - Hook melhorado com transformação automática

## 🎯 COMO FUNCIONA

### 1. **Detecção de Sistema**
O sistema identifica automaticamente de qual sistema veio o backup:
- AllImport (assistência técnica)
- Sistemas de PDV genéricos
- POS (Point of Sale)
- Sistemas personalizados

### 2. **Mapeamento de Campos**
Mapeia inteligentemente os campos:

```typescript
PRODUTOS:
name ← ['name', 'nome', 'produto', 'description', 'title']
preco ← ['preco', 'price', 'valor', 'cost', 'amount'] 
codigo ← ['codigo', 'code', 'sku', 'barcode']
categoria ← ['categoria', 'category', 'tipo', 'group']

CLIENTES:
name ← ['name', 'nome', 'cliente', 'razao_social']
email ← ['email', 'e_mail', 'mail']
telefone ← ['telefone', 'phone', 'celular'] 
cpf ← ['cpf', 'cnpj', 'document', 'tax_id']
```

### 3. **Transformação**
Converte automaticamente:
- ✅ Produtos com preços e códigos
- ✅ Clientes com contatos
- ✅ Categorias organizadas
- ✅ Dados de vendas (quando disponível)

## 🛠️ COMO USAR

### **No Sistema Web:**

1. **Acesse as Configurações:**
   - Dashboard → Administração → Backup e Restauração
   - Ou: http://localhost:5174/configuracoes

2. **Importar Backup Universal:**
   - Clique em **"Importar Qualquer Backup"**
   - Selecione seu arquivo JSON
   - O sistema detectará automaticamente o formato
   - Confirme a transformação
   - Aguarde o relatório completo

3. **Verificar Resultados:**
   - Veja o relatório de transformação
   - Confirme os dados importados
   - Verifique produtos, clientes e categorias

## 📊 EXEMPLO DE TRANSFORMAÇÃO

### **Entrada (AllImport):**
```json
{
  "produtos": [
    {
      "descricao": "WIRELESS MICROPHONE",
      "valor": "25.00",
      "cod_barras": "WM001",
      "tipo": "Eletrônicos"
    }
  ]
}
```

### **Saída (PDV Allimport):**
```json
{
  "backup_info": {
    "system": "PDV Allimport (Importado de AllImport)",
    "backup_date": "2025-08-19T..."
  },
  "data": {
    "produtos": [
      {
        "name": "WIRELESS MICROPHONE",
        "preco": 25.00,
        "codigo": "WM001",
        "categoria": "Eletrônicos",
        "ativo": true,
        "estoque": 0
      }
    ]
  }
}
```

## 🔧 CONFIGURAÇÕES AVANÇADAS

### **Backup Automático:**
- ⏰ Frequência configurável (diário/semanal/mensal)
- 🕐 Horário personalizável
- 📅 Retenção configurável (7-365 dias)
- 🔒 Criptografia opcional

### **Opções de Importação:**
- 🖼️ Incluir/excluir imagens
- 🗜️ Compressão automática
- 🔐 Proteção com senha
- 📋 Validação rigorosa

## 🎯 SISTEMAS SUPORTADOS

### **Testados e Compatíveis:**
- ✅ **AllImport** (assistência técnica)
- ✅ **PDV Genéricos** (estruturas comuns)
- ✅ **POS Systems** (point of sale)
- ✅ **Backups JSON** personalizados

### **Campos Reconhecidos Automaticamente:**

**Produtos:**
- Nome: `name`, `nome`, `produto`, `descricao`, `description`, `title`
- Preço: `preco`, `price`, `valor`, `value`, `cost`, `custo`
- Código: `codigo`, `code`, `sku`, `barcode`, `id_produto`
- Categoria: `categoria`, `category`, `tipo`, `type`, `group`

**Clientes:**
- Nome: `name`, `nome`, `cliente`, `razao_social`, `company_name`
- Email: `email`, `e_mail`, `mail`, `correio`
- Telefone: `telefone`, `phone`, `tel`, `celular`, `mobile`
- Documento: `cpf`, `cnpj`, `document`, `documento`

## 📈 RELATÓRIOS E LOGS

### **Relatório de Transformação:**
```
🔄 RELATÓRIO DE TRANSFORMAÇÃO DE BACKUP

📊 DADOS ORIGINAIS:
  • produtos: 813 itens
  • clientes: 141 itens
  • categorias: 69 itens
  
📦 TOTAL TRANSFORMADO: 1023 itens

🎯 SISTEMA ORIGEM: AllImport
📅 DATA: 19/08/2025 14:30:00
```

### **Log de Atividades:**
- 📊 Estatísticas de uso
- ⏰ Histórico de importações
- ❌ Registro de erros
- ✅ Sucessos e falhas

## 🚨 IMPORTANTE

### **Antes de Importar:**
- ✅ **Faça backup** dos dados atuais
- ✅ **Verifique o arquivo JSON** (deve ser válido)
- ✅ **Confirme o sistema origem** na pré-visualização
- ✅ **Revise os dados** após importação

### **Limitações:**
- 📁 Apenas arquivos JSON (máx 50MB)
- 🔄 Alguns campos podem precisar ajuste manual
- 🖼️ Imagens não são importadas automaticamente
- 📊 Histórico de vendas pode requerer adaptação

## 🔗 ACESSO RÁPIDO

**URLs Diretas:**
- Configurações: http://localhost:5174/configuracoes
- Dashboard: http://localhost:5174/dashboard
- Backup Manager: Configurações → Backup e Restauração

---

## 🎉 RESULTADO FINAL

O sistema agora aceita **qualquer backup JSON** e transforma automaticamente para funcionar no PDV Allimport, mantendo a integridade dos dados e fornecendo relatórios completos da transformação realizada.

**🚀 Sistema Universal de Backup funcionando perfeitamente!**
