# ?? GUIA DE DEPLOY PRODUÇÃO - VERCEL + SUPABASE

## ? **SISTEMA 100% MULTI-TENANT - PRONTO PARA VENDA**

---

## ?? **PRÉ-REQUISITOS**

### **1?? Contas Necessárias**
- ? **Vercel** - https://vercel.com (para frontend)
- ? **Supabase** - https://supabase.com (para backend)
- ? **GitHub** - https://github.com (para CI/CD)

### **2?? Repositório Git**
```bash
# Seu repo já está configurado:
git remote -v
# origin: https://github.com/Raidosystem/Pdv-Allimport
```

---

## ??? **PASSO 1: CONFIGURAR SUPABASE (Backend)**

### **1.1 Criar Projeto**
```
1. Acesse: https://app.supabase.com
2. Clique: "New Project"
3. Preencha:
   - Name: pdv-allimport-prod
   - Database Password: [senha segura]
   - Region: South America (São Paulo)
4. Clique: "Create new project"
5. Aguarde 2-3 minutos
```

### **1.2 Executar SQL de Instalação**
```
1. No Supabase Dashboard, vá em: SQL Editor
2. Clique: "New query"
3. Cole TODO o conteúdo de: INSTALACAO_PRODUCAO_MULTI_TENANT.sql
4. Clique: "Run" (ou Ctrl+Enter)
5. ? Deve aparecer: "?? INSTALAÇÃO PRODUÇÃO COMPLETA!"
```

### **1.3 Obter Credenciais**
```
1. Vá em: Settings ? API
2. Copie:
   - Project URL: https://[seu-projeto].supabase.co
   - anon public key: eyJ... (chave pública)
3. Anote essas informações para o próximo passo
```

### **1.4 Configurar RLS (Row Level Security)**
```sql
-- No SQL Editor, execute:

-- Ativar RLS em todas as tabelas principais
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- Política: Funcionários veem apenas sua empresa
CREATE POLICY "funcionarios_empresa_isolada" ON funcionarios
  FOR ALL USING (
    empresa_id IN (
      SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
  );

-- Política: Logins isolados por funcionário
CREATE POLICY "login_funcionarios_isolado" ON login_funcionarios
  FOR ALL USING (
    funcionario_id IN (
      SELECT id FROM funcionarios WHERE empresa_id IN (
        SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
      )
    )
  );

-- ? Isolamento total entre empresas garantido!
```

---

## ?? **PASSO 2: DEPLOY NO VERCEL (Frontend)**

### **2.1 Conectar GitHub ao Vercel**
```
1. Acesse: https://vercel.com/new
2. Clique: "Import Git Repository"
3. Autorize: GitHub
4. Selecione: Raidosystem/Pdv-Allimport
5. Clique: "Import"
```

### **2.2 Configurar Variáveis de Ambiente**
```
Na página de configuração do projeto:

1. Vá em: "Environment Variables"
2. Adicione (clique em "Add"):

VITE_SUPABASE_URL = https://[seu-projeto].supabase.co
VITE_SUPABASE_ANON_KEY = eyJ[sua-chave-anon]...
VITE_ADMIN_EMAILS = novaradiosystem@outlook.com
VITE_APP_URL = https://pdv-allimport.vercel.app

3. Clique: "Deploy"
```

### **2.3 Build Settings (Automático)**
```
Framework Preset: Vite
Build Command: npm run build
Output Directory: dist
Install Command: npm install

? Vercel detecta automaticamente!
```

### **2.4 Aguardar Deploy**
```
1. Deploy levará ~2-3 minutos
2. ? Sucesso: "Deployment Ready"
3. URL: https://pdv-allimport.vercel.app (ou similar)
4. Clique na URL para testar
```

---

## ?? **PASSO 3: CONFIGURAR DOMÍNIO PERSONALIZADO (Opcional)**

### **3.1 Adicionar Domínio**
```
1. No Vercel, vá em: Settings ? Domains
2. Clique: "Add"
3. Digite: pdv.gruporaval.com.br
4. Clique: "Add"
```

### **3.2 Configurar DNS**
```
No seu provedor de DNS (ex: Registro.br, GoDaddy):

Tipo: CNAME
Nome: pdv
Valor: cname.vercel-dns.com
TTL: 3600

Aguarde propagação: ~10-60 minutos
```

---

## ?? **PASSO 4: TESTAR SISTEMA EM PRODUÇÃO**

### **4.1 Teste de Cadastro (Primeira Empresa)**
```
1. Acesse: https://pdv-allimport.vercel.app/signup
2. Preencha:
   - Nome completo: Empresa Teste
   - Email: empresa1@teste.com
   - CPF/CNPJ: 12345678000100
   - Razão Social: Empresa Teste LTDA
   - WhatsApp: +55 11 99999-9999
   - Senha: senha123456
3. Clique: "Cadastrar"
4. ? Empresa criada!
```

### **4.2 Teste de Login Local (Funcionário)**
```
1. Logue como empresa1@teste.com
2. Vá em: Administração ? Funcionários
3. Cadastre:
   - Nome: João Silva
   - Função: Vendedor
   - Email: joao@empresa1.com
4. Saia (logout)
5. Acesse: /login-local
6. ? Deve aparecer "João Silva"
7. Clique no card de João
8. Senha: 123456
9. ? Login funcionando!
```

### **4.3 Teste Multi-Tenant (Isolamento)**
```
1. Cadastre segunda empresa:
   - Email: empresa2@teste.com
   - Razão Social: Outra Empresa LTDA
2. Logue como empresa2@teste.com
3. Vá em: /login-local
4. ? NÃO deve ver funcionários da empresa1
5. ? Isolamento total funcionando!
```

---

## ?? **PASSO 5: SEGURANÇA PRODUÇÃO**

### **5.1 Remover Emails de Teste**
```env
# Em Vercel ? Settings ? Environment Variables
# Edite:
VITE_ADMIN_EMAILS = seu-email-real@empresa.com

# Redeploy: Vercel ? Deployments ? Redeploy
```

### **5.2 Configurar Domínios Permitidos (Supabase)**
```
1. Supabase Dashboard ? Authentication ? URL Configuration
2. Site URL: https://pdv.gruporaval.com.br
3. Redirect URLs:
   - https://pdv.gruporaval.com.br/confirm-email
   - https://pdv.gruporaval.com.br/reset-password
   - https://pdv.gruporaval.com.br/login-local
4. Save
```

### **5.3 Ativar Rate Limiting (Supabase)**
```
1. Supabase ? Settings ? API
2. Rate Limiting:
   - Requests per second: 100
   - Burst: 200
3. ? Proteção contra abuso
```

---

## ?? **PASSO 6: MONITORAMENTO**

### **6.1 Analytics (Vercel)**
```
1. Vercel Dashboard ? Analytics
2. Ative: Speed Insights
3. ? Monitore performance
```

### **6.2 Logs (Supabase)**
```
1. Supabase ? Logs & Reports
2. Monitore:
   - API Requests
   - Database Performance
   - Auth Events
3. ? Detecção de problemas
```

### **6.3 Backup (Supabase)**
```
1. Supabase ? Settings ? Database
2. Point-in-Time Recovery: Ativado
3. Backups automáticos: 7 dias
4. ? Dados seguros
```

---

## ?? **PASSO 7: MONETIZAÇÃO (Venda do Sistema)**

### **7.1 Modelo de Negócio**
```
Plano Básico: R$ 97/mês
- 1 empresa
- 5 funcionários
- Suporte email

Plano Pro: R$ 197/mês
- 1 empresa
- Funcionários ilimitados
- Suporte WhatsApp

Plano Enterprise: R$ 497/mês
- Multi-lojas
- Funcionários ilimitados
- Suporte prioritário
```

### **7.2 Configurar Pagamentos (Sugestão)**
```
1. Integrar: Mercado Pago / Stripe
2. Criar: Planos na plataforma
3. Endpoint: /api/webhooks/pagamento
4. Atualizar: Campo subscription_status na tabela user_approvals
5. ? Assinaturas automáticas
```

### **7.3 Landing Page de Vendas**
```
Criar em: https://pdv.gruporaval.com.br

Seções:
- Hero: "PDV Completo na Nuvem"
- Recursos: Lista de funcionalidades
- Preços: Tabela de planos
- Depoimentos: Social proof
- FAQ: Dúvidas frequentes
- CTA: "Experimente Grátis por 7 dias"
```

---

## ? **CHECKLIST FINAL**

- [ ] ? Supabase configurado
- [ ] ? SQL de instalação executado
- [ ] ? RLS ativado
- [ ] ? Vercel conectado ao GitHub
- [ ] ? Variáveis de ambiente configuradas
- [ ] ? Deploy realizado com sucesso
- [ ] ? Domínio personalizado (opcional)
- [ ] ? Teste de cadastro funcionando
- [ ] ? Teste de login local funcionando
- [ ] ? Teste multi-tenant (isolamento OK)
- [ ] ? Segurança configurada
- [ ] ? Monitoramento ativo
- [ ] ? Backup configurado
- [ ] ? Sistema pronto para venda

---

## ?? **SISTEMA PRONTO PARA PRODUÇÃO!**

**URL de Produção:** https://pdv-allimport.vercel.app  
**Admin:** novaradiosystem@outlook.com  
**Suporte:** Documentação completa em `/docs`

---

## ?? **SUPORTE**

Em caso de dúvidas:
1. Verifique logs no Vercel/Supabase
2. Consulte documentação do Supabase
3. GitHub Issues: https://github.com/Raidosystem/Pdv-Allimport/issues

**Sistema 100% Multi-Tenant - Pronto para escalar! ??**
