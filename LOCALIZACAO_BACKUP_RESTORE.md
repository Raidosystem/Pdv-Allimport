# 🔄 SISTEMA DE BACKUP E RESTORE - LOCALIZAÇÃO E USO

## 📍 ONDE ENCONTRAR A OPÇÃO DE BACKUP E RESTORE

### 1. **Acesso pelo Dashboard**
1. Acesse o sistema: http://localhost:5174/dashboard
2. Clique no card **"Administração"** (ícone de engrenagem ⚙️)
3. Você será redirecionado para `/configuracoes`

### 2. **Acesso Direto**
- URL direta: http://localhost:5174/configuracoes
- Navegue até a seção **"Backup e Restauração"**

## 🛠️ FUNCIONALIDADES DISPONÍVEIS

### **Backup Manual**
- Criar backup instantâneo dos seus dados
- Backup armazenado no banco de dados com timestamp
- Apenas seus dados (isolamento total por usuário)

### **Export para JSON**
- Exportar todos os dados para arquivo JSON
- Download direto no navegador
- Formato legível e portável

### **Import de JSON**
- Importar dados de arquivo JSON previamente exportado
- Validação automática do formato
- Segurança: só aceita dados do mesmo usuário

### **Restauração de Backup**
- Listar todos os backups disponíveis
- Restaurar dados de qualquer backup anterior
- Confirmação de segurança antes da restauração

### **Backup Automático**
- ✅ **JÁ CONFIGURADO**: Backup diário automático às 2:00 AM
- Retenção de 30 dias
- Limpeza automática de backups antigos

## 🔐 SEGURANÇA E PRIVACIDADE

### **Isolamento Total**
- Cada usuário só vê seus próprios backups
- Sistema RLS (Row Level Security) garante privacidade
- Impossível acessar dados de outros usuários

### **Dados Incluídos no Backup**
- ✅ Produtos
- ✅ Clientes  
- ✅ Vendas
- ✅ Itens de venda
- ✅ Movimento de caixa
- ✅ Ordens de serviço
- ✅ Configurações
- ✅ Subscriptions
- ✅ Histórico de backups

## 🚀 COMO USAR

### **Fazer Backup Manual**
1. Acesse **Configurações** → **Backup e Restauração**
2. Clique em **"Criar Backup Manual"**
3. Aguarde confirmação de sucesso

### **Exportar Dados**
1. Clique em **"Exportar para JSON"**
2. Arquivo será baixado automaticamente
3. Nome do arquivo: `backup-pdv-YYYY-MM-DD-HH-mm-ss.json`

### **Restaurar Backup**
1. Na lista de backups disponíveis
2. Clique em **"Restaurar"** no backup desejado
3. Confirme a ação (⚠️ substitui dados atuais)

### **Importar JSON**
1. Clique em **"Importar JSON"**
2. Selecione o arquivo de backup
3. Confirme a importação

## 📱 INTERFACE DO USUÁRIO

### **Localização no Dashboard**
```
Dashboard Principal
├── 💰 Vendas
├── 📦 Produtos  
├── 👥 Clientes
├── 💼 Caixa
├── 📄 OS - Ordem de Serviço
└── ⚙️ Administração ← CLIQUE AQUI
    └── 🔄 Backup e Restauração ← OPÇÃO DE BACKUP
```

### **Navegação das Configurações**
```
Configurações (/configuracoes)
├── 🔄 Backup e Restauração ← PRINCIPAL
├── 🔐 Segurança
├── 👤 Perfil do Usuário  
├── 🔔 Notificações
└── 🎨 Aparência
```

## ⚡ AÇÕES RÁPIDAS

### **URLs Diretas**
- **Configurações**: `/configuracoes`
- **Dashboard**: `/dashboard`
- **Página inicial**: `/`

### **Atalhos de Navegação**
- No cabeçalho das configurações: botão "Dashboard" para voltar
- Breadcrumb navegacional em cada seção
- Botão "Voltar às Configurações" em cada subseção

## 🎯 RESUMO PARA O USUÁRIO

**LOCALIZAÇÃO:** Dashboard → Administração → Backup e Restauração

**FUNCIONALIDADES:**
- ✅ Backup manual instantâneo
- ✅ Export/Import JSON
- ✅ Restauração de backups
- ✅ Backup automático diário (já ativo)
- ✅ Privacidade total garantida

**ACESSO RÁPIDO:** http://localhost:5174/configuracoes

---

🔒 **Nota**: O sistema de backup está totalmente funcional e seus dados estão seguros com backup automático diário e possibilidade de backup manual a qualquer momento.
