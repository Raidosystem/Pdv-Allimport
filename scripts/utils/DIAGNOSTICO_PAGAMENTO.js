// 🔍 DIAGNÓSTICO: Problema "Falta pagar R$ 0,00"
// Execute no Console do Browser (F12) para debug

console.log('🔍 DIAGNÓSTICO DO PROBLEMA DE PAGAMENTO');
console.log('=====================================');

// Simular valores para debug
const totalAmount = 100.00;
const payments = []; // Array vazio - sem pagamentos extras
const cashReceived = 100.00; // Dinheiro recebido

// Cálculos (como no PagamentoForm.tsx)
const totalPaid = payments.reduce((sum, payment) => sum + payment.amount, 0) + cashReceived;
const remainingAmount = Math.max(0, totalAmount - totalPaid);
const isPaymentComplete = totalPaid >= totalAmount;

console.log('📊 VALORES CALCULADOS:');
console.log('totalAmount:', totalAmount);
console.log('payments:', payments);
console.log('cashReceived:', cashReceived);
console.log('totalPaid:', totalPaid);
console.log('remainingAmount:', remainingAmount);
console.log('isPaymentComplete:', isPaymentComplete);

console.log('=====================================');

if (remainingAmount === 0 && !isPaymentComplete) {
    console.log('🐛 PROBLEMA ENCONTRADO: remainingAmount = 0 mas isPaymentComplete = false');
    console.log('💡 CAUSA: Possível problema de precisão numérica');
    console.log('🔧 SOLUÇÃO: Usar tolerância para comparação de números decimais');
} else if (remainingAmount > 0 && totalPaid >= totalAmount) {
    console.log('🐛 PROBLEMA ENCONTRADO: totalPaid >= totalAmount mas remainingAmount > 0');
    console.log('💡 CAUSA: Math.max(0, ...) não está funcionando corretamente');
} else if (remainingAmount < 0.01 && remainingAmount > 0) {
    console.log('🐛 PROBLEMA ENCONTRADO: remainingAmount muito pequeno mas maior que 0');
    console.log('💡 CAUSA: Problema de precisão com números decimais');
    console.log('🔧 SOLUÇÃO: Arredondar ou usar tolerância');
} else {
    console.log('✅ Cálculos parecem corretos');
}

console.log('=====================================');
console.log('🔧 TESTE COM DIFERENTES CENÁRIOS:');

// Teste 1: Pagamento exato
console.log('Teste 1 - Pagamento exato:');
testPayment(100, [], 100);

// Teste 2: Pagamento com centavos
console.log('Teste 2 - Pagamento com centavos:');
testPayment(99.99, [], 99.99);

// Teste 3: Pagamento misto
console.log('Teste 3 - Pagamento misto:');
testPayment(100, [{amount: 50}], 50);

function testPayment(total, paymentsArray, cash) {
    const paid = paymentsArray.reduce((sum, p) => sum + p.amount, 0) + cash;
    const remaining = Math.max(0, total - paid);
    const complete = paid >= total;
    
    console.log(`  Total: ${total}, Pago: ${paid}, Falta: ${remaining}, Completo: ${complete}`);
    
    if (remaining <= 0.01 && !complete) {
        console.log('  🐛 PROBLEMA DETECTADO!');
    }
}