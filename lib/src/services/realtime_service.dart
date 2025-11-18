import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Guardar referências para poder cancelar a inscrição
  RealtimeChannel? _messageChannel;
  RealtimeChannel? _presenceChannel;

  // Listener para novas mensagens
  void listenToMessages(
    String conversationId,
    Function(dynamic) onMessageReceived,
  ) {
    _messageChannel = supabase.channel('messages:$conversationId');
    
    _messageChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          // CORREÇÃO (V2): O callback agora é um parâmetro nomeado
          callback: (payload) {
            onMessageReceived(payload);
          },
        )
        .subscribe(); // CORREÇÃO (V2): subscribe() é chamado no final, sem callback
  }

  // Listener para status de digitação
  void listenToTypingStatus(
    String conversationId,
    Function(String userId, bool isTyping) onTypingStatusChanged,
  ) {
    _presenceChannel = supabase.channel('typing:$conversationId');

    _presenceChannel!
      .onPresenceSync((_) {
        // Sync de presença
      })
      .onPresenceJoin((payload) {
        // CORREÇÃO (V2): O payload agora é um objeto e os dados estão em .newPresences
        for (final presence in payload.newPresences) {
          final userId = presence.payload['user_id'] as String?;
          if (userId != null) {
            onTypingStatusChanged(userId, true);
          }
        }
      })
      .onPresenceLeave((payload) {
        // CORREÇÃO (V2): O payload agora é um objeto e os dados estão em .leftPresences
        for (final presence in payload.leftPresences) {
          final userId = presence.payload['user_id'] as String?;
          if (userId != null) {
            onTypingStatusChanged(userId, false);
          }
        }
      })
      .subscribe((status, [ref]) async {
        // CORREÇÃO (V2): O enum foi renomeado para RealtimeSubscribeStatus
        if (status == RealtimeSubscribeStatus.subscribed) {
          final userId = supabase.auth.currentUser?.id ?? '';
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
  }

  // Enviar status de digitação
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      
      if (isTyping) {
        // Usar o _presenceChannel já instanciado
        await _presenceChannel?.track({
          'user_id': userId,
          'is_typing': true,
          'typed_at': DateTime.now().toIso8601String(),
        });
      } else {
        await _presenceChannel?.untrack();
      }
    } catch (e) {
      print('Erro ao enviar status de digitação: $e');
    }
  }

  // Atualizar status online do usuário
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await supabase
          .from('users')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Erro ao atualizar status online: $e');
    }
  }

  // Listener para status online dos usuários
  void listenToUserStatus(
    String userId,
    Function(bool isOnline) onStatusChanged,
  ) {
    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            // Adicionar verificação de nulo, por segurança
            final isOnline = data.first['is_online'] as bool? ?? false;
            onStatusChanged(isOnline);
          }
        });
  }

  // Obter último status online do usuário
  Future<DateTime?> getLastSeen(String userId) async {
    try {
      final response =
          await supabase.from('users').select('last_seen').eq('id', userId);

      if (response.isNotEmpty) {
        final lastSeen = response[0]['last_seen'];
        return lastSeen != null ? DateTime.parse(lastSeen) : null;
      }
      return null;
    } catch (e) {
      print('Erro ao obter último acesso: $e');
      return null;
    }
  }

  // Desinscrever do channel de mensagens
  Future<void> unsubscribeFromMessages() async {
    try {
      if (_messageChannel != null) {
        await _messageChannel!.unsubscribe();
        _messageChannel = null;
      }
    } catch (e) {
      print('Erro ao desinscrever de mensagens: $e');
    }
  }

  // Desinscrever do channel de presença
  Future<void> unsubscribeFromPresence() async {
    try {
      if (_presenceChannel != null) {
        await _presenceChannel!.unsubscribe();
        _presenceChannel = null;
      }
    } catch (e) {
      print('Erro ao desinscrever de presença: $e');
    }
  }

  // Desinscrever de tudo
  Future<void> disposeAll() async {
    await unsubscribeFromMessages();
    await unsubscribeFromPresence();
  }
}