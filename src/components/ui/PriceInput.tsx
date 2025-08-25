import React, { useState, useEffect } from 'react'
import { Input } from './Input'

interface PriceInputProps {
  value?: number
  onChange: (value: number) => void
  placeholder?: string
  error?: string
  className?: string
  disabled?: boolean
}

export function PriceInput({ value = 0, onChange, placeholder = "0,00", error, className, disabled }: PriceInputProps) {
  const [displayValue, setDisplayValue] = useState<string>('0,00')

  console.log('🎯 PriceInput - Valor recebido:', value, typeof value, 'timestamp:', new Date().toISOString())

  // Função de formatação brasileira
  const formatBrazilianPrice = (inputValue: string | number): string => {
    console.log('💰 PriceInput formatBrazilianPrice - entrada:', inputValue, typeof inputValue)
    
    // Se receber um número, converte para centavos e formata
    if (typeof inputValue === 'number') {
      const centavos = Math.round(inputValue * 100)
      const numbers = centavos.toString().padStart(3, '0') // Garante pelo menos 3 dígitos
      console.log('🔢 Número convertido para centavos:', numbers)
      
      if (numbers.length === 1) return `0,0${numbers}`
      if (numbers.length === 2) return `0,${numbers}`
      
      const reaisStr = numbers.slice(0, -2)
      const centavosStr = numbers.slice(-2)
      const reaisFormatted = reaisStr.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
      return `${reaisFormatted},${centavosStr}`
    }
    
    // Se receber string, processa normalmente
    const stringValue = inputValue?.toString() || '0'
    const numbers = stringValue.replace(/\D/g, '')
    
    if (!numbers || numbers === '0') return '0,00'
    
    // Remove zeros à esquerda mas preserva zeros válidos
    let cleanedNumbers = numbers
    if (/^0+/.test(numbers) && numbers.length > 1) {
      cleanedNumbers = numbers.replace(/^0+/, '') || '0'
    }
    
    if (cleanedNumbers === '0' || /^0+$/.test(cleanedNumbers)) return '0,00'
    
    if (cleanedNumbers.length === 1) return `0,0${cleanedNumbers}`
    if (cleanedNumbers.length === 2) return `0,${cleanedNumbers}`
    
    const reaisStr = cleanedNumbers.slice(0, -2)
    const centavosStr = cleanedNumbers.slice(-2)
    const reaisFormatted = reaisStr.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
    
    const result = `${reaisFormatted},${centavosStr}`
    console.log('✅ PriceInput resultado final:', result)
    return result
  }

  // Atualiza o valor exibido quando o valor prop muda
  useEffect(() => {
    const formatted = formatBrazilianPrice(value)
    console.log('🔄 PriceInput useEffect - formatado:', formatted)
    setDisplayValue(formatted)
  }, [value])

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const inputValue = e.target.value
    console.log('📝 PriceInput onChange - input:', inputValue)
    
    const formatted = formatBrazilianPrice(inputValue)
    console.log('📝 PriceInput onChange - formatado:', formatted)
    
    setDisplayValue(formatted)
    
    // Converte para número
    const forCalculation = formatted.replace(/\./g, '').replace(',', '.')
    const numericValue = parseFloat(forCalculation) || 0
    
    console.log('📊 PriceInput onChange - numérico:', numericValue)
    onChange(numericValue)
  }

  return (
    <Input
      type="text"
      value={displayValue}
      onChange={handleChange}
      placeholder={placeholder}
      error={error}
      className={`text-right ${className || ''}`}
      disabled={disabled}
      // Remove setas de número no Firefox
      style={{ MozAppearance: 'textfield' }}
    />
  )
}
