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
import { CategoryTestPage } from './modules/products/CategoryTestPage'
import { ProtectedRoute } from './modules/auth/ProtectedRoute'
import { DebugComponent } from './components/DebugComponent'
import './App.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <DebugComponent />
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
