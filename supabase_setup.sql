-- =====================================================
-- CARTEIRA FIIs — Setup do banco de dados Supabase
-- Execute esse script no SQL Editor do Supabase
-- =====================================================

create table if not exists fiis (
  id uuid primary key default gen_random_uuid(),
  ticker text not null,
  tipo text not null,
  cotas numeric not null default 0,
  pmedio numeric not null default 0,
  preco numeric,
  pvp numeric,
  dy numeric,
  nome text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists dividendos (
  id uuid primary key default gen_random_uuid(),
  data date not null,
  ticker text not null,
  mes_ref text,
  valor numeric not null,
  created_at timestamptz default now()
);

create table if not exists movimentos (
  id uuid primary key default gen_random_uuid(),
  data date not null,
  operacao text not null,
  ticker text not null,
  tipo text,
  qtd numeric not null default 0,
  preco numeric not null default 0,
  taxa numeric default 0,
  total numeric not null default 0,
  created_at timestamptz default now()
);

create table if not exists reserva (
  id uuid primary key default gen_random_uuid(),
  meta numeric not null default 10000,
  atual numeric not null default 600,
  updated_at timestamptz default now()
);

create table if not exists reserva_locs (
  id uuid primary key default gen_random_uuid(),
  local text not null,
  tipo text,
  valor numeric not null default 0,
  liquidez text,
  created_at timestamptz default now()
);

create table if not exists estudo (
  id uuid primary key default gen_random_uuid(),
  ticker text not null,
  nome text,
  tipo text,
  pvp numeric,
  dy numeric,
  liquidez text,
  status text default 'Estudar mais',
  notas text,
  created_at timestamptz default now()
);

-- Dados iniciais
insert into reserva (meta, atual) values (10000, 600);

insert into fiis (ticker, tipo, cotas, pmedio) values
  ('GARE11', 'Renda Urbana', 4, 8.32),
  ('VGIR11', 'Papel', 5, 9.59),
  ('GGRC11', 'Logística', 4, 10.02),
  ('LVBI11', 'Logística', 1, 107.57);

insert into movimentos (data, operacao, ticker, tipo, qtd, preco, taxa, total) values
  ('2026-01-11', 'Compra', 'GARE11', 'Renda Urbana', 4, 8.32, 0, 33.28),
  ('2026-01-11', 'Compra', 'VGIR11', 'Papel', 5, 9.50, 0, 47.50),
  ('2026-01-11', 'Compra', 'GGRC11', 'Logística', 4, 10.02, 0, 40.08),
  ('2026-01-11', 'Compra', 'LVBI11', 'Logística', 1, 107.57, 0, 107.57);

insert into estudo (ticker, nome, tipo, status, notas) values
  ('HGBS11', 'CSHG Brasil Shopping', 'Shopping', 'Acompanhar', 'Parece compensar para um fundo de shopping base 20');

-- Row Level Security
alter table fiis enable row level security;
alter table dividendos enable row level security;
alter table movimentos enable row level security;
alter table reserva enable row level security;
alter table reserva_locs enable row level security;
alter table estudo enable row level security;

create policy "public_all" on fiis for all using (true) with check (true);
create policy "public_all" on dividendos for all using (true) with check (true);
create policy "public_all" on movimentos for all using (true) with check (true);
create policy "public_all" on reserva for all using (true) with check (true);
create policy "public_all" on reserva_locs for all using (true) with check (true);
create policy "public_all" on estudo for all using (true) with check (true);
