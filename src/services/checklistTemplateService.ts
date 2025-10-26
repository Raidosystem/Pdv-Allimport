import { supabase } from '../lib/supabase'

export interface ChecklistItem {
  id: string
  label: string
  ordem: number
}

export interface ChecklistTemplate {
  id: string
  usuario_id: string
  empresa_id: string
  items: ChecklistItem[]
  created_at: string
  updated_at: string
}

/**
 * Buscar template de checklist do usuário
 */
export async function buscarTemplateChecklist(): Promise<ChecklistItem[]> {
  try {
    console.log('📋 [CHECKLIST TEMPLATE] Buscando template do usuário...')
    
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      console.warn('⚠️ [CHECKLIST TEMPLATE] Usuário não autenticado')
      return getDefaultChecklistItems()
    }

    const { data, error } = await supabase
      .from('checklist_templates')
      .select('*')
      .eq('usuario_id', user.id)
      .single()

    if (error) {
      if (error.code === 'PGRST116') {
        // Template não encontrado, retornar itens padrão
        console.log('📋 [CHECKLIST TEMPLATE] Template não encontrado, usando padrão')
        return getDefaultChecklistItems()
      }
      throw error
    }

    console.log(`✅ [CHECKLIST TEMPLATE] Template encontrado com ${data.items.length} itens`)
    return data.items as ChecklistItem[]
  } catch (error) {
    console.error('❌ [CHECKLIST TEMPLATE] Erro ao buscar template:', error)
    return getDefaultChecklistItems()
  }
}

/**
 * Salvar template de checklist do usuário
 */
export async function salvarTemplateChecklist(items: ChecklistItem[]): Promise<boolean> {
  try {
    console.log('💾 [CHECKLIST TEMPLATE] Salvando template com', items.length, 'itens...')
    
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      console.warn('⚠️ [CHECKLIST TEMPLATE] Usuário não autenticado')
      return false
    }

    // Tentar atualizar primeiro
    const { error: updateError } = await supabase
      .from('checklist_templates')
      .update({ 
        items: items,
        updated_at: new Date().toISOString()
      })
      .eq('usuario_id', user.id)

    if (updateError) {
      if (updateError.code === 'PGRST116') {
        // Não existe, criar novo
        console.log('📝 [CHECKLIST TEMPLATE] Criando novo template...')
        const { error: insertError } = await supabase
          .from('checklist_templates')
          .insert({
            usuario_id: user.id,
            empresa_id: user.id,
            items: items
          })

        if (insertError) {
          console.error('❌ [CHECKLIST TEMPLATE] Erro ao criar template:', insertError)
          return false
        }
      } else {
        console.error('❌ [CHECKLIST TEMPLATE] Erro ao atualizar template:', updateError)
        return false
      }
    }

    console.log('✅ [CHECKLIST TEMPLATE] Template salvo com sucesso!')
    return true
  } catch (error) {
    console.error('❌ [CHECKLIST TEMPLATE] Erro ao salvar template:', error)
    return false
  }
}

/**
 * Itens padrão do checklist
 */
export function getDefaultChecklistItems(): ChecklistItem[] {
  return [
    { id: 'aparelho_liga', label: 'Aparelho liga', ordem: 1 },
    { id: 'carregamento_ok', label: 'Carregamento OK', ordem: 2 },
    { id: 'tela_ok', label: 'Tela OK', ordem: 3 },
    { id: 'touch_ok', label: 'Touch OK', ordem: 4 },
    { id: 'camera_ok', label: 'Câmera OK', ordem: 5 },
    { id: 'som_ok', label: 'Som OK', ordem: 6 },
    { id: 'microfone_ok', label: 'Microfone OK', ordem: 7 },
    { id: 'wifi_ok', label: 'Wi-Fi OK', ordem: 8 },
    { id: 'bluetooth_ok', label: 'Bluetooth OK', ordem: 9 },
    { id: 'biometria_ok', label: 'Biometria OK', ordem: 10 }
  ]
}

/**
 * Adicionar item ao template
 */
export async function adicionarItemChecklist(label: string): Promise<ChecklistItem[] | null> {
  try {
    const items = await buscarTemplateChecklist()
    const novoItem: ChecklistItem = {
      id: `item_${Date.now()}`,
      label: label,
      ordem: items.length + 1
    }
    
    const novosItems = [...items, novoItem]
    const sucesso = await salvarTemplateChecklist(novosItems)
    
    return sucesso ? novosItems : null
  } catch (error) {
    console.error('❌ [CHECKLIST TEMPLATE] Erro ao adicionar item:', error)
    return null
  }
}

/**
 * Remover item do template
 */
export async function removerItemChecklist(itemId: string): Promise<ChecklistItem[] | null> {
  try {
    const items = await buscarTemplateChecklist()
    const novosItems = items.filter(item => item.id !== itemId)
    
    // Reordenar
    novosItems.forEach((item, index) => {
      item.ordem = index + 1
    })
    
    const sucesso = await salvarTemplateChecklist(novosItems)
    
    return sucesso ? novosItems : null
  } catch (error) {
    console.error('❌ [CHECKLIST TEMPLATE] Erro ao remover item:', error)
    return null
  }
}
