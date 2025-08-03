import { useState } from 'react'
import { Button } from '../../components/ui/Button'
import { Card } from '../../components/ui/Card'
import { Input } from '../../components/ui/Input'
import { testCategoryOperations, checkCategoryTableStructure } from '../../utils/testCategories'
import { insertDefaultCategories, createCategorySimple, fixCategoryPolicies } from '../../utils/setupDatabase'

export function CategoryTestPage() {
  const [loading, setLoading] = useState(false)
  const [results, setResults] = useState<Record<string, unknown> | null>(null)
  const [newCategoryName, setNewCategoryName] = useState('')

  const runTests = async () => {
    setLoading(true)
    try {
      console.log('🚀 Iniciando testes de categoria...')
      
      // 1. Verificar estrutura da tabela
      const structureCheck = await checkCategoryTableStructure()
      console.log('Resultado verificação estrutura:', structureCheck)
      
      // 2. Testar operações básicas
      const operationsTest = await testCategoryOperations()
      console.log('Resultado teste operações:', operationsTest)
      
      setResults({
        structure: structureCheck,
        operations: operationsTest,
        timestamp: new Date().toISOString()
      })
      
    } catch (error) {
      console.error('Erro nos testes:', error)
      setResults({ error: error instanceof Error ? error.message : String(error) })
    } finally {
      setLoading(false)
    }
  }

  const setupDefaults = async () => {
    setLoading(true)
    try {
      const result = await insertDefaultCategories()
      console.log('Resultado setup:', result)
      alert(result.success ? 'Categorias padrão inseridas!' : 'Erro ao inserir categorias')
    } catch (error) {
      console.error('Erro no setup:', error)
      alert('Erro: ' + (error instanceof Error ? error.message : String(error)))
    } finally {
      setLoading(false)
    }
  }

  const fixPolicies = async () => {
    setLoading(true)
    try {
      const result = await fixCategoryPolicies()
      console.log('Resultado fix políticas:', result)
      
      if (result.success) {
        alert('✅ Políticas funcionando corretamente!')
      } else {
        alert(`❌ ${result.error}\n\n${result.suggestion || ''}`)
      }
    } catch (error) {
      console.error('Erro no fix:', error)
      alert('Erro: ' + (error instanceof Error ? error.message : String(error)))
    } finally {
      setLoading(false)
    }
  }

  const testCreateCategory = async () => {
    if (!newCategoryName.trim()) return
    
    setLoading(true)
    try {
      const result = await createCategorySimple(newCategoryName)
      console.log('Categoria criada:', result)
      alert('Categoria criada com sucesso!')
      setNewCategoryName('')
    } catch (error) {
      console.error('Erro ao criar:', error)
      alert('Erro: ' + (error instanceof Error ? error.message : String(error)))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-2xl font-bold mb-8">Teste de Categorias</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card className="p-6">
            <h2 className="text-lg font-semibold mb-4">Testes Automáticos</h2>
            <div className="space-y-4">
              <Button 
                onClick={runTests} 
                disabled={loading}
                className="w-full"
              >
                {loading ? 'Testando...' : 'Executar Testes'}
              </Button>
              
              <Button 
                onClick={setupDefaults} 
                disabled={loading}
                variant="outline"
                className="w-full"
              >
                Inserir Categorias Padrão
              </Button>
              
              <Button 
                onClick={fixPolicies} 
                disabled={loading}
                variant="outline"
                className="w-full bg-yellow-50 border-yellow-200 text-yellow-800 hover:bg-yellow-100"
              >
                🔧 Corrigir Políticas RLS
              </Button>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="text-lg font-semibold mb-4">Teste Manual</h2>
            <div className="space-y-4">
              <Input
                placeholder="Nome da nova categoria"
                value={newCategoryName}
                onChange={(e) => setNewCategoryName(e.target.value)}
              />
              <Button 
                onClick={testCreateCategory} 
                disabled={loading || !newCategoryName.trim()}
                className="w-full"
              >
                Criar Categoria
              </Button>
            </div>
          </Card>
        </div>

        {results && (
          <Card className="p-6 mt-6">
            <h2 className="text-lg font-semibold mb-4">Resultados dos Testes</h2>
            <pre className="bg-gray-100 p-4 rounded overflow-auto text-sm">
              {JSON.stringify(results, null, 2)}
            </pre>
          </Card>
        )}
      </div>
    </div>
  )
}
