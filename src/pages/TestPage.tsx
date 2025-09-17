import { useState } from 'react';
import { testMercadoPagoCredentials, testSimplePixCreation } from '../utils/testMercadoPago';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

export function TestPage() {
  const [credentialsTest, setCredentialsTest] = useState<any>(null);
  const [pixTest, setPixTest] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const handleTestCredentials = async () => {
    setLoading(true);
    try {
      const result = await testMercadoPagoCredentials();
      setCredentialsTest(result);
    } catch (error) {
      setCredentialsTest({ valid: false, error: error instanceof Error ? error.message : 'Erro desconhecido' });
    } finally {
      setLoading(false);
    }
  };

  const handleTestPix = async () => {
    setLoading(true);
    try {
      const result = await testSimplePixCreation();
      setPixTest(result);
    } catch (error) {
      setPixTest({ success: false, error: error instanceof Error ? error.message : 'Erro desconhecido' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">🧪 Testes do Sistema PDV</h1>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Teste de Credenciais */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">🔑 Teste de Credenciais Mercado Pago</h2>
          
          <Button 
            onClick={handleTestCredentials}
            disabled={loading}
            className="mb-4"
          >
            {loading ? 'Testando...' : 'Testar Credenciais'}
          </Button>

          {credentialsTest && (
            <div className={`p-4 rounded-lg ${credentialsTest.valid ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'}`}>
              <div className="font-medium mb-2">
                {credentialsTest.valid ? '✅ Credenciais Válidas' : '❌ Credenciais Inválidas'}
              </div>
              {credentialsTest.valid && credentialsTest.userInfo && (
                <div className="text-sm text-gray-600">
                  <p>Email: {credentialsTest.userInfo.email || 'N/A'}</p>
                  <p>ID: {credentialsTest.userInfo.id}</p>
                </div>
              )}
              {!credentialsTest.valid && (
                <div className="text-sm text-red-600">
                  {credentialsTest.error}
                </div>
              )}
            </div>
          )}
        </Card>

        {/* Teste de PIX */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">💰 Teste de Criação PIX</h2>
          
          <Button 
            onClick={handleTestPix}
            disabled={loading}
            className="mb-4"
          >
            {loading ? 'Testando...' : 'Testar PIX (R$ 1,00)'}
          </Button>

          {pixTest && (
            <div className={`p-4 rounded-lg ${pixTest.success ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'}`}>
              <div className="font-medium mb-2">
                {pixTest.success ? '✅ PIX Criado com Sucesso' : '❌ Erro ao Criar PIX'}
              </div>
              {pixTest.success && (
                <div className="text-sm text-gray-600">
                  <p>ID: {pixTest.paymentId}</p>
                  <p>Status: {pixTest.status}</p>
                  <p>QR Code: {pixTest.hasQrCode ? '✅ Presente' : '❌ Ausente'}</p>
                  <p>QR Code Base64: {pixTest.hasQrCodeBase64 ? '✅ Presente' : '❌ Ausente'}</p>
                  {pixTest.qrCode && (
                    <div className="mt-2 p-2 bg-gray-100 rounded text-xs break-all">
                      QR: {pixTest.qrCode.substring(0, 100)}...
                    </div>
                  )}
                </div>
              )}
              {!pixTest.success && (
                <div className="text-sm text-red-600">
                  {pixTest.error}
                </div>
              )}
            </div>
          )}
        </Card>
      </div>

      {/* Link para Relatórios */}
      <Card className="p-6 mt-6">
        <h2 className="text-lg font-semibold mb-4">📊 Testar Relatórios Modernos</h2>
        <p className="text-gray-600 mb-4">
          Clique no link abaixo para verificar se os gráficos modernos estão funcionando corretamente:
        </p>
        <Button 
          onClick={() => window.location.href = '/relatorios'}
          variant="outline"
        >
          🚀 Abrir Relatórios
        </Button>
      </Card>
    </div>
  );
}