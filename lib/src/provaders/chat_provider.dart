import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/src/models/messageModel.dart';
import 'package:chat_app/src/services/message_service.dart';
import 'package:chat_app/src/services/realtime_service.dart';

class ChatProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final MessageService _messageService = MessageService();
  final RealtimeService _realtimeService = RealtimeService();

  final List<MessageModel> messages = [];
  final Map<String, bool> typingUsers = {}; // userId -> isTyping
  final Map<String, bool> onlineUsers = {}; // userId -> isOnline

  Timer? _typingTimer;
  String? _currentConversationId;
  String? _otherUserId;
  DateTime? _otherUserLastSeen;
  bool _otherUserIsOnline = false;

  bool get otherUserIsOnline => _otherUserIsOnline;
  DateTime? get otherUserLastSeen => _otherUserLastSeen;

  /// Carrega as mensagens e inicia listeners realtime
  Future<List<MessageModel>> loadMessages(String conversationId, {String? otherUserId}) async {
    try {
      _currentConversationId = conversationId;
      _otherUserId = otherUserId;

      final loaded = await _messageService.loadMessages(conversationId);
      messages
        ..clear()
        ..addAll(loaded);

      final userId = _supabase.auth.currentUser?.id ?? '';
      await _messageService.markAllAsRead(conversationId, userId);

      // Inscrever-se em realtime (mensagens + typing)
      _realtimeService.listenToMessages(conversationId, (payload) {
        _handleRealtimeChange(payload);
      });

      _realtimeService.listenToTypingStatus(conversationId, (String userId, bool isTyping) {
        typingUsers[userId] = isTyping;
        notifyListeners();
      });

      // Inscrever-se ao status online do outro usuário
      if (otherUserId != null) {
        _realtimeService.listenToUserStatus(otherUserId, (bool isOnline) {
          _otherUserIsOnline = isOnline;
          notifyListeners();
        });

        // Obter último acesso
        final lastSeen = await _realtimeService.getLastSeen(otherUserId);
        _otherUserLastSeen = lastSeen;
        notifyListeners();
      }

      notifyListeners();
      return messages;
    } catch (e) {
      if (kDebugMode) print('ChatProvider.loadMessages erro: $e');
      return [];
    }
  }

  /// Envia mensagem de texto (retorna imediatamente se enviado)
  Future<void> sendText(String conversationId, String authorId, String text) async {
    try {
      final msg = await _messageService.sendTextMessage(conversationId, authorId, text);
      if (msg != null) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          notifyListeners();
        }
      }
      _stopTyping(conversationId);
    } catch (e) {
      if (kDebugMode) print('ChatProvider.sendText erro: $e');
    }
  }

  /// Envia arquivo/imagem
  Future<void> sendFile(String conversationId, String authorId, String fileUrl) async {
    try {
      final msg = await _messageService.sendFileMessage(conversationId, authorId, fileUrl);
      if (msg != null) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('ChatProvider.sendFile erro: $e');
    }
  }

  /// Edita mensagem (regras no service)
  Future<bool> editMessage(String messageId, String newText) async {
    try {
      final edited = await _messageService.editMessage(messageId, newText);
      if (edited != null) {
        final idx = messages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          messages[idx] = edited;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('ChatProvider.editMessage erro: $e');
      return false;
    }
  }

  /// Apaga mensagem (soft delete)
  Future<bool> deleteMessage(String messageId) async {
    try {
      final ok = await _messageService.deleteMessage(messageId);
      if (ok) {
        messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('ChatProvider.deleteMessage erro: $e');
      return false;
    }
  }

  /// Marca mensagem como lida
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final ok = await _messageService.markAsRead(messageId);
      if (ok) {
        final idx = messages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          messages[idx] = messages[idx].copyWith(isRead: true);
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('ChatProvider.markMessageAsRead erro: $e');
    }
  }

  /// Inicia indicador de digitação (envia typing true e agenda false)
  void startTyping(String conversationId) {
    _typingTimer?.cancel();
    _realtimeService.sendTypingStatus(conversationId, true);

    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopTyping(conversationId);
    });
  }

  void _stopTyping(String conversationId) {
    _typingTimer?.cancel();
    _realtimeService.sendTypingStatus(conversationId, false);
  }

  /// Cancela listeners e timers
  void disposeSubscription() {
    _typingTimer?.cancel();
    if (_currentConversationId != null) {
      _realtimeService.unsubscribeFromMessages(_currentConversationId!);
      _realtimeService.unsubscribeFromPresence(_currentConversationId!);
    }
  }

  /// Trata eventos vindo do RealtimeService
  void _handleRealtimeChange(dynamic payload) {
    try {
      dynamic eventType;
      dynamic record;
      
      if (payload is PostgresChangePayload) {
        eventType = payload.eventType;
        record = payload.newRecord ?? payload.oldRecord;
      } else if (payload is Map<String, dynamic>) {
        eventType = payload['eventType'] ?? payload['type'];
        record = payload['new'] ?? payload['record'] ?? payload['newRecord'] ?? payload['payload'];
      } else {
        return;
      }

      // Inserção
      if (eventType == PostgresChangeEvent.insert || 
          eventType == 'INSERT' || 
          eventType?.toString().toLowerCase().contains('insert') == true) {
        if (record == null) return;
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(record));
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          final currentUserId = _supabase.auth.currentUser?.id ?? '';
          if (msg.authorId != currentUserId) {
            markMessageAsRead(msg.id);
          }
        }
      }

      // Atualização
      else if (eventType == PostgresChangeEvent.update || 
               eventType == 'UPDATE' || 
               eventType?.toString().toLowerCase().contains('update') == true) {
        if (record == null) return;
        final updated = MessageModel.fromJson(Map<String, dynamic>.from(record));
        final idx = messages.indexWhere((m) => m.id == updated.id);
        if (idx != -1) {
          messages[idx] = updated;
        }
      }

      // Deleção
      else if (eventType == PostgresChangeEvent.delete || 
               eventType == 'DELETE' || 
               eventType?.toString().toLowerCase().contains('delete') == true) {
        if (record == null) return;
        final id = record['id'] ?? record['old']?['id'];
        if (id != null) {
          messages.removeWhere((m) => m.id == id);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('ChatProvider._handleRealtimeChange erro: $e');
    }
  }

  bool canEditMessage(String messageId) {
    final m = messages.firstWhere(
      (x) => x.id == messageId,
      orElse: () => MessageModel(
        id: '',
        conversationId: '',
        authorId: '',
        createdAt: DateTime.now(),
      ),
    );
    return m.canBeEdited();
  }

  bool canDeleteMessage(String messageId) {
    final m = messages.firstWhere(
      (x) => x.id == messageId,
      orElse: () => MessageModel(
        id: '',
        conversationId: '',
        authorId: '',
        createdAt: DateTime.now(),
      ),
    );
    return m.canBeDeleted();
  }

  List<MessageModel> getUnreadMessages() => messages.where((m) => !m.isRead).toList();

  int getUnreadCount() => getUnreadMessages().length;
}