import { Link } from 'react-router-dom'
import type { LucideIcon } from 'lucide-react'

type Module = {
  name: string
  title: string
  description: string
  icon: LucideIcon
  color?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
  path: string
}

interface ModuleGridProps {
  modules: Module[]
  title?: string
}

const colorClasses = {
  primary: 'bg-primary-500 hover:bg-primary-600',
  secondary: 'bg-secondary-500 hover:bg-secondary-600',
  success: 'bg-green-500 hover:bg-green-600',
  warning: 'bg-yellow-500 hover:bg-yellow-600',
  danger: 'bg-red-500 hover:bg-red-600',
  info: 'bg-blue-500 hover:bg-blue-600',
  default: 'bg-gray-400 hover:bg-gray-500',
}

export function ModuleGrid({ modules, title }: ModuleGridProps) {
  return (
    <div className="w-full">
      {title && (
        <h2 className="text-xl sm:text-2xl md:text-3xl font-semibold text-gray-800 mb-6">
          {title}
        </h2>
      )}

      <div className="grid grid-cols-[repeat(auto-fit,minmax(220px,1fr))] gap-4 sm:gap-6">
        {modules.map((module) => {
          const Icon = module.icon
          const colorClass = colorClasses[module.color || 'default']

          return (
            <Link key={module.name} to={module.path}>
              <div className="flex flex-col items-center justify-center gap-3 p-4 rounded-xl bg-white shadow hover:shadow-md transition w-full h-full">
                <div className={`aspect-square w-16 sm:w-20 md:w-24 ${colorClass} rounded-xl flex items-center justify-center`}>
                  <Icon className="w-1/2 h-1/2 text-white" />
                </div>
                <h3 className="text-base sm:text-lg font-semibold text-gray-800 text-center line-clamp-1">
                  {module.title}
                </h3>
                <p className="text-sm sm:text-base text-gray-600 text-center line-clamp-2 hidden sm:block">
                  {module.description}
                </p>
              </div>
            </Link>
          )
        })}
      </div>
    </div>
  )
}
