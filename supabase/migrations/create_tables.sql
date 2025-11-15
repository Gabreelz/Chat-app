create table public.users (
  id uuid references auth.users not null primary key, -- Chave estrangeira para o usuário autenticado
  name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Habilita RLS (Row Level Security) - Segurança!
alter table public.users enable row level security;

-- Política: Todo mundo pode ver os perfis (para listar contatos)
create policy "Perfis são visíveis para todos" on public.users
  for select using (true);

-- Política: Só o dono pode atualizar seu próprio perfil
create policy "Usuários podem atualizar próprio perfil" on public.users
  for update using (auth.uid() = id);

-- 2. Tabela de Conversas
create table public.conversations (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text, -- Opcional, para grupos
  is_group boolean default false
);

alter table public.conversations enable row level security;

-- 3. Tabela de Participantes (quem está em qual conversa)
create table public.participants (
  conversation_id uuid references public.conversations not null,
  user_id uuid references public.users not null,
  joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (conversation_id, user_id)
);

alter table public.participants enable row level security;

-- 4. Tabela de Mensagens
create table public.messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid references public.conversations not null,
  sender_id uuid references public.users not null,
  content text,      -- Texto da mensagem
  file_url text,     -- URL se for imagem/arquivo
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.messages enable row level security;

-- Exemplo de política vital para mensagens (RLS):
-- "Um usuário só pode ver mensagens de conversas das quais ele é participante"
create policy "Ver mensagens apenas se for participante" on public.messages
  for select using (
    exists (
      select 1 from public.participants p
      where p.conversation_id = messages.conversation_id
      and p.user_id = auth.uid()
    )
  );

-- Função para encontrar ou criar uma conversa 1-para-1
create or replace function public.find_or_create_conversation(other_user_id uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  existing_conversation_id uuid;
  new_conversation_id uuid;
  current_user_id uuid := auth.uid();
begin
  -- 1. Tentar encontrar uma conversa 1-para-1 existente
  select c.id into existing_conversation_id
  from conversations c
  join participants p1 on p1.conversation_id = c.id
  join participants p2 on p2.conversation_id = c.id
  where c.is_group = false
    and p1.user_id = current_user_id
    and p2.user_id = other_user_id;

  -- 2. Se encontrada, retorna o ID
  if existing_conversation_id is not null then
    return existing_conversation_id;
  end if;

  -- 3. Se não, cria uma nova conversa
  insert into public.conversations (name, is_group)
  values (null, false)
  returning id into new_conversation_id;

  -- 4. Adiciona os participantes
  insert into public.participants (conversation_id, user_id)
  values (new_conversation_id, current_user_id),
         (new_conversation_id, other_user_id);

  return new_conversation_id;
end;
$$;