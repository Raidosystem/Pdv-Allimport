import { useState } from 'react'
import { UserPlus, Mail, Clock, CheckCircle, X, AlertTriangle } from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'

/**
 * Página de Gestão de Convites
 * Sistema PDV Allimport - Versão Simplificada
 */
export default function AdminConvitesPage() {
  const [convites] = useState([])
  const [loading, setLoading] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    email: '',
    nome: '',
    role: 'vendedor'
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    
    try {
      // Simular envio de convite
      await new Promise(resolve => setTimeout(resolve, 1000))
      console.log('📧 Convite enviado:', formData)
      
      // Reset form
      setFormData({ email: '', nome: '', role: 'vendedor' })
      setShowForm(false)
    } catch (error) {
      console.error('❌ Erro ao enviar convite:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'aceito': return <CheckCircle className="w-4 h-4 text-green-600" />
      case 'expirado': return <AlertTriangle className="w-4 h-4 text-red-600" />
      case 'cancelado': return <X className="w-4 h-4 text-gray-600" />
      default: return <Clock className="w-4 h-4 text-yellow-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'aceito': return 'text-green-600 bg-green-100'
      case 'expirado': return 'text-red-600 bg-red-100'
      case 'cancelado': return 'text-gray-600 bg-gray-100'
      default: return 'text-yellow-600 bg-yellow-100'
    }
  }

  const getStatusText = (status: string) => {
    switch (status) {
      case 'aceito': return 'Aceito'
      case 'expirado': return 'Expirado'
      case 'cancelado': return 'Cancelado'
      default: return 'Pendente'
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">
            Gestão de Convites
          </h1>
          <p className="text-gray-600 mt-1">
            Convide novos usuários para acessar o sistema
          </p>
        </div>
        
        <Button 
          onClick={() => setShowForm(true)}
          className="gap-2"
        >
          <UserPlus className="w-4 h-4" />
          Novo Convite
        </Button>
      </div>

      {/* Formulário de Convite */}
      {showForm && (
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Enviar Novo Convite
          </h2>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email *
                </label>
                <input
                  type="email"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="usuario@email.com"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nome
                </label>
                <input
                  type="text"
                  value={formData.nome}
                  onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nome do usuário"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Função
              </label>
              <select
                value={formData.role}
                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="vendedor">Vendedor</option>
                <option value="gerente">Gerente</option>
                <option value="admin">Administrador</option>
              </select>
            </div>

            <div className="flex gap-3 pt-4">
              <Button type="submit" disabled={loading}>
                {loading ? 'Enviando...' : 'Enviar Convite'}
              </Button>
              <Button 
                type="button" 
                variant="outline"
                onClick={() => setShowForm(false)}
              >
                Cancelar
              </Button>
            </div>
          </form>
        </Card>
      )}

      {/* Lista de Convites */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Convites Enviados
        </h2>
        
        {convites.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Mail className="w-12 h-12 mx-auto mb-4 text-gray-300" />
            <p>Nenhum convite encontrado</p>
            <p className="text-sm">Clique em "Novo Convite" para enviar seu primeiro convite</p>
          </div>
        ) : (
          <div className="space-y-3">
            {convites.map((convite: any) => (
              <div key={convite.id} className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50">
                <div className="flex items-center gap-3">
                  {getStatusIcon(convite.status)}
                  
                  <div>
                    <p className="font-medium">{convite.email}</p>
                    {convite.nome && (
                      <p className="text-sm text-gray-600">{convite.nome}</p>
                    )}
                    <p className="text-xs text-gray-500">
                      Função: {convite.role} • Enviado em {new Date(convite.created_at).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                
                <div className="flex items-center gap-2">
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(convite.status)}`}>
                    {getStatusText(convite.status)}
                  </span>
                  
                  {convite.status === 'pendente' && (
                    <div className="flex gap-1">
                      <Button variant="outline" size="sm">
                        Reenviar
                      </Button>
                      <Button variant="outline" size="sm">
                        Cancelar
                      </Button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  )
}