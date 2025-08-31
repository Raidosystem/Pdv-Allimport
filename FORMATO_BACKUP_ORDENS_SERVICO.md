# 📋 Formato do Backup de Ordens de Serviço

## ✅ Funcionalidade de Importação Implementada!

### 🎯 **Como usar:**

1. **Faça login** com `assistenciaallimport10@gmail.com`
2. **Vá para** a seção "Ordens de Serviço"
3. **Clique em** "Importar Backup" (botão verde)
4. **Selecione** seu arquivo JSON de backup
5. **Aguarde** a importação automática

---

## 📄 **Formato JSON Esperado**

O arquivo de backup deve ser um **array JSON** com objetos no seguinte formato:

```json
[
  {
    "id": "opcional - será gerado automaticamente se não fornecido",
    "numero_os": "OS001",
    "cliente_nome": "João Silva",
    "cliente_telefone": "(17) 99999-9999",
    "cliente_email": "joao@email.com",
    "tipo": "Celular",
    "marca": "Samsung",
    "modelo": "Galaxy S21",
    "cor": "Preto",
    "numero_serie": "ABC123456",
    "defeito_relatado": "Tela quebrada",
    "observacoes": "Cliente relatou queda",
    "status": "Em andamento",
    "data_entrada": "2024-01-15",
    "data_conclusao": null,
    "valor_orcamento": 250.00,
    "valor_final": 220.00,
    "garantia_meses": 3,
    "tecnico_responsavel": "Ana"
  }
]
```

---

## 🔧 **Campos Suportados**

### **Obrigatórios:**
- `cliente_nome` - Nome do cliente
- `defeito_relatado` - Problema relatado

### **Opcionais:**
- `numero_os` - Será gerado automaticamente se não fornecido
- `cliente_telefone` - Telefone do cliente
- `cliente_email` - Email do cliente
- `tipo` - Tipo do equipamento (Celular, Notebook, Console, Tablet, Outro)
- `marca` - Marca do equipamento
- `modelo` - Modelo do equipamento
- `cor` - Cor do equipamento
- `numero_serie` - Número de série
- `observacoes` - Observações técnicas
- `data_entrada` - Data de entrada (formato: YYYY-MM-DD)
- `data_conclusao` - Data de conclusão
- `valor_orcamento` - Valor orçado
- `valor_final` - Valor final cobrado
- `garantia_meses` - Meses de garantia
- `tecnico_responsavel` - Técnico responsável

---

## 📊 **Mapeamento de Status**

O sistema converte automaticamente os status do backup:

| Status no Backup | Status no Sistema |
|------------------|-------------------|
| Orçamento | Em análise |
| Em andamento | Em conserto |
| Concluído | Pronto |
| Entregue | Entregue |
| Cancelado | Cancelado |

---

## ⚡ **Funcionalidades Implementadas**

- ✅ **Validação de usuário** - Apenas assistenciaallimport10@gmail.com
- ✅ **Validação de arquivo** - Apenas arquivos JSON
- ✅ **Mapeamento automático** - Converte campos do backup para o sistema
- ✅ **Geração de IDs** - Cria IDs únicos se não fornecidos
- ✅ **Feedback visual** - Toast notifications de progresso
- ✅ **Recarga automática** - Atualiza a lista após importação
- ✅ **Tratamento de erros** - Exibe erros de forma clara

---

## 🚀 **Exemplo de Uso**

1. Prepare seu arquivo `backup-ordens-servico.json`
2. Faça login como `assistenciaallimport10@gmail.com`
3. Vá para "Ordens de Serviço"
4. Clique em "Importar Backup" (botão verde ao lado de "Nova OS")
5. Selecione seu arquivo JSON
6. Aguarde a mensagem de sucesso
7. As ordens aparecerão na lista automaticamente!

---

## ⚠️ **Observações Importantes**

- **Acesso Restrito**: Apenas o usuário `assistenciaallimport10@gmail.com` pode importar
- **Arquivo JSON**: Deve ser um arquivo válido no formato JSON
- **Dados Únicos**: Não há verificação de duplicatas - cuidado para não importar o mesmo backup múltiplas vezes
- **Backup de Segurança**: Recomendamos fazer backup dos dados existentes antes da importação

---

**🎯 A funcionalidade está pronta e operacional!** 

Agora você pode importar seu arquivo de backup real diretamente na interface do sistema.
