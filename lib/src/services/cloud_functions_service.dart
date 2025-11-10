import 'package:supabase_flutter/supabase_flutter.dart';

class CloudFunctionsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> callFunction(String functionName, {Map<String, dynamic>? parameters, required Map<String, dynamic> body}) async {
    try {
      final response = await _supabase.functions.invoke(functionName, body: body);
      if (response.status != 200) {
        throw Exception('Error calling function: ${response.status}');
      }
      return response.data;
    } catch (e) {
      throw Exception('Exception during function call: $e');
    }
  }
  Future<void> sendPushNotification(String userId, String message) async{
    await callFunction('notify-user', body: {
      'user_id': userId,
      'message': message,
    });
  }

}