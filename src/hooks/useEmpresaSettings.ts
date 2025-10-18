import { useState, useEffect, useCallback } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../modules/auth'

export interface EmpresaSettings {
  nome: string
  razao_social: string
  cnpj: string
  telefone: string
  email: string
  site: string
  cep: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
  logo?: string
}

const DEFAULT_SETTINGS: EmpresaSettings = {
  nome: '',
  razao_social: '',
  cnpj: '',
  telefone: '',
  email: '',
  site: '',
  cep: '',
  logradouro: '',
  numero: '',
  complemento: '',
  bairro: '',
  cidade: '',
  estado: '',
  logo: undefined
}

const STORAGE_KEY = 'pdv-empresa-settings'

export function useEmpresaSettings() {
  const { user } = useAuth()
  const [settings, setSettings] = useState<EmpresaSettings>(DEFAULT_SETTINGS)
  const [loading, setLoading] = useState(true)
  const [uploading, setUploading] = useState(false)

  // Carregar configurações
  const loadSettings = useCallback(async () => {
    try {
      // 1. Tentar carregar do localStorage primeiro
      const localSettings = localStorage.getItem(STORAGE_KEY)
      if (localSettings) {
        const parsed = JSON.parse(localSettings)
        setSettings(parsed)
      }

      // 2. Se usuário logado, carregar do Supabase
      if (user?.id) {
        const { data: empresaDataArray, error } = await supabase
          .from('empresas')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', { ascending: false })
          .limit(1)

        const data = empresaDataArray && empresaDataArray.length > 0 ? empresaDataArray[0] : null;

        if (!error && data) {
          const empresaData: EmpresaSettings = {
            nome: data.nome || '',
            razao_social: data.razao_social || '',
            cnpj: data.cnpj || '',
            telefone: data.telefone || '',
            email: data.email || '',
            site: data.site || '',
            cep: data.cep || '',
            logradouro: data.logradouro || '',
            numero: data.numero || '',
            complemento: data.complemento || '',
            bairro: data.bairro || '',
            cidade: data.cidade || '',
            estado: data.estado || '',
            logo: data.logo_url || undefined
          }
          
          setSettings(empresaData)
          localStorage.setItem(STORAGE_KEY, JSON.stringify(empresaData))
        }
      }
    } catch (error) {
      console.error('Erro ao carregar dados da empresa:', error)
    } finally {
      setLoading(false)
    }
  }, [user])

  // Salvar configurações
  const saveSettings = useCallback(async (newSettings: EmpresaSettings) => {
    try {
      setSettings(newSettings)
      localStorage.setItem(STORAGE_KEY, JSON.stringify(newSettings))

      // Salvar no Supabase se usuário logado
      if (user?.id) {
        const { error } = await supabase
          .from('empresas')
          .upsert({
            user_id: user.id,
            nome: newSettings.nome,
            razao_social: newSettings.razao_social,
            cnpj: newSettings.cnpj,
            telefone: newSettings.telefone,
            email: newSettings.email,
            site: newSettings.site,
            cep: newSettings.cep,
            logradouro: newSettings.logradouro,
            numero: newSettings.numero,
            complemento: newSettings.complemento,
            bairro: newSettings.bairro,
            cidade: newSettings.cidade,
            estado: newSettings.estado,
            logo_url: newSettings.logo,
            updated_at: new Date().toISOString()
          }, {
            onConflict: 'user_id'
          })

        if (error) {
          console.error('Erro ao salvar no Supabase:', error)
          return { success: false, error }
        }
      }

      return { success: true }
    } catch (error) {
      console.error('Erro ao salvar dados da empresa:', error)
      return { success: false, error }
    }
  }, [user])

  // Upload de logo
  const uploadLogo = useCallback(async (file: File) => {
    if (!user?.id) {
      return { success: false, error: 'Usuário não autenticado' }
    }

    try {
      setUploading(true)

      // Validar arquivo
      if (file.size > 2 * 1024 * 1024) { // 2MB
        return { success: false, error: 'Arquivo muito grande. Máximo 2MB' }
      }

      if (!file.type.startsWith('image/')) {
        return { success: false, error: 'Apenas imagens são permitidas' }
      }

      // Nome do arquivo único
      const fileExt = file.name.split('.').pop()
      const fileName = `${user.id}-${Date.now()}.${fileExt}`
      const filePath = `logos/${fileName}`

      // Upload para o Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('empresa-assets')
        .upload(filePath, file, {
          upsert: true
        })

      if (uploadError) {
        console.error('Erro no upload:', uploadError)
        return { success: false, error: uploadError.message }
      }

      // Obter URL pública
      const { data: { publicUrl } } = supabase.storage
        .from('empresa-assets')
        .getPublicUrl(filePath)

      return { success: true, url: publicUrl }
    } catch (error: any) {
      console.error('Erro ao fazer upload:', error)
      return { success: false, error: error.message }
    } finally {
      setUploading(false)
    }
  }, [user])

  // Carregar configurações quando o componente montar
  useEffect(() => {
    loadSettings()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return {
    settings,
    loading,
    uploading,
    saveSettings,
    uploadLogo,
    loadSettings
  }
}
