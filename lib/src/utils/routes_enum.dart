enum RoutesEnum {
  login('/login'),
  register('/register'),
  home('/home'),
  newChat('/new_chat'),
  chatList('/chat_list'),
  chatPage('/chat_page'),
  profile('/profile'); // <-- ADICIONADO

  const RoutesEnum(this.route);
  final String route;
}