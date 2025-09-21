import { useState, useEffect } from 'react'
import { 
  Plus, 
  Mail, 
  Clock, 
  CheckCircle, 
  XCircle, 
  RotateCcw,
  Trash2,
  Send
} from 'lucide-react'
import { Card } from '../../components/ui/Card'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { GuardProfessional } from '../../components/admin/GuardProfessional'
import type { Convite, ConviteForm } from '../../types/admin-professional'

/**
 * Página de Gerenciamento de Convites de Usuários
 * Baseado no Blueprint Profissional do PDV Allimport
 */
export default function AdminConvitesPage() {
  const [convites, setConvites] = useState<Convite[]>([])
  const [loading, setLoading] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState<ConviteForm>({
    email: '',
    funcao_id: '',
    mensagem_personalizada: ''
  })

  // Mock de dados (substituir por API real)
  useEffect(() => {
    loadConvites()
  }, [])

  const loadConvites = async () => {
    setLoading(true)
    try {
      // const data = await conviteAPI.listar()
      // setConvites(data)
      
      // Mock data
      setConvites([
        {
          id: '1',
          empresa_id: '1',
          email: 'funcionario@exemplo.com',
          funcao_id: '1',
          status: 'pendente',
          token: 'abc123',
          expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
          created_at: new Date().toISOString(),
          funcao: { nome: 'Vendedor', descricao: 'Operador de PDV' },
          criado_por: { nome: 'Admin', email: 'admin@empresa.com' }
        }
      ])
    } catch (error) {
      console.error('Erro ao carregar convites:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.email || !formData.funcao_id) return

    setLoading(true)
    try {
      // await conviteAPI.criar(formData)
      console.log('Enviando convite:', formData)
      
      // Mock: adicionar convite à lista
      const novoConvite: Convite = {
        id: Date.now().toString(),
        empresa_id: '1',
        email: formData.email,
        funcao_id: formData.funcao_id,
        status: 'pendente',
        token: 'abc' + Date.now(),
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        created_at: new Date().toISOString(),
        funcao: { nome: 'Vendedor', descricao: 'Operador de PDV' }
      }
      
      setConvites(prev => [novoConvite, ...prev])
      setFormData({ email: '', funcao_id: '', mensagem_personalizada: '' })
      setShowForm(false)
    } catch (error) {
      console.error('Erro ao enviar convite:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCancelar = async (id: string) => {
    if (!confirm('Tem certeza que deseja cancelar este convite?')) return
    
    try {
      // await conviteAPI.cancelar(id)
      setConvites(prev => prev.map(c => 
        c.id === id ? { ...c, status: 'cancelado' as const } : c
      ))
    } catch (error) {
      console.error('Erro ao cancelar convite:', error)
    }
  }

  const handleReenviar = async (id: string) => {
    try {
      // await conviteAPI.reenviar(id)
      console.log('Reenviando convite:', id)
    } catch (error) {
      console.error('Erro ao reenviar convite:', error)
    }
  }

  const getStatusIcon = (status: Convite['status']) => {
    switch (status) {
      case 'pendente':
        return <Clock className="w-4 h-4 text-yellow-500" />
      case 'aceito':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'expirado':
        return <XCircle className="w-4 h-4 text-red-500" />
      case 'cancelado':
        return <XCircle className="w-4 h-4 text-gray-500" />
      default:
        return <Clock className="w-4 h-4 text-gray-500" />
    }
  }

  const getStatusLabel = (status: Convite['status']) => {
    switch (status) {
      case 'pendente': return 'Pendente'
      case 'aceito': return 'Aceito'
      case 'expirado': return 'Expirado'
      case 'cancelado': return 'Cancelado'
      default: return status
    }
  }

  return (
    <GuardProfessional perms={[]} need="convites.read">
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-gray-900">
              Convites de Usuários
            </h1>
            <p className="text-gray-600">
              Gerencie convites para novos funcionários da empresa
            </p>
          </div>
          
          <GuardProfessional perms={[]} need="convites.create">
            <Button
              onClick={() => setShowForm(!showForm)}
              className="gap-2"
            >
              <Plus className="w-4 h-4" />
              Novo Convite
            </Button>
          </GuardProfessional>
        </div>

        {/* Formulário de Novo Convite */}
        {showForm && (
          <Card className="p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Enviar Novo Convite
            </h2>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    E-mail do funcionário
                  </label>
                  <Input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                    placeholder="funcionario@empresa.com"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Função
                  </label>
                  <select
                    value={formData.funcao_id}
                    onChange={(e) => setFormData(prev => ({ ...prev, funcao_id: e.target.value }))}
                    className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="">Selecione uma função</option>
                    <option value="1">Vendedor</option>
                    <option value="2">Gerente</option>
                    <option value="3">Administrador</option>
                  </select>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Mensagem personalizada (opcional)
                </label>
                <textarea
                  value={formData.mensagem_personalizada}
                  onChange={(e) => setFormData(prev => ({ ...prev, mensagem_personalizada: e.target.value }))}
                  placeholder="Adicione uma mensagem de boas-vindas..."
                  rows={3}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              
              <div className="flex gap-3">
                <Button type="submit" loading={loading} className="gap-2">
                  <Send className="w-4 h-4" />
                  Enviar Convite
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
          
          {loading ? (
            <div className="text-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="text-gray-500 mt-2">Carregando convites...</p>
            </div>
          ) : convites.length === 0 ? (
            <div className="text-center py-8">
              <Mail className="w-12 h-12 mx-auto text-gray-300 mb-3" />
              <div className="font-medium text-gray-900">Nenhum convite enviado</div>
              <div className="text-sm text-gray-500">
                Envie convites para adicionar funcionários à empresa
              </div>
            </div>
          ) : (
            <div className="space-y-3">
              {convites.map((convite) => (
                <div
                  key={convite.id}
                  className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-gray-300 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <div className="p-2 bg-gray-100 rounded-lg">
                      <Mail className="w-5 h-5 text-gray-600" />
                    </div>
                    
                    <div>
                      <div className="font-medium text-gray-900">{convite.email}</div>
                      <div className="text-sm text-gray-600">
                        Função: {convite.funcao?.nome} • Enviado em {new Date(convite.created_at).toLocaleDateString()}
                      </div>
                      {convite.criado_por && (
                        <div className="text-xs text-gray-500">
                          Por: {convite.criado_por.nome}
                        </div>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-3">
                    <div className="flex items-center gap-2">
                      {getStatusIcon(convite.status)}
                      <span className="text-sm font-medium text-gray-700">
                        {getStatusLabel(convite.status)}
                      </span>
                    </div>
                    
                    {convite.status === 'pendente' && (
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => handleReenviar(convite.id)}
                          className="gap-1"
                        >
                          <RotateCcw className="w-3 h-3" />
                          Reenviar
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => handleCancelar(convite.id)}
                          className="gap-1 text-red-600 hover:text-red-700"
                        >
                          <Trash2 className="w-3 h-3" />
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
    </GuardProfessional>
  )
}