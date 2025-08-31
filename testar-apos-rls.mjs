import { createClient } from '@supabase/supabase-js'

// Configurações do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

async function testarAposDesabilitarRLS() {
    console.log('🧪 TESTE APÓS DESABILITAR RLS VIA DASHBOARD')
    console.log('Execute este script DEPOIS de desabilitar o RLS no dashboard')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // 1. Verificar acesso atual
        console.log('📋 1. Verificando acesso atual...')
        const { data: currentData, error: currentError } = await supabase
            .from('clientes')
            .select('*')
            
        if (currentError) {
            console.error('❌ AINDA com problema de acesso:', currentError.message)
            console.log('⚠️  Certifique-se de ter desabilitado o RLS no dashboard!')
            return
        }
        
        console.log(`✅ Acesso funcionando! Registros atuais: ${currentData.length}`)
        
        // 2. Testar inserção
        console.log('📋 2. Testando inserção de cliente...')
        const { data: insertData, error: insertError } = await supabase
            .from('clientes')
            .insert({
                nome: "TESTE - Cliente via Script",
                telefone: "(11) 99999-SCRIPT", 
                cpf_cnpj: "000.000.000-02",
                email: "script@teste.com",
                endereco: "Endereço teste script",
                tipo: "Física",
                observacoes: "Cliente inserido via script após correção RLS",
                ativo: true
            })
            .select()
            
        if (insertError) {
            console.error('❌ Erro na inserção:', insertError.message)
        } else {
            console.log('✅ INSERÇÃO FUNCIONOU!', insertData[0].nome)
            
            // 3. Inserir múltiplos clientes de teste
            console.log('📋 3. Inserindo múltiplos clientes de teste...')
            
            const clientesTeste = [
                {
                    nome: "João Silva Santos",
                    telefone: "(11) 98888-1111",
                    cpf_cnpj: "111.111.111-11",
                    email: "joao@teste.com",
                    endereco: "Rua A, 123",
                    tipo: "Física",
                    observacoes: "Cliente teste 1",
                    ativo: true
                },
                {
                    nome: "Maria Oliveira Costa", 
                    telefone: "(11) 97777-2222",
                    cpf_cnpj: "222.222.222-22",
                    email: "maria@teste.com",
                    endereco: "Av. B, 456",
                    tipo: "Física", 
                    observacoes: "Cliente teste 2",
                    ativo: true
                },
                {
                    nome: "Empresa ABC Ltda",
                    telefone: "(11) 96666-3333",
                    cpf_cnpj: "11.222.333/0001-44",
                    email: "contato@abc.com",
                    endereco: "R. Comercial, 789",
                    tipo: "Jurídica",
                    observacoes: "Empresa teste",
                    ativo: true
                }
            ]
            
            const { data: batchData, error: batchError } = await supabase
                .from('clientes')
                .insert(clientesTeste)
                .select()
                
            if (batchError) {
                console.error('❌ Erro na inserção em lote:', batchError.message)
            } else {
                console.log(`✅ INSERÇÃO EM LOTE FUNCIONOU! ${batchData.length} clientes inseridos`)
                
                // 4. Verificar total final
                const { data: finalData, error: finalError } = await supabase
                    .from('clientes')
                    .select('id, nome, telefone, ativo')
                    
                if (!finalError) {
                    console.log(`🎉 SISTEMA FUNCIONANDO! Total: ${finalData.length} clientes`)
                    console.log('📄 Primeiros clientes:')
                    finalData.slice(0, 5).forEach((cliente, i) => {
                        console.log(`   ${i + 1}. ${cliente.nome} - ${cliente.telefone}`)
                    })
                    
                    console.log('')
                    console.log('🚀 PRÓXIMO PASSO: Reinicie o frontend e teste a seção Clientes!')
                    console.log('   npm run dev')
                }
            }
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error)
    }
}

console.log('⏳ Aguardando você desabilitar o RLS no dashboard...')
console.log('📱 Dashboard: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw')
console.log('')
console.log('Depois de desabilitar o RLS, execute este script novamente!')

// Executar teste
testarAposDesabilitarRLS()
