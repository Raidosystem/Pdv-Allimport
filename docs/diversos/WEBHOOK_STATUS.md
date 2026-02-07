# Sistema de Webhook Mercado Pago - Implementação Completa

## ✅ O que foi corrigido e implementado:

### 1. **Runtime e Leitura de Body**
- ✅ Mudança para Node.js runtime (em vez de Edge)
- ✅ Uso de raw body para validação de assinatura
- ✅ Configuração correta do bodyParser: false

### 2. **Estrutura da Base de Dados**
- ✅ Tabela `payments_processed` com BIGINT para idempotência
- ✅ Função helper `table_exists()` para verificar tabelas dinamicamente
- ✅ Função RPC `extend_company_paid_until_v2()` que funciona com ou sem tabela orders

### 3. **Webhook Inteligente**
- ✅ Idempotência automática via RPC (não precisa verificar manualmente)
- ✅ Suporte a metadados do pagamento
- ✅ Fallback para buscar orders por mp_payment_id se company_id não estiver nos metadados
- ✅ Sempre retorna 200 para evitar reenvios infinitos do MP

## 🚀 Como usar o sistema:

### Passo 1: Aplicar SQL no Supabase
Execute o conteúdo do arquivo `CRIAR_FUNCAO_RPC_V2.sql` no SQL Editor do Supabase.

### Passo 2: Criar pagamento com metadados
```javascript
const paymentBody = {
  transaction_amount: 123.45,
  description: "Assinatura 30 dias",
  payment_method_id: "pix",
  payer: { email: "cliente@exemplo.com" },
  notification_url: "https://pdv-allimport.vercel.app/api/mp/webhook",
  external_reference: "company-123", // opcional
  metadata: { 
    company_id: "uuid-da-empresa-aqui", // OBRIGATÓRIO
    order_id: "uuid-do-pedido-aqui"     // opcional
  }
};

// POST para https://api.mercadopago.com/v1/payments
// Header: Authorization: Bearer SEU_ACCESS_TOKEN
```

### Passo 3: Webhook processa automaticamente
Quando o pagamento for aprovado:
1. ✅ MP envia notificação para o webhook
2. ✅ Webhook consulta detalhes do pagamento
3. ✅ Extrai company_id dos metadados
4. ✅ Chama `extend_company_paid_until_v2()` que:
   - Verifica idempotência (não processa duas vezes)
   - Estende +30 dias na empresa
   - Marca order como paid (se existir)
   - Registra o pagamento como processado

## 🔧 Configuração no Mercado Pago:
1. **Webhook URL**: `https://pdv-allimport.vercel.app/api/mp/webhook`
2. **Eventos**: `payment.created`, `payment.updated`
3. **Modo**: Produção
4. **Secret**: Configurado na env var `MP_WEBHOOK_SECRET`

## 🎯 Vantagens da implementação:

1. **Idempotência automática**: Não processa o mesmo pagamento duas vezes
2. **Flexível**: Funciona com ou sem tabela orders
3. **Robusto**: Sempre retorna 200, logs detalhados para debug
4. **Escalável**: Usa metadados para identificar empresa diretamente
5. **Compatível**: Fallback para buscar por mp_payment_id se necessário

## 🚨 Para testar:
1. Aplique o SQL no Supabase
2. Crie um pagamento REAL com metadados usando a API do MP
3. O webhook processará automaticamente quando o pagamento for aprovado

## 📋 Status atual:
- Webhook deploy: ✅ Funcionando
- Função RPC: ⏳ Precisa aplicar SQL no Supabase
- Teste real: ⏳ Aguardando pagamento com metadados