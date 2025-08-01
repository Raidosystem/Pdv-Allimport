-- Função para atualizar total de vendas no caixa
create or replace function public.update_cash_register_sales(
  register_id uuid,
  sale_amount decimal(10,2)
)
returns void as $$
begin
  update public.cash_registers 
  set total_sales = coalesce(total_sales, 0) + sale_amount
  where id = register_id and status = 'open';
end;
$$ language plpgsql security definer;
