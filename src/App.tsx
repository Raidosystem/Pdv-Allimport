import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './modules/auth'
import { LoginPage } from './modules/auth/LoginPage'
import { SignupPage } from './modules/auth/SignupPage'
import { EmailConfirmationPage } from './modules/auth/EmailConfirmationPage'
import { ResendConfirmationPage } from './modules/auth/ResendConfirmationPage'
import { TestLoginPage } from './modules/auth/TestLoginPage'
import { EmailInstructionsPage } from './modules/auth/EmailInstructionsPage'
import { LandingPage } from './modules/landing/LandingPage'
import { DashboardPage } from './modules/dashboard/DashboardPage'
import { SalesPage } from './modules/sales/SalesPage'
import { ProductsPage } from './modules/products/ProductsPage'
import { ClientesPage } from './modules/clientes/ClientesPage'
import { CaixaPage } from './pages/CaixaPage'
import { HistoricoCaixaPage } from './pages/HistoricoCaixaPage'
import { OrdensServicoPage } from './pages/OrdensServicoPage'
import { OrdemServicoDetalhePage } from './pages/OrdemServicoDetalhePage'
import { CategoryTestPage } from './modules/products/CategoryTestPage'
import { ProtectedRoute } from './modules/auth/ProtectedRoute'
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
          <Route path="/confirm-email" element={<EmailConfirmationPage />} />
          <Route path="/resend-confirmation" element={<ResendConfirmationPage />} />
          <Route path="/test-login" element={<TestLoginPage />} />
          <Route path="/email-help" element={<EmailInstructionsPage />} />
          
          {/* Rotas protegidas */}
          <Route 
            path="/dashboard" 
            element={
              <ProtectedRoute>
                <DashboardPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/vendas" 
            element={
              <ProtectedRoute>
                <SalesPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/produtos" 
            element={
              <ProtectedRoute>
                <ProductsPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/clientes" 
            element={
              <ProtectedRoute>
                <ClientesPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/caixa" 
            element={
              <ProtectedRoute>
                <CaixaPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/caixa/historico" 
            element={
              <ProtectedRoute>
                <HistoricoCaixaPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/ordens-servico" 
            element={
              <ProtectedRoute>
                <OrdensServicoPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/ordens-servico/:id" 
            element={
              <ProtectedRoute>
                <OrdemServicoDetalhePage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/test-categorias" 
            element={
              <ProtectedRoute>
                <CategoryTestPage />
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
