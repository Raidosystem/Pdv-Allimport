# 📧 Backup Automático por Email (Gmail/Outlook)

## ✅ Solução Completa - Envia backup diário por email

Esta solução usa GitHub Actions para fazer backup e enviar automaticamente por email.

---

## 🔐 Opção 1: Gmail (Google)

### Passo 1: Configurar Gmail

1. **Ativar verificação em 2 etapas**:
   - Acesse: https://myaccount.google.com/security
   - Ative: **Verificação em duas etapas**

2. **Criar Senha de App**:
   - Acesse: https://myaccount.google.com/apppasswords
   - Selecione: **Email** > **Outro (nome personalizado)**
   - Digite: `PDV Backup System`
   - Clique em **Gerar**
   - **Copie a senha de 16 dígitos** (ex: `abcd efgh ijkl mnop`)

### Passo 2: Configurar Secrets no GitHub

Vá em: `https://github.com/Raidosystem/Pdv-Allimport/settings/secrets/actions`

**Secret 1: EMAIL_SENDER**
- Name: `EMAIL_SENDER`
- Value: `seu-email@gmail.com`

**Secret 2: EMAIL_RECEIVER**
- Name: `EMAIL_RECEIVER`
- Value: `email-onde-quer-receber@gmail.com` (pode ser o mesmo)

**Secret 3: EMAIL_PASSWORD**
- Name: `EMAIL_PASSWORD`
- Value: Cole a **senha de app** de 16 dígitos (sem espaços: `abcdefghijklmnop`)

**Secret 4: SUPABASE_URL**
- Name: `SUPABASE_URL`
- Value: `https://kmcaaqetxtwkdcczdomw.supabase.co`

**Secret 5: SUPABASE_ANON_KEY**
- Name: `SUPABASE_ANON_KEY`
- Value: Sua chave anon do Supabase

---

## 🔐 Opção 2: Outlook (Microsoft)

### Passo 1: Configurar Outlook

1. **Ativar verificação em 2 etapas**:
   - Acesse: https://account.microsoft.com/security
   - Ative: **Verificação em duas etapas**

2. **Criar Senha de App**:
   - Na mesma página de segurança
   - Clique em: **Opções avançadas de segurança**
   - Clique em: **Criar nova senha de aplicativo**
   - Digite: `PDV Backup`
   - **Copie a senha gerada**

### Passo 2: Configurar Secrets no GitHub

**Secret 1: EMAIL_SENDER**
- Name: `EMAIL_SENDER`
- Value: `seu-email@outlook.com` (ou `@hotmail.com`)

**Secret 2: EMAIL_RECEIVER**
- Name: `EMAIL_RECEIVER`
- Value: Email onde quer receber os backups

**Secret 3: EMAIL_PASSWORD**
- Name: `EMAIL_PASSWORD`
- Value: Cole a senha de app do Outlook

**Secret 4: EMAIL_SMTP_SERVER**
- Name: `EMAIL_SMTP_SERVER`
- Value: `smtp-mail.outlook.com`

**Secret 5: EMAIL_SMTP_PORT**
- Name: `EMAIL_SMTP_PORT`
- Value: `587`

**Secret 6 e 7**: SUPABASE_URL e SUPABASE_ANON_KEY (mesmos da opção Gmail)

---

## 📧 Como Funciona

1. **Todo dia às 2:00 AM UTC** (23:00 Brasília):
   - Cria backup no Supabase
   - Baixa o backup como arquivo JSON
   - Envia por email com anexo

2. **Email recebido contém**:
   - Assunto: `[PDV] Backup Automático - 24/11/2025`
   - Corpo: Resumo do backup (quantos clientes, produtos, etc.)
   - Anexo: `backup-pdv-2025-11-24.json`

---

## 📁 Organização dos Backups

**Recomendação**: Configure uma regra no Gmail/Outlook para organizar automaticamente

### Gmail:
1. Abra o email do backup
2. Clique nos 3 pontos > **Filtrar mensagens assim**
3. Em "Assunto": `[PDV] Backup Automático`
4. Clique em **Criar filtro**
5. Marque: **Aplicar marcador** > Criar novo: `Backups PDV`
6. Marque: **Pular caixa de entrada** (Arquivar)
7. Clique em **Criar filtro**

### Outlook:
1. Abra o email do backup
2. Clique com botão direito > **Regras** > **Criar regra**
3. Condição: Assunto contém `[PDV] Backup`
4. Ação: Mover para pasta > Criar nova: `Backups PDV`
5. Salvar

---

## 🚀 Como Usar

1. Configure Gmail ou Outlook (Passos acima)
2. Configure os Secrets no GitHub
3. O workflow já está criado em `.github/workflows/backup-email.yml`
4. Faça commit e push
5. Pronto! Backup automático por email funcionando 24/7

---

## 🧪 Testar Agora

1. Vá em: `https://github.com/Raidosystem/Pdv-Allimport/actions`
2. Clique em **Backup por Email**
3. Clique em **Run workflow** > **Run workflow**
4. Aguarde ~30 segundos
5. Verifique sua caixa de entrada! 📧

---

## ⏰ Alterar Horário

Edite `.github/workflows/backup-email.yml`:

```yaml
schedule:
  - cron: '0 0 * * *'  # Meia-noite UTC = 21:00 Brasília
  - cron: '0 12 * * *' # Meio-dia UTC = 9:00 AM Brasília
```

---

## 📊 Vantagens

✅ **Simples**: Recebe direto no email  
✅ **Acessível**: Acesse de qualquer dispositivo  
✅ **Seguro**: Email criptografado  
✅ **Gratuito**: Sem custo adicional  
✅ **Histórico**: Todos os backups salvos no email  
✅ **Offline**: Baixe e guarde localmente  

---

## 🔒 Segurança

✅ Usa senha de app (não sua senha real)  
✅ Conexão criptografada (TLS/SSL)  
✅ Credenciais seguras no GitHub Secrets  
✅ Apenas você recebe os backups  

---

## 💾 Restaurar Backup

1. Baixe o anexo `.json` do email
2. Acesse: Admin > Backups > Restaurar de PC
3. Selecione o arquivo baixado
4. Clique em **Restaurar**

---

## 🆘 Solução de Problemas

### Email não chega
**Solução**:
1. Verifique pasta de Spam/Lixo eletrônico
2. Adicione o email remetente aos contatos
3. Verifique se a senha de app está correta

### Erro: "Authentication failed"
**Solução**:
1. Verifique se ativou verificação em 2 etapas
2. Crie nova senha de app
3. Copie a senha sem espaços

### Erro: "Connection timeout"
**Solução**:
- Gmail: Use servidor `smtp.gmail.com` porta `587`
- Outlook: Use servidor `smtp-mail.outlook.com` porta `587`

---

## 📈 Comparação: Gmail vs Outlook

| Recurso | Gmail | Outlook |
|---------|-------|---------|
| Espaço gratuito | 15 GB | 5 GB |
| Tamanho máx. anexo | 25 MB | 20 MB |
| Facilidade de configurar | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Confiabilidade | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Recomendação**: Gmail (mais fácil e mais espaço)

---

## 💡 Dicas

1. **Backup muito grande?**
   - Os backups são compactados automaticamente
   - Tamanho médio: ~500 KB a 2 MB

2. **Quer receber em múltiplos emails?**
   - Configure `EMAIL_RECEIVER` com emails separados por vírgula:
   - `email1@gmail.com,email2@outlook.com,email3@yahoo.com`

3. **Organização**:
   - Use pastas/marcadores para organizar backups
   - Configure regras para arquivamento automático

---

✅ **Pronto! Backup automático por email configurado!**

Você receberá um email todo dia com o backup do sistema! 📧
