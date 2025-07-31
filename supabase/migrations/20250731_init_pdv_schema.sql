-- Criar tabela de usuários (estende auth.users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  name text not null,
  role text not null default 'operator' check (role in ('admin', 'manager', 'operator')),
  avatar_url text,
  phone text,
  active boolean default true,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de categorias de produtos
create table if not exists public.categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  active boolean default true,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de produtos
create table if not exists public.products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  sku text unique,
  barcode text unique,
  category_id uuid references public.categories(id),
  price decimal(10,2) not null default 0,
  cost decimal(10,2) default 0,
  stock_quantity integer default 0,
  min_stock integer default 0,
  unit text default 'un',
  active boolean default true,
  image_url text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de clientes
create table if not exists public.customers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  email text unique,
  phone text,
  document text unique, -- CPF/CNPJ
  address jsonb, -- {street, number, city, state, zip_code}
  active boolean default true,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de caixa
create table if not exists public.cash_registers (
  id uuid default gen_random_uuid() primary key,
  opened_by uuid references public.profiles(id) not null,
  closed_by uuid references public.profiles(id),
  opening_amount decimal(10,2) not null default 0,
  closing_amount decimal(10,2),
  total_sales decimal(10,2) default 0,
  opened_at timestamp with time zone default now(),
  closed_at timestamp with time zone,
  status text not null default 'open' check (status in ('open', 'closed'))
);

-- Criar tabela de vendas
create table if not exists public.sales (
  id uuid default gen_random_uuid() primary key,
  customer_id uuid references public.customers(id),
  cash_register_id uuid references public.cash_registers(id) not null,
  user_id uuid references public.profiles(id) not null,
  total_amount decimal(10,2) not null default 0,
  discount_amount decimal(10,2) default 0,
  payment_method text not null check (payment_method in ('cash', 'card', 'pix', 'mixed')),
  payment_details jsonb, -- detalhes específicos do pagamento
  status text not null default 'completed' check (status in ('pending', 'completed', 'cancelled')),
  notes text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de itens da venda
create table if not exists public.sale_items (
  id uuid default gen_random_uuid() primary key,
  sale_id uuid references public.sales(id) on delete cascade not null,
  product_id uuid references public.products(id) not null,
  quantity integer not null default 1,
  unit_price decimal(10,2) not null,
  total_price decimal(10,2) not null,
  created_at timestamp with time zone default now()
);

-- Criar tabela de ordens de serviço
create table if not exists public.service_orders (
  id uuid default gen_random_uuid() primary key,
  customer_id uuid references public.customers(id) not null,
  user_id uuid references public.profiles(id) not null,
  equipment text not null,
  brand text,
  model text,
  serial_number text,
  defect_description text not null,
  service_description text,
  estimated_cost decimal(10,2),
  final_cost decimal(10,2),
  status text not null default 'pending' check (status in ('pending', 'in_progress', 'completed', 'delivered', 'cancelled')),
  priority text default 'medium' check (priority in ('low', 'medium', 'high', 'urgent')),
  estimated_delivery date,
  delivered_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Criar tabela de movimentações de estoque
create table if not exists public.stock_movements (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) not null,
  user_id uuid references public.profiles(id) not null,
  type text not null check (type in ('in', 'out', 'adjustment')),
  quantity integer not null,
  reason text not null,
  reference_id uuid, -- ID da venda, compra, etc.
  reference_type text, -- 'sale', 'purchase', 'adjustment'
  created_at timestamp with time zone default now()
);

-- Habilitar RLS (Row Level Security)
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.customers enable row level security;
alter table public.cash_registers enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.service_orders enable row level security;
alter table public.stock_movements enable row level security;

-- Políticas de segurança básicas (podem ser refinadas conforme necessário)
-- Profiles: usuários podem ver e editar apenas seu próprio perfil (admins podem ver todos)
create policy "Users can view own profile" on public.profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);

-- Categorias: todos os usuários autenticados podem ver, apenas admins podem modificar
create policy "Authenticated users can view categories" on public.categories
  for select using (auth.role() = 'authenticated');

-- Produtos: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage products" on public.products
  for all using (auth.role() = 'authenticated');

-- Clientes: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage customers" on public.customers
  for all using (auth.role() = 'authenticated');

-- Caixa: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage cash registers" on public.cash_registers
  for all using (auth.role() = 'authenticated');

-- Vendas: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage sales" on public.sales
  for all using (auth.role() = 'authenticated');

-- Itens de venda: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage sale items" on public.sale_items
  for all using (auth.role() = 'authenticated');

-- Ordens de serviço: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage service orders" on public.service_orders
  for all using (auth.role() = 'authenticated');

-- Movimentações de estoque: todos os usuários autenticados podem ver e modificar
create policy "Authenticated users can manage stock movements" on public.stock_movements
  for all using (auth.role() = 'authenticated');

-- Triggers para updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger handle_updated_at_profiles
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at_categories
  before update on public.categories
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at_products
  before update on public.products
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at_customers
  before update on public.customers
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at_sales
  before update on public.sales
  for each row execute procedure public.handle_updated_at();

create trigger handle_updated_at_service_orders
  before update on public.service_orders
  for each row execute procedure public.handle_updated_at();

-- Trigger para criar perfil automaticamente quando usuário se cadastra
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', new.email));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Trigger para atualizar estoque automaticamente após venda
create or replace function public.handle_sale_stock_update()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    -- Reduzir estoque
    update public.products 
    set stock_quantity = stock_quantity - new.quantity
    where id = new.product_id;
    
    -- Registrar movimentação
    insert into public.stock_movements (product_id, user_id, type, quantity, reason, reference_id, reference_type)
    select new.product_id, s.user_id, 'out', new.quantity, 'Venda', new.sale_id, 'sale'
    from public.sales s where s.id = new.sale_id;
    
  elsif TG_OP = 'DELETE' then
    -- Devolver estoque (em caso de cancelamento)
    update public.products 
    set stock_quantity = stock_quantity + old.quantity
    where id = old.product_id;
    
    -- Registrar movimentação
    insert into public.stock_movements (product_id, user_id, type, quantity, reason, reference_id, reference_type)
    select old.product_id, s.user_id, 'in', old.quantity, 'Cancelamento de venda', old.sale_id, 'sale_cancellation'
    from public.sales s where s.id = old.sale_id;
  end if;
  
  return coalesce(new, old);
end;
$$ language plpgsql security definer;

create trigger handle_sale_stock_update
  after insert or delete on public.sale_items
  for each row execute procedure public.handle_sale_stock_update();
