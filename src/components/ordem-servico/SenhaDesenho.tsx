import { useRef, useEffect, useState } from 'react'
import { Button } from '../ui/Button'

interface SenhaDesenhoProps {
  value: string
  onChange: (desenho: string) => void
}

export function SenhaDesenho({ value, onChange }: SenhaDesenhoProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [isDrawing, setIsDrawing] = useState(false)
  const [lastPos, setLastPos] = useState({ x: 0, y: 0 })

  // Carregar desenho existente
  useEffect(() => {
    if (value && canvasRef.current) {
      const canvas = canvasRef.current
      const ctx = canvas.getContext('2d')
      if (ctx) {
        const img = new Image()
        img.onload = () => {
          ctx.clearRect(0, 0, canvas.width, canvas.height)
          ctx.drawImage(img, 0, 0)
        }
        img.src = value
      }
    }
  }, [value])

  const getCoordinates = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current
    if (!canvas) return { x: 0, y: 0 }

    const rect = canvas.getBoundingClientRect()
    const scaleX = canvas.width / rect.width
    const scaleY = canvas.height / rect.height
    
    if ('touches' in e) {
      // Touch event
      const touch = e.touches[0]
      return {
        x: (touch.clientX - rect.left) * scaleX,
        y: (touch.clientY - rect.top) * scaleY
      }
    } else {
      // Mouse event
      return {
        x: (e.clientX - rect.left) * scaleX,
        y: (e.clientY - rect.top) * scaleY
      }
    }
  }

  const startDrawing = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    e.preventDefault()
    setIsDrawing(true)
    const pos = getCoordinates(e)
    setLastPos(pos)
  }

  const draw = (e: React.MouseEvent<HTMLCanvasElement> | React.TouchEvent<HTMLCanvasElement>) => {
    e.preventDefault()
    
    if (!isDrawing) return

    const canvas = canvasRef.current
    const ctx = canvas?.getContext('2d')
    if (!ctx || !canvas) return

    const pos = getCoordinates(e)

    ctx.beginPath()
    ctx.strokeStyle = '#3b82f6' // Cor azul
    ctx.lineWidth = 3
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    
    ctx.moveTo(lastPos.x, lastPos.y)
    ctx.lineTo(pos.x, pos.y)
    ctx.stroke()

    setLastPos(pos)
  }

  const stopDrawing = () => {
    if (isDrawing && canvasRef.current) {
      setIsDrawing(false)
      
      // Salvar desenho como base64
      const canvas = canvasRef.current
      const dataURL = canvas.toDataURL('image/png')
      onChange(dataURL)
    }
  }

  const limparDesenho = () => {
    const canvas = canvasRef.current
    const ctx = canvas?.getContext('2d')
    if (ctx && canvas) {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      onChange('')
    }
  }

  return (
    <div className="space-y-2">
      <div className="relative border-2 border-dashed border-gray-300 rounded-lg bg-gray-50 p-2 inline-block">
        <canvas
          ref={canvasRef}
          width={300}
          height={300}
          onMouseDown={startDrawing}
          onMouseMove={draw}
          onMouseUp={stopDrawing}
          onMouseLeave={stopDrawing}
          onTouchStart={startDrawing}
          onTouchMove={draw}
          onTouchEnd={stopDrawing}
          className="bg-white rounded cursor-crosshair touch-none"
          style={{ 
            width: '300px', 
            height: '300px',
            display: 'block'
          }}
        />
      </div>
      
      <div className="flex items-center justify-between">
        <p className="text-xs text-gray-500">
          ✏️ Desenhe o padrão de desbloqueio (300x300px)
        </p>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={limparDesenho}
        >
          🗑️ Limpar
        </Button>
      </div>
    </div>
  )
}
