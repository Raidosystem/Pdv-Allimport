# 👥 Guia: Criar Funcionário pelo Sistema

## ✅ Status Atual
- **Proprietário**: assistenciaallimport10@gmail.com (CORRIGIDO e funcionando)
- **Funcionário**: cris-ramos30@hotmail.com (PRECISA SER CRIADO)

## 🎯 Passo-a-Passo para Criar o Funcionário

### 1. **Fazer Login como Proprietário**
```
URL: http://localhost:5173/login
Email: assistenciaallimport10@gmail.com
Senha: [sua senha]
```

### 2. **Acessar Gerenciamento de Funcionários**
```
URL: http://localhost:5173/funcionarios
```
Ou pelo menu lateral: **"Gerenciar Funcionários"**

### 3. **Criar Novo Funcionário**
1. Clique no botão **"Adicionar Funcionário"**
2. Preencha o formulário:
   - **Email**: `cris-ramos30@hotmail.com`
   - **Nome Completo**: `Cristiano Ramos` (ou nome desejado)
   - **Senha**: `123456` (ou senha desejada)
   - **Nome da Empresa**: `Assistencia All-import` (mesmo do proprietário)

3. Clique **"Criar Funcionário"**

### 4. **Resultado Esperado**
- ✅ Funcionário será criado automaticamente
- ✅ Status: **approved** (auto-aprovado)
- ✅ Tipo: **employee**
- ✅ Vinculado ao proprietário (assistenciaallimport10@gmail.com)
- ✅ Aparecerá na lista de funcionários
- ✅ Aparecerá no AdminPanel

### 5. **Teste do Login do Funcionário**
```
URL: http://localhost:5173/login
Email: cris-ramos30@hotmail.com
Senha: [senha que você definiu]
```

## 🚀 Executar Agora

1. **Inicie o servidor de desenvolvimento**:
```bash
npm run dev
```

2. **Acesse**: http://localhost:5173

3. **Siga os passos acima** ⬆️

## 🔧 Se Houver Problemas

### Erro na Criação:
- Verifique se está logado como proprietário
- Confirme se a página `/funcionarios` carrega
- Verifique o console do navegador (F12)

### Funcionário não aparece:
- Atualize a página
- Verifique no AdminPanel (`/admin`)
- Execute o script de diagnóstico novamente

### Login do funcionário não funciona:
- Confirme a senha usada na criação
- Verifique se o email foi digitado corretamente
- Aguarde alguns segundos após a criação

## 💡 Funcionalidades do Sistema

Após criar o funcionário, ele terá acesso a:
- ✅ Sistema de vendas
- ✅ Cadastro de clientes
- ✅ Cadastro de produtos
- ✅ Relatórios (limitados)
- ❌ AdminPanel (apenas proprietários)
- ❌ Gerenciamento de funcionários (apenas proprietários)

## 📞 Suporte

Se precisar de ajuda durante o processo, me informe em qual etapa está tendo dificuldade!
