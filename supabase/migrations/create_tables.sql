-- (Seu código SQL existente) ...
create table public.users (
  id uuid references auth.users not null primary key,
  name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
-- ... (suas tabelas e políticas existentes) ...

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


-- NOVA FUNÇÃO PARA BUSCAR A LISTA DE CONVERSAS (TASK 1)
-- Esta função busca todas as conversas de um usuário e faz os joins
-- necessários para obter os detalhes do "outro usuário" e a "última mensagem".
create or replace function public.get_conversations_for_user(current_user_id_input uuid)
returns setof json
language plpgsql
security definer
as $$
begin
  return query
  with ranked_messages as (
    -- Subquery para encontrar a última mensagem de cada conversa
    select
      m.conversation_id,
      m.text,
      m.created_at,
      m.author_id,
      m.is_read,
      row_number() over(partition by m.conversation_id order by m.created_at desc) as rn
    from messages m
    -- Otimização: só ranquear mensagens de conversas que o usuário participa
    where m.conversation_id in (
      select p.conversation_id from participants p where p.user_id = current_user_id_input
    )
  ),
  last_messages as (
    select *
    from ranked_messages
    where rn = 1
  )
  -- Query principal
  select
    json_build_object(
      'conversation_id', c.id,
      'other_user_id', u.id,
      'other_user_name', u.name,
      'other_user_avatar_url', u.avatar_url,
      'last_message_text', lm.text,
      'last_message_timestamp', lm.created_at,
      'last_message_author_id', lm.author_id,
      'is_last_message_read', lm.is_read
    )
  from conversations c
  -- Join para encontrar o *outro* participante
  join participants p_other on p_other.conversation_id = c.id
    and p_other.user_id <> current_user_id_input
  -- Join para pegar os dados do *outro* usuário
  join users u on u.id = p_other.user_id
  -- Join para pegar a *última mensagem*
  left join last_messages lm on lm.conversation_id = c.id
  -- Condição: Onde o usuário atual é participante E é uma conversa 1-para-1
  where c.id in (
    select p.conversation_id from participants p where p.user_id = current_user_id_input
  )
  and c.is_group = false
  -- Ordenar pela última mensagem, da mais nova para a mais antiga
  order by lm.created_at desc nulls last;

end;
$$;