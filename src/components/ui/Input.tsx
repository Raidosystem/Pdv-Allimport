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
    <div className="space-y-2">
      {label && (
        <label 
          htmlFor={inputId}
          className="block text-lg font-medium text-secondary-700"
        >
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          'block w-full px-4 py-3 rounded-xl border border-secondary-200',
          'text-secondary-900 placeholder-secondary-400',
          'focus:outline-none focus:ring-3 focus:ring-primary-500/20 focus:border-primary-500',
          'transition-all duration-200',
          'bg-white/80 backdrop-blur-sm shadow-sm',
          'hover:border-secondary-300 hover:shadow-md',
          error && 'border-red-300 focus:border-red-500 focus:ring-red-500/20',
          className
        )}
        {...props}
      />
      {error && (
        <p className="text-red-600 text-sm font-medium">{error}</p>
      )}
      {helperText && !error && (
        <p className="text-secondary-500 text-sm">{helperText}</p>
      )}
    </div>
  )
}
