import { useState, useRef, useEffect } from 'react'
import { User, Search, Plus, X, Phone, Mail, FileText } from 'lucide-react'
import { Button } from '../../../components/ui/Button'
import { Card } from '../../../components/ui/Card'
import { Input } from '../../../components/ui/Input'
import { useDebounce } from '../../../hooks/useSales'
import { customerService } from '../../../services/sales'
import type { Customer } from '../../../types/sales'
import { formatPhone } from '../../../utils/format'
import InputMask from 'react-input-mask'

interface ClienteSelectProps {
  selectedCustomer?: Customer | null
  onCustomerSelect: (customer: Customer | null) => void
}

export function ClienteSelect({ selectedCustomer, onCustomerSelect }: ClienteSelectProps) {
  const [searchTerm, setSearchTerm] = useState('')
  const [customers, setCustomers] = useState<Customer[]>([])
  const [loading, setLoading] = useState(false)
  const [showResults, setShowResults] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [selectedIndex, setSelectedIndex] = useState(-1)
  
  // Novo cliente
  const [newCustomer, setNewCustomer] = useState({
    name: '',
    email: '',
    phone: '',
    document: ''
  })

  const searchInputRef = useRef<HTMLInputElement>(null)
  const debouncedSearchTerm = useDebounce(searchTerm, 300)

  // Buscar clientes quando termo de busca mudar
  useEffect(() => {
    const searchCustomers = async () => {
      if (!debouncedSearchTerm.trim()) {
        setCustomers([])
        setShowResults(false)
        return
      }

      setLoading(true)
      try {
        const data = await customerService.search(debouncedSearchTerm)
        setCustomers(data)
        setShowResults(true)
        setSelectedIndex(-1)
      } catch (error) {
        console.error('Erro ao buscar clientes:', error)
        setCustomers([])
      } finally {
        setLoading(false)
      }
    }

    searchCustomers()
  }, [debouncedSearchTerm])

  // Navegação com teclado
  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (!showResults || customers.length === 0) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        setSelectedIndex(prev => 
          prev < customers.length - 1 ? prev + 1 : prev
        )
        break
      case 'ArrowUp':
        event.preventDefault()
        setSelectedIndex(prev => prev > 0 ? prev - 1 : -1)
        break
      case 'Enter':
        event.preventDefault()
        if (selectedIndex >= 0 && selectedIndex < customers.length) {
          handleCustomerSelect(customers[selectedIndex])
        }
        break
      case 'Escape':
        setShowResults(false)
        setSelectedIndex(-1)
        break
    }
  }

  // Selecionar cliente
  const handleCustomerSelect = (customer: Customer) => {
    onCustomerSelect(customer)
    setSearchTerm('')
    setShowResults(false)
    setSelectedIndex(-1)
  }

  // Remover cliente selecionado
  const handleRemoveCustomer = () => {
    onCustomerSelect(null)
    setSearchTerm('')
    searchInputRef.current?.focus()
  }

  // Criar novo cliente
  const handleCreateCustomer = async () => {
    if (!newCustomer.name.trim()) {
      alert('Nome é obrigatório')
      return
    }

    try {
      const customer = await customerService.create({
        name: newCustomer.name,
        email: newCustomer.email || undefined,
        phone: newCustomer.phone || undefined,
        document: newCustomer.document || undefined,
        active: true
      })

      handleCustomerSelect(customer)
      setShowForm(false)
      setNewCustomer({ name: '', email: '', phone: '', document: '' })
    } catch (error) {
      console.error('Erro ao criar cliente:', error)
      alert('Erro ao criar cliente')
    }
  }

  // Reset form
  const resetForm = () => {
    setShowForm(false)
    setNewCustomer({ name: '', email: '', phone: '', document: '' })
  }

  // Se cliente selecionado, mostrar informações
  if (selectedCustomer) {
    return (
      <Card className="p-6 bg-white border-0 shadow-lg">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-4">
            <div className="w-14 h-14 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center shadow-lg">
              <User className="w-7 h-7 text-white" />
            </div>
            <div>
              <h3 className="text-xl font-bold text-secondary-900">Cliente Selecionado</h3>
              <p className="text-lg font-medium text-purple-600">{selectedCustomer.name}</p>
            </div>
          </div>
          
          <Button
            variant="outline"
            size="sm"
            onClick={handleRemoveCustomer}
            className="text-red-600 border-red-300 hover:bg-red-50 hover:border-red-400 transition-colors"
          >
            <X className="w-4 h-4 mr-2" />
            Remover
          </Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t border-gray-200">
          {selectedCustomer.email && (
            <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
              <Mail className="w-4 h-4 text-gray-500" />
              <div>
                <span className="text-xs text-gray-500 uppercase font-medium">Email</span>
                <p className="text-sm font-medium text-gray-900">{selectedCustomer.email}</p>
              </div>
            </div>
          )}
          
          {selectedCustomer.phone && (
            <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
              <Phone className="w-4 h-4 text-gray-500" />
              <div>
                <span className="text-xs text-gray-500 uppercase font-medium">Telefone</span>
                <p className="text-sm font-medium text-gray-900">{formatPhone(selectedCustomer.phone)}</p>
              </div>
            </div>
          )}
          
          {selectedCustomer.document && (
            <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
              <FileText className="w-4 h-4 text-gray-500" />
              <div>
                <span className="text-xs text-gray-500 uppercase font-medium">Documento</span>
                <p className="text-sm font-medium text-gray-900">{selectedCustomer.document}</p>
              </div>
            </div>
          )}
        </div>
      </Card>
    )
  }

  return (
    <Card className="p-6 bg-white border-0 shadow-lg">
      <div className="space-y-6">
        {/* Cabeçalho */}
        <div className="flex items-center space-x-4">
          <div className="w-14 h-14 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center shadow-lg">
            <User className="w-7 h-7 text-white" />
          </div>
          <div>
            <h3 className="text-xl font-bold text-secondary-900">Cliente</h3>
            <p className="text-sm text-gray-500 font-medium">Opcional - Busque ou cadastre</p>
          </div>
        </div>

        {/* Área de Ações */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Buscar Cliente */}
          <div className="space-y-4">
            <div className="flex items-center space-x-2">
              <Search className="w-5 h-5 text-purple-600" />
              <span className="text-base font-semibold text-secondary-700">Buscar Cliente</span>
            </div>
            
            <div className="relative">
              <Input
                ref={searchInputRef}
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Digite nome, email ou documento..."
                className="h-12 pl-12 pr-12 text-base border-2 border-purple-200 rounded-xl focus:border-purple-500 focus:ring-purple-500/20 transition-all"
              />
              
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-purple-400" />
              
              {loading && (
                <div className="absolute right-4 top-1/2 transform -translate-y-1/2">
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-purple-500"></div>
                </div>
              )}
            </div>
          </div>

          {/* Novo Cliente */}
          <div className="space-y-4">
            <div className="flex items-center space-x-2">
              <Plus className="w-5 h-5 text-green-600" />
              <span className="text-base font-semibold text-secondary-700">Novo Cliente</span>
            </div>
            
            <Button
              onClick={() => setShowForm(!showForm)}
              className="w-full h-12 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-200 border-0"
            >
              <Plus className="w-5 h-5 mr-2" />
              Cadastrar Novo Cliente
            </Button>
          </div>
        </div>

        {/* Resultados da busca */}
        {showResults && customers.length > 0 && (
          <div className="bg-white border border-purple-200 rounded-xl shadow-lg max-h-64 overflow-y-auto">
            {customers.map((customer, index) => (
              <div
                key={customer.id}
                onClick={() => handleCustomerSelect(customer)}
                className={`p-4 cursor-pointer transition-colors border-b last:border-b-0 ${
                  index === selectedIndex 
                    ? 'bg-purple-50 border-purple-200' 
                    : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                    <User className="w-5 h-5 text-purple-600" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-secondary-900">{customer.name}</p>
                    <div className="flex space-x-4 text-sm text-gray-500">
                      {customer.email && <span>{customer.email}</span>}
                      {customer.phone && <span>{formatPhone(customer.phone)}</span>}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Formulário de novo cliente */}
        {showForm && (
          <div className="space-y-6 p-6 bg-gradient-to-br from-green-50 to-green-100 rounded-xl border border-green-200">
            <div className="flex items-center justify-between">
              <h4 className="text-lg font-semibold text-secondary-900">Cadastrar Novo Cliente</h4>
              <Button
                variant="outline"
                size="sm"
                onClick={resetForm}
                className="text-gray-600 border-gray-300 hover:bg-gray-50"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Input
                label="Nome *"
                type="text"
                value={newCustomer.name}
                onChange={(e) => setNewCustomer({ ...newCustomer, name: e.target.value })}
                placeholder="Nome completo"
                required
                className="h-11"
              />
              
              <Input
                label="Email"
                type="email"
                value={newCustomer.email}
                onChange={(e) => setNewCustomer({ ...newCustomer, email: e.target.value })}
                placeholder="email@exemplo.com"
                className="h-11"
              />
              
              <InputMask
                mask="(99) 99999-9999"
                value={newCustomer.phone}
                onChange={(e) => setNewCustomer({ ...newCustomer, phone: e.target.value })}
              >
                {(inputProps: any) => (
                  <Input
                    {...inputProps}
                    label="Telefone"
                    placeholder="(11) 99999-9999"
                    className="h-11"
                  />
                )}
              </InputMask>
              
              <InputMask
                mask="999.999.999-99"
                value={newCustomer.document}
                onChange={(e) => setNewCustomer({ ...newCustomer, document: e.target.value })}
              >
                {(inputProps: any) => (
                  <Input
                    {...inputProps}
                    label="CPF"
                    placeholder="000.000.000-00"
                    className="h-11"
                  />
                )}
              </InputMask>
            </div>

            <div className="flex space-x-3 pt-4">
              <Button
                variant="outline"
                onClick={resetForm}
                className="flex-1 h-11 border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </Button>
              <Button
                onClick={handleCreateCustomer}
                className="flex-1 h-11 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-medium shadow-lg"
              >
                <Plus className="w-4 h-4 mr-2" />
                Cadastrar
              </Button>
            </div>
          </div>
        )}
      </div>
    </Card>
  )
}