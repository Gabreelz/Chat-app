enum RoutesEnum {
  login('/login'),

  register('/register'),

  home('/home'),

  newChat('/new_chat'),

  chatList('/chat_list'),

  chatPage('/chat_page'); // Adicionado

  /// Construtor da enumeração [RoutesEnum]
  const RoutesEnum(this.route);

  final String route;
}