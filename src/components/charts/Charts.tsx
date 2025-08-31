import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  Area,
  AreaChart
} from 'recharts'

// Cores para os gráficos
const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4', '#84CC16', '#F97316']

interface ChartProps {
  data: any[]
  title?: string
}

// Gráfico de barras para vendas diárias
export function SalesBarChart({ data, title = 'Vendas por Dia' }: ChartProps) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="data" />
          <YAxis />
          <Tooltip
            labelFormatter={(value) => `Data: ${value}`}
            formatter={(value: number, name) => [
              `R$ ${value.toFixed(2)}`,
              name === 'valor' ? 'Valor' : 'Quantidade'
            ]}
          />
          <Legend />
          <Bar dataKey="valor" fill="#3B82F6" name="Valor" />
          <Bar dataKey="quantidade" fill="#10B981" name="Quantidade" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

// Gráfico de pizza para formas de pagamento
export function PaymentPieChart({ data, title = 'Formas de Pagamento' }: ChartProps) {
  const formatData = data.map((item, index) => ({
    name: item.forma,
    value: item.valor,
    quantidade: item.quantidade,
    color: COLORS[index % COLORS.length]
  }))

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie
            data={formatData}
            cx="50%"
            cy="50%"
            labelLine={false}
            label={({ name, percent }) => `${name}: ${((percent || 0) * 100).toFixed(0)}%`}
            outerRadius={100}
            fill="#8884d8"
            dataKey="value"
          >
            {formatData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip formatter={(value: number) => [`R$ ${value.toFixed(2)}`, 'Valor']} />
        </PieChart>
      </ResponsiveContainer>
    </div>
  )
}

// Gráfico de linha para evolução financeira
export function FinancialLineChart({ data, title = 'Evolução Financeira' }: ChartProps) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="data" />
          <YAxis />
          <Tooltip
            labelFormatter={(value) => `Data: ${value}`}
            formatter={(value: number, name) => [
              `R$ ${value.toFixed(2)}`,
              name === 'entradas' ? 'Entradas' : 'Saídas'
            ]}
          />
          <Legend />
          <Line type="monotone" dataKey="entradas" stroke="#10B981" strokeWidth={2} name="Entradas" />
          <Line type="monotone" dataKey="saidas" stroke="#EF4444" strokeWidth={2} name="Saídas" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}

// Gráfico de área para evolução das vendas
export function SalesAreaChart({ data, title = 'Evolução das Vendas' }: ChartProps) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <AreaChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="data" />
          <YAxis />
          <Tooltip
            labelFormatter={(value) => `Data: ${value}`}
            formatter={(value: number) => [`R$ ${value.toFixed(2)}`, 'Vendas']}
          />
          <Area type="monotone" dataKey="valor" stroke="#3B82F6" fill="#3B82F6" fillOpacity={0.3} />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}

// Gráfico horizontal para top produtos
export function TopProductsChart({ data, title = 'Top Produtos' }: ChartProps) {
  const formattedData = data.map((item, index) => ({
    ...item,
    color: COLORS[index % COLORS.length]
  }))

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={400}>
        <BarChart
          data={formattedData}
          layout="horizontal"
          margin={{ top: 5, right: 30, left: 80, bottom: 5 }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis type="number" />
          <YAxis dataKey="produto" type="category" width={80} />
          <Tooltip
            formatter={(value: number) => [`R$ ${value.toFixed(2)}`, 'Valor']}
          />
          <Bar dataKey="valor" fill="#3B82F6" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

// Gráfico de pizza para categorias financeiras
export function CategoryPieChart({ data, title = 'Distribuição por Categoria', type = 'entrada' }: ChartProps & { type?: 'entrada' | 'saida' }) {
  const formatData = data.map((item, index) => ({
    name: item.categoria,
    value: item.valor,
    color: type === 'entrada' ? 
      ['#10B981', '#34D399', '#6EE7B7', '#A7F3D0', '#D1FAE5'][index % 5] :
      ['#EF4444', '#F87171', '#FCA5A5', '#FED7D7', '#FEE2E2'][index % 5]
  }))

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie
            data={formatData}
            cx="50%"
            cy="50%"
            labelLine={false}
            label={({ name, percent }) => `${name}: ${((percent || 0) * 100).toFixed(0)}%`}
            outerRadius={100}
            fill="#8884d8"
            dataKey="value"
          >
            {formatData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip formatter={(value: number) => [`R$ ${value.toFixed(2)}`, 'Valor']} />
        </PieChart>
      </ResponsiveContainer>
    </div>
  )
}
