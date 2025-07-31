import type { InputHTMLAttributes } from 'react'
import { cn } from '../../utils'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  helperText?: string
}

export function Input({
  label,
  error,
  helperText,
  className,
  id,
  ...props
}: InputProps) {
  const inputId = id || label?.toLowerCase().replace(/\s+/g, '-')

  return (
    <div className="space-y-1">
      {label && (
        <label 
          htmlFor={inputId}
          className="block text-sm font-medium text-secondary-700"
        >
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          'block w-full rounded-lg border-secondary-300 shadow-sm',
          'focus:ring-primary-500 focus:border-primary-500',
          'transition-colors duration-200',
          error && 'border-danger-500 focus:ring-danger-500 focus:border-danger-500',
          className
        )}
        {...props}
      />
      {error && (
        <p className="text-sm text-danger-500">{error}</p>
      )}
      {helperText && !error && (
        <p className="text-sm text-secondary-500">{helperText}</p>
      )}
    </div>
  )
}
