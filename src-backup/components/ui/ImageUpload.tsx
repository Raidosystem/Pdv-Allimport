import { useState, useRef } from 'react'
import { Upload, X, Camera } from 'lucide-react'
import { Button } from '../ui/Button'

interface ImageUploadProps {
  value?: File | string
  onChange: (file: File | null) => void
  disabled?: boolean
  className?: string
}

export function ImageUpload({ value, onChange, disabled, className = '' }: ImageUploadProps) {
  const [preview, setPreview] = useState<string | null>(
    typeof value === 'string' ? value : null
  )
  const [isDragging, setIsDragging] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileChange = (file: File | null) => {
    if (file) {
      // Validar tipo de arquivo
      if (!file.type.startsWith('image/')) {
        alert('Por favor, selecione apenas arquivos de imagem')
        return
      }

      // Validar tamanho (máximo 5MB)
      if (file.size > 5 * 1024 * 1024) {
        alert('A imagem deve ter no máximo 5MB')
        return
      }

      // Criar preview
      const reader = new FileReader()
      reader.onload = (e) => {
        setPreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)

      onChange(file)
    } else {
      setPreview(null)
      onChange(null)
    }
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)

    const files = Array.from(e.dataTransfer.files)
    if (files.length > 0) {
      handleFileChange(files[0])
    }
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
  }

  const openFileDialog = () => {
    fileInputRef.current?.click()
  }

  const removeImage = () => {
    setPreview(null)
    onChange(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  return (
    <div className={`space-y-2 ${className}`}>
      <label className="block text-sm font-medium text-gray-700">
        Imagem do Produto
      </label>
      
      <div
        className={`relative border-2 border-dashed rounded-xl transition-all duration-200 ${
          isDragging
            ? 'border-orange-400 bg-orange-50'
            : preview
            ? 'border-gray-200'
            : 'border-gray-300 hover:border-orange-400'
        } ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}`}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onClick={!disabled && !preview ? openFileDialog : undefined}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={(e) => handleFileChange(e.target.files?.[0] || null)}
          className="hidden"
          disabled={disabled}
        />

        {preview ? (
          <div className="relative group">
            <img
              src={preview}
              alt="Preview"
              className="w-full h-48 object-cover rounded-lg"
            />
            <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-200 rounded-lg flex items-center justify-center">
              <div className="opacity-0 group-hover:opacity-100 transition-opacity duration-200 space-x-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={(e) => {
                    e.stopPropagation()
                    openFileDialog()
                  }}
                  disabled={disabled}
                  className="bg-white hover:bg-gray-50"
                >
                  <Camera className="w-4 h-4" />
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={(e) => {
                    e.stopPropagation()
                    removeImage()
                  }}
                  disabled={disabled}
                  className="bg-white hover:bg-red-50 text-red-600 hover:text-red-700"
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <div className="p-8 text-center">
            <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <div className="space-y-2">
              <p className="text-lg font-medium text-gray-600">
                {isDragging ? 'Solte a imagem aqui' : 'Adicionar Imagem'}
              </p>
              <p className="text-sm text-gray-500">
                Arraste e solte ou clique para selecionar
              </p>
              <p className="text-xs text-gray-400">
                PNG, JPG ou GIF (máx. 5MB)
              </p>
            </div>
          </div>
        )}
      </div>

      {preview && (
        <div className="flex justify-between items-center text-sm text-gray-600">
          <span>Imagem selecionada</span>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={removeImage}
            disabled={disabled}
            className="text-red-600 hover:text-red-700 hover:bg-red-50"
          >
            Remover
          </Button>
        </div>
      )}
    </div>
  )
}
