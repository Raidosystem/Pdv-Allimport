# 📦 Backup Automático para Google Drive

## ✅ Solução Completa - Salva backup diretamente no Google Drive

Esta solução usa GitHub Actions para fazer backup automático diário e enviar para seu Google Drive.

---

## 🔐 Passo 1: Criar Credenciais do Google

### 1.1 Acessar Google Cloud Console
1. Acesse: https://console.cloud.google.com/
2. Crie um novo projeto ou selecione um existente
3. Nome sugerido: "PDV Backup System"

### 1.2 Habilitar Google Drive API
1. No menu lateral, vá em: **APIs e Serviços** > **Biblioteca**
2. Busque por: "Google Drive API"
3. Clique em **Ativar**

### 1.3 Criar Service Account
1. Vá em: **APIs e Serviços** > **Credenciais**
2. Clique em **Criar Credenciais** > **Conta de serviço**
3. Preencha:
   - Nome: `pdv-backup-service`
   - Descrição: "Serviço para backup automático do PDV"
4. Clique em **Criar e continuar**
5. Função: Selecione **Editor** (ou **Proprietário**)
6. Clique em **Concluir**

### 1.4 Baixar Chave JSON
1. Na lista de contas de serviço, clique na que você criou
2. Vá na aba **Chaves**
3. Clique em **Adicionar chave** > **Criar nova chave**
4. Escolha formato: **JSON**
5. Clique em **Criar** (arquivo JSON será baixado)

### 1.5 Criar Pasta no Google Drive
1. Acesse seu Google Drive: https://drive.google.com
2. Crie uma pasta chamada: **Backups PDV**
3. Clique com botão direito na pasta > **Compartilhar**
4. Adicione o email da service account (encontrado no JSON baixado)
   - Email será algo como: `pdv-backup-service@seu-projeto.iam.gserviceaccount.com`
5. Permissão: **Editor**
6. Copie o **ID da pasta** da URL:
   - URL: `https://drive.google.com/drive/folders/1ABcD_EfGhIjKlMnOpQrStUvWxYz`
   - ID: `1ABcD_EfGhIjKlMnOpQrStUvWxYz`

---

## 🔑 Passo 2: Configurar Secrets no GitHub

Vá em: `https://github.com/Raidosystem/Pdv-Allimport/settings/secrets/actions`

### Secret 1: GOOGLE_DRIVE_CREDENTIALS
- Name: `GOOGLE_DRIVE_CREDENTIALS`
- Value: Cole **todo o conteúdo** do arquivo JSON baixado

### Secret 2: GOOGLE_DRIVE_FOLDER_ID
- Name: `GOOGLE_DRIVE_FOLDER_ID`
- Value: Cole o **ID da pasta** copiado

### Secret 3: SUPABASE_URL
- Name: `SUPABASE_URL`
- Value: `https://kmcaaqetxtwkdcczdomw.supabase.co`

### Secret 4: SUPABASE_ANON_KEY
- Name: `SUPABASE_ANON_KEY`
- Value: Sua chave anon do Supabase

---

## 📁 Estrutura dos Backups

Os backups serão salvos no Google Drive com o seguinte padrão:

```
📁 Backups PDV/
  📁 2025/
    📁 11-Novembro/
      📄 backup-pdv-2025-11-24.json
      📄 backup-pdv-2025-11-25.json
      📄 backup-pdv-2025-11-26.json
```

---

## 🚀 Como Usar

1. Configure as credenciais (Passos 1 e 2 acima)
2. O workflow já está criado em `.github/workflows/backup-google-drive.yml`
3. Faça commit e push do workflow
4. O backup rodará automaticamente todo dia às 2:00 AM UTC (23:00 Brasília)

---

## 🧪 Testar Manualmente

1. Vá em: `https://github.com/Raidosystem/Pdv-Allimport/actions`
2. Clique em **Backup para Google Drive**
3. Clique em **Run workflow** > **Run workflow**
4. Aguarde ~1 minuto
5. Verifique seu Google Drive - backup estará lá! 📦

---

## 📊 Monitoramento

Para ver o histórico de backups:
1. Acesse: https://github.com/Raidosystem/Pdv-Allimport/actions
2. Clique em qualquer execução
3. Veja os logs detalhados

---

## ⏰ Alterar Horário do Backup

Edite o arquivo `.github/workflows/backup-google-drive.yml`:

```yaml
schedule:
  - cron: '0 3 * * *'  # 3:00 AM UTC = Meia-noite Brasília
  - cron: '0 6 * * *'  # 6:00 AM UTC = 3:00 AM Brasília
```

---

## 🔒 Segurança

✅ As credenciais ficam seguras nos GitHub Secrets  
✅ Apenas você tem acesso aos backups no Google Drive  
✅ Backups são criptografados em trânsito  
✅ Service Account tem acesso apenas à pasta específica  

---

## 🆘 Solução de Problemas

### Erro: "Access denied"
**Solução**: Verifique se compartilhou a pasta do Drive com o email da service account

### Erro: "Invalid credentials"
**Solução**: Verifique se copiou todo o JSON corretamente no secret

### Backup não aparece no Drive
**Solução**: 
1. Verifique os logs no GitHub Actions
2. Confirme que o FOLDER_ID está correto
3. Teste manualmente o workflow

---

## 💾 Restaurar Backup

1. Baixe o arquivo JSON do Google Drive
2. Acesse: Admin > Backups > Restaurar de PC
3. Selecione o arquivo baixado
4. Clique em **Restaurar**

---

## 📈 Vantagens

✅ **Automático**: Backup todo dia sem você fazer nada  
✅ **Seguro**: Armazenado no seu Google Drive pessoal  
✅ **Gratuito**: 15 GB de espaço grátis no Google Drive  
✅ **Acessível**: Baixe de qualquer lugar  
✅ **Organizado**: Backups organizados por ano/mês  
✅ **Confiável**: Google Drive tem 99.9% de uptime  

---

## 📚 Recursos Adicionais

- [Google Drive API Documentation](https://developers.google.com/drive)
- [Service Account Guide](https://cloud.google.com/iam/docs/service-accounts)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

✅ **Pronto! Seu sistema PDV terá backup automático diário no Google Drive!**
