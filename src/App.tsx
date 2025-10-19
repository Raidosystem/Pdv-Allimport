import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './modules/auth'
import { PermissionsProvider } from './hooks/usePermissions'
import { LoginPage } from './modules/auth/LoginPage'
import { LocalLoginPage } from './modules/auth/LocalLoginPage'
import { SignupPageNew } from './modules/auth/SignupPageNew'
import { ConfirmEmailPage } from './modules/auth/ConfirmEmailPage'
import { ForgotPasswordPage } from './modules/auth/ForgotPasswordPage'
import { ResetPasswordPage } from './modules/auth/ResetPasswordPage'
import { AdminPanel } from './components/admin/AdminPanel'
import { LandingPage } from './modules/landing/LandingPage'
import { DashboardPage } from './modules/dashboard/DashboardPageNew'
import { SalesPage } from './modules/sales/SalesPage'
import { ClientesPage } from './modules/clientes/ClientesPage'
import { ProductsPage } from './pages/ProductsPage'
import { TestePage } from './pages/TestePage'
import { TestPage } from './pages/TestPage'
import { CaixaPage } from './pages/CaixaPageNew'
import { HistoricoCaixaPage } from './pages/HistoricoCaixaPage'
import { OrdensServicoPage } from './pages/OrdensServicoPageNew'
import ContasPagarList from './modules/financeiro/contas-pagar/ContasPagarList'
import { OrdemServicoDetalhePage } from './pages/OrdemServicoDetalhePage'
import { OrdemServicoEditPage } from './pages/OrdemServicoEditPage'
import { ConfiguracoesPage } from './pages/ConfiguracoesPage'
import { CacheErrorBoundary } from './utils/cacheBuster'
import { ConfiguracoesEmpresaPage } from './pages/ConfiguracoesEmpresaPageNew'
import ImportBackupPage from './pages/ImportBackupPage'
import ImportacaoPrivadaPage from './pages/ImportacaoPrivadaPage'
import ImportacaoAutomaticaPage from './pages/ImportacaoAutomaticaPage'
import RelatoriosPage from './pages/RelatoriosPage'
import RelatoriosPageAdvanced from './pages/RelatoriosPageAdvanced'
import ResumoDiarioPage from './pages/RelatoriosResumoDiarioPage'
import RelatoriosPeriodoPage from './pages/RelatoriosPeriodoPage'
import RelatoriosRankingPage from './pages/RelatoriosRankingPage'
import RelatoriosGraficosPage from './pages/RelatoriosGraficosPage'
import RelatoriosExportacoesPage from './pages/RelatoriosExportacoesPage'
import RelatoriosDetalhadoPage from './pages/RelatoriosDetalhadoPage'
import GerenciarFuncionarios from './pages/GerenciarFuncionarios'
import FuncionariosPage from './pages/admin/FuncionariosPage'
import { ActivateUsersPage } from './modules/admin/pages/ActivateUsersPage'
import DebugSupabase from './pages/DebugSupabase'
import { ProtectedRoute } from './modules/auth/ProtectedRoute'
import { SubscriptionGuard } from './components/SubscriptionGuard'
import { PaymentPage } from './components/subscription/PaymentPage'
import { PaymentTest } from './components/PaymentTest'
import { OfflineIndicator } from './components/OfflineIndicator'
import { UpdateCard } from './components/UpdateCard'
// import { InstallPWA } from './components/InstallPWA'
import './App.css'
import { useState, useEffect } from 'react'
import { initVersionCheck } from './utils/version-check'
import { startVersionChecking } from './utils/versionControl'

function App() {
  // PWA Install Hook
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [showInstallBanner, setShowInstallBanner] = useState(false);
  const [appError, setAppError] = useState<string | null>(null);

  useEffect(() => {
    try {
      // Inicializar sistema de detecção de versão
      initVersionCheck()
      
      // Inicializar sistema de controle de cache e versão
      startVersionChecking()
      
      const handleBeforeInstallPrompt = (e: Event) => {
        console.log('🎯 PWA install prompt captured!');
        e.preventDefault();
        setDeferredPrompt(e);
        setShowInstallBanner(true);
      };

      const handleAppInstalled = () => {
        console.log('✅ PWA installed successfully!');
        setShowInstallBanner(false);
        setDeferredPrompt(null);
      };

      window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
      window.addEventListener('appinstalled', handleAppInstalled);

      return () => {
        window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
        window.removeEventListener('appinstalled', handleAppInstalled);
      };
    } catch (error) {
      console.error('PWA setup error:', error);
      setAppError('Erro na configuração PWA');
    }
  }, []);

  const handlePWAInstall = async () => {
    if (!deferredPrompt) return;
    
    try {
      await (deferredPrompt as any).prompt();
      const result = await (deferredPrompt as any).userChoice;
      
      console.log(`PWA install: ${result.outcome}`);
      setDeferredPrompt(null);
      setShowInstallBanner(false);
    } catch (error) {
      console.error('PWA install error:', error);
    }
  };

  if (appError) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center p-8">
          <h1 className="text-2xl font-bold text-red-600 mb-4">Erro na aplicação</h1>
          <p className="text-gray-600">{appError}</p>
          <button 
            onClick={() => window.location.reload()} 
            className="mt-4 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
          >
            Tentar novamente
          </button>
        </div>
      </div>
    );
  }

  return (
    <CacheErrorBoundary>
      <AuthProvider>
        <PermissionsProvider>
          <Router>
          {/* PWA Install Banner - Removido */}
          {false && showInstallBanner && deferredPrompt && (
            <div className="fixed top-4 right-4 bg-green-600 text-white p-4 rounded-lg shadow-lg z-50 max-w-sm">
              <div className="flex items-center gap-3">
                <span role="img" aria-label="mobile">📱</span>
                <div className="flex-1">
                  <div className="font-bold text-sm">Instalar PDV Allimport</div>
                  <div className="text-xs opacity-90">Acesso rápido + offline</div>
              </div>
              <div className="flex gap-1">
                <button
                  onClick={handlePWAInstall}
                  className="bg-white text-green-600 px-3 py-1 rounded text-sm font-bold hover:bg-gray-100 transition-colors"
                >
                  Instalar
                </button>
                <button
                  onClick={() => setShowInstallBanner(false)}
                  className="text-white hover:bg-green-700 px-2 py-1 rounded text-sm transition-colors"
                  aria-label="Fechar"
                >
                  ✕
                </button>
              </div>
            </div>
          </div>
        )}
        <Toaster 
          position="top-right"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#fff',
              color: '#333',
              border: '1px solid #e5e7eb',
              borderRadius: '12px',
              boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
            },
            success: {
              iconTheme: {
                primary: '#10b981',
                secondary: '#fff',
              },
            },
            error: {
              iconTheme: {
                primary: '#ef4444',
                secondary: '#fff',
              },
            },
          }}
        />
        
        {/* Indicador Offline e PWA */}
        <OfflineIndicator />
        {/* PWA Install component now inline above */}
        
        <Routes>
          {/* Rotas públicas */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/login-local" element={<LocalLoginPage />} />
          <Route path="/signup" element={<SignupPageNew />} />
          <Route path="/confirm-email" element={<ConfirmEmailPage />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/reset-password" element={<ResetPasswordPage />} />
          <Route path="/admin" element={<AdminPanel />} />
          
          {/* Página de Debug Supabase */}
          <Route path="/debug-supabase" element={<DebugSupabase />} />
          
          {/* Página de Teste de Pagamento */}
          <Route path="/payment-test" element={<PaymentTest />} />
          
          {/* Página de Teste do Sistema */}
          <Route path="/test" element={<TestPage />} />
          
          {/* Página de Assinatura */}
          <Route 
            path="/assinatura" 
            element={
              <ProtectedRoute>
                <PaymentPage onPaymentSuccess={() => window.location.href = '/dashboard'} />
              </ProtectedRoute>
            } 
          />
          
          {/* Rotas protegidas */}
          <Route 
            path="/dashboard" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <DashboardPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/vendas" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <SalesPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/clientes" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ClientesPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/produtos" 
            element={<ProductsPage />} 
          />
          <Route 
            path="/teste" 
            element={<TestePage />} 
          />
          <Route 
            path="/caixa" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <CaixaPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/caixa/historico" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <HistoricoCaixaPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/financeiro/contas-pagar" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ContasPagarList />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/ordens-servico" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <OrdensServicoPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/ordens-servico/:id" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <OrdemServicoDetalhePage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/ordens-servico/:id/editar" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <OrdemServicoEditPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/configuracoes" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ConfiguracoesPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/import-backup" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ImportBackupPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/import-privado" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ImportacaoPrivadaPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/import-automatico" 
            element={<ImportacaoAutomaticaPage />} 
          />
          <Route 
            path="/configuracoes-empresa" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ConfiguracoesEmpresaPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/funcionarios" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <FuncionariosPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/funcionarios/antigo" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <GerenciarFuncionarios />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/admin/ativar-usuarios" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ActivateUsersPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          
          {/* Rotas de Relatórios */}
          <Route 
            path="/relatorios" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosPageAdvanced />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/classico" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/resumo-diario" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ResumoDiarioPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/periodo" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosPeriodoPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/ranking" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosRankingPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/detalhado" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosDetalhadoPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/graficos" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosGraficosPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/exportacoes" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosExportacoesPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/relatorios/analytics" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <RelatoriosPageAdvanced />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          
          {/* Redirecionamento padrão */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
        
        {/* Componentes Globais */}
        <OfflineIndicator />
        <UpdateCard />
          </Router>
        </PermissionsProvider>
      </AuthProvider>
    </CacheErrorBoundary>
  )
}

export default App
