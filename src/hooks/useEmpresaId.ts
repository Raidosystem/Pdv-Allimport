import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

/**
 * Hook para obter o empresa_id do usuário logado
 * Retorna o ID da empresa associada ao usuário atual
 */
export function useEmpresaId() {
  const [empresaId, setEmpresaId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function loadEmpresaId() {
      try {
        // Pegar usuário autenticado
        const { data: { user }, error: authError } = await supabase.auth.getUser()
        
        if (authError) throw authError
        if (!user) {
          setError('Usuário não autenticado')
          setLoading(false)
          return
        }

        // Buscar empresa do usuário
        const { data: empresa, error: empresaError } = await supabase
          .from('empresas')
          .select('id')
          .eq('user_id', user.id)
          .single()

        if (empresaError) {
          console.error('Erro ao buscar empresa:', empresaError)
          setError('Empresa não encontrada')
          setLoading(false)
          return
        }

        if (!empresa) {
          setError('Empresa não encontrada para este usuário')
          setLoading(false)
          return
        }

        setEmpresaId(empresa.id)
        setError(null)
      } catch (err: any) {
        console.error('Erro ao carregar empresa_id:', err)
        setError(err.message || 'Erro desconhecido')
      } finally {
        setLoading(false)
      }
    }

    loadEmpresaId()
  }, [])

  return { empresaId, loading, error }
}
