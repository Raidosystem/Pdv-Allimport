import { ArrowLeft } from 'lucide-react'
import { Button } from './Button'
import { useBackButton } from '../../hooks/useBackButton'

interface BackButtonProps {
  className?: string
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  customAction?: () => void
  children?: React.ReactNode
}

export function BackButton({ 
  className = '', 
  variant = 'outline', 
  size = 'md',
  customAction,
  children
}: BackButtonProps) {
  const { goBack } = useBackButton()

  const handleClick = () => {
    if (customAction) {
      customAction()
    } else {
      goBack()
    }
  }

  return (
    <Button
      variant={variant}
      size={size}
      onClick={handleClick}
      className={`gap-2 ${className}`}
    >
      <ArrowLeft className="w-4 h-4" />
      {children || 'Voltar'}
    </Button>
  )
}
