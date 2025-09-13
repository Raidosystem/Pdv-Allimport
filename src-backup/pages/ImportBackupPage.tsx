import { useState } from 'react';
import { supabase } from '../lib/supabase';
import { Button } from '../components/ui/Button';
import { Upload, Database, CheckCircle, AlertCircle, Users, Package, ShoppingCart, Wrench } from 'lucide-react';
import toast from 'react-hot-toast';
import { useAuth } from '../modules/auth/AuthContext';

interface BackupData {
  metadata: {
    backup_type: string;
    created_at: string;
    version: string;
    description: string;
    user: any;
    establishment: any;
  };
  data: {
    profiles: any[];
    clients: any[];
    products: any[];
    categories: any[];
    sales: any[];
    sale_items: any[];
    service_orders: any[];
    service_parts: any[];
    establishments: any[];
    cash_registers: any[];
    cash_movements: any[];
    stock_movements: any[];
    suppliers: any[];
    accounts_payable: any[];
  };
}

export default function ImportBackupPage() {
  const { user } = useAuth();
  const [backupFile, setBackupFile] = useState<File | null>(null);
  const [backupData, setBackupData] = useState<BackupData | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [importStatus, setImportStatus] = useState<Record<string, 'pending' | 'success' | 'error'>>({});

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (file.type !== 'application/json' && !file.name.toLowerCase().endsWith('.json')) {
      toast.error('Por favor, selecione um arquivo JSON válido.');
      return;
    }

    setBackupFile(file);
    
    try {
      const text = await file.text();
      const data: BackupData = JSON.parse(text);
      
      // Validação mais robusta da estrutura
      if (!data.metadata) {
        throw new Error('Arquivo não possui seção "metadata"');
      }
      
      if (!data.data) {
        throw new Error('Arquivo não possui seção "data"');
      }
      
      // Verificar se os arrays principais existem
      const dataObj = data.data as any;
      const requiredArrays = ['clients', 'products', 'service_orders', 'establishments', 'categories'];
      const missingArrays = requiredArrays.filter(arr => !Array.isArray(dataObj[arr]));
      
      if (missingArrays.length > 0) {
        console.warn('Arrays ausentes ou inválidos:', missingArrays);
        // Inicializar arrays ausentes como arrays vazios
        missingArrays.forEach(arr => {
          dataObj[arr] = [];
        });
      }
      
      setBackupData(data);
      toast.success(`Backup validado com sucesso! ${getTotalRecords(data)} registros encontrados.`);
    } catch (error) {
      console.error('Erro ao ler backup:', error);
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
      
      if (errorMessage.includes('JSON')) {
        toast.error('Arquivo JSON inválido ou corrompido.');
      } else if (errorMessage.includes('metadata') || errorMessage.includes('data')) {
        toast.error(`Estrutura de backup inválida: ${errorMessage}`);
      } else {
        toast.error('Erro ao processar arquivo de backup. Verifique o formato.');
      }
      
      setBackupFile(null);
      setBackupData(null);
    }
  };

  const getTotalRecords = (data: BackupData): number => {
    const dataObj = data.data as any;
    return (dataObj.clients?.length || 0) + 
           (dataObj.products?.length || 0) + 
           (dataObj.service_orders?.length || 0) + 
           (dataObj.establishments?.length || 0) + 
           (dataObj.categories?.length || 0);
  };

  const importTable = async (tableName: string, data: any[], transform?: (item: any) => any) => {
    try {
      setImportStatus(prev => ({ ...prev, [tableName]: 'pending' }));
      
      if (data.length === 0) {
        setImportStatus(prev => ({ ...prev, [tableName]: 'success' }));
        return;
      }

      let processedData = transform ? data.map(transform) : data;
      
      // Mapeamento especial para tabelas do backup Allimport
      if (tableName === 'clientes' && data.length > 0) {
        // Mapear estrutura de clientes se necessário
        processedData = data.map((item: any) => ({
          ...item,
          user_id: user?.id,
          created_at: item.created_at || new Date().toISOString(),
          updated_at: new Date().toISOString(),
          // Mapear campos específicos se necessário
          nome: item.nome || item.name || item.full_name,
          email: item.email || '',
          telefone: item.telefone || item.phone || '',
          endereco: item.endereco || item.address || ''
        }));
      } else if (tableName === 'products' && data.length > 0) {
        // Mapear estrutura de produtos
        processedData = data.map((item: any) => ({
          ...item,
          user_id: user?.id,
          created_at: item.created_at || new Date().toISOString(),
          updated_at: new Date().toISOString(),
          // Mapear campos específicos
          name: item.name || item.nome || item.title,
          price: item.price || item.preco || 0,
          stock: item.stock || item.estoque || 0
        }));
      } else if (transform) {
        processedData = data.map(transform);
      } else {
        // Adicionar user_id para todos os registros por padrão
        processedData = data.map((item: any) => ({
          ...item,
          user_id: user?.id,
          created_at: item.created_at || new Date().toISOString(),
          updated_at: new Date().toISOString()
        }));
      }
      
      // Inserir em lotes de 100
      const batchSize = 100;
      for (let i = 0; i < processedData.length; i += batchSize) {
        const batch = processedData.slice(i, i + batchSize);
        
        const { error } = await supabase
          .from(tableName)
          .upsert(batch, { onConflict: 'id' });

        if (error) {
          throw error;
        }
      }

      setImportStatus(prev => ({ ...prev, [tableName]: 'success' }));
      toast.success(`${tableName}: ${data.length} registros importados`);
    } catch (error) {
      console.error(`Erro ao importar ${tableName}:`, error);
      setImportStatus(prev => ({ ...prev, [tableName]: 'error' }));
      toast.error(`Erro ao importar ${tableName}: ${error instanceof Error ? error.message : 'Erro desconhecido'}`);
    }
  };

  const startImport = async () => {
    if (!backupData || !user) return;

    setIsLoading(true);
    
    try {
      // 1. Importar categorias primeiro (dependência)
      await importTable('categories', backupData.data.categories, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 2. Importar clientes
      await importTable('clientes', backupData.data.clients, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 3. Importar produtos
      await importTable('products', backupData.data.products, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 4. Importar ordens de serviço
      await importTable('service_orders', backupData.data.service_orders, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 5. Importar vendas
      await importTable('sales', backupData.data.sales, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 6. Importar itens de venda
      await importTable('sale_items', backupData.data.sale_items, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      // 7. Importar peças de serviço
      await importTable('service_parts', backupData.data.service_parts, (item) => ({
        ...item,
        user_id: user.id,
        created_at: item.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }));

      toast.success('🎉 Importação concluída com sucesso!');
    } catch (error) {
      console.error('Erro na importação:', error);
      toast.error('Erro durante a importação. Verifique os logs.');
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-4 h-4 text-green-500" />;
      case 'error':
        return <AlertCircle className="w-4 h-4 text-red-500" />;
      default:
        return <div className="w-4 h-4 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />;
    }
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-3">
        <Database className="w-8 h-8 text-blue-600" />
        <div>
          <h1 className="text-2xl font-bold">Importar Backup Allimport</h1>
          <p className="text-gray-600">Importe dados de backup do sistema antigo</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Upload do Arquivo */}
        <div className="bg-white rounded-lg border p-6 space-y-4">
          <h2 className="text-lg font-semibold flex items-center gap-2">
            <Upload className="w-5 h-5" />
            Selecionar Arquivo de Backup
          </h2>

          <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
            <input
              type="file"
              accept=".json"
              onChange={handleFileSelect}
              className="hidden"
              id="backup-file"
            />
            <label htmlFor="backup-file" className="cursor-pointer">
              <Upload className="w-12 h-12 mx-auto text-gray-400 mb-4" />
              <p className="text-lg font-medium text-gray-700">
                Clique para selecionar arquivo JSON
              </p>
              <p className="text-sm text-gray-500 mt-2">
                Aceita apenas arquivos .json de backup
              </p>
            </label>
          </div>

          {backupFile && (
            <div className="bg-green-50 border border-green-200 rounded-lg p-4">
              <p className="text-green-800 font-medium">✅ Arquivo carregado:</p>
              <p className="text-green-700">{backupFile.name}</p>
            </div>
          )}
        </div>

        {/* Prévia dos Dados */}
        {backupData && (
          <div className="bg-white rounded-lg border p-6 space-y-4">
            <h2 className="text-lg font-semibold">Prévia dos Dados</h2>
            
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                <div className="flex items-center gap-2">
                  <Users className="w-5 h-5 text-blue-600" />
                  <span className="font-medium">Clientes</span>
                </div>
                <span className="bg-blue-600 text-white px-2 py-1 rounded text-sm">
                  {backupData.data.clients.length}
                </span>
              </div>

              <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                <div className="flex items-center gap-2">
                  <Package className="w-5 h-5 text-green-600" />
                  <span className="font-medium">Produtos</span>
                </div>
                <span className="bg-green-600 text-white px-2 py-1 rounded text-sm">
                  {backupData.data.products.length}
                </span>
              </div>

              <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                <div className="flex items-center gap-2">
                  <Wrench className="w-5 h-5 text-purple-600" />
                  <span className="font-medium">Ordens de Serviço</span>
                </div>
                <span className="bg-purple-600 text-white px-2 py-1 rounded text-sm">
                  {backupData.data.service_orders.length}
                </span>
              </div>

              <div className="flex items-center justify-between p-3 bg-orange-50 rounded-lg">
                <div className="flex items-center gap-2">
                  <ShoppingCart className="w-5 h-5 text-orange-600" />
                  <span className="font-medium">Vendas</span>
                </div>
                <span className="bg-orange-600 text-white px-2 py-1 rounded text-sm">
                  {backupData.data.sales.length}
                </span>
              </div>
            </div>

            <div className="border-t pt-4">
              <p className="text-sm text-gray-600">
                <strong>Data do Backup:</strong> {new Date(backupData.metadata.created_at).toLocaleString()}
              </p>
              <p className="text-sm text-gray-600">
                <strong>Descrição:</strong> {backupData.metadata.description}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Botão de Importação */}
      {backupData && (
        <div className="bg-white rounded-lg border p-6 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold">Iniciar Importação</h2>
            
            <Button
              onClick={startImport}
              disabled={isLoading}
              className="bg-blue-600 hover:bg-blue-700"
            >
              {isLoading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                  Importando...
                </>
              ) : (
                <>
                  <Database className="w-4 h-4 mr-2" />
                  Importar Todos os Dados
                </>
              )}
            </Button>
          </div>

          {Object.keys(importStatus).length > 0 && (
            <div className="space-y-2">
              <h3 className="font-medium text-gray-700">Status da Importação:</h3>
              {Object.entries(importStatus).map(([table, status]) => (
                <div key={table} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span className="font-medium capitalize">{table.replace('_', ' ')}</span>
                  {getStatusIcon(status)}
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Avisos */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <h3 className="font-medium text-yellow-800 mb-2">⚠️ Importante:</h3>
        <ul className="text-yellow-700 text-sm space-y-1">
          <li>• Esta operação irá importar todos os dados do backup</li>
          <li>• Dados existentes com mesmo ID serão atualizados</li>
          <li>• Faça backup do sistema atual antes de importar</li>
          <li>• A importação pode demorar alguns minutos para grandes volumes</li>
        </ul>
      </div>
    </div>
  );
}
