// 🔬 SCRIPT DE DIAGNÓSTICO - Cole no Console do Navegador
// Execute este script no Console (F12) do sistema em http://localhost:5186/ordens-servico

console.log('🔬 INICIANDO DIAGNÓSTICO...');

// 1. Verificar se há dados no localStorage/sessionStorage
console.log('📋 1. Verificando autenticação...');
const authData = localStorage.getItem('supabase.auth.token');
if (authData) {
    console.log('✅ Dados de auth encontrados:', JSON.parse(authData));
} else {
    console.log('❌ Sem dados de autenticação');
}

// 2. Verificar se o Supabase está carregado
console.log('📋 2. Verificando Supabase...');
if (window.supabase) {
    console.log('✅ Supabase carregado');
} else {
    console.log('❌ Supabase não encontrado');
}

// 3. Função para testar busca de ordens
async function testarBuscaOrdens() {
    console.log('📋 3. Testando busca de ordens...');
    
    try {
        // Simular importação do serviço (se disponível)
        if (window.ordemServicoService) {
            const ordens = await window.ordemServicoService.buscarOrdens();
            console.log('✅ Ordens encontradas:', ordens);
            
            const ordemTarget = ordens.find(o => o.numero_os === 'OS-20250915-003');
            if (ordemTarget) {
                console.log('🎉 ORDEM OS-20250915-003 ENCONTRADA!', ordemTarget);
            } else {
                console.log('❌ Ordem OS-20250915-003 NÃO encontrada na lista');
                console.log('📋 Ordens disponíveis:', ordens.map(o => o.numero_os));
            }
        } else {
            console.log('⚠️ Serviço de ordens não disponível no window');
        }
    } catch (error) {
        console.log('❌ Erro ao buscar ordens:', error);
    }
}

// 4. Executar teste
testarBuscaOrdens();

// 5. Verificar se há erros na página
console.log('📋 4. Verificando erros na página...');
if (console.error.length > 0) {
    console.log('❌ Erros encontrados na página');
} else {
    console.log('✅ Nenhum erro aparente');
}

// 6. Função para forçar reload do componente (se React)
function forcarReload() {
    console.log('🔄 Forçando reload...');
    window.location.reload();
}

// 7. Instruções
console.log('');
console.log('📝 INSTRUÇÕES:');
console.log('1. Se não viu a ordem OS-20250915-003, execute: forcarReload()');
console.log('2. Verifique se está logado com: assistenciaallimport10@gmail.com');
console.log('3. Se o problema persistir, o issue é no banco de dados');
console.log('');
console.log('🔧 Para forçar reload: forcarReload()');

// Disponibilizar função global
window.forcarReload = forcarReload;
window.testarBuscaOrdens = testarBuscaOrdens;