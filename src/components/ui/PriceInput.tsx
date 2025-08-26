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
  const [displayValue, setDisplayValue] = useState<string>('')

  // Formatação brasileira simples - BASEADA NO FORMULÁRIO QUE FUNCIONA
  const formatPrice = (inputValue: string) => {
    // Remove tudo que não é número
    const numbers = inputValue.replace(/\D/g, '')
    if (!numbers) return ''
    
    // Converte para centavos e depois para reais
    const cents = parseInt(numbers)
    const reais = cents / 100
    
    return reais.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }

  // Atualiza display quando prop value muda
  useEffect(() => {
    if (value > 0) {
      const formatted = (value).toLocaleString('pt-BR', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
      setDisplayValue(formatted)
    } else if (displayValue === '') {
      // Mantém vazio se está vazio
      setDisplayValue('')
    }
  }, [value])

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.target.value
    
    // Se apagou tudo, deixa vazio
    if (input === '') {
      setDisplayValue('')
      onChange(0)
      return
    }

    // Formatar usando a função que funciona
    const formatted = formatPrice(input)
    setDisplayValue(formatted)
    
    // Converte de volta para número
    if (formatted === '') {
      onChange(0)
    } else {
      const numericValue = parseFloat(formatted.replace(/\./g, '').replace(',', '.')) || 0
      onChange(numericValue)
    }
  }

  const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
    // Se está com valor 0 ou similar, limpa o campo
    if (displayValue === '0,00' || value === 0) {
      setDisplayValue('')
    }
    // Seleciona tudo para fácil substituição
    e.target.select()
  }

  const handleBlur = () => {
    // Se saiu vazio, coloca 0,00 apenas no blur
    if (displayValue === '') {
      setDisplayValue('0,00')
      onChange(0)
    }
  }

  return (
    <Input
      type="text"
      value={displayValue}
      onChange={handleChange}
      onFocus={handleFocus}
      onBlur={handleBlur}
      placeholder={placeholder}
      error={error}
      className={`text-right ${className || ''}`}
      disabled={disabled}
      inputMode="numeric"
      // Remove setas de número em todos os navegadores
      style={{ 
        MozAppearance: 'textfield',
        WebkitAppearance: 'none',
        appearance: 'none'
      }}
    />
  )
}
