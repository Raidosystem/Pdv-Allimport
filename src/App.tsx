import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './modules/auth'
import { PermissionsProvider } from './hooks/usePermissions'
import { ProtectedRoute } from './modules/auth/ProtectedRoute'
import { SubscriptionGuard } from './components/SubscriptionGuard'
import { CacheErrorBoundary } from './utils/cacheBuster'
import { OfflineIndicator } from './components/OfflineIndicator'
import { UpdateCard } from './components/UpdateCard'
import { PWARedirect } from './components/PWARedirect'
import { PWAUpdateNotification } from './components/PWAUpdateNotification'
import { BackupFolderSetup } from './components/BackupFolderSetup'
import './App.css'
import { useState, useEffect, lazy, Suspense } from 'react'
import { initVersionCheck } from './utils/version-check'
import { startVersionChecking } from './utils/versionControl'
import { useAppearanceSettings } from './hooks/useAppearanceSettings'

// 🚀 LAZY LOADING - Carrega componentes sob demanda para bundle inicial menor
// Auth pages - carregadas imediatamente (usuário precisa fazer login)
import { LoginPage } from './modules/auth/LoginPage'
import { LocalLoginPage } from './modules/auth/LocalLoginPage'
import { SignupPageNew } from './modules/auth/SignupPageNew'
import { ResetPasswordPage } from './modules/auth/ResetPasswordPage' // 🔥 MUDADO: Não lazy para debug

// Landing page - lazy loading para melhorar performance inicial
const LandingPage = lazy(() => import('./modules/landing/LandingPage').then(m => ({ default: m.LandingPage })))

// Páginas principais - lazy loading
const DashboardPage = lazy(() => import('./modules/dashboard/DashboardPageNew').then(m => ({ default: m.DashboardPage })))
const SalesPage = lazy(() => import('./modules/sales/SalesPage').then(m => ({ default: m.SalesPage })))
const ClientesPage = lazy(() => import('./modules/clientes/ClientesPage').then(m => ({ default: m.ClientesPage })))
const ProductsPage = lazy(() => import('./pages/ProductsPage').then(m => ({ default: m.ProductsPage })))
const CaixaPage = lazy(() => import('./pages/CaixaPageNew').then(m => ({ default: m.CaixaPage })))
const OrdensServicoPage = lazy(() => import('./pages/OrdensServicoPageNew').then(m => ({ default: m.OrdensServicoPage })))

// Admin pages - lazy loading
const AdminPanel = lazy(() => import('./components/admin/AdminPanel').then(m => ({ default: m.AdminPanel })))
const AdminDashboard = lazy(() => import('./components/admin/AdminDashboard').then(m => ({ default: m.AdminDashboard })))
const ActivateUsersPage = lazy(() => import('./modules/admin/pages/ActivateUsersPage').then(m => ({ default: m.ActivateUsersPage })))
const ConfiguracaoModulosPage = lazy(() => import('./pages/admin/ConfiguracaoModulosPage').then(m => ({ default: m.ConfiguracaoModulosPage })))
const LojaOnlinePage = lazy(() => import('./pages/admin/LojaOnlinePage'))

// Auth secundárias - lazy loading
const ConfirmEmailPage = lazy(() => import('./modules/auth/ConfirmEmailPage').then(m => ({ default: m.ConfirmEmailPage })))
const ForgotPasswordPage = lazy(() => import('./modules/auth/ForgotPasswordPage').then(m => ({ default: m.ForgotPasswordPage })))
// ResetPasswordPage removido do lazy - carregado diretamente acima
const TrocarSenhaPage = lazy(() => import('./pages/TrocarSenhaPage'))

// Páginas secundárias - lazy loading
const FornecedoresPage = lazy(() => import('./pages/FornecedoresPage').then(m => ({ default: m.FornecedoresPage })))
const HistoricoCaixaPage = lazy(() => import('./pages/HistoricoCaixaPage').then(m => ({ default: m.HistoricoCaixaPage })))
const ContasPagarList = lazy(() => import('./modules/financeiro/contas-pagar/ContasPagarList'))
const OrdemServicoDetalhePage = lazy(() => import('./pages/OrdemServicoDetalhePage').then(m => ({ default: m.OrdemServicoDetalhePage })))
const OrdemServicoEditPage = lazy(() => import('./pages/OrdemServicoEditPage').then(m => ({ default: m.OrdemServicoEditPage })))
const ConfiguracoesPage = lazy(() => import('./pages/ConfiguracoesPage').then(m => ({ default: m.ConfiguracoesPage })))
const ConfiguracoesEmpresaPage = lazy(() => import('./pages/ConfiguracoesEmpresaPageNew').then(m => ({ default: m.ConfiguracoesEmpresaPage })))

// Relatórios - lazy loading
const RelatoriosPage = lazy(() => import('./pages/RelatoriosPage'))
const RelatoriosPageAdvanced = lazy(() => import('./pages/RelatoriosPageAdvanced'))
const ResumoDiarioPage = lazy(() => import('./pages/RelatoriosResumoDiarioPage'))
const RelatoriosPeriodoPage = lazy(() => import('./pages/RelatoriosPeriodoPage'))
const RelatoriosRankingPage = lazy(() => import('./pages/RelatoriosRankingPage'))
const RelatoriosGraficosPage = lazy(() => import('./pages/RelatoriosGraficosPage'))
const RelatoriosExportacoesPage = lazy(() => import('./pages/RelatoriosExportacoesPage'))
const RelatoriosDetalhadoPage = lazy(() => import('./pages/RelatoriosDetalhadoPage'))

// Backup/Importação - lazy loading
const ImportBackupPage = lazy(() => import('./pages/ImportBackupPage'))
const ImportacaoPrivadaPage = lazy(() => import('./pages/ImportacaoPrivadaPage'))
const ImportacaoAutomaticaPage = lazy(() => import('./pages/ImportacaoAutomaticaPage'))

// Loja pública - lazy loading
const LojaPublicaPage = lazy(() => import('./pages/LojaPublicaPage'))

// Pagamentos - lazy loading
const PaymentPage = lazy(() => import('./components/subscription/PaymentPage').then(m => ({ default: m.PaymentPage })))
const PaymentTest = lazy(() => import('./components/PaymentTest').then(m => ({ default: m.PaymentTest })))

// Debug/Teste - lazy loading
const TestePage = lazy(() => import('./pages/TestePage').then(m => ({ default: m.TestePage })))
const TestPage = lazy(() => import('./pages/TestPage').then(m => ({ default: m.TestPage })))
const DebugSupabase = lazy(() => import('./pages/DebugSupabase'))

// 🎨 Loading Component - Exibido durante carregamento lazy
const PageLoader = () => (
  <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
    <div className="text-center">
      <div className="relative">
        <div className="animate-spin rounded-full h-16 w-16 border-4 border-blue-200 border-t-blue-600 mx-auto"></div>
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="h-8 w-8 bg-blue-500 rounded-full animate-pulse"></div>
        </div>
      </div>
      <p className="mt-6 text-gray-700 font-medium animate-pulse">Carregando...</p>
      <p className="mt-2 text-sm text-gray-500">Aguarde um momento</p>
    </div>
  </div>
)

// 🎨 Componente que aplica tema globalmente (dentro do AuthProvider)
function ThemeApplier() {
  useAppearanceSettings()
  return null
}

function App() {
  // PWA Install Hook
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [showInstallBanner, setShowInstallBanner] = useState(false);
  const [appError, setAppError] = useState<string | null>(null);

  useEffect(() => {
    try {
      // Inicializar verificações de versão de forma ASSÍNCRONA e NÃO BLOQUEANTE
      setTimeout(() => {
        initVersionCheck()
        startVersionChecking()
      }, 2000) // Espera 2 segundos após carregamento inicial
      
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
          {/* 🎨 Aplicar tema globalmente após AuthProvider estar montado */}
          <ThemeApplier />
          
          <Router>
          {/* PWA Install Banner - Removido */}
          {false && showInstallBanner && deferredPrompt && (
            <div className="fixed top-4 right-4 bg-green-600 text-white p-4 rounded-lg shadow-lg z-50 max-w-sm">
              <div className="flex items-center gap-3">
                <span role="img" aria-label="mobile">📱</span>
                <div className="flex-1">
                  <div className="font-bold text-sm">Instalar RaVal pdv</div>
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
        {/* PWA Install component now inline above */}
        <PWARedirect />
        <PWAUpdateNotification />
        <BackupFolderSetup />
        <Suspense fallback={<PageLoader />}>
          <Routes>
          {/* Rotas públicas */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/login-local" element={<LocalLoginPage />} />
          <Route path="/trocar-senha" element={<TrocarSenhaPage />} />
          <Route path="/signup" element={<SignupPageNew />} />
          <Route path="/confirm-email" element={<ConfirmEmailPage />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/reset-password" element={<ResetPasswordPage />} />
          <Route path="/admin" element={<AdminDashboard />} />
          <Route path="/admin/old" element={<AdminPanel />} />
          
          {/* Loja Pública - SEM proteção de login */}
          <Route path="/loja/:slug" element={<LojaPublicaPage />} />
          
          <Route path="/debug-supabase" element={<DebugSupabase />} />
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
            path="/fornecedores" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <FornecedoresPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
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
            path="/admin/ativar-usuarios" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ActivateUsersPage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          
          <Route 
            path="/admin/loja-online" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <LojaOnlinePage />
                </SubscriptionGuard>
              </ProtectedRoute>
            } 
          />
          
          <Route 
            path="/admin/configuracao-modulos" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ConfiguracaoModulosPage />
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
        </Suspense>
        
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
