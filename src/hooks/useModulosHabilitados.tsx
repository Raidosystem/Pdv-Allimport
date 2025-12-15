import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../modules/auth/AuthContext'

interface ModulosHabilitados {
  ordens_servico: boolean
  vendas: boolean
  estoque: boolean
  relatorios: boolean
}

const DEFAULT_MODULOS: ModulosHabilitados = {
  ordens_servico: true,
  vendas: true,
  estoque: true,
  relatorios: true
}

export function useModulosHabilitados() {
  const { user } = useAuth()
  const [modulos, setModulos] = useState<ModulosHabilitados>(DEFAULT_MODULOS)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    carregarModulos()
  }, [user])

  const carregarModulos = async () => {
    if (!user) {
      setModulos(DEFAULT_MODULOS)
      setLoading(false)
      return
    }

    try {
      setLoading(true)

      // Buscar configuração da empresa do usuário
      const { data: empresaData, error } = await supabase
        .from('empresas')
        .select('modulos_habilitados')
        .eq('user_id', user.id)
        .single()

      if (error) {
        console.warn('⚠️ Erro ao carregar módulos:', error.message)
        setModulos(DEFAULT_MODULOS)
        return
      }

      if (empresaData?.modulos_habilitados) {
        setModulos({
          ...DEFAULT_MODULOS,
          ...empresaData.modulos_habilitados
        })
      } else {
        setModulos(DEFAULT_MODULOS)
      }
    } catch (error) {
      console.error('❌ Erro ao carregar módulos habilitados:', error)
      setModulos(DEFAULT_MODULOS)
    } finally {
      setLoading(false)
    }
  }

  const atualizarModulo = async (modulo: keyof ModulosHabilitados, habilitado: boolean) => {
    if (!user) return false

    try {
      const novosModulos = {
        ...modulos,
        [modulo]: habilitado
      }

      const { error } = await supabase
        .from('empresas')
        .update({ modulos_habilitados: novosModulos })
        .eq('user_id', user.id)

      if (error) throw error

      setModulos(novosModulos)
      return true
    } catch (error) {
      console.error('❌ Erro ao atualizar módulo:', error)
      return false
    }
  }

  return {
    modulos,
    loading,
    ordensServicoHabilitado: modulos.ordens_servico,
    vendasHabilitado: modulos.vendas,
    estoqueHabilitado: modulos.estoque,
    relatoriosHabilitado: modulos.relatorios,
    atualizarModulo,
    recarregar: carregarModulos
  }
}
