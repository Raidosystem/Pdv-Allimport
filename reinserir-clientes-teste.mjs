import { createClient } from '@supabase/supabase-js'
import { v4 as uuidv4 } from 'uuid'

// Configurações do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

// Dados de exemplo para testar a inserção (baseados nos dados ALL IMPORT)
const clientesParaInserir = [
    {
        nome: "João Silva Santos",
        telefone: "(11) 99999-1234",
        cpf_cnpj: "123.456.789-00",
        email: "joao.silva@email.com",
        endereco: "Rua das Flores, 123, Centro",
        tipo: "Física",
        observacoes: "Cliente desde 2020",
        ativo: true
    },
    {
        nome: "Maria Oliveira Costa",
        telefone: "(11) 98888-5678",
        cpf_cnpj: "987.654.321-00",
        email: "maria.costa@email.com",
        endereco: "Av. Principal, 456, Vila Nova",
        tipo: "Física",
        observacoes: "Cliente preferencial",
        ativo: true
    },
    {
        nome: "Empresa ABC Ltda",
        telefone: "(11) 97777-9012",
        cpf_cnpj: "12.345.678/0001-90",
        email: "contato@empresaabc.com",
        endereco: "R. Comercial, 789, Centro",
        tipo: "Jurídica",
        observacoes: "Compras em grande quantidade",
        ativo: true
    },
    {
        nome: "Pedro Santos Lima",
        telefone: "(11) 96666-3456", 
        cpf_cnpj: "456.789.123-00",
        email: "pedro.lima@email.com",
        endereco: "Travessa da Paz, 321, Jardim",
        tipo: "Física",
        observacoes: "",
        ativo: true
    },
    {
        nome: "Ana Paula Ferreira",
        telefone: "(11) 95555-7890",
        cpf_cnpj: "789.123.456-00", 
        email: "ana.ferreira@email.com",
        endereco: "Alameda das Árvores, 654, Bosque",
        tipo: "Física",
        observacoes: "Cliente fiel",
        ativo: true
    }
]

async function reinserirClientesTeste() {
    console.log('🔄 Reinserindo clientes de teste...')
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    
    try {
        // 1. Verificar tabela antes
        console.log('📋 1. Verificando tabela antes da inserção...')
        const { data: antesData, error: antesError } = await supabase
            .from('clientes')
            .select('id')
            
        if (antesError) {
            console.error('❌ Erro ao verificar tabela:', antesError.message)
            return
        }
        
        console.log(`✅ Tabela clientes atual: ${antesData.length} registros`)
        
        // 2. Inserir clientes um por um para debug
        console.log('📋 2. Inserindo clientes...')
        let sucessos = 0
        let erros = 0
        
        for (const [index, cliente] of clientesParaInserir.entries()) {
            try {
                console.log(`   Inserindo ${index + 1}/5: ${cliente.nome}`)
                
                const { data, error } = await supabase
                    .from('clientes')
                    .insert({
                        id: uuidv4(),
                        ...cliente,
                        criado_em: new Date().toISOString(),
                        atualizado_em: new Date().toISOString()
                    })
                    .select()
                    
                if (error) {
                    console.error(`   ❌ Erro ao inserir ${cliente.nome}:`, error.message)
                    erros++
                } else {
                    console.log(`   ✅ ${cliente.nome} inserido com sucesso`)
                    sucessos++
                }
                
            } catch (err) {
                console.error(`   ❌ Erro inesperado ao inserir ${cliente.nome}:`, err.message)
                erros++
            }
        }
        
        // 3. Verificar resultado
        console.log('📋 3. Verificando resultado da inserção...')
        const { data: depoisData, error: depoisError } = await supabase
            .from('clientes')
            .select('id, nome, telefone, ativo')
            
        if (depoisError) {
            console.error('❌ Erro ao verificar resultado:', depoisError.message)
        } else {
            console.log(`✅ Total após inserção: ${depoisData.length} clientes`)
            console.log(`📊 Resumo: ${sucessos} sucessos, ${erros} erros`)
            
            if (depoisData.length > 0) {
                console.log('📄 Primeiros clientes inseridos:')
                depoisData.slice(0, 3).forEach((cliente, i) => {
                    console.log(`   ${i + 1}. ${cliente.nome} - ${cliente.telefone}`)
                })
            }
        }
        
    } catch (error) {
        console.error('❌ Erro geral:', error)
    }
}

// Executar reinserção
reinserirClientesTeste()
