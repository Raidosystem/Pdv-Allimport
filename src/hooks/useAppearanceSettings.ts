import { useState, useEffect, useCallback } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../modules/auth'

export interface AppearanceSettings {
  tema: 'claro' | 'escuro' | 'automatico'
  cor_primaria: string
  cor_secundaria: string
  tamanho_fonte: 'pequeno' | 'medio' | 'grande'
  animacoes: boolean
  sidebar_compacta: boolean
}

const DEFAULT_SETTINGS: AppearanceSettings = {
  tema: 'claro',
  cor_primaria: '#3B82F6',
  cor_secundaria: '#10B981',
  tamanho_fonte: 'medio',
  animacoes: true,
  sidebar_compacta: false
}

export function useAppearanceSettings() {
  const { user } = useAuth()
  const [settings, setSettings] = useState<AppearanceSettings>(DEFAULT_SETTINGS)
  const [loading, setLoading] = useState(true)

  // Carregar configurações
  const loadSettings = useCallback(async () => {
    try {
      // Carregar APENAS do Supabase (100% online)
      if (user?.id) {
        const { data, error } = await supabase
          .from('user_settings')
          .select('appearance_settings')
          .eq('user_id', user.id)
          .single()

        if (!error && data?.appearance_settings) {
          const serverSettings = data.appearance_settings as AppearanceSettings
          setSettings(serverSettings)
          applySettings(serverSettings)
        } else {
          // Usar configurações padrão se não encontrar
          setSettings(DEFAULT_SETTINGS)
          applySettings(DEFAULT_SETTINGS)
        }
      } else {
        // Sem usuário logado, usar padrão
        setSettings(DEFAULT_SETTINGS)
        applySettings(DEFAULT_SETTINGS)
      }
    } catch (error) {
      console.error('Erro ao carregar configurações de aparência:', error)
      setSettings(DEFAULT_SETTINGS)
      applySettings(DEFAULT_SETTINGS)
    } finally {
      setLoading(false)
    }
  }, [user])

  // Salvar configurações
  const saveSettings = useCallback(async (newSettings: AppearanceSettings) => {
    try {
      setSettings(newSettings)
      applySettings(newSettings)

      // Salvar APENAS no Supabase (100% online)
      if (user?.id) {
        const { error } = await supabase
          .from('user_settings')
          .upsert({
            user_id: user.id,
            appearance_settings: newSettings,
            updated_at: new Date().toISOString()
          }, {
            onConflict: 'user_id'
          })

        if (error) {
          console.error('Erro ao salvar no Supabase:', error)
          return { success: false, error }
        }
        
        return { success: true }
      } else {
        console.warn('Não é possível salvar sem usuário logado')
        return { success: false, error: 'Usuário não logado' }
      }
    } catch (error) {
      console.error('Erro ao salvar configurações:', error)
      return { success: false, error }
    }
  }, [user])

  // Aplicar configurações no DOM
  const applySettings = useCallback((config: AppearanceSettings) => {
    const root = document.documentElement

    // 1. Aplicar tema (dark/light mode)
    applyTheme(config.tema)

    // 2. Aplicar cores personalizadas
    root.style.setProperty('--color-primary', config.cor_primaria)
    root.style.setProperty('--color-secondary', config.cor_secundaria)

    // 3. Aplicar tamanho de fonte
    const fontSizes = {
      pequeno: '14px',
      medio: '16px',
      grande: '18px'
    }
    root.style.setProperty('--font-size-base', fontSizes[config.tamanho_fonte])

    // 4. Aplicar animações
    if (config.animacoes) {
      root.classList.remove('no-animations')
    } else {
      root.classList.add('no-animations')
    }

    // 5. Aplicar sidebar compacta
    if (config.sidebar_compacta) {
      root.classList.add('sidebar-compact')
    } else {
      root.classList.remove('sidebar-compact')
    }
  }, [])

  // Aplicar tema (considera modo automático)
  const applyTheme = useCallback((tema: 'claro' | 'escuro' | 'automatico') => {
    const root = document.documentElement

    if (tema === 'automatico') {
      // Detectar preferência do sistema
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      root.classList.toggle('dark', prefersDark)
    } else {
      root.classList.toggle('dark', tema === 'escuro')
    }
  }, [])

  // Resetar para configurações padrão
  const resetSettings = useCallback(async () => {
    return saveSettings(DEFAULT_SETTINGS)
  }, [saveSettings])

  // Carregar configurações quando o componente montar
  useEffect(() => {
    loadSettings()
  }, [loadSettings])

  // Detectar mudanças no tema do sistema (modo automático)
  useEffect(() => {
    if (settings.tema === 'automatico') {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
      
      const handleChange = () => {
        applyTheme('automatico')
      }

      mediaQuery.addEventListener('change', handleChange)
      return () => mediaQuery.removeEventListener('change', handleChange)
    }
  }, [settings.tema, applyTheme])

  return {
    settings,
    loading,
    saveSettings,
    resetSettings,
    applySettings
  }
}
