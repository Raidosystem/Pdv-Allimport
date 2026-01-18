// 🗄️ FUNÇÃO SUPABASE EDGE - BACKUP AUTOMÁTICO
// Executa backup de todas as empresas e salva no Supabase Storage
// Deploy: supabase functions deploy backup-automatico

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Empresa {
  id: string
  user_id: string
  nome: string
  razao_social: string
}

interface BackupResult {
  empresa: string
  user_id: string
  tabelas_sucesso: number
  tabelas_falha: number
  total_registros: number
  data_backup: string
  erro?: string
}

// Tabelas para backup (mesmas do sistema local)
const TABELAS_BACKUP = [
  'user_approvals',
  'empresas',
  'subscriptions',
  'produtos',
  'clientes',
  'vendas',
  'vendas_itens',
  'caixa',
  'categorias',
  'fornecedores',
  'despesas',
  'ordens_servico',
  'funcionarios',
]

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Criar cliente Supabase com SERVICE_ROLE_KEY
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    console.log('🚀 Iniciando backup automático...')

    // 1. Buscar todas as empresas usando RPC que bypassa RLS
    const { data: empresas, error: empresasError } = await supabase
      .rpc('backup_listar_empresas')

    if (empresasError) {
      throw new Error(`Erro ao listar empresas: ${empresasError.message}`)
    }

    if (!empresas || empresas.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Nenhuma empresa encontrada' 
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`✅ ${empresas.length} empresa(s) encontrada(s)`)

    const resultados: BackupResult[] = []

    // 2. Fazer backup de cada empresa
    for (const empresa of empresas as Empresa[]) {
      try {
        console.log(`\n📊 Processando: ${empresa.nome || empresa.razao_social}`)
        
        const empresaBackup: any = {
          empresa_info: {
            id: empresa.id,
            user_id: empresa.user_id,
            nome: empresa.nome,
            razao_social: empresa.razao_social
          },
          data_backup: new Date().toISOString(),
          tabelas: {}
        }

        let sucessos = 0
        let falhas = 0
        let totalRegistros = 0

        // Backup de cada tabela
        for (const tabela of TABELAS_BACKUP) {
          try {
            const { data, error } = await supabase
              .rpc('backup_tabela_por_user', {
                tabela_nome: tabela,
                filtro_user_id: empresa.user_id
              })

            if (error) {
              console.log(`   ❌ ${tabela}: ${error.message}`)
              falhas++
              continue
            }

            if (data && data.length > 0) {
              empresaBackup.tabelas[tabela] = data
              totalRegistros += data.length
              sucessos++
              console.log(`   ✅ ${tabela}: ${data.length} registros`)
            } else {
              falhas++
            }
          } catch (err) {
            console.log(`   ❌ ${tabela}: ${err.message}`)
            falhas++
          }
        }

        // 3. Salvar backup no Supabase Storage
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
        const filename = `empresa_${empresa.user_id.substring(0, 8)}/backup_${timestamp}.json`
        
        const { error: uploadError } = await supabase.storage
          .from('backups')
          .upload(filename, JSON.stringify(empresaBackup, null, 2), {
            contentType: 'application/json',
            upsert: false
          })

        if (uploadError) {
          console.log(`   ❌ Erro ao salvar: ${uploadError.message}`)
          resultados.push({
            empresa: empresa.nome || empresa.razao_social,
            user_id: empresa.user_id,
            tabelas_sucesso: sucessos,
            tabelas_falha: falhas,
            total_registros: totalRegistros,
            data_backup: timestamp,
            erro: uploadError.message
          })
        } else {
          console.log(`   ✅ Backup salvo: ${filename}`)
          resultados.push({
            empresa: empresa.nome || empresa.razao_social,
            user_id: empresa.user_id,
            tabelas_sucesso: sucessos,
            tabelas_falha: falhas,
            total_registros: totalRegistros,
            data_backup: timestamp
          })
        }

        // 4. Limpar backups antigos (manter últimos 7 dias)
        await limparBackupsAntigos(supabase, empresa.user_id)

      } catch (err) {
        console.log(`❌ Erro ao processar empresa ${empresa.nome}: ${err.message}`)
        resultados.push({
          empresa: empresa.nome || empresa.razao_social,
          user_id: empresa.user_id,
          tabelas_sucesso: 0,
          tabelas_falha: TABELAS_BACKUP.length,
          total_registros: 0,
          data_backup: new Date().toISOString(),
          erro: err.message
        })
      }
    }

    // 5. Resumo final
    const totalEmpresas = resultados.length
    const totalSucesso = resultados.filter(r => !r.erro).length
    const totalFalhas = resultados.filter(r => r.erro).length
    const totalRegistros = resultados.reduce((sum, r) => sum + r.total_registros, 0)

    console.log('\n' + '='.repeat(60))
    console.log('🎉 BACKUP AUTOMÁTICO CONCLUÍDO!')
    console.log('='.repeat(60))
    console.log(`✅ Empresas com sucesso: ${totalSucesso}/${totalEmpresas}`)
    console.log(`❌ Empresas com falha: ${totalFalhas}`)
    console.log(`📦 Total de registros: ${totalRegistros}`)

    return new Response(
      JSON.stringify({
        success: true,
        timestamp: new Date().toISOString(),
        resumo: {
          total_empresas: totalEmpresas,
          empresas_sucesso: totalSucesso,
          empresas_falha: totalFalhas,
          total_registros: totalRegistros
        },
        resultados
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Erro fatal:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        stack: error.stack
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

/**
 * Remove backups com mais de 7 dias
 */
async function limparBackupsAntigos(supabase: any, userId: string) {
  try {
    const pastaEmpresa = `empresa_${userId.substring(0, 8)}`
    
    // Listar todos os backups da empresa
    const { data: arquivos, error } = await supabase.storage
      .from('backups')
      .list(pastaEmpresa)

    if (error || !arquivos) return

    const dataLimite = new Date()
    dataLimite.setDate(dataLimite.getDate() - 7)

    // Remover arquivos antigos
    const arquivosAntigos = arquivos
      .filter((arquivo: any) => new Date(arquivo.created_at) < dataLimite)
      .map((arquivo: any) => `${pastaEmpresa}/${arquivo.name}`)

    if (arquivosAntigos.length > 0) {
      await supabase.storage
        .from('backups')
        .remove(arquivosAntigos)
      
      console.log(`   🧹 ${arquivosAntigos.length} backup(s) antigo(s) removido(s)`)
    }
  } catch (err) {
    console.log(`   ⚠️ Erro ao limpar backups antigos: ${err.message}`)
  }
}
