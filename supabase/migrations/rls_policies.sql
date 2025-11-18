alter table public.users enable row level security;

create policy "Allow authenticated users to read all users"
on public.users
for select
using (auth.role() = 'authenticated');

create policy "Allow user to update their own profile"
on public.users
for update
using (auth.uid() = id);

alter table public.conversations enable row level security;
alter table public.participants enable row level security;
alter table public.messages enable row level security;

create policy "Allow access to own conversations"
on public.conversations
for all
using (
  id in (
    select conversation_id from public.participants where user_id = auth.uid()
  )
);

create policy "Allow access to own participants"
on public.participants
for all
using (
  conversation_id in (
    select conversation_id from public.participants where user_id = auth.uid()
  )
);

create policy "Allow access to own messages"
on public.messages
for all
using (
  conversation_id in (
    select conversation_id from public.participants where user_id = auth.uid()
  )
);
