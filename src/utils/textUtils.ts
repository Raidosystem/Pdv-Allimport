/**
 * Utilitários para formatação de texto
 */

/**
 * Capitaliza a primeira letra de cada palavra
 * Exemplo: "cristiano silva" -> "Cristiano Silva"
 */
export const capitalizeWords = (text: string): string => {
  return text
    .toLowerCase()
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

/**
 * Capitaliza apenas a primeira letra da string
 * Exemplo: "cristiano silva" -> "Cristiano silva"
 */
export const capitalizeFirst = (text: string): string => {
  return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase()
}

/**
 * Handler para input que aplica capitalização automática
 */
export const handleCapitalizeInput = (
  event: React.ChangeEvent<HTMLInputElement>,
  capitalizeType: 'words' | 'first' = 'words'
) => {
  const { value, selectionStart } = event.target
  const capitalizedValue = capitalizeType === 'words' 
    ? capitalizeWords(value) 
    : capitalizeFirst(value)
  
  event.target.value = capitalizedValue
  
  // Manter a posição do cursor
  setTimeout(() => {
    event.target.setSelectionRange(selectionStart, selectionStart)
  }, 0)
}

/**
 * Handler para textarea que aplica capitalização automática
 */
export const handleCapitalizeTextarea = (
  event: React.ChangeEvent<HTMLTextAreaElement>,
  capitalizeType: 'words' | 'first' = 'words'
) => {
  const { value, selectionStart } = event.target
  const capitalizedValue = capitalizeType === 'words' 
    ? capitalizeWords(value) 
    : capitalizeFirst(value)
  
  event.target.value = capitalizedValue
  
  // Manter a posição do cursor
  setTimeout(() => {
    event.target.setSelectionRange(selectionStart, selectionStart)
  }, 0)
}
