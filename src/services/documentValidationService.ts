import { supabase } from '../lib/supabase'

interface ValidationResult {
  valid: boolean
  error?: string
  documentType?: string
  existingEmail?: string
}

/**
 * Verifica se CPF/CNPJ já está cadastrado no sistema
 */
export async function checkDocumentExists(document: string): Promise<ValidationResult> {
  try {
    const { data, error } = await supabase.rpc('validate_document_uniqueness', {
      p_document: document,
      p_user_id: null
    })

    if (error) {
      console.warn('⚠️ Função RPC não encontrada, validação desabilitada temporariamente:', error)
      // Retornar válido temporariamente até a função ser criada no banco
      return {
        valid: true,
        documentType: document.replace(/\D/g, '').length === 11 ? 'CPF' : 'CNPJ'
      }
    }

    return data as ValidationResult
  } catch (error) {
    console.warn('⚠️ Erro ao validar documento, permitindo cadastro:', error)
    // Em caso de erro, permitir cadastro (falha aberta)
    return {
      valid: true,
      documentType: document.replace(/\D/g, '').length === 11 ? 'CPF' : 'CNPJ'
    }
  }
}

/**
 * Verifica se email já está cadastrado
 */
export async function checkEmailExists(email: string): Promise<boolean> {
  try {
    const { data, error } = await supabase
      .from('auth.users')
      .select('email')
      .eq('email', email.toLowerCase().trim())
      .single()

    if (error && error.code !== 'PGRST116') {
      console.error('Erro ao verificar email:', error)
      return false
    }

    return !!data
  } catch (error) {
    console.error('Erro ao verificar email:', error)
    return false
  }
}

/**
 * Buscar usuário por CPF/CNPJ
 */
export async function findUserByDocument(document: string) {
  try {
    const { data, error } = await supabase.rpc('find_user_by_document', {
      p_document: document
    })

    if (error) {
      console.error('Erro ao buscar usuário:', error)
      return null
    }

    return data
  } catch (error) {
    console.error('Erro ao buscar usuário:', error)
    return null
  }
}
