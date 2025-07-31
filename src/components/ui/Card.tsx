import type { ReactNode } from 'react'
import { cn } from '../../utils'

interface CardProps {
  children: ReactNode
  className?: string
  hover?: boolean
}

export function Card({ children, className, hover = false }: CardProps) {
  return (
    <div
      className={cn(
        'bg-white rounded-xl border border-secondary-200 shadow-card p-6',
        hover && 'hover:shadow-card-hover hover:border-secondary-300 transition-all duration-200 cursor-pointer',
        className
      )}
    >
      {children}
    </div>
  )
}
