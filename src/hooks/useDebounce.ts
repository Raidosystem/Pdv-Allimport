import { useEffect, useState } from 'react'

/**
 * Hook para debounce de valores
 * @param value Valor a ser debounced
 * @param delay Delay em milissegundos (padrão: 250ms)
 * @returns Valor debounced
 */
export function useDebounce<T>(value: T, delay = 250): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const id = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(id)
  }, [value, delay])

  return debouncedValue
}