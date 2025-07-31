-- Inserir categorias iniciais
insert into public.categories (name, description) values 
('Eletrônicos', 'Produtos eletrônicos em geral'),
('Acessórios', 'Acessórios diversos'),
('Serviços', 'Serviços prestados'),
('Peças', 'Peças de reposição');

-- Inserir alguns produtos de exemplo
insert into public.products (name, description, sku, price, cost, stock_quantity, category_id) 
select 
  'Cabo USB-C', 
  'Cabo USB-C para carregamento e dados', 
  'CABO-USBC-001', 
  25.90, 
  15.00, 
  50,
  c.id
from public.categories c where c.name = 'Acessórios';

insert into public.products (name, description, sku, price, cost, stock_quantity, category_id) 
select 
  'Carregador Universal', 
  'Carregador universal para celulares', 
  'CARR-UNIV-001', 
  45.90, 
  28.00, 
  30,
  c.id
from public.categories c where c.name = 'Eletrônicos';

insert into public.products (name, description, sku, price, cost, stock_quantity, category_id) 
select 
  'Película de Vidro', 
  'Película de vidro temperado para smartphone', 
  'PELIC-VID-001', 
  15.90, 
  8.00, 
  100,
  c.id
from public.categories c where c.name = 'Acessórios';

insert into public.products (name, description, sku, price, cost, stock_quantity, category_id) 
select 
  'Conserto de Tela', 
  'Serviço de conserto de tela de smartphone', 
  'SERV-TELA-001', 
  120.00, 
  80.00, 
  999,
  c.id
from public.categories c where c.name = 'Serviços';

-- Inserir cliente de exemplo
insert into public.customers (name, email, phone, document, address) values 
('Cliente Exemplo', 'cliente@exemplo.com', '(11) 99999-9999', '123.456.789-00', 
 '{"street": "Rua das Flores", "number": "123", "city": "São Paulo", "state": "SP", "zip_code": "01234-567"}'::jsonb);

-- Função para gerar relatórios de vendas
create or replace function public.get_sales_report(
  start_date date default current_date,
  end_date date default current_date
)
returns table (
  total_sales bigint,
  total_amount numeric,
  avg_sale_amount numeric,
  top_products json
) as $$
begin
  return query
  select 
    count(s.id)::bigint as total_sales,
    coalesce(sum(s.total_amount), 0) as total_amount,
    coalesce(avg(s.total_amount), 0) as avg_sale_amount,
    (
      select json_agg(row_to_json(t))
      from (
        select 
          p.name,
          sum(si.quantity) as quantity_sold,
          sum(si.total_price) as total_revenue
        from public.sale_items si
        join public.products p on p.id = si.product_id
        join public.sales s on s.id = si.sale_id
        where date(s.created_at) between start_date and end_date
        group by p.id, p.name
        order by quantity_sold desc
        limit 5
      ) t
    ) as top_products
  from public.sales s
  where date(s.created_at) between start_date and end_date;
end;
$$ language plpgsql security definer;

-- Função para verificar estoque baixo
create or replace function public.get_low_stock_products(min_stock_threshold integer default 10)
returns table (
  product_id uuid,
  name text,
  current_stock integer,
  min_stock integer,
  category_name text
) as $$
begin
  return query
  select 
    p.id as product_id,
    p.name,
    p.stock_quantity as current_stock,
    p.min_stock,
    c.name as category_name
  from public.products p
  left join public.categories c on c.id = p.category_id
  where p.active = true 
    and p.stock_quantity <= greatest(p.min_stock, min_stock_threshold)
  order by p.stock_quantity asc;
end;
$$ language plpgsql security definer;

-- Função para dashboard resumo
create or replace function public.get_dashboard_summary()
returns json as $$
declare
  result json;
begin
  select json_build_object(
    'today_sales', (
      select count(*) from public.sales 
      where date(created_at) = current_date
    ),
    'today_revenue', (
      select coalesce(sum(total_amount), 0) from public.sales 
      where date(created_at) = current_date
    ),
    'total_customers', (
      select count(*) from public.customers where active = true
    ),
    'total_products', (
      select count(*) from public.products where active = true
    ),
    'low_stock_products', (
      select count(*) from public.products 
      where active = true and stock_quantity <= min_stock
    ),
    'open_cash_registers', (
      select count(*) from public.cash_registers where status = 'open'
    ),
    'pending_service_orders', (
      select count(*) from public.service_orders 
      where status in ('pending', 'in_progress')
    )
  ) into result;
  
  return result;
end;
$$ language plpgsql security definer;
