import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './modules/auth'
import { LoginPage } from './modules/auth/LoginPage'
import { SignupPage } from './modules/auth/SignupPage'
import { ForgotPasswordPage } from './modules/auth/ForgotPasswordPage'
import { ResetPasswordPage } from './modules/auth/ResetPasswordPage'
import { AdminPanel } from './components/admin/AdminPanel'
import { LandingPage } from './modules/landing/LandingPage'
import { DashboardPage } from './modules/dashboard/DashboardPage.tsx'
import { SalesPage } from './modules/sales/SalesPage'
import { ProductsPage } from './modules/products/ProductsPage'
import { ClientesPage } from './modules/clientes/ClientesPage'
import { CaixaPage } from './pages/CaixaPage'
import { HistoricoCaixaPage } from './pages/HistoricoCaixaPage'
import { OrdensServicoPage } from './pages/OrdensServicoPage'
import { OrdemServicoDetalhePage } from './pages/OrdemServicoDetalhePage'
import { CategoryTestPage } from './modules/products/CategoryTestPage'
import { ConfiguracoesPage } from './pages/ConfiguracoesPage'
import { ProtectedRoute } from './modules/auth/ProtectedRoute'
import { SubscriptionGuard } from './components/SubscriptionGuard'
import { PaymentPage } from './components/subscription/PaymentPage'
import { PaymentTest } from './components/PaymentTest'
import './App.css'

function App() {
  return (
    <AuthProvider>
      <Router>
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
        <Routes>
          {/* Rotas públicas */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/reset-password" element={<ResetPasswordPage />} />
          <Route path="/admin" element={<AdminPanel />} />
          
          {/* Página de Teste de Pagamento */}
          <Route path="/payment-test" element={<PaymentTest />} />
          
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
            path="/produtos" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <ProductsPage />
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
            path="/test-categorias" 
            element={
              <ProtectedRoute>
                <SubscriptionGuard>
                  <CategoryTestPage />
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
          
          {/* Redirecionamento padrão */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App
