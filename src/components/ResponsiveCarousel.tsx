import { useState, useRef, useEffect } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'

interface ResponsiveCarouselProps {
  children: React.ReactNode
  className?: string
}

/**
 * Carrossel responsivo que:
 * - Em telas pequenas (< 768px): Mostra 1 item por vez com setas laterais
 * - Em telas grandes (>= 768px): Mostra grid normal sem carrossel
 */
export function ResponsiveCarousel({ children, className = '' }: ResponsiveCarouselProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isMobile, setIsMobile] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)

  // Converter children para array
  const childrenArray = Array.isArray(children) 
    ? children 
    : children 
      ? [children].flat() 
      : []

  // Detectar se é mobile
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768)
    }
    
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  const goToPrevious = () => {
    setCurrentIndex((prev) => (prev === 0 ? childrenArray.length - 1 : prev - 1))
  }

  const goToNext = () => {
    setCurrentIndex((prev) => (prev === childrenArray.length - 1 ? 0 : prev + 1))
  }

  // Suporte para swipe em mobile
  const [touchStart, setTouchStart] = useState(0)
  const [touchEnd, setTouchEnd] = useState(0)

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchStart(e.targetTouches[0].clientX)
  }

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd(e.targetTouches[0].clientX)
  }

  const handleTouchEnd = () => {
    if (!touchStart || !touchEnd) return
    
    const distance = touchStart - touchEnd
    const isLeftSwipe = distance > 50
    const isRightSwipe = distance < -50

    if (isLeftSwipe) {
      goToNext()
    } else if (isRightSwipe) {
      goToPrevious()
    }
  }

  // Em desktop, renderizar grid normal
  if (!isMobile) {
    return <div className={className}>{children}</div>
  }

  // Em mobile, renderizar carrossel
  return (
    <div className="relative w-full">
      {/* Contador de itens */}
      <div className="flex justify-center items-center gap-2 mb-4">
        <span className="text-sm font-medium text-gray-600">
          {currentIndex + 1} / {childrenArray.length}
        </span>
      </div>

      {/* Container do carrossel */}
      <div
        ref={containerRef}
        className="relative overflow-hidden rounded-lg"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {/* Items do carrossel */}
        <div
          className="flex transition-transform duration-300 ease-out"
          style={{
            transform: `translateX(-${currentIndex * 100}%)`,
          }}
        >
          {childrenArray.map((child, index) => (
            <div
              key={index}
              className="w-full flex-shrink-0 px-2"
              style={{ minWidth: '100%' }}
            >
              {child}
            </div>
          ))}
        </div>

        {/* Seta Esquerda */}
        <button
          onClick={goToPrevious}
          className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-white/90 hover:bg-white shadow-lg rounded-full p-2 ml-2 transition-all duration-200 hover:scale-110 active:scale-95"
          aria-label="Anterior"
        >
          <ChevronLeft className="w-6 h-6 text-gray-700" />
        </button>

        {/* Seta Direita */}
        <button
          onClick={goToNext}
          className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-white/90 hover:bg-white shadow-lg rounded-full p-2 mr-2 transition-all duration-200 hover:scale-110 active:scale-95"
          aria-label="Próximo"
        >
          <ChevronRight className="w-6 h-6 text-gray-700" />
        </button>
      </div>

      {/* Indicadores (bolinhas) */}
      <div className="flex justify-center gap-2 mt-4">
        {childrenArray.map((_, index) => (
          <button
            key={index}
            onClick={() => setCurrentIndex(index)}
            className={`w-2 h-2 rounded-full transition-all duration-200 ${
              index === currentIndex
                ? 'bg-blue-600 w-6'
                : 'bg-gray-300 hover:bg-gray-400'
            }`}
            aria-label={`Ir para item ${index + 1}`}
          />
        ))}
      </div>

      {/* Dica de swipe (aparece apenas no primeiro acesso) */}
      {currentIndex === 0 && (
        <div className="text-center mt-3 text-xs text-gray-500 animate-pulse">
          ← Deslize para navegar →
        </div>
      )}
    </div>
  )
}
