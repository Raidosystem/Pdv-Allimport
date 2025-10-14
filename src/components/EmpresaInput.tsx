import { memo } from 'react'

interface EmpresaInputProps {
  label: string
  value: string
  onChange: (value: string) => void
  type?: string
  placeholder?: string
  required?: boolean
}

// Componente memoizado para evitar re-renders
export const EmpresaInput = memo(({ 
  label, 
  value, 
  onChange, 
  type = 'text', 
  placeholder,
  required = false 
}: EmpresaInputProps) => {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">
        {label} {required && '*'}
      </label>
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        placeholder={placeholder}
      />
    </div>
  )
})

EmpresaInput.displayName = 'EmpresaInput'
