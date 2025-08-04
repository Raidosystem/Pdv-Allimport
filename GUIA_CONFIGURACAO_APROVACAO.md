# 🚀 CONFIGURAÇÃO DO SISTEMA DE APROVAÇÃO - PASSO A PASSO

## 📋 Situação Atual

✅ **Deploy realizado com sucesso** em: https://pdv-allimport-rfyw3ybg5-radiosystem.vercel.app

⚠️ **Sistema de aprovação precisa ser configurado** no banco de dados Supabase

---

## 🔧 PASSOS PARA CONFIGURAR

### 1. 🌐 Acesse o Supabase Dashboard

Abra o link: https://supabase.com/dashboard/project/hkbrcnacgcxqkjjgdpsq/sql

### 2. 🔐 Faça Login

Use suas credenciais do Supabase para acessar o dashboard

### 3. 📝 Execute o SQL

1. **Cole todo o conteúdo** do arquivo `SETUP_APROVACAO_COMPLETO.sql` no SQL Editor
2. **Clique em "Run"** para executar
3. **Aguarde** a confirmação de sucesso

### 4. ✅ Verifique se funcionou

Execute este comando no terminal:
```bash
node verificar-sistema-aprovacao.mjs
```

---

## 📁 ARQUIVOS IMPORTANTES

- `SETUP_APROVACAO_COMPLETO.sql` - Script SQL completo para configurar o sistema
- `verificar-sistema-aprovacao.mjs` - Script para testar se funcionou
- `DEPLOY_SUCCESS.md` - Documentação do deploy

---

## 🎯 O QUE O SISTEMA FAZ

### Fluxo de Aprovação:
1. **Usuário se cadastra** → Não precisa confirmar email
2. **Sistema cria registro** automático na tabela `user_approvals`
3. **Status inicial:** "pending" (pendente)
4. **Usuário tenta login** → Sistema verifica aprovação
5. **Se pendente:** Mostra "Aguardando aprovação do administrador"
6. **Admin aprova/rejeita** via painel administrativo
7. **Usuário consegue acessar** após aprovação

### Funcionalidades Criadas:
- ✅ Tabela `user_approvals` com controle de status
- ✅ Trigger automático para criar aprovação no cadastro
- ✅ Políticas RLS para segurança
- ✅ Funções SQL para aprovar/rejeitar
- ✅ Interface admin para gerenciar aprovações

---

## 🔐 CONTAS ADMINISTRATIVAS

Para acessar o painel de aprovação, use uma dessas contas:

- `admin@pdvallimport.com`
- `novaradiosystem@outlook.com`
- `teste@teste.com`

---

## 🧪 COMO TESTAR

### Após configurar o sistema:

1. **Acesse a aplicação:** https://pdv-allimport-rfyw3ybg5-radiosystem.vercel.app
2. **Cadastre novo usuário** com email/senha
3. **Tente fazer login** (deve mostrar mensagem de aprovação pendente)
4. **Login como admin** e acesse o painel
5. **Aprove o usuário** através da interface
6. **Faça login** com o usuário aprovado (deve funcionar)

---

## ❓ SOLUÇÃO DE PROBLEMAS

### Se der erro de conectividade:
- Verifique se está logado no Supabase
- Tente atualizar a página do SQL Editor
- Use a aba "SQL Editor" no dashboard

### Se a tabela não for criada:
- Execute novamente o script SQL
- Verifique se não há erros na saída
- Rode o script de verificação

### Se o sistema não funcionar:
- Verifique os logs no console do navegador
- Execute `node verificar-sistema-aprovacao.mjs`
- Confira se as políticas RLS foram criadas

---

## 📞 RESUMO

1. ✅ **Deploy concluído** - Aplicação online
2. ⚠️ **Configurar aprovação** - Execute SQL no Supabase
3. ✅ **Testar sistema** - Cadastro → Aprovação → Login
4. 🎉 **Sistema pronto** - PDV funcionando com aprovação

**Próximo passo:** Execute o SQL no Supabase Dashboard!
