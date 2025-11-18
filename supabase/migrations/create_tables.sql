create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  name text,
  is_group boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table public.participants (
  id bigserial primary key,
  conversation_id uuid references public.conversations(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade
);

create table public.messages (
  id bigserial primary key,
  conversation_id uuid references public.conversations(id) on delete cascade,
  author_id uuid references public.users(id) on delete cascade,
  text text,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

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
  select c.id into existing_conversation_id
  from conversations c
  join participants p1 on p1.conversation_id = c.id
  join participants p2 on p2.conversation_id = c.id
  where c.is_group = false
    and p1.user_id = current_user_id
    and p2.user_id = other_user_id;

  if existing_conversation_id is not null then
    return existing_conversation_id;
  end if;

  insert into public.conversations (name, is_group)
  values (null, false)
  returning id into new_conversation_id;

  insert into public.participants (conversation_id, user_id)
  values (new_conversation_id, current_user_id),
         (new_conversation_id, other_user_id);

  return new_conversation_id;
end;
$$;

create or replace function public.get_conversations_for_user(current_user_id_input uuid)
returns setof json
language plpgsql
security definer
as $$
begin
  return query
  with ranked_messages as (
    select
      m.conversation_id,
      m.text,
      m.created_at,
      m.author_id,
      m.is_read,
      row_number() over(partition by m.conversation_id order by m.created_at desc) as rn
    from messages m
    where m.conversation_id in (
      select p.conversation_id from participants p where p.user_id = current_user_id_input
    )
  ),
  last_messages as (
    select *
    from ranked_messages
    where rn = 1
  )
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
  join participants p_other on p_other.conversation_id = c.id
    and p_other.user_id <> current_user_id_input
  join users u on u.id = p_other.user_id
  left join last_messages lm on lm.conversation_id = c.id
  where c.id in (
    select p.conversation_id from participants p where p.user_id = current_user_id_input
  )
  and c.is_group = false
  order by lm.created_at desc nulls last;
end;
$$;
