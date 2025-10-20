import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { AlertCircle, CheckCircle, Loader } from 'lucide-react';

interface ResultadoImportacao {
  sucesso: boolean;
  total: number;
  detalhes: Record<string, number>;
  erros: string[];
  tempo: string;
}

export function ImportarBackupPage() {
  const [importando, setImportando] = useState(false);
  const [resultado, setResultado] = useState<ResultadoImportacao | null>(null);
  const [progresso, setProgresso] = useState('');

  const importarClientes = async (clientes: any[]): Promise<number> => {
    setProgresso(`Importando ${clientes.length} clientes...`);
    
    const clientesFormatados = clientes.map((cliente: any) => ({
      id: cliente.id || crypto.randomUUID(),
      nome: cliente.name || 'Cliente',
      telefone: cliente.phone || '',
      email: cliente.email || null,
      cpf_cnpj: cliente.cpf_cnpj || null,
      cpf_digits: cliente.cpf_cnpj ? cliente.cpf_cnpj.replace(/\D/g, '') : null,
      endereco: cliente.address || null,
      cidade: cliente.city || null,
      estado: cliente.state || null,
      cep: cliente.zip_code || null,
      tipo: 'Física',
      ativo: true,
      observacoes: null,
      created_at: cliente.created_at || new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));

    let importados = 0;
    const loteSize = 100;

    for (let i = 0; i < clientesFormatados.length; i += loteSize) {
      const lote = clientesFormatados.slice(i, i + loteSize);
      
      const { error } = await supabase
        .from('clientes')
        .upsert(lote, { onConflict: 'id' });

      if (error) {
        console.error(`Erro no lote ${i / loteSize + 1}:`, error);
      } else {
        importados += lote.length;
        setProgresso(`Clientes: ${importados}/${clientesFormatados.length}`);
      }
    }

    return importados;
  };

  const importarProdutos = async (produtos: any[]): Promise<number> => {
    setProgresso(`Importando ${produtos.length} produtos...`);
    
    const produtosFormatados = produtos.map((produto: any) => ({
      id: produto.id || crypto.randomUUID(),
      nome: produto.name || 'Produto',
      preco: Number(produto.sale_price || produto.price || 0),
      custo: Number(produto.cost_price || 0),
      estoque: Number(produto.current_stock || produto.stock || 0),
      estoque_minimo: Number(produto.minimum_stock || 0),
      unidade: produto.unit_measure || 'un',
      codigo_barras: produto.barcode || null,
      categoria_id: produto.category_id || null,
      ativo: produto.active !== false,
      created_at: produto.created_at || new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));

    let importados = 0;
    const loteSize = 100;

    for (let i = 0; i < produtosFormatados.length; i += loteSize) {
      const lote = produtosFormatados.slice(i, i + loteSize);
      
      const { error } = await supabase
        .from('produtos')
        .upsert(lote, { onConflict: 'id' });

      if (error) {
        console.error(`Erro no lote ${i / loteSize + 1}:`, error);
      } else {
        importados += lote.length;
        setProgresso(`Produtos: ${importados}/${produtosFormatados.length}`);
      }
    }

    return importados;
  };

  const importarOrdensServico = async (ordens: any[]): Promise<number> => {
    setProgresso(`Importando ${ordens.length} ordens de serviço...`);
    
    const ordensFormatadas = ordens.map((ordem: any) => ({
      id: ordem.id || crypto.randomUUID(),
      cliente_id: ordem.client_id || null,
      nome_cliente: ordem.client_name || null,
      equipamento: ordem.equipment || ordem.device_name || 'Equipamento',
      modelo: ordem.device_model || null,
      defeito_relatado: ordem.defect || 'Defeito',
      status: ordem.status || 'Aguardando',
      valor_total: Number(ordem.total || ordem.total_amount || 0),
      valor_mao_obra: Number(ordem.labor_cost || 0),
      forma_pagamento: ordem.payment_method || null,
      data_abertura: ordem.opening_date || null,
      data_fechamento: ordem.closing_date || null,
      observacoes: ordem.observations || null,
      created_at: ordem.created_at || new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));

    let importados = 0;
    const loteSize = 100;

    for (let i = 0; i < ordensFormatadas.length; i += loteSize) {
      const lote = ordensFormatadas.slice(i, i + loteSize);
      
      const { error } = await supabase
        .from('ordens_servico')
        .upsert(lote, { onConflict: 'id' });

      if (error) {
        console.error(`Erro no lote ${i / loteSize + 1}:`, error);
      } else {
        importados += lote.length;
        setProgresso(`Ordens de Serviço: ${importados}/${ordensFormatadas.length}`);
      }
    }

    return importados;
  };

  const executarImportacao = async () => {
    setImportando(true);
    setResultado(null);
    setProgresso('Iniciando importação...');

    const inicio = Date.now();
    const result: ResultadoImportacao = {
      sucesso: false,
      total: 0,
      detalhes: {},
      erros: [],
      tempo: ''
    };

    try {
      // Carregar backup
      setProgresso('Carregando backup...');
      const response = await fetch('/backup-allimport.json');
      const backup = await response.json();

      if (!backup.data) {
        throw new Error('Estrutura do backup inválida');
      }

      // Importar Clientes
      if (backup.data.clients?.length > 0) {
        const importados = await importarClientes(backup.data.clients);
        result.detalhes.clientes = importados;
      }

      // Importar Produtos
      if (backup.data.products?.length > 0) {
        const importados = await importarProdutos(backup.data.products);
        result.detalhes.produtos = importados;
      }

      // Importar Ordens de Serviço
      if (backup.data.service_orders?.length > 0) {
        const importados = await importarOrdensServico(backup.data.service_orders);
        result.detalhes.ordens_servico = importados;
      }

      result.total = Object.values(result.detalhes).reduce((sum, count) => sum + count, 0);
      result.sucesso = result.total > 0;
      result.tempo = `${((Date.now() - inicio) / 1000).toFixed(2)}s`;

      setResultado(result);
      setProgresso('');
    } catch (error: any) {
      console.error('Erro na importação:', error);
      result.erros.push(error.message);
      result.sucesso = false;
      setResultado(result);
    } finally {
      setImportando(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <Card className="p-6">
        <div className="space-y-6">
          <div>
            <h1 className="text-2xl font-bold mb-2">Importar Backup para Supabase</h1>
            <p className="text-gray-600">
              Importa todos os dados do arquivo backup-allimport.json para o banco de dados do Supabase.
            </p>
          </div>

          <div className="flex items-center gap-2 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <AlertCircle className="w-5 h-5 text-yellow-600" />
            <p className="text-sm text-yellow-800">
              Esta operação irá sobrescrever dados existentes com o mesmo ID.
              Certifique-se de estar logado como administrador.
            </p>
          </div>

          <Button
            onClick={executarImportacao}
            disabled={importando}
            className="w-full"
          >
            {importando ? (
              <>
                <Loader className="w-4 h-4 mr-2 animate-spin" />
                Importando...
              </>
            ) : (
              'Iniciar Importação'
            )}
          </Button>

          {progresso && (
            <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-sm text-blue-800">{progresso}</p>
            </div>
          )}

          {resultado && (
            <div className={`p-4 rounded-lg border ${
              resultado.sucesso 
                ? 'bg-green-50 border-green-200' 
                : 'bg-red-50 border-red-200'
            }`}>
              <div className="flex items-start gap-2 mb-4">
                {resultado.sucesso ? (
                  <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                ) : (
                  <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                )}
                <div className="flex-1">
                  <h3 className="font-semibold mb-1">
                    {resultado.sucesso ? 'Importação Concluída!' : 'Erro na Importação'}
                  </h3>
                  <p className="text-sm text-gray-600">
                    Tempo: {resultado.tempo} | Total: {resultado.total} registros
                  </p>
                </div>
              </div>

              {Object.keys(resultado.detalhes).length > 0 && (
                <div className="space-y-2">
                  <p className="text-sm font-medium">Detalhes:</p>
                  {Object.entries(resultado.detalhes).map(([tabela, quantidade]) => (
                    <div key={tabela} className="text-sm pl-4">
                      • {tabela}: {quantidade} registros
                    </div>
                  ))}
                </div>
              )}

              {resultado.erros.length > 0 && (
                <div className="mt-4 space-y-2">
                  <p className="text-sm font-medium text-red-700">Erros:</p>
                  {resultado.erros.map((erro, i) => (
                    <div key={i} className="text-sm text-red-600 pl-4">
                      • {erro}
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </Card>
    </div>
  );
}
